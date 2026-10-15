# MY202 · Lab 3 — Linear Regression: our first algorithm

Lesson plan, slide outline and speaker script, based on `W3/notebooksanddata/solutions.qmd` (the student notebook is still to be derived from it, see "Fix before release").

## Lesson plan

**Format:** 90-minute computer lab in two modes, following the student notebook (`student.qmd`, 378 lines). Where the notebook gives the code or scaffolds it with comments, we **code together**: the slide explains each piece of the line (anatomy), and a notebook reference under the slide title says which lines to type or run. Where the notebook has a `# Code here` chunk and action points, it is **your turn**: a timer, tasks with line numbers, a syntax sheet, then a solution walkthrough. Only two sections are "your turn": the EDA (line 131) and lasso Steps 2–5 (lines 348, 356, 364, 376).

**What is new this week.** This is the first *algorithm* of the course. The deck therefore spends about 12 minutes at the start building the intuition for ordinary least squares from scratch, with questions rather than definitions, before any code. Every equation that appears in the lab (prediction, residual, RSS, R², RMSE, the lasso loss) gets the same treatment as code: one line, colour-coded parts, one short explanation per part. The same applies to the new `tidymodels` syntax.

**Learning objectives.** By the end, students can:

1. Explain in plain words what a linear model is, what a coefficient means, and how ordinary least squares picks the line (minimise the sum of squared residuals)
2. Read the output of `summary()` for a fitted model: estimate, standard error, p-value, R²
3. Explain why we split data into training and test sets, and do it with `initial_split()`, `training()` and `testing()`
4. Fit a model with `linear_reg() |> fit()`, get predictions with `augment()` and evaluate them with R² and RMSE
5. Read a residual plot and say whether a model fits well
6. Explain what the lasso penalty does, why it sets coefficients to exactly zero, and what a hyperparameter is; fit a lasso with `penalty` and `mixture = 1`

**Before class**

- The lab runs on Nuvolos, with the notebook, packages and data already set up, so there is no setup block in the deck. Check once that the Week 3 workspace has the student notebook and `data/students-data-cleaned.csv`, and that the setup chunk runs.
- Render the completed notebook once yourself. The deck's solution slides run the real code, so the numbers on the slides match what students will see (the split uses `set.seed(123)`).

**Timing**

| Time | Block | Mode |
|---|---|---|
| 0:00–0:02 | Welcome, lab overview, open the notebook on Nuvolos and run the setup chunk | Whole class |
| 0:02–0:17 | Concept block. Opens with three warm-up questions voted by hand (read a rule, how OLS picks the line, what R² means) whose answers set the pace; then OLS from scratch, the equations and the `fit()` syntax | Slides, questions to the room |: our first algorithm. Building OLS from scratch, then the equations and the `fit()` syntax | Slides, questions to the room |
| 0:17–0:29 | Part 1: meet the data, EDA (notebook line 131). 8-minute timer, 2-minute share | Your turn, tutor circulates |
| 0:29–0:37 | Part 2: the hypothesis-testing approach. Run lines 146–152 and 160–165; reading `summary()`; `~ .` | Code together |
| 0:37–0:55 | Part 3: the machine learning approach. Made-up model (lines 191–212), why split, the split (218–225), fit (233–235), evaluate (246–256), what you should see, debrief (258–260) | Code together |
| 0:55–1:03 | Part 4: residual plots. Run lines 268–324; reading the plot; action point (line 326) | Code together |
| 1:03–1:25 | Part 5: lasso. Concept (penalty, λ, why exactly zero, hyperparameter); Step 1 together (336–341); Steps 2–5 (347–377) with a 9-minute timer; solutions; debrief; bonus sweep | Concept + Step 1 together, then your turn |
| 1:25–1:29 | Wrap-up: three takeaways, exit question, next week | Whole class |
| 1:29–1:30 | Spare | |

