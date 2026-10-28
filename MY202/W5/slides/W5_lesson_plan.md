# MY202 · Lab 5 — Neighbours and trees: tuning models with cross-validation

Lesson plan, slide outline and speaker script, based on the solutions notebook of 27 October 2026: `W5/notebooksanddata/my202-05-lab-completed.qmd` (505 lines; **all line numbers refer to this file**). There is no student notebook yet. The deck assumes one derived from the solutions with `# Code here` in the challenge chunks and the same line layout; once it exists, re-map the line numbers on the slides (every reference bar and task list carries them) and in this plan.

The lab data sit in `W5/notebooksanddata/data/` (`ptsd-for-knn.csv`, `childcare-costs.csv`) and the course team's pre-fitted kNN models in `W5/notebooksanddata/models/knn_models_output.R`, as the notebook's paths expect. The slow parts of the notebook (tuning the kNN, the forests) are run once by `W5/slides/w5-compute.R`, which caches every number the deck shows in `W5/notebooksanddata/cache/w5-results.rds`; the deck sources that script when the cache is missing. The whole folder is git-ignored, so only a machine with the data can re-render the deck.

Last year's DS202 Week 5 lab (autumn 2024) is the same lab with the same two data sets; its teaching moments ("every algorithm draws a boundary", "how many neighbours get to vote?") are kept, and the solutions file there picked k = 3,000, as this run does.

## Lesson plan

**Format:** 90-minute computer lab. The tidymodels machinery is all new this week (folds, `tune()`, recipes, workflows, `tune_grid()`, `select_best()`, `finalize_workflow()`), so the deck decides what is typed **together** and what is **your turn** by whether the code carries a new idea:

- **Together** in Part I: the split and `vfold_cv()`, the model with `tune()`, the recipe and workflow, the metric set, the grid and `tune_grid()` (lines 116–175), each as an anatomy slide. The tuning run is started together and a one-minute check question covers the wait.
- **Your turn** in Part I: `collect_metrics()`, the plot, `select_best()`, `finalize_workflow() |> fit()`, and the test-set F1 (lines 179–229). Students have the tools: the plot is Lab 2, the F1 is Lab 4, the new functions are on the syntax sheet.
- **Together** in Part II: the split by year with `sliding_period()` and the recipe with `update_role()` (lines 265–291, 358–363).
- **Your turn** in Part II: Tasks 1–4 (lines 365–504). The three models reuse the spec–workflow–fit pattern with a different model function each time; Task 4 is Lab 4's `map_dfr()` over a list of fits.

Every code chunk the notebook asks for is annotated on a slide: an anatomy (each piece numbered and explained) for code-together, a commented syntax sheet plus a step-by-step solution walkthrough for your-turn. Every slide that touches the notebook carries a reference bar with the line numbers.

