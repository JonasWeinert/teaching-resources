# MY202 · Lab 7 — Fewer dimensions: PCA and MCA

Lesson plan and slide outline, based on the notebooks of 12 November 2026: the student workbook `W7/notebooksanddata/my202-07-lab-student.qmd` (292 lines; **all line numbers on the slides and in this plan refer to this file**) and the solutions `my202-07-lab-completed.qmd` (325 lines; the same code with the answers to the reflection questions). Every chunk in the workbook is ready to run: there is nothing to type and nothing to fill in. What students do is run, look and answer the notebook's reflection questions, so the deck's "your turn" blocks are those questions, with a sheet on how to read the output in place of a syntax sheet.

Part I uses `holzinger.swineford` from `psychTools` (no file). Part II reads `data/wvs-wave-7-ethical-norms.csv`, so the CSV sits in `W7/notebooksanddata/data/`. The two synthetic surveys in the folder (`attitudes_survey.csv`, `media_civic_survey.csv`) are the lecture's; the lab does not use them. The whole folder is git-ignored, so only a machine with the data can re-render the deck. The render takes about 30 seconds; nothing is cached.

Last year's DS202 Week 7 lab (`DS202 Winter/week7ds202.pptx`, 25 slides) had three 10-minute intuition blocks around the lab: why reduce dimensions (customers on an income line, then income and debt; distances losing meaning; overfitting on noise), PCA and MCA (rotations, a loadings table read as "financial strength", one slide for MCA) and autoencoders. This deck keeps the first block's income-and-debt picture in one slide, replaces the PCA table with a picture that is built up click by click, gives MCA its own worked example, and drops autoencoders: the notebook does not cover them, and they cost 10 minutes last year.

## Lesson plan