**Will it fit?** The table above adds up to 89 minutes with one minute spare, which is tight. A realistic run of the slides, with the click-throughs, the voting and students typing along, comes to about 95: the concept block tends to take 15 rather than 12, Part 3 about 20 with everyone typing, and Part 5 about 24. Treat these as the checkpoints: Part 1 should start by 0:17, Part 2 by 0:29, Part 3 by 0:37, Part 4 by 0:55, Part 5 by 1:03 and the wrap-up by 1:25. **If you are behind at a checkpoint, skip in this order:** (1) the bonus sweep slide, 1 minute; (2) the "Parameters and hyperparameters" slide, say it in one sentence on the dial slide, 2 minutes; (3) running the simulated-data chunks in Part 4, lines 268–298, the plots are on the slides, 3 minutes; (4) shorten the Part 5 timer from 9 to 8 minutes. Those four recover about 7 minutes. Parts 3 and 5 are the core and should not be cut.
**For fast finishers:** try `penalty = 0.3` and `penalty = 1` and count the non-zero coefficients; plot residuals against a single feature such as `absences`; fit the simple model on the training set only and compare its test RMSE with the full model's (3.04).

**Fix before release** (found while reading the notebooks and running the code)

- The slides reference `student.qmd` by line number (setup 24–62, EDA chunk 131, hypothesis tests 146–152 and 160–165, made-up model 191–212, split 218–225, fit 233–235, evaluate 246–256, residual plots 268–324, lasso Step 1 336–341, Steps 2–5 at 348, 356, 364, 376). If the notebook is edited before release, re-check these on the slides (search the deck for `nbref`).
- The data file was missing from the local folder (students get it on Nuvolos). For rendering the deck, the CSV now sits in `W3/notebooksanddata/data/` (fetched from the LSE-DSI/DS202 repository, 649 rows × 31 columns; the folder is git-ignored).
- The variable list in `student.qmd` and `solutions.qmd` describes `medu`, `fedu`, `traveltime`, `studytime`, `famrel`, `freetime`, `goout`, `dalc`, `walc` and `health` as numeric codes (0–4 or 1–5). In the file they are text labels (`"Higher"`, `"2-5hrs"`, `"VeryLow"`). Update the descriptions, or students will look for numbers that aren't there. `failures` is numeric (0–3), `age` and `absences` are numeric.
- Both notebooks' headers still say "MY202A, Week 03" by "The DS202 Team".
- The section timings in the notebook add up to 80 minutes (5 + 15 + 5 + 20 + 10 + 25). The plan above redistributes them to 90 with the concept block.
- The bonus chunk (line 375–377) is an empty `# Code here` with no scaffolding, while the solutions use a nested-tibble `map()` sweep. On the slides the bonus asks students to try two or three penalties by hand; the sweep plot is shown on the bonus slide.
- The EDA section says "Share your most interesting findings on Slack!". Replace with whichever channel MY202 uses.
- `advertising.csv` (the ISLR advertising data) is in the folder but the lab never uses it. The deck uses it for the concept block (sales against TV budget) because one predictor makes a clearer picture than 30. If it is meant for the lab, say so and I'll swap the examples.
- The full multivariable model has 67 coefficients from 649 rows. Its test R² (0.21) is far below its training R² (0.45). This is a feature, not a bug: it is the best motivation for the lasso, so the Part 3 debrief leans on it.

**Key numbers** (seed 123, 75% split: 486 training rows, 163 test rows)

| Model | Data | R² | RMSE |
|---|---|---|---|
| `final_grade ~ higher` | all | 0.110 | 3.05 (residual SE) |
| `final_grade ~ .` | all | 0.410 | 2.59 (residual SE) |
| `final_grade ~ .` | training | 0.446 | 2.37 |
| `final_grade ~ .` | test | 0.211 | 3.04 |
| lasso, penalty 0.1 | test | 0.240 | 2.95 |

Lasso with penalty 0.1 keeps 40 of 67 coefficients. Largest: `higheryes` 1.81, `failures` −1.37, `schoolsupyes` −1.05, `feduNone` 1.01, `schoolMS` −0.97. Penalty sweep (test RMSE): 0.0001 → 3.039, 0.001 → 3.039, 0.01 → 3.025, 0.1 → 2.950. Beyond the bonus grid: 0.3 → 3.044 with 14 coefficients, 1 → 3.29 with 2.

