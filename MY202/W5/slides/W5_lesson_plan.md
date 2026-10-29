# MY202 · Lab 5 — Neighbours and trees: tuning models with cross-validation

Lesson plan, slide outline and speaker script, based on the notebooks of 28 October 2026: the student workbook `W5/notebooksanddata/my202-05-lab-students.qmd` (391 lines; **all line numbers on the slides and in this plan refer to this file**, as for Lab 4) and the solutions `my202-05-lab-completed.qmd` (497 lines; the same chunks filled in, about 40 lines further down in Part II). The one slide that points at the solutions says so: the tutors' pre-fitted kNN models (slide 8) exist only there. The workbook gives several chunks ready to run (the Part I plot and `select_best()`, the Part II split and recipe), leaves others empty (`# Code here`) and sketches two with placeholders (`tune_grid()`, the forest and XGBoost specs); the deck's modes follow that.

The lab data sit in `W5/notebooksanddata/data/` (`ptsd-for-knn.csv`, `childcare-costs.csv`) and the course team's pre-fitted kNN models in `W5/notebooksanddata/models/knn_models_output.R`, as the notebook's paths expect. The slow parts of the notebook (tuning the kNN, the forests) are run once by `W5/slides/w5-compute.R`, which caches every number the deck shows in `W5/notebooksanddata/cache/w5-results.rds`; the deck sources that script when the cache is missing. The whole folder is git-ignored, so only a machine with the data can re-render the deck.

Last year's DS202 Week 5 lab (autumn 2024) is the same lab with the same two data sets; its solutions picked k = 3,000, as this run does. Last year's winter-term lab deck built every intuition from an everyday example before any data: Spotify's "fans also like" for kNN (would a Fontaines D.C. and Radiohead fan buy Smiths tickets?), k = 1 against k = 60 boundaries, a 10-fold diagram, a hand-sized table to find "the cleanest question" for trees (Swifties), and crowd and relay diagrams for forests and boosting. This deck keeps that recipe with a different running example, London flats, so students who saw last year's deck get a fresh story.

## Lesson plan

