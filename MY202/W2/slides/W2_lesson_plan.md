# MY202 · Lab 2 — Data visualisation: building plots with ggplot

Lesson plan, slide outline and speaker script, based on `W2/notebooksanddata/my202-02-lab-student.qmd` (229 lines; all slide line numbers refer to this file) and `my202-02-lab-completed.qmd` (dated 29 September 2026).

## Lesson plan

**Format:** 90-minute computer lab. ggplot is new this week (Lab 1 only mentioned it). The notebook's Part 2.0 (themes) is fully written out, so it is run **together** and taken apart on the slides. The six design exercises (2.1–2.6) have empty `# Code here` chunks, so they are **your turn**, in three rounds of two, each with a timer, an annotated syntax sheet and a step-by-step solution walkthrough. Concepts the notebook doesn't explain but the solutions rely on get a slide next to their exercise: bins, overplotting and jitter, "what is one row?", reading a box plot, `as.factor()` for a numeric group.

**Learning objectives.** By the end, students can:

1. Build a plot from data, aesthetics and a geom, joined with `+`, and say what goes inside `aes()` (columns) and what outside (fixed settings)
2. Choose a chart from the question: histogram, bar chart, scatter plot, line plot, box plot, density plot
3. Change a plot's look with `theme()`, save it as a theme function, and start from a ready-made theme
4. Write a caption that states the finding, not the chart type
5. Spot and fix common traps: bin width, overplotting, counting the wrong unit, a numeric group variable, colours that colour-blind readers can't tell apart

**Before class**

- The lab runs on Nuvolos. Check that the Week 2 workspace has `ggsci`, `ggthemes`, `psychTools`, `psymetadata` and `tidyverse`; `ggthemes` and `psychTools` are new this week. Both data sets ship inside packages, so there are no data files.
- The deck's solution slides run the real code, so rendering needs those packages plus `patchwork`, `scales` and `colorspace`.

**Timing**

| Time | Block | Mode | Notebook lines |
|---|---|---|---|
| 0:00–0:08 | Overview, run the library and `hs_data` chunks; two warm-up questions (which chart; which caption); meet the data | Whole class | 16–23, 29–38 |
| 0:08–0:22 | **Part 2.0.** Three parts of a ggplot (3) · a plot one layer at a time (3) · `theme()` and `my_theme()` (3) · four looks (2) · the caption (1) · which chart for which question (2) | Together | 52, 58–122, 133 |
| 0:22–0:37 | **Round 1: 2.1–2.2.** Your turn (10-minute timer) · solutions (3) · bins are a design choice (1) | Your turn | 130–152 |
| 0:37–0:55 | **Round 2: 2.3–2.4.** Your turn (12) · scatter solution (2) · overplotting (1) · line solution (1) · what is one row? (2) | Your turn | 160–182 |
| 0:55–1:11 | **Round 3: 2.5–2.6.** Reading a box plot (3) · your turn (9) · solutions (4) | Concept, then your turn | 191–213 |
| 1:11–1:20 | **Design.** Five principles (2) · colour for everyone (2) · makeover (1) · peer critique in pairs (4-minute timer) | Together, then pairs | 215–229 |
| 1:20–1:25 | Summary, exit question, further reading, feedback QR | Whole class | |
| 1:25–1:30 | Spare | | |

**Will it fit?** 85 minutes planned, 5 spare. Checkpoints: Part 2.0 by 0:08, round 1 by 0:22, round 2 by 0:37, round 3 by 0:55, design by 1:11, wrap-up by 1:20. **If behind, skip in this order:** (1) warm-up 1, 1 minute; (2) "Four looks, same plot", say it in one sentence, 1 minute; (3) shorten the round 3 timer from 9 to 7; (4) take the makeover at speed. The peer critique can become homework.

The notebook's own timings (setup 10, Part 2 70) add up to 80.

**For fast finishers:** try `bins = 5` and `bins = 60` in 2.1; redo 2.2 with `geom_bar()` and no `count()`; add `shape = school` to 2.3 and a colour-blind safe palette (`scale_colour_viridis_d()`); redo 2.4 with `geom_area()`; in 2.5 add `fill = as.factor(grade)` so `scale_fill_bmj()` does something; overlay the points on the box plots with `geom_jitter(width = 0.1, alpha = 0.3)`.

**Fix before release** (found while reading the notebooks and running the code)