Advertising (concept block): `sales = 7.03 + 0.0475 × TV`, R² = 0.61. First row: TV 230.1, sales 22.1, prediction 17.96, residual 4.14.

---

## Slides and script

About 48 slides. Every slide was checked at 16:9 with all fragments revealed: content stays above the footer. Each slide lists its **on-slide content**, then the **script**. The tracker bar at the top of content slides reads: Concept · 1 EDA · 2 Hypothesis · 3 ML · 4 Residuals · 5 Lasso · Wrap-up.

### Slide 1 — Title: "Linear Regression: our first algorithm"
- On slide: course, Lab 3, author, logo
- Script: Welcome. Last week you made plots. Today you make predictions. We meet the first algorithm of the course and learn the workflow we'll use for every model from now on: split, fit, evaluate. Open the Week 3 notebook on Nuvolos and run the setup chunk while I talk.

### Slides 4–6 — Warm-up: three questions (the first three slides of the concept block, one multiple-choice slide each)
- On slide: 1, read a rule: "10 + 0.5 × hours, 4 hours → ?" (12). 2, how does linear regression choose the line? (smallest sum of squared gaps; "the gaps add up to zero" is the trap). 3, R² = 0.65 means… (the features explain 65% of the variation). Each has a "not sure" option so nobody has to guess. Click reveals the answer with one line of explanation.
- Script: Hands up for each option, then reveal. No teaching here. The notes on each slide say which concept slides to speed up or slow down depending on the vote: question 1 sets the pace for the arithmetic slides, question 2 for the least-squares build-up, question 3 for the R² and RMSE slides.

### Slide 2 — Lab overview
- On slide: table of parts (Concept · 1 EDA · 2 Hypothesis testing · 3 ML approach · 4 Residuals · 5 Lasso), with functions, data and minutes. "Each part: a short demonstration, exercises in the notebook, then the solutions."
- Script: Two data sets today. A small advertising data set on the slides, to see the algorithm with one predictor, and the students data in the notebook, with 30 predictors. Same rhythm as before: I show, you do, we go through the solutions.

### Slide 3 — Divider: "Our first algorithm"
- Kicker: Concept. Line: "What a model is · how a line is chosen · how we judge it"

### Slide 4 — What is a model?
- On slide: a made-up rule in words, no code: `grade = 10 + 0.5 × hours − 2 × failures`. Click-through arithmetic for one student: 6 hours and 1 failure → 10 + 3 − 2 = 11; actual grade 13; residual +2. Question in a dark card: "Where do 10, 0.5 and −2 come from?"
- Script: A model is nothing more than a rule. Put numbers in, get a prediction out. Click through the arithmetic one line at a time; nothing harder than this happens all day. The numbers in the rule are called coefficients, or parameters. Someone had to pick them. An algorithm is the recipe for picking them from data. That recipe is what we build in the next five slides.
- The concept block uses plain arithmetic throughout, revealed one line per click (`.calc` blocks): the residual for one market, squaring and summing residuals, plugging a budget into the fitted line, computing R² and RMSE from RSS and TSS, and the lasso's "bill" for three coefficients. R code appears only on the last concept slide.
- Every concept visual builds up click by click in step with the explanation (stacked plot versions in an `.r-stack`): the three candidate lines appear with the vote; one market lights up, then the line's guess, then the residual, then all 200; the flat line's residuals appear when "add them up" is proposed; the bowl is traced one line and one dot at a time; the R² picture switches from the flat line (TSS) to line B (RSS); the lasso dial adds one panel per penalty; the ridge curve appears only when ridge is mentioned.

### Slide 5 — Which line is best? (question)
- On slide: scatter of TV advertising budget against sales (200 markets), with three candidate lines A, B, C drawn through it. "Vote: A, B or C?"
- Script: 200 markets, how much was spent on TV ads and how much was sold. We want a line that lets us predict sales from a budget. Here are three. Hands up for A… B… C. Most pick B. Now the hard question: *why*? What makes a line good? You need a number that says how wrong a line is, otherwise a computer can't choose.

