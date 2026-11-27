# MY202 · Lab 9 — Text as data: from words to predictions

Lesson plan and slide outline, based on the student workbook downloaded from Nuvolos on 25 November 2026: `W9/notebooksanddata/my202-09-lab-student.qmd` (388 lines; **all line numbers on the slides and in this plan refer to this file**). No solutions file was in the download. The workbook mixes given chunks (the whole quanteda pipeline, keyness, the bigram network, the recipe, the model, SHAP, the confusion matrix and F1) with four things students write: reading the data (lines 50–52), the token-count plot (156–164), the train/test split (239–243) and the importance bar chart (291–302). The solutions for those four are on the slides.

The notebook reads `data/NHS-reviews.csv`. The download also held the lecture demo (`my202-09-lecture-demo.R`, the same pipeline on ECB sentences); the deck does not use it. The whole folder is git-ignored. The render takes about 20 seconds; nothing is cached (the XGBoost fit takes about a second).

**Packages.** `quanteda`, `quanteda.textstats`, `quanteda.textplots`, `shapviz`, `ggraph` and `stopwords` were added from CRAN on the machine this deck was built on. **`textrecipes` was archived on CRAN on 25 November 2026** ("issues were not corrected in time"): `install.packages("textrecipes")` now fails. Version 1.2.0 was installed from the CRAN archive (it needs `tokenizers`); that route compiles code, so it fails on student machines without Rtools or Xcode. **For students, use the ready-built version from the tidymodels r-universe:** `install.packages("textrecipes", repos = c("https://tidymodels.r-universe.dev", "https://cloud.r-project.org"))`. Tested on 27 November 2026: it installs 1.2.0.9000 without compiling, and the notebook's recipe and model give the same 100 columns and test F1 of 0.82. `reticulate` is loaded by the workbook and never used; it was not installed here and the deck does not need it.

## Lesson plan