**Format:** 90-minute computer lab. Each part runs **concept** (a hand-sized everyday example) → **run together** (the notebook chunk, with an anatomy slide for the one line that matters) → **your turn** (reflection questions in pairs, a timer, then the answers on the notebook's own plots).

| Block | Concept | Run together | Your turn |
|---|---|---|---|
| Why | Income, then income and debt; farthest ÷ nearest neighbour as variables are added | Setup (25–36); the callout (38–53) | |
| I · PCA | The school report: two marks, one number; four subjects and their loadings | Data and split (68–80); heatmap (82–97); the recipe (99–118) | **A** variance and the PC1–PC2 scatter (120–174) · **B** loadings (176–214) |
| II · MCA | Why not PCA (230–233); what do you watch: a map of answers | Median split (235–252); `MCA()` and the supplementary variable (254–263) | **C** biplot and contributions (265–291) |
| Wrap-up | PCA or MCA: the same story twice | | |

**Running examples.**

- *The school report* (Part I). Forty made-up pupils with a maths and a physics mark (correlation about 0.9). Four clicks: the cloud; the direction with the most spread; each pupil's shadow on that line; the page turned so that line lies flat. PC1 holds 94% of the spread, PC2 6%. Then 200 made-up pupils with four subjects, built from an overall level and a lean towards sciences or humanities: PC1 has four equal positive loadings (62%), PC2 sets maths and physics against English and history (31%). The loadings are drawn in the notebook's own style (blue positive, red negative), so the slide teaches the plot students read in exercise B. It mirrors what the lab finds: PC1 a level, PC2 a contrast.
- *What do you watch?* (Part II). Twelve made-up people, four yes/no questions (football, F1, Bake Off, Strictly). MCA on that table gives a map of eight answers: `football_y` by `f1_y`, `bakeoff_y` by `strictly_y`, each `_y` opposite its own `_n`; Dim 1 (60%) is sport against shows. Three rules for the biplot come out of it: close means the same people, y faces n, name an axis by its ends.

Both tables are checked with `stopifnot()` in the deck's setup, as are the signs the answer slides rely on, so a changed seed or table fails the render instead of showing a wrong reading.

**Learning objectives** (the notebook's six, lines 14–21). By the end, students can:

1. Explain why we reduce dimensions (slide 3)
2. Apply PCA to continuous data and decide how many components to keep (slides 10–12)
3. Interpret PCA loadings and component plots (slides 5–6, 13–15)
4. Apply MCA to categorical data (slides 17–20)
5. Interpret an MCA biplot and the contributions of categories to each dimension (slides 18, 21–23)
6. Compare the two methods and say when each one is appropriate (slide 24)

**Before class**

- Check on Nuvolos that the Week 7 workspace has the student workbook and `data/wvs-wave-7-ethical-norms.csv`, and that the setup chunk (lines 25–36) runs. **`factoextra` and `FactoMineR` are new this week**; `factoextra` was not installed on the machine this deck was built on.
- Nothing is slow: the PCA is instant, and `MCA()` on 94,278 rows takes about 2 seconds on a laptop. The biplot takes a second or two more because of the label placement.
- Render once (`quarto render W7/slides/W7-lab-slides.qmd` from `MY202/`).

**Timing**

| Time | Block | Mode | Notebook lines |
|---|---|---|---|
| 0:00–0:03 | Welcome, overview, run the setup chunk | Whole class | 25–36 |
| 0:03–0:07 | **Why fewer dimensions** | Concept | 38–53 |
| 0:07–0:16 | **PCA concept.** The school report (4) · four subjects (3) · class discussion MCQ (1½) | Concept | 66 |
| 0:16–0:26 | **Run together.** Data and split (2) · heatmap and reflection (4) · the recipe (4) | Together | 68–118 |
| 0:26–0:39 | **Your turn A.** Variance and the scatter (8-minute timer) · answers (3 + 2) | Pairs | 120–174 |
| 0:39–0:48 | **Your turn B.** Loadings (5-minute timer) · answers (4) | Pairs | 176–214 |
| 0:48–0:55 | **MCA concept.** Why not PCA (2) · what do you watch (5) | Concept | 230–233 |
| 0:55–1:01 | **Run together.** Median split (3) · `MCA()` and the supplementary variable (2½) | Together | 235–263 |
| 1:01–1:14 | **Your turn C.** Biplot and contributions (7-minute timer) · answers (4 + 2) | Pairs | 265–291 |
| 1:14–1:20 | **Wrap-up.** PCA or MCA (3) · summary and exit question (3) | Whole class | |
| 1:20–1:30 | Feedback form (1) and **9 minutes spare** | | |

**Will it fit?** 80 minutes planned (81 in the table, which rounds two half minutes up), so 9 to 10 spare. That is three times Lab 5's margin, on purpose: the notebook runs in seconds, so the only way to lose time is talking, and the three reflection debriefs are where that happens. Checkpoints: data loaded by 0:18, your turn A started by 0:27, Part II started by 0:50, your turn C started by 1:03. **If behind, skip in this order:** (1) the class-discussion MCQ, 1½ minutes; (2) the last click on "the first two components" (colour by school), 1; (3) the slide "who builds Dim 1?", 2 (say its dark card on the biplot instead); (4) shorten your turn A from 8 to 6. That recovers 6½ minutes on top of the spare 9. The school report, the four-subjects loadings and the TV map carry the intuitions and should not be cut. **If ahead**, use the fast-finisher tasks below; do not add content.

**For fast finishers:** `colour = school` in the PC1–PC2 scatter; the same scatter for PC3 against PC4; `cor(pca_data$PC1, pca_data$PC2)`; `fviz_contrib()` with `axes = 2`; `fviz_screeplot(mca)`; rerun the MCA after setting the negative codes to `NA` and dropping those rows (see below).

**Fix before release** (the notebooks of 12 November)

*Both notebooks*

- **Missing-value codes are treated as answers.** The WVS file contains −1 (don't know), −2 (no answer) and −5 (missing): 3.5% of all cells. `if_else(.x > median(.x), "y", "n")` turns them into "n". Either filter them out first (`filter(if_all(everything(), ~ .x > 0))`) or say so in the text.
- **"Original responses are 0–10" and "support vs oppose"** (line 228): the scale is 1 (never justifiable) to 10 (always). For 12 of the 19 questions the median is 1, so "y" means "anything but never", not "support". Slide 19 says this; the notebook should too, since the biplot's labels invite the reading "supports terrorism".
- The setup chunk loads `corrplot` and `patchwork`, which no chunk uses.
- `test_data` is created (line 79) and never used. One sentence on why the split is there would help; slide 8 gives one.

*Solutions* (`my202-07-lab-completed.qmd`)

- **The PC2 and PC3 answers name the wrong tests** (lines 226–228). With the notebook's seed, PC2 sets the verbal tests (`t05`–`t09`, loadings 0.18 to 0.30) against `t17`, `t10`, `t15`, `t18`, `t11`, `t12` (−0.37 to −0.25): memory and speed. The solutions list `t02`, `t19` and `t20` on the non-verbal end, but their loadings are +0.09, −0.12 and +0.05. PC3 sets `t15`, `t04`, `t02`, `t16`, `t14` (0.24 to 0.33) against `t10`, `t12`, `t11` (−0.40 to −0.26); the solutions' "reasoning tests `t22`, `t23`" load 0.05 and 0.11. Slide 15 follows the plot.
- **The Dim 2 answer is half right** (line 305). The top of Dim 2 is not only the restrictive answers on private morality: `violence_against_spouse_y` (0.79) and `terrorism_y` (0.76) are the highest points on it, above `sex_before_marriage_n` (0.65). Read across the right-hand side, Dim 2 separates the y-answers by kind: harm and dishonesty at the top, private life at the bottom. Slide 22 reads it that way.
- **"Colored by school"** (line 167): the subtitle says so, but the plot has no colour aesthetic. Slide 13 shows the coloured version on its last click.
- The Part II heading still carries "(20 mins)".

**Consistency check of the deck against the notebook:** every line reference on the slides points at the right lines of the student workbook. Every code chunk in the workbook is on a slide: setup (2), data and split (8), heatmap (9), recipe and `bake()` (10), the two variance plots (11–12), the scatter (11, 13), loadings (14–15), the median split (19), `MCA()` (20), biplot and contributions (21–23). The plots of lab data are drawn with the notebook's code; the only changes are text sizes for the room, and the colour by school on slide 13's last click. Terms match the notebook: principal component, loadings, variance explained, cumulative variance, supplementary variable, biplot, contribution, dimension.

**Key numbers** (seed 12345, as in the notebook)

*Holzinger–Swineford.* 301 pupils, 24 tests after dropping `t25` and `t26`; 240 training (116 Grant-White, 124 Pasteur), 61 test. Mean correlation between tests 0.26, lowest −0.10; 0.68 among the five verbal tests.

| Component | Variance | Cumulative |
|---|---|---|
| PC1 | 30.7% | 30.7% |
| PC2 | 9.8% | 40.5% |
| PC3 | 7.6% | 48.1% |
| PC4 | 7.1% | 55.2% |
| PC5 | 4.3% | 59.6% |

PC1 loadings all positive, 0.09 (`t15`) to 0.28 (`t09`). School means: Grant-White +0.56 on PC1 and +0.54 on PC2, Pasteur −0.53 and −0.50.

*World Values Survey.* 94,278 respondents, 19 questions. Share "y" after the median split: from 23% (terrorism) and 25% (violence against a spouse) to 49% (sex before marriage, euthanasia, cheating on benefits). Dim 1 37.0%, Dim 2 16.0%, Dim 3 6.1%. Top contributors to Dim 1: `stealing_property_y` 5.3%, `political_violence_y` 5.2%, `social_violence_y` 5.1%, `terrorism_y` 5.1%, `accept_bribes_y` 5.0%, `suicide_y` 4.7%, `cheating_taxes_y` 4.4%, `violence_against_spouse_y` 4.2%; an equal share would be 2.8% (36 categories). The supplementary `cheating_benefits_y` lands at (0.49, 0.27).

*Concept examples.* The curse plot uses 200 uniform random points per number of variables (`set.seed(1)`): the median ratio of farthest to nearest neighbour is 32 with 2 variables and 1.1 with 1,000.

---

## Slides

27 slides. Every slide was checked at 16:9 (1200 × 675) with all fragments revealed: content stays above the footer. The script is in the speaker notes (press `S`). The tracker bar reads: Why · I PCA · II MCA · Wrap-up.

- **1 Title · 2 Lab overview**: parts, notebook lines, minutes; run the setup chunk.
- **3 Why fewer dimensions?** (38–53): customers on an income line, then income and debt, then the farthest ÷ nearest ratio; sparse, distances, overfitting.
- **4 Divider · 5 The school report**: four clicks from a cloud to one number per pupil.
- **6 Four subjects: reading the loadings**: a level and a contrast; the three questions to ask of any component.
- **7 Class discussion** (66): MCQ on two correlated tests.
- **8 Meet the data** (68–80) · **9 Explore: do the tests overlap?** (82–97): heatmap, two predictions for the components.
- **10 Apply PCA: read the recipe** (99–118): anatomy of `step_normalize()`, `step_pca()`, `num_comp`, `prep()`.
- **11 Your turn A** (120–174, 8 min) · **12 Answers: variance explained** · **13 Answers: the first two components**.
- **14 Your turn B** (176–214, 5 min) · **15 Answers: naming the components**.
- **16 Divider · 17 Why not PCA?** (230–233) · **18 What do you watch?**: the table, the map, the reading rules.
- **19 Load the data** (235–252): the median split and what "y" means · **20 Apply MCA** (254–263): the call and the supplementary variable.
- **21 Your turn C** (265–291, 7 min) · **22 Answers: the biplot** · **23 Answers: who builds Dim 1?**
- **24 PCA or MCA?** · **25 Summary** with exit question · **26 Further reading** · **27 Feedback**.