### Slide 6 — How wrong is a line? Residuals
- On slide: same scatter with line B and vertical segments from each point to the line. Click-through for one market: budget 230.1 → the line says 18.0 → actually sold 22.1 → residual 22.1 − 18.0 = +4.1. Then the definition: residual = actual − predicted. "Positive: the line guessed too low. Negative: too high."
- Script: For each market, the line makes a guess. The gap between what happened and the guess is the residual. 200 markets, 200 residuals. Now, how do we turn 200 numbers into one score for the line?

### Slide 7 — Add them up? (question)
- On slide: two columns. Left: "Add them up?" with residuals +4.1, −3.9, +0.2 … "sum ≈ 0" and a line that is clearly wrong but balances. Right: "Square first, then add" with 16.8, 15.2, 0.04 … "RSS = sum of squared residuals". Two reasons: cancelling stops; big misses count a lot more than small ones (a miss of 4 costs 16, two misses of 2 cost 8).
- Script: Ask the room first. Someone will say "add them". Problem: positives and negatives cancel, so a terrible line can score zero. Fix: square each residual first. Squaring also makes one big miss cost more than several small ones, which is usually what we want. The total is the residual sum of squares, RSS. That is our score. Lower is better.

### Slide 8 — Try every line: the bowl
- On slide: left, four lines with different slopes and their RSS; right, a curve of RSS against slope, bowl-shaped, with the minimum marked. "Ordinary least squares (OLS): the line with the smallest RSS." Card: "You don't have to try every line. There's a formula that jumps straight to the bottom of the bowl. R does it in milliseconds."
- Script: Imagine trying every slope and writing down its RSS. You get a bowl. The bottom of the bowl is the best line. That's the whole algorithm: *least squares* means "smallest sum of squared residuals". For linear models there is a closed formula for the bottom, so nothing is actually tried; for other models later in the course the computer really does walk downhill.

### Slide 9 — The equation, piece by piece
- On slide: equation anatomy `ŷ = β₀ + β₁ · x` with four numbered parts: ŷ (the prediction, hat = "estimated"), β₀ (intercept: prediction when x is 0), β₁ (slope: change in prediction when x goes up by 1), x (the feature). Below, the fitted version: `sales = 7.03 + 0.0475 × TV` with its reading: "with no TV ads, about 7,000 units; every extra $1,000 on TV adds about 48 units".
- Script: Same thing in symbols. Greek letters are just names for the numbers the algorithm chooses. The hat means "our estimate", as opposed to the truth. Read the slope as "for every one-unit increase in x, the prediction changes by β₁".

### Slide 10 — More than one feature
- On slide: `ŷ = β₀ + β₁x₁ + β₂x₂ + … + βₚxₚ`; "one coefficient per feature; each one: change in the prediction when that feature rises by 1, with the others held fixed". Card: categorical features become 0/1 columns: `higher` = yes/no → `higheryes` (1 if yes). Card: "67 coefficients from 30 features in today's data, because every category except the reference gets its own 0/1 column."
- Script: Adding features adds terms. Nothing else changes: still squared residuals, still the bottom of a bowl, just a bowl in more dimensions. Text columns are turned into 0/1 columns automatically. "higheryes = 3.5" means: students who want higher education score 3.5 points higher, other things equal.

### Slide 11 — How good is the line? R²
- On slide: equation anatomy R² = 1 − RSS/TSS. Below, a picture that switches on click from the flat line with its residuals (TSS = 5,417) to line B with its residuals (RSS = 2,103), next to the arithmetic: 1 − 2,103/5,417 = 0.61.
- Script: Start from the dumbest model, predict the average for everyone; its squared residuals are the total variation to explain. Click: line B's squared residuals. Click: the share left over; one minus that is R².

### Slide 11b — How good is the line? RMSE
- On slide: equation anatomy RMSE = √mean(residual²), then the arithmetic for the advertising data: 2,103 / 200 = 10.5, √10.5 = 3.2 thousand units. "Students' grades run 0–20, so an RMSE of 3 means a typical prediction is about 3 points off."
- Script: RMSE undoes the squaring so the number is in the units of the outcome again.

