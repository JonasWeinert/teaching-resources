# Runs the Week 5 notebook pipeline (my202-05-lab-completed.qmd) and caches every number the deck shows in
# W5/notebooksanddata/cache/w5-results.rds. The deck sources this file when the cache is missing. Run it from
# W5/notebooksanddata:  Rscript ../slides/w5-compute.R   (the kNN tuning takes a few minutes).
# Each block is skipped when the cache already holds its result, so a failed run can be resumed.
suppressPackageStartupMessages({
  library(tidyverse); library(tidymodels); library(rpart.plot); library(ranger); library(xgboost); library(doParallel)
})
tic <- function() Sys.time()
tock <- function(t, what) cat(sprintf("[%s] %s: %.1f s\n", format(Sys.time(), "%H:%M:%S"), what, as.numeric(difftime(Sys.time(), t, units = "secs"))))
dir.create("cache", showWarnings = FALSE)
res_path <- "cache/w5-results.rds"
out <- if (file.exists(res_path)) read_rds(res_path) else list()
save <- function() write_rds(out, res_path)

# ---------- Part I: kNN, as in the notebook (lines 116–223) ----------
ptsd <- read_csv("data/ptsd-for-knn.csv", show_col_types = FALSE) |> mutate(ptsd = as.factor(ptsd))
set.seed(123)
ptsd_split <- initial_split(ptsd, prop = 0.75, strata = ptsd)
ptsd_train <- training(ptsd_split); ptsd_test <- testing(ptsd_split)
ptsd_cv <- vfold_cv(ptsd_train, v = 5)
knn_model <- nearest_neighbor(neighbors = tune()) |> set_mode("classification") |> set_engine("kknn")
knn_rec <- recipe(ptsd ~ ., data = ptsd_train) |> step_normalize(all_numeric_predictors())
wf_knn <- workflow() |> add_model(knn_model) |> add_recipe(knn_rec)
class_metrics <- metric_set(recall, precision, f_meas)
registerDoParallel()

if (is.null(out$knn_test_f1)) {
  out$ptsd_n <- c(train = nrow(ptsd_train), test = nrow(ptsd_test))
  out$ptsd_cv_sizes <- map_dfr(ptsd_cv$splits, ~ tibble(analysis = nrow(analysis(.x)), assessment = nrow(assessment(.x))))
  grid_knn <- tibble(neighbors = c(100, 500, 1000, 3000))
  t <- tic()
  set.seed(123)
  knn_model_cv <- tune_grid(wf_knn, resamples = ptsd_cv, metrics = class_metrics, grid = grid_knn,
                            control = control_resamples(event_level = "second"))
  tock(t, "tune_grid, notebook grid")
  out$knn_cv_metrics <- collect_metrics(knn_model_cv)
  out$knn_best <- select_best(knn_model_cv, metric = "f_meas")
  t <- tic()
  knn_model_final <- wf_knn |> finalize_workflow(out$knn_best) |> fit(ptsd_train)
  out$knn_train_f1 <- knn_model_final |> augment(new_data = ptsd_train) |> f_meas(truth = ptsd, estimate = .pred_class, event_level = "second")
  out$knn_test_f1  <- knn_model_final |> augment(new_data = ptsd_test)  |> f_meas(truth = ptsd, estimate = .pred_class, event_level = "second")
  out$knn_test_all <- knn_model_final |> augment(new_data = ptsd_test) |>
    metric_set(recall, precision, f_meas, accuracy)(truth = ptsd, estimate = .pred_class, event_level = "second")
  tock(t, "final kNN fit and predictions")
  save()
}

# ---------- Part II: trees, as in the notebook (lines 256–504) ----------
childcare <- read_csv("data/childcare-costs.csv", show_col_types = FALSE)
childcare_train <- childcare |> filter(study_year <= 2016) |> arrange(study_year) |> mutate(study_date = as.Date(paste0(study_year, "-01-01")))
childcare_test  <- childcare |> filter(study_year > 2016) |> mutate(study_date = as.Date(paste0(study_year, "-01-01")))
childcare_cv <- sliding_period(childcare_train, index = study_date, period = "year", lookback = Inf, assess_stop = 1, step = 1)
childcare_rec <- recipe(mcsa ~ ., data = childcare_train) |>
  update_role(starts_with(c("county", "state")), new_role = "id") |>
  update_role(c("study_date", "study_year"), new_role = "id")
regress_metrics <- metric_set(rsq, rmse)
ev <- function(fit) bind_rows(train = fit |> augment(new_data = childcare_train) |> regress_metrics(mcsa, .pred),
                              test  = fit |> augment(new_data = childcare_test)  |> regress_metrics(mcsa, .pred), .id = "set")
id_cols <- c("county_fips_code", "county_name", "state_name", "state_abbreviation", "study_date", "study_year")