- **2.5 task says "histogram"** (student line 191, completed line 248): "Use a histogram to plot the distribution of `t16_figrrecg` by `grade`." The section is about box plots, and the solution draws one. The deck and guide point this out.
- **ggpomological link** (student line 122, completed line 120) points to the tvthemes repository. The right URL is https://github.com/gadenbuie/ggpomological.
- **2.4 counts results, not studies** (completed lines 222, 237): `count(year)` counts rows of `nuijten2020`, and one row is one effect size: 2,443 rows from 1,917 studies. The y label "Number of Studies" and the caption should say "results" (or effect sizes), or the code should count distinct studies.
- **2.4 drop after 2008:** the meta-analyses were done by about 2014, so recent studies are missing. Worth one sentence in the notebook, or students read it as a decline in research. Line 171 also calls the data "longitudinal"; it isn't (each row is a different study).
- **2.5 solution has dead lines** (completed lines 259–262): `scale_fill_bmj()` and `alpha = 0.75` do nothing, because nothing is mapped to `fill`. Add `fill = as.factor(grade)` inside `aes()` or remove both.
- **Captions overclaim:** Figure 1 says cube scores are "normally distributed" (roughly bell-shaped, with a right tail; skewness 0.47); Figure 6 says "There are no differences" (means 2.08 vs 1.96). The deck uses "Most students score between 5 and 7" and "almost the same".
- **`as_tibble()` repeated** in every Holzinger solution (completed lines 142, 175, 200, 258, 282): `hs_data` is already a tibble. Harmless; the slides leave it out and the notes say so.
- **Figure 3 uses `geom_jitter()`** without a word of explanation, and it's random: the plot changes on every run. Add `set.seed()` or a note.
- **`female` coding** (1 = male, 2 = female) is only in the help page. The 2.6 solution gets it right; say it in the notebook next to the task, since students will guess 0/1.
- The completed notebook's caption for Figure 2 reads "(slightly) more students from Pasteur": 156 against 145. Fine; the slide gives the numbers.

**Consistency check of the deck against the notebooks** (27 October): every line reference on the slides points at the right line of the student notebook. Every solution walkthrough uses the completed notebook's code, except: `as_tibble()` is left out after `hs_data` (explained in the notes), the 2.4 y label stays as in the solution on the solution slide but the next slide says it should read "results", and plots are drawn at base size 14 for the projector. The guide's 2.5 plot adds `fill = as.factor(grade)` so the BMJ colours show, and its 2.4 plot uses the corrected y label; both are explained next to the plot.

**Key numbers**

Holzinger-Swineford: 301 children; Pasteur 156, Grant-White 145; grade 7 157, grade 8 144; `female` 1 (male) 146, 2 (female) 155; 26 tests; missing values only in `t25_frmbord2` and `t26_flags` (156 each, not used).

- 2.1: `t02_cubes` takes 25 values (quarter points), median 6.0, 72% between 5 and 7.
- 2.3: correlation of `t01_visperc` and `t03_frmbord` 0.37 (0.37 Grant-White, 0.36 Pasteur); the 301 children share 177 positions.
- 2.5: `t16_figrrecg` medians 6.57 (grade 7) and 6.86 (grade 8); one grade 7 child scored 0.29.
- 2.6: `t23_series` means 2.08 (male) and 1.96 (female).

`nuijten2020`: 2,443 effect sizes from 1,917 studies in 131 meta-analyses; years 1915–2013; peak 2005 (126 rows); 2009 72, 2011 52, 2012 25, 2013 4.

---

## Slides and script

39 slides. Every slide was checked at 16:9 with all fragments revealed: content stays above the footer. The full script is in the speaker notes (press `S`). The tracker bar reads: Warm-up · 1 Setup · 2.0 ggplot · 2.1–2.2 · 2.3–2.4 · 2.5–2.6 · Design · Wrap-up.

### 1 Title · 2 Lab overview
- Table of parts, functions, mode and minutes. Notes explain the together/your-turn split. Script: last week you summarised data, today you draw it; the three-part recipe (theme, skeleton, annotation). Run lines 16–23 and 29–36 now.

### 3 Divider · 4–5 Warm-up 1 and 2 (vote)
- 1: one score per student, show the spread: which chart? (histogram). 2: which caption helps more? ("Most students score between 5 and 7…" over "Histogram of t02_cubes"). Plants the annotation idea.