### (The R² check moved to the warm-up as question 3.)

### Slide 13 — The same thing in code
- On slide: code anatomy `linear_reg() |> fit(final_grade ~ higher, data = students)` with four parts: `linear_reg()` (which kind of model: a linear one, nothing fitted yet), `fit()` (run the algorithm), `final_grade ~ higher` (the formula: outcome on the left of the tilde, features on the right), `data = students` (which table). Card: "the tilde `~` reads as 'explained by'"; card: "`~ .` means 'every other column'".
- Script: Two steps: say what kind of model you want, then fit it. `linear_reg()` on its own does nothing; it's an empty recipe. The formula is how R writes an equation: outcome, tilde, features. The dot is a shortcut for "everything else". We'll see why that's dangerous later.

### Slide 14 — Divider: "Part 1 · Exploring the data"

### Slide 15 — Meet the data
- On slide: 649 students, two Portuguese schools, outcome `final_grade` 0–20 (mean 11.9); bignums: 649 rows · 30 features · 1 outcome. Three groups of features: who they are (school, sex, age, address, family), how they study (studytime, failures, schoolsup, paid, higher, absences), how they live (goout, freetime, dalc, walc, health). Note: most features are text labels, e.g. `studytime` is `"<2hrs"`, `"2-5hrs"`, `"5-10hrs"`, `">10hrs"`.
- Script: Grades out of 20, Portuguese secondary school. Every row is a student. Features come in three flavours; glance at them now because you'll need to choose some for the EDA.

### Slide 16 — Exercises: Part 1 EDA (your turn, timer 8)
- On slide: tasks: 1 histogram of `final_grade`; 2 boxplot of `final_grade` by `higher`; 3 one plot of your own from the list in the notebook (study time, failures, school, going out, health, support); 4 one sentence: what seems to matter? Cheat: `ggplot(aes(x = final_grade)) + geom_histogram(bins = 20) + theme_histogram()`; `ggplot(aes(x = higher, y = final_grade)) + geom_boxplot() + theme_boxplot()`; `ggplot(aes(x = studytime, y = final_grade)) + geom_boxplot()`. Stuck: `theme_histogram` not found → run the setup chunk; empty plot → check the `+` at the end of each line.
- Script: Eight minutes. Pick from the list. Post one plot and one sentence in the channel; we'll look at two or three.

### Slide 17 — Part 1: what did we see?
- On slide: histogram of `final_grade` (left: peak at 10–14, a handful of zeros), boxplot by `higher` (right: yes ≈ 12, no ≈ 9). Cards: "Grades cluster between 10 and 14; a few students scored 0"; "Students who plan higher education score higher. How much higher, and could it be chance? That's the next part."
- Script: Take two findings from the room. Then the pivot: plots suggest, models measure.

### Slide 18 — Divider: "Part 2 · The hypothesis-testing approach"

### Slide 19 — Reading `summary()`
- On slide: code `linear_reg() |> fit(final_grade ~ higher, data = students) |> extract_fit_engine() |> summary()` with a note that the last two lines only pull out the underlying `lm` object so `summary()` can print it. Right: the coefficient table annotated: Estimate 3.48 ("yes-students score 3.48 points higher"), Std. Error 0.39 ("how uncertain that is"), t value = estimate / SE (8.96, "nine standard errors from zero"), Pr(>|t|) ("the p-value: if the true effect were zero, how surprising would this be? < 0.001: very"). Multiple R-squared 0.11.
- Script: This is the social scientist's question: is there an effect, and is it bigger than chance would produce? Estimate, uncertainty, p-value. Note R² of 0.11: significant is not the same as predictive. One feature explains 11% of the variation.