**What is new this week.** Two ideas, each with its own concept block before any code: (1) **hyperparameters and cross-validation**: a setting the data cannot tell `fit()`, chosen by scoring candidates on held-out folds of the training set, with the test set sealed until the end; (2) **trees and ensembles**: a tree splits greedily and overfits when grown far; a forest averages many trees on resampled rows with random features; boosting adds small trees that each fix the last one's errors. The concept visuals are step-by-step plots built from the lab's own data (one feature, the county's median income, against the weekly childcare cost), so the staircase, the overfitting curve, the bagged average and the boosting rounds are all real.

**Learning objectives.** By the end, students can:

1. Say what a hyperparameter is and why it cannot be chosen on the test set (warm-ups; Part I concept)
2. Explain k-fold cross-validation in one picture: folds, rounds, one averaged score per candidate (slide 10), and build it with `vfold_cv()`, `tune()`, `tune_grid()`, `collect_metrics()`, `select_best()` and `finalize_workflow()`
3. Explain what a recipe and a workflow are, and why features are normalised for a distance-based model
4. Explain *k* nearest neighbours as a vote among the closest training rows, and what small and large k do to the decision boundary
5. Read a decision tree, explain how a split is chosen and why a tree overfits when grown too far
6. Explain bagging, random forests and boosting in plain words, fit all three with `decision_tree()`, `rand_forest()` and `boost_tree()`, and compare them on a test set split by time

**Before class**

- The lab runs on Nuvolos. Check once that the Week 5 workspace has the notebook, `data/ptsd-for-knn.csv`, `data/childcare-costs.csv` and `models/knn_models_output.R`, and that `kknn`, `ranger`, `xgboost`, `rpart.plot`, `viridis` and `doParallel` load (the library chunk, lines 12–22).
- **Time the tuning run on Nuvolos.** `tune_grid()` with the notebook's grid (k = 100, 500, 1000, 3000; 5 folds) took 150 seconds on a laptop with ten cores and `registerDoParallel()`; the final fit 28 seconds; predictions on the training and test sets about 85 seconds more. On a slower workspace the exercise's step 4 may take a couple of minutes. If it is much slower, drop k = 3,000 from the grid for the session and say so (1,000 scores the same, see Key numbers).
- Render the deck once yourself (`quarto render W5/slides/W5-lab-slides.qmd` from `MY202/`). If `cache/w5-results.rds` is missing, the render runs `w5-compute.R` first (about 12 minutes); otherwise it takes 20 seconds.

**Timing**

| Time | Block | Mode | Notebook lines |
|---|---|---|---|
| 0:00–0:05 | Welcome, overview, run the library chunk; two warm-up questions (who chooses λ; why not choose on the test set) | Whole class | 12–22 |
| 0:05–0:15 | **Part I data and concept.** Meet the data: the feature space, run together (3) · kNN: the neighbours vote (2) · the boundary depends on k, the tutors' pre-fitted models (2) · choosing k without the test set: the folds picture (3) | Together, then slides | 30–56, 60–78 |
| 0:15–0:27 | **Part I code.** Split and folds (3) · model, recipe, workflow (4) · metrics, grid, `tune_grid()`, start the run (3) · "while it runs" check question (1) and the rest of the wait | Code together | 116–175 |
| 0:27–0:43 | **Part I exercise.** `collect_metrics()`, plot, `select_best()`, final fit, test F1 (7-minute timer) · solutions (4) · debrief (5) | Your turn | 179–229 |
| 0:43–1:00 | **Part II data, concept and code.** Meet the data, run `read_csv()` (2) · how a tree splits (3) · growing and overfitting (2) · bagging and the forest (3) · boosting (2) · split by time with the folds picture (3) · the recipe with roles (2) | Together, slides, together | 257, 265–291, 358–363 |
| 1:00–1:10 | **Task 1.** Decision tree (6-minute timer) · solutions (2) · reading the tree, class discussion (2) | Your turn, then discuss | 365–397 |
| 1:10–1:23 | **Tasks 2–4.** Forest, XGBoost, comparison (9-minute timer) · solutions (2) · debrief (2) | Your turn | 399–504 |
| 1:23–1:27 | Wrap-up: three takeaways, exit question on Moodle | Whole class | |
| 1:27–1:30 | Spare | | |

**Will it fit?** 87 minutes planned, 3 spare. Checkpoints: Part I by 0:05, the Part I exercise by 0:27, Part II by 0:43, the Task 1 exercise by 1:00, the Tasks 2–4 exercise by 1:10, wrap-up by 1:23. The one block that can run away is the wait for `tune_grid()`: if it takes more than three minutes on Nuvolos, start the exercise's reading of the slides (the syntax sheet) during the wait. **If behind, skip in this order:** (1) warm-up 1, 1 minute; (2) the boosting visual, say it in one sentence on the XGBoost card, 2 minutes; (3) the "while it runs" question, 1 minute; (4) shorten the Tasks 2–4 timer from 9 to 7. The folds picture (slide 10) and "how a tree splits" (slide 20) should not be cut.

The notebook's own headings give no timings this week; last year's version allotted 50 minutes to kNN and 40 to trees.

**For fast finishers:** `show_best(knn_model_cv, metric = "f_meas")`; recall and precision on the kNN test set; `set_engine("kknn", kernel = "rectangular")` to see a plain majority vote at k = 100; `extract_fit_engine(dt_fit)$variable.importance`; `decision_tree(tree_depth = 2)` drawn with `rpart.plot()`; a forest with `importance = "permutation"`; tuning `learn_rate = tune()` with `tune_grid(…, resamples = childcare_cv)`, which is what the time folds are for.

**Fix before release** (found while reading the notebook and running the code)

- **Title and intro disagree** (lines 2 and 8): "Week 04 - Student Solutions" above "Here are the solutions to Lab 5".
- **The task list and the code disagree twice.** The tasks say 10-fold cross-validation (lines 83, 106); the code uses `v = 5` (line 123). The tasks say to test `c(1, 5, 10, 20, 50, 100, 200)` neighbours (line 110); the code uses `c(100, 500, 1000, 3000)` (line 158), and the pre-fitted models for the boundary plot use 100, 200, 500 and 1000 (neither list). Align the text with the code, and say why k starts at 100: the two features take only 121 distinct values, so at small k the `kknn` engine's distance weighting breaks on ties (every neighbour at distance 0) and F1 is near zero (k = 100: 0.085; k = 30: 0.005; k = 10: undefined, no positives predicted). A plain majority vote (`weight_func = "rectangular"`) does better at k = 100 (0.21) but still badly.
- **Discussion answer** (line 229): "the best-performing k value is 1000". With `set.seed(123)` the winner is 3,000 by a hair (cross-validated F1 0.736 against 0.733, within one standard error); last year's solutions also said 3,000. Suggest "1,000 or 3,000; the two are indistinguishable".
- **`childcare_cv` is never used.** The time folds are built at line 280, silently replaced by the Scenario B folds at line 332 (4 grouped folds instead of 8 time folds, same name), and nothing after that touches them. Task 3's heading, "XGBoost with hyperparameter tuning" (line 428), promises a `tune_grid()` that is not there. Either add one (`learn_rate = tune()` with `resamples = childcare_cv`, which would also justify the folds), or drop the folds and the heading's last three words. If the callout stays, give its folds another name.
- **`mtry = round(sqrt(52), 0)`** (lines 405, 433): after the id roles there are 50 predictors (57 columns minus the outcome and six ids), not 52. Both round to 7, so nothing changes, but "52" will puzzle anyone who counts.
- **"Does it help with overfitting?"** (answers at lines 426 and 462): the forest and XGBoost are said to show a "larger discrepancy" and "overfitting is still an issue" because their training RMSE (6.7 and 3.8) is far below the test RMSE (24.8 and 23.3). An ensemble's training error is always close to zero and says little about overfitting; the test RMSE is the comparison, and there both beat the tree clearly. Part of the gap is also time: median prices rose from $100 in 2016 to $106 in 2018, so a model trained on the past under-predicts. The deck says this on the debrief slide.
- **No seed before the forest and XGBoost fits** (lines 404–413, 431–448): both are random, so the answers' 24.9 and 23.5 come out as 24.8 and 23.3 here, and differently again on Nuvolos. Add `set.seed(123)` before each fit.
- **Variable list missing** for the childcare data: the notebook never says what `mcsa`, `mhi_2018`, `one_race_a`, `femp_m` or `households` are, and the tree's first split is on `one_race_a`. Add a short list (from the National Database of Childcare Prices): `mcsa` weekly median price of centre-based care for a school-age child; `mhi_2018` median household income in 2018 dollars; `one_race_a` share of residents of one race, Asian; `femp_m` share of employed women in management, business, science and arts jobs; `femp_sales` the same for sales and office jobs; `households` number of households.
- **Headings**: "# For tutors to run" (line 58), "# Create train-test split…" (114) and the other `#` headings inside Part I render as top-level sections beside "Part I" and "Part II". Make them `##` or `###`. The tutor-only chunk (lines 60–78) should probably be marked `eval: false` in the student version, since students don't have the models folder.
- `library("rsample")` (line 18) is redundant; tidymodels attaches it. `percent` (line 45) works only because tidymodels attaches `scales`; fine, but worth knowing.

**Consistency check of the deck against the notebook** (28 October): every line reference on the slides (reference bars, task lists and speaker notes) points at the right lines of the solutions notebook. Every code line shown on a slide matches the notebook, with four deliberate differences, each explained in the speaker notes: the Part I syntax sheet and walkthrough write `wf_knn |> finalize_workflow() |> fit()` on fewer lines; the Tasks 2–4 syntax sheet leaves out `eval_metric = "rmse"` (it only affects what xgboost prints); plot styling (themes, titles, colours) is left out of the solution walkthroughs; the Task 1 walkthrough prints the metrics as one table per set. The kNN engine prints `kernel = optimal` in the final workflow; the slide's shortened printout keeps that line. Terms match the notebook: hyperparameter, cross-validation, folds, recipe, workflow, k nearest neighbours, decision tree, random forest, XGBoost, `mtry`, `learn_rate`, RMSE, R².

**Key numbers** (seed 123 throughout; `w5-compute.R`)

*PTSD data.* 33,234 people; 34.3% with PTSD; 121 cells (anxiety × acute stress), about 275 people per cell. Split stratified on `ptsd`: 24,924 training, 8,310 test. Five folds of 19,939 to fit on and 4,985 held out (the last 19,940 / 4,984).

Cross-validated means (5 rounds):

| k | Precision | Recall | F1 |
|---|---|---|---|
| 100 | 0.670 | 0.046 | 0.085 |
| 500 | 0.700 | 0.565 | 0.625 |
| 1,000 | 0.705 | 0.763 | 0.733 |
| 3,000 | 0.704 | 0.771 | **0.736** |

`select_best()`: 3,000. Final model: training F1 0.736, test F1 0.737 (recall 0.769, precision 0.708, accuracy 0.812). The simplest rule, "predict the majority of your own cell" (from the training set), scores F1 0.739 on the test set. A wider grid for reference: k = 300 gives 0.577, k = 10,000 gives 0.726 (test 0.732). Timings on a 10-core laptop: `tune_grid()` 150 s, final fit 28 s, predictions on both sets 85 s.

*Childcare data.* 23,593 county-years, 57 columns (50 features after the outcome and six id columns), 2,904 counties, 2008–2018. Training 2008–2016: 18,797 rows; test 2017–2018: 4,796. Eight expanding-window folds: fit on 2008 and score 2009 (1,424 / 1,901 rows) up to fit on 2008–2015 and score 2016 (16,156 / 2,641). Median weekly price $96.5; prices rise from a median of $85 (2008) to $106 (2018). Predicting the training mean scores a test RMSE of 39.1.

| Model | Train RMSE | Test RMSE | Test R² |
|---|---|---|---|
| Decision tree (defaults, 8 leaves) | 27.8 | 31.8 | 0.33 |
| Random forest (1,000 trees, mtry 7) | 6.7 | 24.8 | 0.62 |
| XGBoost (1,000 trees, learn rate 0.1) | 3.8 | 23.3 | 0.64 |

The tree: `one_race_a < 2.23` first (87% of counties left, mean $94; right, mean $133), then `mhi_2018 < 47,748`, `households < 7,862`, `femp_sales ≥ 33.9`, `one_race_a < 5.15`, `mhi_2018 < 54,848`, `femp_m < 53.3`; leaves from $86 to $224. Forest permutation importance: `mhi_2018`, `households`, `total_pop`, `h_6to17_both_work`, `one_race_a`. Trees of growing depth (all features, no pruning): test RMSE falls to 31.1 at depth 7 and creeps back to 32.1 at depth 12, while training RMSE falls to 15.7 (1,904 leaves). Forest size: 1 tree 35.9, 10 trees 26.4, 100 trees 24.9, 1,000 trees 24.8 (test RMSE). XGBoost as trees are added: 37.8 after 1, 31.5 after 10, 26.4 after 100, 23.3 after 1,000.

*Concept examples.* The kNN toy is a simulated cloud of 40 people (`set.seed(7)`); at the new point, 1 neighbour votes no, 5 vote yes (3–2), 15 vote no (8–7). The one-feature trees use the training counties' median income: the first cut is at $59.2k (means $93 and $125). The bagging picture resamples the counties (`set.seed(11)` for the three trees, `set.seed(12)` for the average of 50); the boosting picture adds a tenth of a depth-2 tree per round for 100 rounds.

---

## Slides and script

35 slides. Every slide was checked at 16:9 (1200 × 675) with all fragments revealed: content stays above the footer. The full script is in the speaker notes (press `S`). The tracker bar reads: Warm-up · I kNN + CV · II Trees · Wrap-up. Mode in brackets.

### 1 Title · 2 Lab overview
- Overview table with parts, functions, mode and minutes; notes give the checkpoints and the skip order. Script: last week one model and a lab on judging it; this week two new models and a way to choose a model's settings without touching the test set. Run the library chunk (lines 12–22).

### 3 Divider · 4–5 Warm-up 1 and 2 (vote)
- 1: who chose λ in Lab 3? (we did: a hyperparameter). 2: try 7 values, score each on the test set, keep the best, report that score: what's wrong? (the test set helped choose, so it flatters). Plants the three jobs of the day: training rows fit, held-out folds choose, test rows judge once.

### 6 Divider "Part I" · 7 Meet the data: a feature space (run together, lines 30–56)
- The notebook's grid plot; 33,234 people, 34% with PTSD, two 0–10 questions, 121 cells of about 275 people. Ask the room where the boundary goes.

### 8 k nearest neighbours: the neighbours vote (concept)
- A made-up cloud and a new person; clicks circle 1, 5 and 15 nearest and the vote flips each time. Cards: distance needs normalised features (hence the recipe); the vote and `.pred_1`; k is a hyperparameter.

### 9 The boundary depends on k (demo, lines 60–78)
- The tutors' pre-fitted models for k = 100, 200, 500, 1,000: jagged to smooth. Notes explain the k = 100 tie artefact without making a point of it in class.

### 10 Choosing k without the test set: cross-validation (concept)
- The folds picture: five rounds, each fitting on four folds and scoring the fifth, then the mean; one number per k; the test set never in the picture. Notes: v for folds, k for neighbours.

### 11 Split and folds (together, lines 116–126)
- Anatomy of Lab 4's split plus `vfold_cv(ptsd_train, v = 5)`, with the printout of the five splits.

### 12 Model, recipe, workflow (together, lines 130–150)
- Six pieces: `nearest_neighbor()`, `tune()`, `set_mode()`, `recipe()`, `step_normalize()`, `workflow()`. Notes: nothing is fitted yet; the recipe is pre-processing written down so the test set gets the same treatment.

### 13 Metrics, candidates, and the tuning run (together, lines 154–175)
- Six pieces: the metric set, the grid, `registerDoParallel()`, `tune_grid()`, `resamples`, `event_level` through `control`. Start the run.

### 14 While it runs (vote)
- How many models is `tune_grid()` fitting? 20, none of them the final one: `finalize_workflow() |> fit()` fits that afterwards.

### 15 Exercises: Part I (your turn, 7 min, lines 179–229)
- `collect_metrics()`, the plot, `select_best()`, finalise and fit, test F1, which k and overfitting? Syntax sheet with every new function commented.

### 16 Solutions: Part I (walkthrough)
- The 12-row table (shown wide), the plot (recall climbs, precision flat, F1 peaks at 3,000 with 1,000 level), `select_best()`, the refit on all 24,924 rows, test F1 0.737 against training 0.736 and cross-validated 0.736.

### 17 Part I: what did we learn?
- Three bars that agree; the cell-majority rule at 0.739; why large k won on 121 cells; kNN has no coefficients. Notes: the k = 100 collapse is partly the kknn kernel on ties.

### 18 Divider "Part II" · 19 Meet the data (run together, line 257)
- 23,593 county-years, 50 features, median price $97; prices by year with the test years shaded; back to regression; time is in the data.

### 20 How a tree splits (concept)
- One feature, median income: clicks add the first cut ($59.2k, means $93 and $125), depth 2, depth 3. Cards: a yes/no question chosen to cut the squared error most; greedy; a staircase of leaf means.

### 21 Growing the tree, and overfitting (concept)
- Click: the same tree grown to 3 counties per leaf (4,444 leaves) chases every wobble. Click: training against test RMSE by depth with all features: the test error bottoms out at depth 7. Cards name `cost_complexity` and `min_n` as the knobs.

### 22 Many trees: bagging and the random forest (concept)
- Three trees on three resamples give three staircases; the average of 50 is a smooth curve. Cards: bagging; random features (`mtry` ≈ 7 of 50); the price, no picture to read.

### 23 Boosting: each tree fixes the last one's mistakes (concept)
- A tenth of a depth-2 tree per round, after 1, 5, 20 and 100 rounds; then today's XGBoost test RMSE as trees are added (37.8 → 23.3). Cards: residuals; `learn_rate`; it can overfit, trees and learning rate are knobs for the folds.

### 24 Split by time (together, lines 265–291)
- Anatomy of the year filter, the date column, `sliding_period()` with `lookback = Inf` and `assess_stop = 1`; the expanding-window picture on the right (round 1 fits 2008 and scores 2009, round 8 fits 2008–2015 and scores 2016). The dark card says plainly that today's models don't use the folds. Skip the Scenario B callout.

### 25 A recipe with roles (together, lines 358–363)
- `mcsa ~ .` and `update_role(…, new_role = "id")` for the six label columns; no normalising for trees; one recipe shared by three workflows.

### 26 Exercises: Part II · Task 1 (your turn, 6 min, lines 365–397)
- Spec, workflow and fit, `rpart.plot()`, `metric_set(rsq, rmse)` on both sets, what does the tree show? Syntax sheet: Part I's pattern without `tune()`.

### 27 Solutions: Task 1 (walkthrough)
- The tree as text, the tree as a flow chart, training RMSE 27.8 and R² 0.31, test RMSE 31.8 and R² 0.33 against 39.1 for predicting the mean.

### 28 Reading the tree (discuss, line 394)
- The flow chart large. Cards: the first question is a proxy for expensive metro counties; five of 50 features used; eight numbers, one per leaf, $86 to $224.

### 29 Exercises: Part II · Tasks 2–4 (your turn, 9 min, lines 399–504)
- Forest spec, XGBoost spec, both fitted and scored, then the comparison table and bar chart. Syntax sheet: three specs, one pattern, and the `map_dfr()` over a named list.

### 30 Solutions: Tasks 2 and 3 · 31 Solutions: Task 4 (walkthroughs)
- Forest 6.7 → 24.8, XGBoost 3.8 → 23.3 (R² 0.62 and 0.64); the one-table comparison and the sorted bar chart.

### 32 Part II: what did we learn?
- Test RMSE bars: mean 39.1, tree 31.8, forest 24.8, XGBoost 23.3; the train-to-test gaps. Cards: many trees beat one; mind the gap (ensembles memorise their training rows; part of the gap is the rise in prices after 2016); nothing was tuned.

### 33 Summary · 34 Further reading · 35 Feedback
- Three checks (hyperparameters and cross-validation with the five functions; kNN and trees; ensembles). Exit question on Moodle: you have the 2019 prices, which model do you deploy, and how would you check whether the forest's training RMSE of $7 means anything? Reading: ISLR 5.1 and 8.1–8.2, TMWR chapters 10, 12 and 13, the tidymodels "Get started" guides. Feedback QR code last.