**Format:** 90-minute computer lab, built as a repeating cycle that follows the notebook: **concept** (an everyday example the room reasons through by hand, then the same idea on the lab's data) → **code together** (we type the notebook chunk; an anatomy slide numbers each piece) → **your turn** (timer, tasks and a syntax sheet, then a step-by-step solution). Part I runs the cycle twice before its exercise; Part II runs it three times, once per model.

| Block | Concept | Code together | Your turn |
|---|---|---|---|
| I · kNN | The estate agent's comparables; the vote; the boundary depends on k; the PTSD boundaries | | |
| I · choosing k | The trap (k = 1 scores 100% on its own rows); cross-validation as mock exams | Split and folds (107–111); the model with `tune()` (113–119) | |
| I · normalise | Units decide who is close (the workbook's note at line 123) | Recipe and workflow (121–129); metrics, grid, `tune_grid()` (131–152) | Plot, `select_best()`, final fit, test F1 (156–198) |
| II · tree | The Swiftie game: one question, ask again, the Swiftie who isn't a pop fan; the same game with prices | The recipe and the tree spec and fit (314–327) | Draw and score the tree, Task 1 (330–338) |
| II · forest | Three friends who each saw part of the table vote; three resampled staircases averaged | The forest spec (348–351) | Fit and score, Task 2 (353–358) |
| II · boosting | A relay: each friend aimed at the last one's mistakes; small trees adding up on prices | The boosting spec (365–372) | Fit and score, compare all three, Tasks 3–4 (374–390) |

The data, the split by year and the recipe are given in the workbook (lines 296–318) and run together at "Meet the data".

**What is new this week.** Two ideas: (1) **hyperparameters and cross-validation**: a setting the data cannot tell `fit()`, chosen by scoring candidates on held-out folds of the training set, with the test set sealed until the end; (2) **trees and ensembles**: a tree asks the cleanest question, then again inside each group, and overfits when grown until every leaf is pure; a forest averages many trees grown independently on resampled rows with random columns; boosting adds small trees in turn, each aimed at what the previous ones still get wrong.

**Running examples.** Part I: London flats (the estate agent's comparables, the trap, mock exams). Part II: last year's Swiftie game from the DS202 Winter deck, with a new table built so every step comes out cleanly:

- *One tree*: twelve people, five facts (age, likes pop, plays guitar, enjoys lyrics, follows trends). One question, then guess: "likes pop?" gets 10 of 12 right (wrong about K and L), lyrics and trends 9, guitar and the best age cut-off 8. Inside the pop fans, "enjoys lyrics?" finds K: 11 of 12. Among the non-pop fans only "age 30 or over?" finds L (31, the oldest): a question invented for one person, so overfitting.
- *A forest*: three friends each see 8 random people and may ask 2 random questions (`set.seed(1)`). They grow three different one-question trees ("follows trends?", "age 26 or over?", "enjoys lyrics?") and vote on Mia (22, not a pop fan, plays guitar, enjoys lyrics, follows trends): Swiftie, not, Swiftie. The forest says Swiftie; the one tree said "not".
- *Boosting*: friend 1 asks "likes pop?" and is wrong about K and L. Friend 2 is told K and L count four times: "enjoys lyrics?" gets them right and is wrong about C, E, H. Friend 3 is told C, E, H, K, L count four times: "follows trends?" is wrong about B, F, J. Nobody is wrong twice, so 2 of 3 gets all 12 right.
- After each game, the same idea on county income against childcare cost: the staircase of a tree, three resampled staircases and their average, and boosting after 1, 5, 20 and 100 small trees.

**Learning objectives.** By the end, students can:

1. Say what a hyperparameter is, why scoring it on the training rows rewards memorising (k = 1 scores 100% on its own flats) and why it cannot be chosen on the test set either (slides 6 and 9)
2. Explain k-fold cross-validation in one picture: folds, rounds, one averaged score per candidate (slide 10), and build it with `vfold_cv()`, `tune()`, `tune_grid()`, `collect_metrics()`, `select_best()` and `finalize_workflow()`
3. Explain what a recipe and a workflow are, and why a distance-based model needs its features in standard deviations (slide 7)
4. Explain *k* nearest neighbours as the estate agent's comparables, a vote among the k most similar training rows, and what small and large k do to the decision boundary (slides 5, 6, 8)
5. Read a decision tree, explain how a split is chosen (the Swiftie game: the question that sorts cleanest; with prices, the cut that reduces the squared error most) and why a tree overfits when grown too far
6. Explain bagging, random forests and boosting in plain words, fit all three with `decision_tree()`, `rand_forest()` and `boost_tree()`, and compare them on a test set split by time

**Before class**

- The lab runs on Nuvolos. Check once that the Week 5 workspace has the student workbook, `data/ptsd-for-knn.csv` and `data/childcare-costs.csv`, and that `ranger`, `xgboost`, `rpart.plot`, `viridis` and `doParallel` load (the library chunk, lines 27–36). `kknn` is not in the chunk but must be installed: the kNN engine loads it when the model is fitted. The tutors' pre-fitted models (`models/knn_models_output.R`) are only read by the solutions notebook; slide 8 shows their output.
- **Time the tuning run on Nuvolos.** `tune_grid()` with the notebook's grid (k = 100, 500, 1000, 3000; 5 folds) took 150 seconds on a laptop with ten cores and `registerDoParallel()`; the final fit 28 seconds; predictions on the training and test sets about 85 seconds more. On a slower workspace the exercise's step 4 may take a couple of minutes. If it is much slower, drop k = 3,000 from the grid for the session and say so (1,000 scores the same, see Key numbers).
- Render the deck once yourself (`quarto render W5/slides/W5-lab-slides.qmd` from `MY202/`). If `cache/w5-results.rds` is missing, the render runs `w5-compute.R` first (about 12 minutes); otherwise it takes 20 seconds.

**Timing**

| Time | Block | Mode | Notebook lines |
|---|---|---|---|
| 0:00–0:03 | Welcome, overview, run the library chunk | Whole class | 27–36 |
| 0:03–0:14 | **I · kNN concept.** Meet the data, run the plot (3) · the estate agent (3) · the vote (2) · the boundary (2) · back to the PTSD boundaries (1) | Run together, concept | 44–70 (solutions 61–79) |
| 0:14–0:19 | **I · choosing k concept.** The trap (2) · cross-validation as mock exams (3) | Concept | |
| 0:19–0:23 | **Code together.** Split and folds (2) · the model with `tune()` (1½) | Together | 107–119 |
| 0:23–0:29 | **Why normalise** (1) · **code together:** recipe and workflow (1½) · metrics, grid, `tune_grid()`, start the run (2½) · "while it runs" (1) | Concept, together | 121–152 |
| 0:29–0:40 | **Your turn.** Plot, `select_best()`, final fit, test F1 (6-minute timer) · solutions (3) · debrief (2) | Your turn | 156–198 |
| 0:40–0:43 | **Part II data.** Run the data, split and recipe (1½) · split by time (1½) | Run together | 296–318 |
| 0:43–0:59 | **Tree.** The Swiftie game: one question (3) · ask again (2) · L (2) · with prices (1½) · **together:** the recipe and the tree (2½) · **your turn:** Task 1 (5-minute timer) · solutions and discussion (3) | Game, together, your turn | 314–338 |
| 0:59–1:09 | **Forest.** Three friends (2) · with prices (1½) · **together:** the spec (1½) · **your turn:** Task 2 (4-minute timer) · solutions (1) | Game, together, your turn | 347–358 |
| 1:09–1:24 | **Boosting.** The relay (3) · with prices (1½) · **together:** the spec (1½) · **your turn:** Tasks 3–4 (6-minute timer) · solutions (2) · tree vs forest vs boosting (2) | Game, together, your turn | 364–390 |
| 1:24–1:27 | Wrap-up: three takeaways, exit question on Moodle | Whole class | |
| 1:27–1:30 | Spare | | |

**Will it fit?** 87 minutes planned, 3 spare; the slide notes have the detailed split. The games are built on questions to the room and can run long; the wait for `tune_grid()` is the other risk (if it passes three minutes on Nuvolos, read the exercise's syntax sheet during the wait). Checkpoints: Part I code by 0:23, Part II by 0:40, Task 1 by 0:54, Task 2 by 1:06, Tasks 3–4 by 1:19. **If behind, skip in this order:** (1) the "while it runs" question, 1 minute; (2) "A forest, with prices", 1½; (3) "Boosting, with prices", 1½; (4) the Part I debrief, 2; (5) shorten the Tasks 3–4 timer from 6 to 5. The estate agent, the trap, the mock exams and the three Swiftie games carry the intuitions and should not be cut.

**For fast finishers:** `show_best(knn_model_cv, metric = "f_meas")`; recall and precision on the kNN test set; `set_engine("kknn", kernel = "rectangular")` to see a plain majority vote at k = 100; `extract_fit_engine(dt_fit)$variable.importance`; `decision_tree(tree_depth = 2)` drawn with `rpart.plot()`; a forest with `importance = "permutation"`; tuning `learn_rate = tune()` on folds that respect time (`sliding_period()` on a date column, which the workbook's glossary names but no chunk uses).

**Fix before release** (the notebooks of 28 October; the earlier list was sent to Stuart and most of it is done: `v = 5`, the k grid, the tie explanation, the discussion answers, the variable table, the folds removed)

*Student workbook* (`my202-05-lab-students.qmd`)

- **The mission and task list are still the old ones**: "10-fold cross-validation" (line 74 and task 2 at 97) and the k grid `c(1, 5, 10, 20, 50, 100, 200)` (task 6 at 101). The solutions use `v = 5` and `c(100, 500, 1000, 3000)` and explain why k starts at 100 (solutions 115–124). Copy that task list over; the deck teaches 5 folds and the new grid.
- **The Task 1 answer is printed in the workbook** (lines 340–341, the `> The clue is…` block under "Class discussion"). Delete it. That shifts everything below by three lines: every Part II reference from Task 2 on (slides 32–41, the stuck boxes and this plan) then needs 3 taken off.
- **The glossary lists `sliding_period()`** (line 289) but no chunk uses it any more. Either drop the entry or keep it as "for reference"; the deck mentions it in one sentence on slide 22.
- Task 3's comment says "Fit the random forest and assign to `xgb_fit`" (line 374): XGBoost.
- The `#` headings inside Part I ("# Create train-test split…", 105, 113, 121, 131, 139, 154, 175, 188) render as top-level sections beside "Part I" and "Part II"; make them `###` as in the solutions.
- `kknn` is not in the library chunk (27–36). The engine loads it on demand, so this only matters if it is not installed on Nuvolos.

*Solutions* (`my202-05-lab-completed.qmd`)

- **Title** (line 2): still "Week 04 - Student Solutions".
- **Two "Your tasks" lists** (104–113 and 115–124): the old one (10-fold, old grid) is still there above the corrected one. Delete the first.
- **Stale comment at the split** (341–342): "We sort by year … and create a Date column (`study_date`) for time-series cross-validation", but the code no longer does either.
- **No seed before the forest and XGBoost** (400–409, 427–440): both are random, so the answers' 23.9 and 22.4 come out as 23.9 and 22.3 here (with `set.seed(123)`) and differently again on Nuvolos. Add a seed before each fit.
- **The Task 1 answer misses a variable** (392): the tree also splits on `study_year` (before/after 2012, inside the low-income branch, since the year stays a predictor), so six variables are used, not five. Either add it, or give `study_year` the `id` role too; the deck follows the notebook as it is and says "six of 52".

**Consistency check of the deck against the notebooks** (28 October, evening versions): every line reference on the slides (reference bars, task lists, stuck boxes and speaker notes) points at the right lines of the student workbook; slide 8 is the one reference to the solutions. Every code chunk in the workbook is on a slide: the library chunk (slide 2), the feature-space plot (4), split and folds (11), the model (12), recipe and workflow (14), metrics, grid and `tune_grid()` (15), the plot and `select_best()` chunks and the test F1 (17–18), `read_csv()`, the split and the recipe (21–22, 27), Task 1 (27–29), Task 2 (32–34), Tasks 3–4 (37–40); the solutions' extra chunk, the tutors' models, is slide 8. Every code line shown matches the solutions, with three deliberate differences, each explained in the speaker notes: the Part I syntax sheet and walkthrough write `wf_knn |> finalize_workflow() |> fit()` on fewer lines; plot styling (themes, titles, colours) is left out of the solution walkthroughs; the Task 1 walkthrough prints the metrics as one table per set; the Task 4 syntax sheet leaves out the bar chart's styling. The forest spec slide shows `set_engine("ranger", num.threads = …)` as in the solutions, where the workbook's sketch has the bare engine. The kNN engine prints `kernel = optimal` in the final workflow; the slide's shortened printout keeps that line. Terms match the notebook: hyperparameter, cross-validation, folds, recipe, workflow, k nearest neighbours, decision tree, random forest, XGBoost, `mtry`, `learn_rate`, RMSE, R².

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

*Childcare data.* 23,593 county-years, 57 columns (52 features after the outcome and the four id columns; `study_year` stays a predictor, as in the notebook), 2,904 counties, 2008–2018. Training 2008–2016: 18,797 rows; test 2017–2018: 4,796. Median weekly price $96.5; prices rise from a median of $85 (2008) to $106 (2018). Predicting the training mean scores a test RMSE of 39.1.

| Model | Train RMSE | Test RMSE | Test R² |
|---|---|---|---|
| Decision tree (defaults, 9 leaves) | 27.5 | 31.5 | 0.32 |
| Random forest (1,000 trees, mtry 7) | 6.6 | 23.9 | 0.64 |
| XGBoost (1,000 trees, learn rate 0.1) | 3.6 | 22.3 | 0.66 |

The tree (identical to the solutions' printout): `one_race_a < 2.23` first (87% of counties left, mean $94; right, mean $133), then `mhi_2018 < 47,748`, and in the poorer counties `study_year < 2012` ($80 before, $91 from 2012), `households < 7,862`, `femp_sales ≥ 33.9`, `one_race_a < 5.15`, `mhi_2018 < 54,848`, `femp_m < 53.3`; nine leaves from $80 to $224. Forest permutation importance: `mhi_2018`, `households`, `total_pop`, `h_6to17_both_work`, `one_race_a`. Trees of growing depth (all features, no pruning): test RMSE falls to 30.0 at depth 7 and creeps back to 31.0 at depth 12, while training RMSE falls to 15.1 (2,014 leaves). Forest size: 1 tree 35.0, 10 trees 25.1, 100 trees 24.0, 1,000 trees 23.9 (test RMSE). XGBoost as trees are added: 37.9 after 1, 31.3 after 10, 25.1 after 100, 22.3 after 1,000.

*Concept examples.* The hand table of eight sold flats is made up; the new flat is 55 m², 6 minutes, and its five comparables (A–E) vote 3–2 "sells". The 160 simulated flats use the first seed (4) at which 1 and 15 neighbours disagree about the new flat: k = 1 says "doesn't sell", k = 5 says "sells" (3–2), k = 15 says "sells" (13–2); the simulated SDs are 26 m² and 7.4 minutes, so flat F's 40 m² gap is 1.5 SD and flat G's 14-minute gap is 1.9 SD. The trap: training accuracy 100% at k = 1, 82% at k = 5 and 50; 5-fold accuracy 71%, 78%, 80%, so k = 50 wins. The Swiftie table and its numbers are listed under Running examples; the deck's setup chunk checks them with `stopifnot()`, so a changed table fails the render instead of showing wrong counts. The one-feature trees use the training counties' median income: the first cut is at $59.2k (means $93 and $125). The bagging picture resamples the counties (`set.seed(11)` for the three trees, `set.seed(12)` for the average of 50); the boosting picture adds a tenth of a depth-2 tree per round for 100 rounds.

---

## Slides and script

44 slides. Every slide was checked at 16:9 (1200 × 675) with all fragments revealed: content stays above the footer. The full script is in the speaker notes (press `S`). The tracker bar reads: I kNN + CV · II Trees · Forests · Boosting · Wrap-up. Mode in brackets.

### 1 Title · 2 Lab overview
- The parts, functions and minutes, and the cycle every block follows: concept, code together, your turn. Run the library chunk (lines 27–36).

### Part I · kNN concept
- **3 Divider · 4 Meet the data** (run together, 44–70): the feature space; 33,234 people, 34% with PTSD, 121 cells. Ask where the boundary goes, then go to the flats.
- **5 How does an estate agent price a flat?** Eight sold flats and a new one; the five most similar vote 3–2 "sells". That is the whole algorithm.
- **6 The neighbours vote**: 160 simulated flats; k = 1, 5, 15; the vote flips. k is a hyperparameter.
- **7 The boundary depends on k**: k = 1 islands, k = 50 smooth.
- **8 Back to the PTSD data** (demo, solutions 61–79): the tutors' four models. Which k? We need a fair score.

### Part I · choosing k, then code together
- **9 The trap**: k = 1 scores 100% on its own flats; held-out flats reverse the ranking.
- **10 Cross-validation: mock exams**: five folds, rotate, average; the test set sealed.
- **11 Split and folds** (together, 107–111): Lab 4's split plus `vfold_cv(v = 5)`.
- **12 The model: leave k open** (together, 113–119): `nearest_neighbor(neighbors = tune())`; nothing fitted yet.

### Part I · normalise, then code together, then your turn
- **13 Why normalise?** (concept, the workbook's note at 123): flat F or G is closer depending on the units; measure in SDs.
- **14 Recipe and workflow** (together, 121–129): `step_normalize()` and the workflow.
- **15 Metrics, candidates, and the tuning run** (together, 131–152): fill the `tune_grid()` sketch; start the run.
- **16 While it runs**: 20 fits, none of them the final model.
- **17 Exercises: Part I** (your turn, 6 min, 156–198) · **18 Solutions** · **19 What did we learn?**

### Part II · data
- **20 Divider · 21 Meet the data** (run together, 296–318): data, split and recipe, all given. **22 Split by time**: why not a random split; folds would need the same care.

### Part II · the tree cycle
- **23 Who's a Swiftie? You may ask one question** (game): the table; scores revealed; "likes pop?" 10 of 12; the first split.
- **24 Then ask again, inside each group** (game): "enjoys lyrics?" finds K; 11 of 12; a decision tree.
- **25 What about L?** (game): only "age 30 or over?" finds L; would you bet on it? Overfitting, and the brakes.
- **26 Same game, with prices**: income cut-offs and means; the staircase.
- **27 Your first tree, together** (314–327): the recipe's id roles; `decision_tree()`, `set_mode("regression")`, fit. No normalising.
- **28 Exercises: Task 1** (your turn, 5 min, 330–338): draw, score both sets, discuss. **29 Solutions: Task 1**: the tree, training 27.5, test 31.5; the notes carry the class discussion of line 338.

### Part II · the forest cycle
- **30 A forest: ask three friends** (game): three real one-question trees from 8 people and 2 questions each; Mia: 2 to 1 Swiftie.
- **31 A forest, with prices**: three resampled staircases, then the average of 50.
- **32 The forest, together** (348–351): `rand_forest(mtry, trees)`, ranger.
- **33 Exercises: Task 2** (your turn, 4 min, 353–358) · **34 Solutions: Task 2**: test 23.9; training 6.6 is normal for a forest.

### Part II · the boosting cycle
- **35 Boosting: a relay** (game): friends 1–3 ("pop?", "lyrics?", "trends?") each aimed at the previous mistakes; together 12 of 12.
- **36 Boosting, with prices**: after 1, 5, 20, 100 small trees; `learn_rate`.
- **37 Boosting, together** (365–372): `boost_tree(trees, learn_rate)`, xgboost.
- **38 Exercises: Tasks 3 and 4** (your turn, 6 min, 374–390) · **39 Solutions: Task 3**: test 22.3 · **40 Solutions: Task 4**: the comparison table and bar chart.
- **41 Tree, forest, boosting: what's the difference?** One table: the game, how the trees are grown, how they're combined, the knobs, readability, test and training RMSE.

### 42 Summary · 43 Further reading · 44 Feedback
- Three takeaways; exit question on Moodle (you have the 2019 prices: which model, and what does the forest's training RMSE of $7 mean?); reading; feedback QR code.