### Slide 20 — Controlling for everything: `~ .`
- On slide: `fit(final_grade ~ ., data = students)`; "the dot: every other column". Result cards: `higheryes` drops from 3.48 to 1.62 and stays significant; R² rises to 0.41; 67 coefficients; still-significant features: `failures` (−1.47 per failure), `schoolMS`, `schoolsupyes`, `higheryes`. Caveat card: p-values tell you which features matter for explanation; they are not a guarantee the model predicts well on new students. Note on p-hacking with the Data Colada link.
- Script: Add everything and the "higher" effect halves: part of it was study time and past failures travelling with the wish for higher education. Still there, still significant. Keep R² = 0.41 in mind; we'll see it again from a different angle.

### Slide 21 — Divider: "Part 3 · The machine learning approach"

### Slide 22 — Two questions, two approaches (then: A made-up model, in the notebook, lines 191–212: the R function at 192–195, type `sim_model_preds(10, 20, 30)` at line 201 → 154, and `150 - sim_model_preds(10, 20, 30)` at line 209 → −4; the same three words as the concept block: prediction, actual, residual)
- On slide: two cards side by side. Hypothesis testing: "Does *higher* matter? How sure are we?" → coefficients, standard errors, p-values, uses all the data. Machine learning: "How well can we predict a grade we haven't seen?" → predictions, error on new data, splits the data. Punchline: "Same model. Different question. Different workflow."
- Script: Same `linear_reg()`, same formula. The difference is what we look at and which rows we're allowed to use.

### Slide 23 — Why split? (question)
- On slide: "You revise with last year's exam paper. Then you sit… last year's paper again. Is your mark a fair measure of what you learned?" Flow: data → 75% training (fit the model here) / 25% test (score it here, never used for fitting). Card: a model scored on its own training data looks better than it is: it has memorised quirks of those rows. The gap between training and test performance is the first warning sign of **overfitting**.
- Script: Let them answer the exam question. The test set is a fresh exam. We lock it away, fit on the rest, and only open it to score the finished model.

### Slide 24 — The split, piece by piece
- On slide: code anatomy in three lines. `set.seed(123)`: the split is random; the seed makes the same random draw every time, so your numbers match mine. `students_split <- initial_split(students, prop = 0.75)`: `initial_split` decides which rows go where; `prop` is the share for training; the result is a "split object", not yet two tables. `students_train <- training(students_split)` / `students_test <- testing(students_split)`: pull out the two tables. 486 and 163 rows.
- Script: Three steps, three functions, all from `rsample` inside tidymodels. Students forget that `initial_split()` doesn't give you tables yet.

### Slide 25 — Fit and predict
- On slide: code anatomy. `mv_model <- linear_reg() |> fit(final_grade ~ ., data = students_train)`: same as before, only on the training rows, and saved. `mv_model |> augment(new_data = students_test)`: `augment` gives the table back with two new columns, shown in a mini table: `.pred` (the prediction) and `.resid` (actual − prediction).
- Script: `augment` is the one to remember: it's how you get predictions out of any tidymodels model, this week and every week after.

### Slide 25b — Evaluate
- On slide: code anatomy. `reg_metrics <- metric_set(rsq, rmse)`: bundle the two metrics into one function. `reg_metrics(truth = final_grade, estimate = .pred)`: which column is the truth, which the guess. Run it twice, once per set.
- Script: `metric_set` makes a function; `reg_metrics` then compares two columns of the augmented table. Hand over: "Part 3, 8 minutes. Deliverable: the two metric tables."

### Slide 26 — Part 3 together: what you should see (walkthrough, real output)
- On slide: `.walk` over notebook lines 218–256 as one pipeline: the split object, the fitted coefficients, the metric set, `augment()` on the test set showing `.pred` and `.resid`, then the test metrics.
- Script: after everyone has run the chunks, step through the output. Point at `.pred` and `.resid` in the augmented table before showing the metrics.

### Slide 28 — Part 3: training vs test
- On slide: bars: R² training 0.446 vs test 0.211; RMSE training 2.37 vs test 3.04. Cards: "On students it has seen, the model explains 45% of the variation. On new students, 21%. A typical prediction is 3 grade points off." Dark card: "67 coefficients fitted on 486 rows. Many of them are fitting noise. Could we keep only the useful ones?"
- Script: Ask: is this model good? Both answers are right: better than guessing the mean, but it flatters itself on the training set. This is the overfitting gap. The question on the dark card is the lasso's job.