### 6 Divider "Part 1" · 7 Setup (run together, lines 16–36) · 8 Meet the data
- The five packages with a comment each; no data files; `?holzinger.swineford` (line 38). 301 children · 26 tests · 2,443 rows of `nuijten2020`; the columns used today; `female` is 1 = male, 2 = female; `grade` is a number.

### 9 Divider "Part 2.0" · 10 Every ggplot has three parts (lines 58–64)
- Anatomy of `hs_data |> ggplot(aes(x, y)) + geom_point()` in five pieces: data, canvas, aesthetics, `+`, geom. Notes: the `|>`-instead-of-`+` error.

### 11 A plot, one layer at a time (walkthrough, code together)
- Canvas only → points → `labs()` → `theme_minimal()`.

### 12 `theme()`: change the look (lines 68–98)
- Anatomy of `my_theme()`: function, `theme()`, `element_blank()`, `element_rect()`, used with `+`. Notes: the notebook's hot take (line 52), finding a part's name with Tab or an LLM.

### 13 Four looks, same plot (lines 102–122)
- Default, `my_theme()`, `theme_minimal()`, `theme_clean()` side by side. Cards: start from a ready-made theme, then adjust; the three-part recipe.

### 14 The annotation (line 133)
- Anatomy of `#| fig-cap:`; describes vs says what it shows; cover-the-plot test.

### 15 Which chart for which question?
- Six thumbnails from the lab's data, one per exercise, each with its question.

### 16 Divider "Round 1" · 17 Exercises 2.1 and 2.2 (your turn, 10 min)
- Histogram of `t02_cubes`; count by `school` and bar chart. Syntax sheet with comments; stuck: the `bins = 30` message, missing `+`, `geom_bar()`.

### 18 Solutions 2.1 · 19 Solutions 2.2 (walkthroughs)
- Theme function → histogram → theme and labels; caption "most students score between 5 and 7" (72%). `count(school)` table → `geom_col()` with names on y → theme and labels.

### 20 Round 1: bins are a design choice
- 5, 20 and 60 bins side by side: too few, about right, too many.

### 21 Divider "Round 2" · 22 Exercises 2.3 and 2.4 (your turn, 12 min)
- Scatter coloured by `school`; `count(year)` and a line. Stuck: `colour = school` inside `aes()`; `scale_colour_*` vs `scale_fill_*`.

### 23 Solutions 2.3 (walkthrough) · 24 Hidden dots: overplotting
- Default colours → theme and cosmic palette → labels; caption with "tend to" (r = 0.37). `geom_point()` vs `geom_jitter()`: 301 children, 177 positions.

### 25 Solutions 2.4 (walkthrough) · 26 Round 2: what is one row?
- `count(year)` table → line → theme and labels. Effect sizes against distinct studies by year, with the post-2008 region shaded; "why the drop?" revealed: data collection, not less research.

### 27 Divider "Round 3" · 28 Reading a box plot (concept)
- Grade 8 dots → box → labels: median, 25% and 75% lines, whisker, outliers. Card: why use it; notes: what it hides (the shape).

### 29 Exercises 2.5 and 2.6 (your turn, 9 min)
- Box plots by `grade` (line 191 says "histogram": it means box plot); density by gender with `if_else(female == 2, …)`. Stuck: one box and *continuous x* → `as.factor()`.

### 30 Solutions 2.5 · 31 Solutions 2.6 (walkthroughs)
- Box plots → theme and labels (`scale_fill_bmj()` does nothing) → without `as.factor()`: one box. `if_else()` table → densities → theme, lancet, labels; "almost the same", not "no differences".

### 32 Divider "Design" · 33 Five principles (lines 215–229)
- Accessibility, clarity, context, consistency, focus, and the goal.

### 34 Accessibility: colour for everyone
- Red/green scatter, its deuteranopia simulation, and Okabe–Ito with shapes. 1 in 12 men; viridis or Okabe–Ito plus a second cue.

### 35 Makeover · 36 Peer critique (pairs, 4 min)
- Default box plot → labelled, decluttered, one group highlighted, finding as title. Swap screens, cover-the-plot test on a caption, one change per the five-point checklist.

### 37 Summary · 38 Further reading · 39 Feedback
- Three checks (grammar and `aes()`; question → chart and the traps; recipe and design for everyone). Exit question: what would a reader learn from your best plot's caption alone? R4DS chapters 1, 9 and 11; Wilke; ggplot2 cheat sheet. Feedback QR (same survey as Lab 4).
