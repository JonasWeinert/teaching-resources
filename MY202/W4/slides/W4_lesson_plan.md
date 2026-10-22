# MY202 · Lab 4 — Classification: predicting yes or no

Lesson plan, slide outline and speaker script, based on the updated notebooks of 21 October 2026: `W4/notebooksanddata/my202-04-lab-students.qmd` (322 lines; all slide line numbers refer to this file) and `my202-04-lab-completed.qmd`. Last year's DS202 Week 4 deck supplied two ideas kept here: the chess example for "line → S-curve → threshold", and the threshold walk-through.

The updated notebooks dropped cross-validation and *k*-nearest neighbours, moved Q7 to the training set and added Q10 (choose the threshold on the training set, check it on the test set). The deck follows: three parts, no CV, no kNN.

## Lesson plan

**Format:** 90-minute computer lab. The student notebook has `# Code here` in every chunk, so the deck decides what is typed **together** and what is **your turn**:

- **Your turn** where the code is something students have written before, or a near copy of Lab 3: the first look at the data (`dim()`, NA count, `glimpse()`), the EDA plots, the split + `logistic_reg()` fit + `summary()` (the notebook's hint says "look back at the lasso section from Lab 3"), and the Q8–Q10 plots and the final test-set check.
- **Together** where the code carries a new idea or new syntax: `across()` for the type conversion, predictions with a threshold (`augment()` + `if_else()`), the confusion matrix, and the Q7 threshold sweep (`metric_set()` + `partial(event_level = )` + `map_dfr()`).

Every code chunk the notebook asks for is annotated on a slide: either as an anatomy (each piece numbered and explained) for code-together, or as a commented syntax sheet plus a step-by-step solution walkthrough for your-turn. Every slide that touches the notebook carries a reference bar with the line number.

**Learning objectives** (the notebook's two, made concrete). By the end, students can:

1. Convert many columns to the right type at once with `across()`, and say why the outcome must be a factor for classification
2. Explain why a straight line is a poor model for a 0/1 outcome, and what the sigmoid does
3. Fit a logistic regression with `logistic_reg() |> fit()`, and read a coefficient as a change in the log-odds (its sign gives the direction) and, after `exp()`, as an odds ratio
4. Turn predicted probabilities into classes with a threshold, and read a confusion matrix
5. Compute accuracy, recall, precision, specificity and F1, and explain why accuracy misleads when one class is rare
6. Choose a threshold on the training set by comparing metrics across thresholds, and check it on the test set for overfitting

**Before class**

- The lab runs on Nuvolos, with the notebook, packages and data already set up. Check once that the Week 4 workspace has the student notebook and `data/diabetes.csv`, and that `ggsci`, `kknn` and `reshape2` load (the library chunk still loads `kknn`, although the lab no longer uses it).
- The deck's solution slides run the real code (split with `set.seed(123)`, `strata = diabetes`), so the numbers match what students see. The data for rendering sit in `W4/notebooksanddata/data/diabetes.csv` (git-ignored).

**Timing**

| Time | Block | Mode | Notebook lines |
|---|---|---|---|
| 0:00–0:06 | Welcome, overview, run the library and `read_csv()` chunks; two warm-up questions (why a test set; the accuracy trap) | Whole class | 18–25, 53–56 |
| 0:06–0:30 | **Part I.** Meet the data (2) · first look, your turn (4-minute timer) + solutions (1) · Step 2, which type is each column (1) · Step 3–4 with `across()`, together (5) · EDA, your turn (8-minute timer) · debrief (3) | Your turn → together → your turn | 58–74 · 86 · 92–104 · 145, 150 |
| 0:30–0:40 | **Part II concept.** Chess example: line, S-curve, threshold (5) · what the model learns: two dials (2) · reading a coefficient: the odds ratio (3). No equations, but the notebook's two terms, log-odds and odds ratio, are named and used | Slides | 168 (teaching moment) |
| 0:40–0:53 | **Part II code.** Q1–Q4 your turn (7-minute timer) · solutions (2) · reading the output, class discussion (4) | Your turn, then discuss | 176–235 |
| 0:53–1:24 | **Part III.** Q1–Q3 predictions and the threshold, together (4) · Q4 confusion matrix, together (3) · Q5 five metrics (3) · table partners: which mistake is worse (1) · Q6 moving the threshold (2) · Q7 sweep, together (4) · Q8–Q10 your turn (9-minute timer) · solutions (3) · debrief (2) | Together → your turn | 241–320 |
| 1:24–1:28 | Wrap-up: three takeaways, exit question on Moodle | Whole class | |
| 1:28–1:30 | Spare | | |

**Will it fit?** 88 minutes planned, 2 spare. Checkpoints: Part I by 0:06, Part II by 0:30, the Part II exercise by 0:40, Part III by 0:53, the Part III exercise by 1:11, wrap-up by 1:24. **If behind, skip in this order:** (1) warm-up 1, 1 minute; (2) the second dial on "What the model learns", say it in one sentence, 1 minute; (3) shorten the EDA timer from 8 to 6; (4) take the Part III solution walkthroughs at speed, since the debrief slide has the answers. Part II's concept block and Q7 should not be cut.

The notebook's own timings (Part I 30 minutes, Part II 50, Part III none) add up to 80; the plan gives Part I 24 and Parts II+III 54 because the setup and warm-up come out of the same 90 minutes.

**For fast finishers:** label the Q9 points with `geom_text(aes(label = alpha))`; compute recall and precision at α = 0.1 on the test set and count false alarms per person found; compute the ROC AUC with `roc_auc(test_preds, diabetes, .pred_1, event_level = "second")` (0.82).

**Fix before release** (found while reading the updated notebooks and running the code)

- **Q9 plot title is backwards** (completed notebook, line 618): "When the probability threshold is lowered, recall decreases and precision increases". Lowering the threshold *raises* recall and lowers precision; the answer text under the plot says it correctly.
- **Sex labels probably flipped** (completed, lines 241–250): the solution relabels `sex == 1` as "Female" and concludes "males are (slightly) less likely to have diabetes". In this BRFSS extract 1 is usually male, which would reverse the conclusion. Check the codebook and say which code is which in the variable list. The deck avoids the sex plot.
- **"It overfits to the majority class"** (completed, line 526): there is no overfitting (training and test metrics agree, which Q10 itself shows). The model is dominated by the majority class because of the imbalance.
- **The `augment()` tip** (student line 245, completed lines 447, 452, 455): `type.predict = "response"` and `data = diabetes_data` are ignored by tidymodels' `augment()`; the probabilities come out anyway. Remove the tip and the arguments, or students copy them forever. The deck types the short version and says why.
- **Variable list** (student lines 43, 47–49): `hvy_alcohol_consum` should be `hvy_alcohol_consump`; "difficulty walking of faces" should be "or faces"; `age` is "the individual's age" but is a 13-level code for 5-year bands (1 = 18–24, 13 = 80+); `gen_hlth` runs 1 = excellent to 5 = poor. The Step 2 answer (completed line 88) repeats the typo.
- **Q4 of Part II** (student line 204) asks students to "generate predictions and evaluate performance", but the answer only prints `summary()`; predictions come in Part III. Reword to "print the coefficient table".
- **Q2 vs Q3 threshold rule** (completed lines 467 and 475): Q2's answer says "≥ 0.5", Q3 and the code use "> 0.5".
- **Q10 wording** (student line 316): "Calculate the F1-score on the training set applying the probability threshold" doesn't say *which* threshold. Suggest: "Take the threshold with the highest F1 on the training set (Q7)…". The solution's answer text also runs into the end of the file with no line break.
- **Learning outcomes** appear only in the student notebook, and the library chunk still loads `kknn` and `reshape2`; `reshape2` is used by the correlation heatmap in the solutions, `kknn` by nothing.
- The prevalence code in the solutions uses `mean(as.numeric(diabetes) == 2)`, which relies on factor level positions. The deck's syntax sheet uses `mean(diabetes == "1")` and the slide notes explain the difference.
- **Q5 table rounding** (completed lines 511 and 515): accuracy is given as 0.86 and F1 as ≈ 0.25; with the same counts they are 0.867 and 0.244. The slides show the exact values and the notes mention it.
- **Step 2 answer vs code** (completed line 88 vs lines 96, 119): the answer calls `gen_hlth`, `education` and `income` "categorical (ordinal)", the code makes them integers. The slides follow the code.

**Consistency check of the deck against the notebooks** (22 October): all 40 line references point at the right line of the student notebook. Every code line shown on a slide matches the completed notebook, except three deliberate differences, each explained in the speaker notes: the EDA syntax sheet uses `mean(diabetes == "1")` and `|>` instead of the solutions' `mean(as.numeric(diabetes) == 2)` and `%>%`; the Part III predictions leave out the ignored `type.predict` and `data` arguments of `augment()`; and plot styling (themes, titles, colours) is left out of the solution walkthroughs. Terms match the notebook: log-odds, odds ratio (OR), recall (also called sensitivity), precision, specificity, F1, threshold α. Sharing is on Moodle, as in the notebook.

**Key numbers** (seed 123, 75% split stratified on `diabetes`: 19,025 training rows, 6,343 test rows)

Data: 25,368 rows, 20 columns, no missing values; 13.8% with diabetes. Prevalence: by age band from 1.1% (18–24) to 22.3% (band 11), 17.3% at 80+; high blood pressure 24.3% vs 5.7%; physically active 11.4% vs inactive 21.3%.

Logistic regression, largest effects by p-value (estimate → odds ratio): `gen_hlth` 0.507 → 1.66 per step; `bmi` 0.060 → 1.06 per point (×1.83 per 10); `high_bp1` 0.828 → 2.29; `high_chol1` 0.658 → 1.93; `age` 0.125 → 1.13 per band; `hvy_alcohol_consump1` −0.984 → 0.37. Not significant once the rest is held fixed: `smoker`, `phys_activity`, `veggies`, `diff_walk`, `education`, `stroke`, `any_healthcare`, `no_docbc_cost`.

| Threshold 0.5 | TP | FP | FN | TN |
|---|---|---|---|---|
| Training set | 405 | 356 | 2,215 | 16,049 |
| Test set | 136 | 106 | 738 | 5,363 |

Test set at 0.5: accuracy 0.867 (all "no": 0.862), recall 0.156, precision 0.562, specificity 0.981, F1 0.244. Only 3.8% of test probabilities exceed 0.5. Test set at 0.3: 371 found, 500 false alarms; at 0.2: 558 found, 981 false alarms; at 0.1: 742 found, 1,944 false alarms.

Q7, training set:

| α | Precision | Recall | F1 |
|---|---|---|---|
| 0.1 | 0.276 | 0.850 | 0.416 |
| 0.2 | 0.363 | 0.644 | **0.464** |
| 0.3 | 0.430 | 0.445 | 0.438 |
| 0.4 | 0.493 | 0.282 | 0.359 |
| 0.5 | 0.532 | 0.155 | 0.240 |
| 0.6 | 0.577 | 0.076 | 0.134 |
| 0.7 | 0.555 | 0.025 | 0.048 |

Q10: best α = 0.2; test-set F1 at 0.2 = 0.462 against 0.464 on training → no overfitting.

Concept examples: the chess club is simulated (26 players, `set.seed(20)`); the line predicts 1.46 for 300 games, the S-curve 0.75 for 150.

---

## Slides and script

36 slides. Every slide was checked at 16:9 with all fragments revealed: content stays above the footer. The full script is in the speaker notes (press `S`). The tracker bar reads: Warm-up · I EDA · II Logistic · III Evaluation · Wrap-up. Mode in brackets.

### 1 Title · 2 Lab overview
- Overview table with parts, functions, mode and minutes. Notes explain the rule for the together/your-turn split. Script: last week a number, today a category. Run lines 18–25 and 53–56 now.

### 3 Divider · 4–5 Warm-up 1 and 2 (vote)
- 1: why a test set? (a model flatters itself on its own rows; points ahead to Q1 and Q10). 2: 1 in 100 sick, "healthy" for everyone, accuracy? (99%, useless). Plants the accuracy trap for Part III.

### 6 Divider "Part I" · 7 Meet the data (run together, lines 31–56)
- 25,368 · 19 features · 13.8% with diabetes; features in three groups; note on codes (`age` bands, `gen_hlth` 1–5).

### 8 Exercises: Part I · first look (your turn, 4 min, lines 58–74)
- Q1 `dim()`, NA count, Step 1 `glimpse()`. Syntax sheet with comments; the NA count's `across(everything(), ~ sum(is.na(.x)))` is commented line by line.

### 9 Solutions: Part I · first look (walkthrough)
- `dim()` → 25,368 × 20; NA count → all zeros; `glimpse()` → every column `<dbl>`, which motivates Step 2.

### 10 Step 2: what type is each column? (discuss, line 86)
- `bmi`, `gen_hlth`, `high_bp`: which are really numbers? Reveal: continuous → numeric, ordered → integer, categories → factor. The outcome must be a factor.

### 11 Step 3: convert many columns at once (together, lines 92–104)
- Anatomy of the three name vectors, `mutate(across(all_of(...), ~ as.factor(.x)))` and Step 4's `map_chr(diabetes_data, class)`, seven numbered pieces. Notes: 50+ columns → `where()` or `starts_with()`.

### 12 Exercises: Part I · EDA (your turn, 8 min, line 145)
- Distribution of `diabetes`; prevalence by `age`; one plot of their own; a sentence each; post on Moodle (line 150). Commented syntax sheet; "stuck" covers `mean(diabetes == "1")` on a factor.

### 13 Part I: what did we see?
- Prevalence by age band; high blood pressure (24% vs 6%) and physical activity (11% vs 21%). Plots suggest, a model holds the others fixed.

### 14 Divider "Part II" · 15–19 Concept (the notebook's "teaching moment", line 168)
Kept deliberately light on maths: pictures and words, no equations. The two terms the notebook's answers use (lines 383–407 of the completed notebook) are named on the slides: coefficients are on the **log-odds** scale, and `exp()` turns them into **odds ratios**.
- 15 Predicting yes or no: chess club, a straight line, 300 games → 1.46, impossible regions.
- 16 Squish the line: the S-curve; output is a probability, `.pred_1`.
- 17 From probability to class: 150 games → 0.75 > 0.5 → win; 0.5 is a choice.
- 18 What the model learns: two dials. S-curves for BMI with everything else fixed: today's effect, a stronger feature, no effect (flat), a protective feature (falling); then a second panel where the baseline moves the curve up or down. Cards: how much it matters, which way, where it starts. "These dials are the coefficients that `summary()` prints, on the log-odds scale; `exp()` turns each into an odds ratio."
- 19 Reading a coefficient: the odds ratio. Lollipop plot of the 11 odds ratios with p < 0.05 (cholesterol checked 2.80, high blood pressure 2.29 … heavy drinker 0.37), dashed line at 1. Cards: OR = exp(estimate), with odds defined in words (1 in 10 = 1 to 9); OR > 1 higher odds, < 1 lower, = 1 none; the notebook's own examples (BMI 1.06, about 6% higher odds per point; heavy drinker 0.37, about 63% lower); OR 2.29 takes someone from 10% to about 20%.

### 20 Exercises: Part II (your turn, 7 min, lines 176–208)
- Q1 one sentence; Q2 split with `strata`; Challenge `logistic_reg()` fit; Q3 one sentence; Q4 `extract_fit_engine() |> summary()`. The syntax sheet is last week's code with every changed line commented ("was: linear_reg()", "NEW: strata").

### 21 Solutions: Part II (walkthrough)
- Class shares in both sets (13.8% each); coefficients; the `summary()` table sorted by p-value.

### 22 Reading the output (discuss, lines 210–235)
- The notebook's four discussion boxes: estimate as log-odds and odds ratio (`gen_hlth` ×1.66); p-values; careful: heavy drinking ×0.37, reverse causation; box 4: not accuracy → Part III.

### 23 Divider "Part III" · 24 Predictions, piece by piece (together, lines 241–251)
- Anatomy of `augment(new_data = train/test)` and `pull(test_preds, .pred_1)[1:10]`; Q2's answer: probabilities, so we need a cut-off. Notes: the notebook's extra `augment()` arguments do nothing.

### 25 The threshold, in code (together, lines 257–259)
- Anatomy of `mutate(.pred_class = as.factor(if_else(.pred_1 > 0.5, 1, 0)))` beside the test-set histogram of `.pred_1`; only 3.8% above 0.5.

### 26 The confusion matrix (together, lines 263–269)
- 2×2 grid defined in words, then counts 136 / 106 / 738 / 5,363; the `conf_mat() |> autoplot(type = "heatmap")` line annotated, including that R's heatmap puts 0 first.

### 27 Q5: five numbers from one table (discuss, line 273)
- Accuracy 0.867, recall 0.156, precision 0.562, specificity 0.981, F1 0.244, clicked through; the accuracy trap (all "no" = 0.862).

### 28 Which mistake is worse? (table partners, lines 275–280)
- Screening wants recall; treat-on-a-flag wants precision.

### 29 Q6: moving the threshold (discuss, line 288)
- Histogram with α at 0.5, 0.3, 0.1 and the counts; the trade-off; why 0.8 is bad.

### 30 Q7 in code, piece by piece (together, line 293)
- Anatomy in six pieces: `metric_set`, `partial(event_level = "second")`, `map_dfr` over `alpha_list`, predictions on the **training** set, cut at `.x`, `mutate(alpha = .x)`. Notes: why the training set (choose here, judge in Q10).

### 31 Exercises: Part III (your turn, 9 min, lines 300–320)
- Q8 the metric plot; Q9 the precision–recall plot; Q10 the best training α, test F1, overfitting? Commented syntax sheet for each, including `pivot_wider()` and `slice_max() |> pull()`.

### 32 Solutions: Q8 · 33 Solutions: Q9 and Q10 (walkthroughs)
- Q7's table (F1 peaks at 0.2) and the metric plot; the wide table and the PR curve; `best_alpha` = 0.2; test F1 0.462.

### 34 Part III: what did we learn?
- F1 bars: 0.240 (α 0.5, train), 0.464 (0.2, train), 0.462 (0.2, test). Cards: same model, better use; no overfitting; still not great. Test set at 0.2: 558 of 874 found, 1.8 false alarms per person found.

### 35 Summary · 36 Further reading
- Three checks (logistic regression and factors; threshold chosen on training, checked on test; the accuracy trap and precision/recall). Exit question on Moodle: which threshold, and how many false alarms per person found? Reading: ISLR 4.1–4.3, TMWR chapter 9, yardstick reference.