### Slide 29 — Divider: "Part 4 · Where do we make errors?"

### Slide 30 — Residual plots: what good looks like
- On slide: left, the residual plot of simulated data with correlation 0.99 (a flat, narrow band around 0) with the card "a shapeless cloud around zero". On click, right: our model's residual plot on the test set (a wide band; a diagonal streak of points at the bottom left from the students who scored 0) with the card "wide, and with a pattern: any pattern is something the model missed".

### Slide 30b — The residual plot, piece by piece
- On slide: anatomy of the plot code: `augment(new_data = students_test) |> ggplot(aes(.pred, .resid)) + geom_hline(yintercept = 0, linetype = "dashed") + geom_point()`: x is the prediction, y the residual, the dashed line is "no error". Note: `augment()` first, the two columns only exist afterwards.
- Script: Residuals are what the model couldn't explain. If they still have a shape, there's structure left on the table: a curve, a missing variable, or, here, a group of students who scored 0 that no linear rule reaches. `mvrnorm` builds the simulated data; you don't need to understand it.

### Slide 31 — (Part 4 is coded together: no timer. The two residual-plot slides carry the notebook references, lines 268–324, and the action point at line 326 is asked from the anatomy slide.)

### Slide 32 — Divider: "Part 5 · Lasso: a penalty for every coefficient"

### Slide 33 — The problem with "everything"
- On slide: recap bars from slide 28; "67 coefficients, 486 rows. The model is free to use every coefficient, so it does, including the ones that only describe noise in the training set."  Question card: "How would you stop a model from using coefficients it doesn't need?"
- Script: Collect ideas. "Remove the insignificant ones" is a fine answer and the manual version. The lasso does it automatically, inside the algorithm.

### Slide 34 — Charge rent for every coefficient
- On slide: equation anatomy. OLS: minimise RSS. Lasso: minimise RSS + λ Σ|βⱼ|. Parts: RSS (fit the data, as before); λ (lambda, the price per unit of coefficient; the notebook calls it `penalty`); Σ|βⱼ| (the total size of all coefficients, signs ignored). Reading: "every coefficient now has to earn its place: it is only kept at a size where the improvement in fit is worth the rent".
- Script: Same bowl, plus a bill. A coefficient that barely helps the fit isn't worth paying for, so it shrinks. One that helps a lot stays large.

### Slide 35 — Turning the dial
- On slide: three panels for λ = 0, small, large: coefficient bars shrink; at λ = 0 it's OLS (67 non-zero); at 0.1 → 40 non-zero; at 1 → 2 non-zero; at "huge" → all zero, the model predicts the mean. Card: "Shrinking to *exactly* zero is the lasso's trick: it is feature selection built into the fitting."
- Script: Dial up λ and coefficients drop out one by one. Too little and you're back to overfitting; too much and the model knows nothing. Somewhere in between is a sweet spot.

### Slide 36 — Why exactly zero? (intuition)
- On slide: tug-of-war picture for one coefficient: the data pulls it away from zero with a force that gets weaker as the fit improves; the penalty pulls toward zero with a *constant* force λ, the same whether the coefficient is 2 or 0.02. "If the data's pull is weaker than λ, the coefficient is pinned at 0." Small card: the ridge penalty uses β² instead of |β|; its pull fades as β shrinks, so coefficients get tiny but never exactly zero. `mixture = 1` picks the lasso, `0` the ridge.
- Script: The absolute value is the secret. Its slope is the same size everywhere, so the push toward zero never lets up. A squared penalty goes gentle near zero and never finishes the job. You don't need the calculus; you need the picture.

### Slide 37 — Parameters and hyperparameters
- On slide: two cards. Parameters: the βs; chosen by the algorithm from the data; 67 of them. Hyperparameters: λ (`penalty`), `mixture`; chosen by *you* before fitting; the data cannot tell the model what λ to use because any λ > 0 makes the training fit worse. Card: "How to choose λ? Try several and score each on data the model hasn't seen. That's the bonus today and Lab 5 properly."
- Script: Lambda is a knob on the outside of the machine. The bonus turns the knob by hand; in Lab 5 we automate it.