**Format:** 90-minute computer lab. Each part runs **concept** (a hand-sized example, built up click by click) → **code or run together** (the notebook chunk, with an anatomy slide for the lines that matter) → **your turn** (in pairs, a timer, then the answers on the notebook's own plots).

| Block | Concept | Together | Your turn |
|---|---|---|---|
| Text as data | Six café reviews: which are happy, and how did you know? | Setup (30–43) | |
| I · Text to a table | The café reviews in four steps: corpus, tokens, clean, count · what the table forgets | Read the data, typed together (46–52); corpus and tokens (65–113); the DFM (115–142) | **A** word cloud, with and without stopwords, and review length by label (144–164) |
| II · Which words? | Keyness by hand: where are the uses of "thank", against an even split? | The keyness plot and its discussion (166–185); the bigram network (187–224) | |
| III · Predict and explain | TF-IDF on one café review · SHAP as a start plus one push per word, on one real review | The split, typed together, and the recipe (226–256); the model and fit (258–287) | **B** importance chart, SHAP, confusion matrix, F1 (289–388) |
| Wrap-up | Summary and exit question | | |

**Running examples.**

- *The café* (Parts I and III). Six made-up reviews, three happy and three not. The deck runs quanteda on them: 6 documents, 12 words after cleaning; "coffee" is in 5 of the 6, "rude" in 2. The same reviews carry TF-IDF: in review 4 ("The coffee was cold and the staff were rude") each of the four words is a quarter of the review (TF 0.25); the IDF weights are 0.79 (coffee), 0.92 (staff) and 1.39 (cold, rude), so TF-IDF is 0.20, 0.23, 0.35 and 0.35. The formulas on the slide (`count ÷ words in the review`, `log(1 + reviews ÷ reviews with the word)`) are the ones `step_tfidf()` uses; the deck checks this.
- *"thank"* (Part II). Keyness on the lab data, by hand. After trimming, positive and negative reviews hold almost the same number of words (32,779 and 32,807), so a word unrelated to sentiment would split half and half. "thank" splits 319 to 10; "told" 72 to 468; "surgery" 517 to 525.
- *One real review* (Part III). "Friendly, approachable, they listen instead of assuming, the only down side, it is really hard to get an appointment," (training set, labelled positive). Start: 38% of training reviews are negative. Pushes: friendly −1.64, get +1.22, really −0.33, appointment +0.11, the 96 absent words together −0.52. Prediction: 16% negative.

Every claim the slides make about these examples and about the lab data is checked with `stopifnot()` in the deck's setup (the feature counts, the even split, that the SHAP values plus the start reproduce the workflow's predictions, the example review's four words, the direction of "thank" and "told", training F1 above test F1), so a changed file, seed or package fails the render instead of showing a wrong reading.

**Learning objectives.** The notebook lists three (lines 12–18). By the end, students can:

1. Say why text needs to be turned into columns, and what a bag of words keeps and loses (slides 3, 5–6)
2. Build a corpus, tokens and a document-feature matrix with quanteda, and explain each cleaning choice (slides 5, 8–9, 11)
3. Read a word cloud, a keyness plot and a bigram network, and say what each can and cannot show (slides 11, 14–16)
4. Explain TF-IDF and why it belongs inside the recipe (slides 18–19)
5. Fit boosted trees on text features with a tidymodels workflow (slides 19–20)
6. Read a SHAP value: a push on one prediction, with a direction (slides 21–22, 24)
7. Evaluate with a confusion matrix and F1, and recognise overfitting from the training/testing gap (slide 25)

**Before class**

- Check on Nuvolos that the Week 9 workspace has the workbook and `data/NHS-reviews.csv`, and that the library chunk (lines 30–43) runs. **Six packages are new this week** (`quanteda`, `quanteda.textstats`, `quanteda.textplots`, `textrecipes`, `shapviz`, `ggraph`), and `textrecipes` can no longer be installed from CRAN: it has to be in the image already.
- Run the SHAP chunk (lines 306–331) once on Nuvolos and compare its plot with slide 24. See the first item under "Fix before release".
- Nothing is slow.
- Render once (`quarto render W9/slides/W9-lab-slides.qmd` from `MY202/`).

**Timing**

| Time | Block | Mode | Notebook lines |
|---|---|---|---|
| 0:00–0:03 | Welcome, overview, run the library chunk | Whole class | 30–43 |
| 0:03–0:06 | **Can a model read?** | Concept | |
| 0:06–0:13 | **Text to a table.** The café in four steps (5) · what the table forgets (2) | Concept | |
| 0:13–0:25 | **Together.** Read the data (4) · corpus and tokens (4) · the DFM (4) | Code, then run | 46–142 |
| 0:25–0:38 | **Your turn A** (8-minute timer) · the word clouds (2) · who writes more (3) | Pairs | 144–164 |
| 0:38–0:50 | **Which words?** Keyness by hand (4) · the keyness plot and discussion (4) · the bigram network (4) | Concept, then run | 166–224 |
| 0:50–1:02 | **Predict.** TF-IDF (4) · split and recipe (5) · model and fit (3) | Concept, then code | 226–287 |
| 1:02–1:08 | **Explain.** SHAP for one review (4) · MCQ (1½) | Concept | 304–335 |
| 1:08–1:25 | **Your turn B** (9-minute timer) · which words matter (4) · how good is it (4) | Pairs | 289–388 |
| 1:25–1:29 | **Wrap-up.** Summary and exit question (3) · feedback (1) | Whole class | |

**Will it fit?** 89 minutes planned, 1 spare. Checkpoints: data loaded by 0:13, your turn A started by 0:25, Part II by 0:38, Part III by 0:50, your turn B by 1:08. **If behind, skip in this order:** (1) the SHAP MCQ, 1½ minutes; (2) "what the table forgets", 2 (say its first card on the café slide); (3) the discussion of the bigram network, 2 (run it, name the two hubs); (4) shorten your turn A from 8 to 6. That recovers 7½ minutes. The café slide and the one-review SHAP slide carry the two intuitions and should not be cut. **If ahead**, use the fast-finisher tasks; do not add content.

**For fast finishers:** `topfeatures(nhs_dfm, 20)`; `kwic(nhs_tokens, "told", window = 3)` to see a word in context; `nhs_fit |> augment(new_data = nhs_test) |> filter(.pred_class != positive)` to read the reviews the model gets wrong; add `max_tokens = 1000` to `step_tokenfilter()` and refit.

**Fix before release** (the workbook of 25 November)

- **The SHAP chunk (lines 306–331) explains a different model from the one that was fitted.** `step_tfidf()` produces sparse columns and the workflow hands XGBoost a sparse matrix, in which a word that is absent counts as *missing*. The chunk then bakes a dense matrix (`composition = "matrix"`), in which the same cells are 0, and passes it to `shapviz()` as `X_pred`. XGBoost sends 0 and missing down different branches. On the machine this deck was built on (R 4.6.1, xgboost 3.2.1, parsnip 1.6.1, textrecipes 1.2.0, shapviz 0.10.4) the booster is 97% accurate on the training reviews through the workflow and 66% on the dense matrix; the notebook's SHAP plot ranks "thank, friendly, face, called, feel" and shows large pushes for words that are *not* in a review, and its values do not add up to the model's predictions. With the sparse input the ranking is "thank, get, helpful, told, friendly", the same five words as the importance plot. The lecture demo has the same construction. Fix, two lines:

  ```r
  nhs_sparse <- nhs_fit |> extract_recipe() |>
    bake(new_data = nhs_train, all_predictors(), composition = "dgCMatrix")
  shap <- shapviz(nhs_fit_extracted, X_pred = xgboost::xgb.DMatrix(nhs_sparse),
                  X = as.data.frame(nhs_matrix))
  ```

  Slides 21, 22 and 24 use the corrected values, and the deck checks that they reproduce the workflow's predictions. Whether Nuvolos shows the same problem depends on its package versions: compare before class. If the workbook is not changed, students' SHAP plot will differ from slide 24; the note on slide 23 says so.
- **The recipe keeps 100 words, not about 1,000.** `step_tokenfilter(min_times = 10)` also has `max_tokens`, whose default is 100. The text at lines 260–262 reasons from "about 1,000 features" to `mtry = 0.03`; with 100 features that is 3 words on offer per split. With `max_tokens = 1000` the recipe gives 993 features and the test F1 rises from 0.82 to 0.85 (training 0.98). Either add the argument, as the lecture demo does, or change the text. Slides 19 and 20 say what the code does.
- **SHAP values and F1 are both about "Negative".** R sorts the factor levels alphabetically, so "Negative" is the first level: XGBoost models it (a positive SHAP value pushes towards a negative review) and `f_meas()` scores it. The section heading says "identify positive reviews". Slides 21, 22 and 25 say which way round it is. For "Positive" the test F1 is 0.89.
- **No seed** before the split (the chunk is empty) or before `fit()`. Students' numbers will differ from each other and from the slides. The deck uses `set.seed(123)` for both and a 75% stratified split.
- **Line 54 prints the number of columns**: "a data set of `r ncol(nhs_reviews)` reviews" gives 6. It means `nrow()`: 1,986.
- **"All of them are on the CRAN"** (line 26) is no longer true for `textrecipes`.
- **The title says "Student Solutions"** (line 2); the date is 24 November 2025.
- `dfm_trim(min_termfreq = 12)` in the chunk (line 123) against "the minimum term frequency to 10" in the text (line 142) and in the one-chunk version (line 138). 12 gives 1,033 features, 10 gives 1,173.
- `drop_na(review_positive)` (line 48) drops nothing: no label is missing.
- `reticulate` is loaded (line 37) and not used.
- Three-star reviews are labelled positive (88 of them). Worth a sentence in the data description: several of the model's errors are these.

**Consistency check of the deck against the notebook:** every line reference on the slides points at the right lines of the workbook. Every chunk is on a slide: libraries (2), read the data (7), corpus and docvars (8), tokens (8), DFM and the one-chunk pipeline (9), word cloud (10–11), token counts (10, 12), keyness (15), bigram network (16), model data, split and recipe (19), model and fit (20), importance (23–24), SHAP (22–24), confusion matrix and F1 (23, 25). All four discussion prompts are on a slide: what leads to positive or negative reviews (15), the largest clusters in the network (16), which features are most important (23–24), how well the model performs and another model (23, 25). The notes at lines 113, 144, 218 and 333 are covered on slides 6, 10–11, 16 and 24. The plots of lab data are drawn with the notebook's code; the changes are text sizes for the room, 70 words in the clouds and 10 per side in the keyness plot so that labels can be read, a fixed layout seed for the network, and the corrected SHAP input. Terms match the notebook: corpus, tokens, stopwords, document-feature matrix (DFM), keyness, bigram, TF-IDF, variable importance, Shapley values (SHAP), F1-score.

**Key numbers** (seed 123 for the split and the fit)

*The data.* 1,986 reviews: 754 negative (1 star 611, 2 stars 143), 1,232 positive (3 stars 88, 4 stars 166, 5 stars 978).

*Text to a table.* 182,450 tokens; 164,897 without punctuation, symbols and numbers; 80,209 without the 175 stopwords. 7,560 distinct words, 3,918 of them used once; 1,033 used at least 12 times (sparsity 97%). Most used: appointment 1,199, surgery 1,042, get 916, practice 880, staff 761. With stopwords left in: the 7,331, to 6,798, and 5,750. Median tokens per review: 44 negative, 25 positive.

*Keyness* (chi-squared, target = positive reviews)

| Word | In positive | In negative | Keyness |
|---|---|---|---|
| thank | 319 | 10 | 292 |
| helpful | 326 | 41 | 223 |
| friendly | 234 | 10 | 207 |
| surgery | 517 | 525 | −0.1 |
| appointment | 437 | 762 | −90 |
| get | 218 | 698 | −255 |
| told | 72 | 468 | −292 |

*Bigrams.* get appointment 185, reception staff 156, call back 120, face face 111 ("face to face"), blood test 89.

*The model.* 1,489 training and 497 test reviews; 100 TF-IDF features. Importance, top five: get, thank, told, helpful, friendly. Mean absolute SHAP, top five: thank 0.47, get 0.45, helpful 0.34, told 0.29, friendly 0.24. Test confusion matrix: 157 negative and 272 positive correct, 32 negative reviews called positive, 36 positive called negative (68 wrong, 86% accurate). F1 for "Negative": 0.96 training, 0.82 testing. A lasso logistic regression on the same recipe (penalty 0.01, not tuned): 0.80.

---

## Slides

28 slides. Every slide was checked at 16:9 (1200 × 675) in headless Chrome with all fragments revealed: content stays above the footer. The click sequences of slides 3, 5, 6, 7, 8, 14, 18 and 21 were also checked step by step. The deck's rule: a slide never shows an answer before the room has been asked for it; the question comes first, the answer arrives on a click, and the explanation after that. The script is in the speaker notes (press `S`). The tracker bar reads: Text as data · I Text to table · II Which words? · III Predict, explain · Wrap-up.

- **1 Title · 2 Lab overview**: parts, notebook lines, minutes; run the library chunk.
- **3 Can a model read?**: six café reviews without labels; click: the labels; click: the telling words are boxed; click: "coffee" is boxed; click: one column per word.
- **4 Divider · 5 From six reviews to a table, in four steps**: corpus, tokens, clean, count, on the café reviews; three clicks.
- **6 What the table forgets**: a seventh review, "Not friendly at all", and an empty row to fill in; click: three tokens struck out, a single 1 under "friendly"; order is lost; cleaning is a choice (113).
- **7 The data: reviews of GP practices** (46–63): anatomy of the three lines, typed together; the star ratings in grey, then coloured by label on the click.
- **8 Corpus, then tokens** (65–113): anatomy of `corpus()` and `tokens()`; one real review cut into tokens, the dropped ones struck out on the click.
- **9 The document-feature matrix** (115–142): `dfm()` and `dfm_trim()`; 7,560 columns to 1,033.
- **10 Your turn A** (144–164, 8 min) · **11 Answers: the word cloud**, with and without stopwords · **12 Answers: who writes more?**
- **13 Divider · 14 Keyness: is a word where you would expect it?**: "thank" against an even split, then nine words, then the statistic; three clicks.
- **15 The keyness plot** (166–185): positive reviews are about people, negative ones about access.
- **16 Pairs of words: the bigram network** (187–224): the two hubs; why "face → face".
- **17 Divider · 18 From counts to TF-IDF**: TF, IDF and their product for one café review; why it goes inside the recipe (226).
- **19 Split first, then the recipe** (226–256): the split typed together; the recipe's steps against Part I's functions; 100 columns.
- **20 The model: boosted trees, again** (258–287): anatomy of `boost_tree()`; what `mtry = 0.03` means here.
- **21 What did the model learn? One review**: the review and a question first; then a start, a push per word (each word is boxed as its push appears), a prediction; four clicks.
- **22 Class discussion: read one SHAP value** (304–335): MCQ.
- **23 Your turn B** (289–388, 9 min) · **24 Answers: which words matter?** importance and SHAP side by side · **25 Answers: how good is it?** confusion matrix, F1, another model.
- **26 Summary** with exit question · **27 Further reading** · **28 Feedback**.