if (is.null(out$model_results)) {
  out$cc_n <- c(train = nrow(childcare_train), test = nrow(childcare_test), folds = length(childcare_cv$splits))
  out$cc_folds <- map_dfr(childcare_cv$splits, ~ tibble(
    train_from = min(analysis(.x)$study_year), train_to = max(analysis(.x)$study_year), n_train = nrow(analysis(.x)),
    assess_year = unique(assessment(.x)$study_year)[1], n_assess = nrow(assessment(.x))))
  t <- tic()
  dt_model <- decision_tree() |> set_mode("regression") |> set_engine("rpart")
  dt_fit <- workflow() |> add_recipe(childcare_rec) |> add_model(dt_model) |> fit(data = childcare_train)
  out$dt_rpart <- extract_fit_engine(dt_fit)
  out$dt_metrics <- ev(dt_fit); tock(t, "decision tree")

  t <- tic()
  set.seed(123)
  rf_model <- rand_forest(mtry = round(sqrt(52), 0), trees = 1e3) |> set_mode("regression") |>
    set_engine("ranger", num.threads = parallel::detectCores() - 1, importance = "permutation")
  rf_fit <- workflow() |> add_recipe(childcare_rec) |> add_model(rf_model) |> fit(data = childcare_train)
  out$rf_metrics <- ev(rf_fit); tock(t, "random forest")
  out$rf_importance <- extract_fit_engine(rf_fit)$variable.importance |> enframe("term", "importance") |> arrange(desc(importance))

  t <- tic()
  set.seed(123)
  xgb_model <- boost_tree(mtry = round(sqrt(52), 0), trees = 1000, learn_rate = 0.1) |> set_mode("regression") |>
    set_engine("xgboost", nthread = parallel::detectCores() - 1, eval_metric = "rmse")
  xgb_fit <- workflow() |> add_recipe(childcare_rec) |> add_model(xgb_model) |> fit(data = childcare_train)
  out$xgb_metrics <- ev(xgb_fit); tock(t, "xgboost")
  # test RMSE as trees are added: predict with the first n trees only
  xb <- extract_fit_engine(xgb_fit)
  bake_test <- bake(prep(childcare_rec), childcare_test)
  xmat <- as.matrix(bake_test |> select(-mcsa, -all_of(id_cols)))
  out$xgb_curve <- map_dfr(c(1, 2, 3, 5, 10, 20, 50, 100, 200, 500, 1000), function(n) {
    p <- predict(xb, xmat, iterationrange = c(1, n))
    tibble(trees = n, rmse_test = sqrt(mean((bake_test$mcsa - p)^2)))
  })

  out$model_results <- list("Decision Tree" = dt_fit, "Random Forest" = rf_fit, "XGBoost" = xgb_fit) |>
    map_dfr(~ .x |> augment(new_data = childcare_test), .id = "model") |> group_by(model) |> regress_metrics(mcsa, .pred)
  save()
}

# ---------- Extra, for the concept slides: trees of growing depth, forests of growing size ----------
if (is.null(out$depth_curve)) {
  t <- tic()
  out$depth_curve <- map_dfr(1:12, function(d) {
    m <- decision_tree(tree_depth = d, cost_complexity = 0, min_n = 2) |> set_mode("regression") |> set_engine("rpart")
    f <- workflow() |> add_recipe(childcare_rec) |> add_model(m) |> fit(data = childcare_train)
    ev(f) |> filter(.metric == "rmse") |> mutate(depth = d, leaves = sum(extract_fit_engine(f)$frame$var == "<leaf>"))
  })
  tock(t, "tree depth curve")
  t <- tic()
  out$rf_curve <- map_dfr(c(1, 5, 10, 25, 50, 100, 250, 500, 1000), function(n) {
    set.seed(123)
    m <- rand_forest(mtry = 7, trees = n) |> set_mode("regression") |> set_engine("ranger", num.threads = parallel::detectCores() - 1)
    f <- workflow() |> add_recipe(childcare_rec) |> add_model(m) |> fit(data = childcare_train)
    ev(f) |> filter(.metric == "rmse") |> mutate(trees = n)
  })
  tock(t, "forest size curve")
  save()
}

# ---------- Extra: a wider kNN grid, training-set against cross-validated F1 (the overfitting picture) ----------
if (is.null(out$knn_wide_train)) {
  grid_wide <- tibble(neighbors = c(10, 30, 100, 300, 1000, 3000, 10000))
  t <- tic()
  set.seed(123)
  knn_wide_cv <- tune_grid(wf_knn, resamples = ptsd_cv, metrics = class_metrics, grid = grid_wide,
                           control = control_resamples(event_level = "second"))
  out$knn_wide_cv <- collect_metrics(knn_wide_cv); tock(t, "wide kNN grid, cross-validated")
  t <- tic()
  out$knn_wide_train <- map_dfr(grid_wide$neighbors, function(k) {
    f <- wf_knn |> finalize_workflow(tibble(neighbors = k)) |> fit(ptsd_train)
    bind_rows(train = f |> augment(new_data = ptsd_train) |> class_metrics(truth = ptsd, estimate = .pred_class, event_level = "second"),
              test  = f |> augment(new_data = ptsd_test)  |> class_metrics(truth = ptsd, estimate = .pred_class, event_level = "second"),
              .id = "set") |> mutate(neighbors = k)
  })
  tock(t, "wide kNN grid, training and test"); save()
}
cat("ALL DONE\n")