### Slide 38 — Lasso in code
- On slide: code anatomy `linear_reg(penalty = 0.1, mixture = 1) |> set_engine("glmnet") |> fit(final_grade ~ ., data = students_train)`: `penalty` is λ; `mixture = 1` means pure lasso; `set_engine("glmnet")` says which package does the computing (the default engine, `lm`, cannot penalise); `fit` as before. Then `tidy(lasso_model) |> filter(estimate != 0)`: `tidy()` gives one row per coefficient; the filter keeps the survivors. And the bar plot anatomy: `abs(estimate)` for size, `fct_reorder(term, abs(estimate))` to sort the bars, `fill = estimate > 0` to colour by sign.
- Script: One new argument, one new line. Everything after `fit()` is identical to Part 3, so evaluating the lasso is copy and paste.

### Slide 39 — Exercises: Part 5 (your turn, timer 9)
- On slide: Step 1 (lines 336–341) was run together on the previous slide. Tasks with line numbers: 1 line 348, `tidy()` and filter non-zero: how many survived? which is biggest?; 2 line 356, the bar plot; 3 line 364, test-set metrics with `reg_metrics`, compare with Part 3; 4 line 376 (bonus), try other penalties by hand. Cheat: `tidy() |> filter(estimate != 0)`, the bar plot code, the evaluation lines from Part 3. Stuck: `fct_reorder` not found → run the setup chunk; bonus → copy Step 1 with a new penalty, then Step 4 again.
- Script: Nine minutes. The bonus is optional; the comparison in task 3 is not.

### Slide 40 — Solutions: Part 5 (walkthrough, real output)
- On slide: `.walk` fitting the lasso, `tidy()` filtered (40 rows), the bar plot, the test metrics.
- Script: step through; stop on the bar plot and read the top five.

### Slide 41 — Part 5: did the penalty help?
- On slide: bar plot of the 12 largest surviving coefficients (`higheryes` 1.81, `failures` −1.37, `schoolsupyes` −1.05, `feduNone` 1.01, `schoolMS` −0.97, …); test-set table: linear 67 coefficients, R² 0.211, RMSE 3.04 against lasso 40, 0.240, 2.95. Card: "A simpler model that predicts new students slightly better: that's regularisation."
- Script: Small gain in RMSE, big gain in simplicity. Twenty-seven coefficients gone and nothing lost.

### Slide 41b — Bonus: turning the dial by hand
- On slide: the real sweep plot, test RMSE by penalty for the notebook's grid (0.0001, 0.001, 0.01, 0.1) plus 0.3 and 1 in a second colour. Cards: the grid (0.1 is best at 2.95); two more past the grid (0.3 → 3.04 with 14 coefficients, 1 → 3.29 with 2); "that's tuning: turn the knob, score on unseen data, keep the best; Lab 5 automates it".
- Script: The curve has a bottom, like the RSS bowl, but this time on test data. That is what tuning a hyperparameter means.

### Slide 42 — Summary
- On slide: checks: 1 OLS picks the line with the smallest sum of squared residuals; coefficients are "change in prediction per unit of x". 2 Split first: fit on training, score on test; the gap is overfitting. 3 `linear_reg() |> fit()` · `augment()` · `metric_set(rsq, rmse)` is the workflow for every model from now on. 4 Lasso adds a price per coefficient; λ is a hyperparameter you set; useless coefficients go to exactly zero. Exit question: "Which of the 30 features would you have bet on before today? Did the lasso agree?"
- Script: Recap in four sentences. Collect answers to the exit question in the channel.

### Slide 43 — Further reading (closing)
- On slide: ISLR (James et al., *An Introduction to Statistical Learning*), chapter 3 (linear regression) and section 6.2 (lasso); *Tidy Modeling with R* chapters on `parsnip` and `yardstick`; tidymodels reference sheet. Dark card: Week 4 preview.
- Script: Completed notebook goes up after class. Preview next week.
