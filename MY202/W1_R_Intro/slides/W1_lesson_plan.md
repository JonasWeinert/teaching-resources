# MY202 · Lab 1 — Working with Data in the Tidyverse

Lesson plan, slide outline and speaker script, based on `my202-01-lab-student.qmd` / `-completed.qmd`.

## Lesson plan

**Format:** 90-minute computer lab. Mini-lectures ("teaching moments") of 5–7 minutes each, then students work through the notebook while you circulate.

**Learning objectives.** By the end, students can:

1. Inspect an unfamiliar data object (`?`, `class()`, `as_tibble()`, `glimpse()`)
2. Chain the core `dplyr` verbs with the native pipe `|>` (`count`, `mutate`, `group_by`, `summarise`, `filter`, `select`, `rename`, `pull`)
3. Explain what "tidy" data is, and reshape between wide and long with `pivot_longer()` / `pivot_wider()`
4. Apply one function to every element of a list with `purrr::map()` and recombine the results with `bind_rows()` / `map_dfr()`

**Before class**

- Check that `ggsci`, `gt`, `psymetadata` and `tidyverse` install on the lab machines (`psymetadata` is the one most likely to be missing)
- Release the student `.qmd` and `wb-life-exp.csv` together, with the folder layout the notebook expects (see "Fix before release")
- Render the completed notebook once yourself, so you have the outputs ready to show

**Timing**

| Time | Block | Mode |
|---|---|---|
| 0:00–0:05 | Welcome, setup, run the setup chunk | Whole class |
| 0:05–0:12 | Teaching moment 1: data frames, tibbles, pipes, `dplyr` verbs | Live coding |
| 0:12–0:30 | Part 1, Q1–11 (meta-analysis data, `agadullina2018`) | Pairs, tutor circulates |
| 0:30–0:37 | Teaching moment 2: tidy data, wide vs long | Slides + whiteboard |
| 0:37–1:02 | Part 2, Q1–8 (World Bank life expectancy) | Pairs |
| 1:02–1:08 | Teaching moment 3: lists, iteration, `map()` | Live coding |
| 1:08–1:25 | Part 3, Q1–5 (`maldonado2020` split into a list) | Pairs |
| 1:25–1:30 | Wrap-up: what did we find out? Exit question | Whole class |

**If you run short of time,** cut Part 3 Q5 (`map_dfr`) and set it as homework. Parts 1 and 2 are the core.
**For fast finishers:** use `glimpse()`; plot the four countries with `ggplot` and `ggsci::scale_color_npg()` (the notebook loads `ggsci` but never uses it); work out which rows in the World Bank file are regional aggregates rather than countries.

**Fix before release** (found while reading the notebooks)

- `read_csv("data/wb-life-exp.csv")` expects a `data/` subfolder, but the CSV sits next to the `.qmd`. Either move it or change the path to `"wb-life-exp.csv"`.
- Part 1 numbering skips Q5 (it goes 4 → 6).
- The `2025` column in the CSV is entirely empty (trailing comma), so `pivot_longer()` produces about 263 `NA` rows. You can use this as a teaching moment (`drop_na()`, or `values_drop_na = TRUE`) or remove the column from the file.
- The file mixes 217 countries with about 46 aggregates ("World", "High income", "IDA only", "Euro area", …). Mention this in Part 2 Q2, because it is a real-world data trap.
- The completed Q6 quietly changes the years to 1970/80/90/2000/2010 and adds `round()`, so it doesn't match Q5. Align the two, or point out the change.
- The file names contain ` (1)` (from a download). Rename them before release.

---

## Slides and script

Around 14 slides. Each slide lists its **on-slide content**, then the **script** (what to say).

### Slide 1 — Title: "Lab 1: Working with Data in the Tidyverse"
- On slide: course, week, today's 3 parts, packages loaded
- Script:
  - Welcome. The aim today is to get fluent with the handful of verbs that make up about 80% of everyday data work in R.
  - Three blocks: summarising data with `dplyr`, reshaping messy data with `tidyr`, and doing the same thing many times with `purrr`.
  - Open the student notebook now and run the setup chunk. If a package is missing, put your hand up straight away rather than at minute 40.

### Slide 2 — Today's toolkit
- On slide: the "Functions Used" table, grouped by package (base · dplyr · tidyr · readr · purrr · gt)
- Script:
  - You don't need to memorise this. It's your reference sheet for the session and the notebook keeps it at the top.
  - The tidyverse is a family of packages with one shared philosophy: each function does one thing, takes a data frame first, and returns a data frame.

### Slide 3 — Teaching moment 1: what are we looking at?
- On slide: `?agadullina2018` · `class()` · `data.frame` vs `tibble` (side-by-side printout)
- Script:
  - The first thing to do with any new dataset is to find out what it is. `?` gives you the documentation, and `class()` gives you the type.
  - This is a meta-analysis dataset: each row is an effect size from a published study, `yi` is the effect size and `vi` is its variance.
  - Tibbles are data frames with better manners. They print only the first rows, show column types, and never silently convert strings.
  - Exam tip: don't print whole data frames. Use the tibble print or `glimpse()`.

### Slide 4 — The pipe `|>`
- On slide: `count(df, design)` vs `df |> count(design)`; read `|>` as "and then"; shortcut Ctrl/Cmd + Shift + M
- Script:
  - The pipe takes what's on the left and feeds it in as the first argument on the right.
  - With one step it makes no difference. With three or more steps, it lets you read code top to bottom like a recipe instead of inside-out.
  - We use the native `|>`. You'll also see `%>%` online; for our purposes they do the same thing.

### Slide 5 — Five verbs to know today
- On slide: `count` (frequencies) · `mutate` (add a column) · `summarise` (collapse to one row) · `group_by` (do it per group) · `filter`/`select` (rows/columns)
- Script:
  - Demonstrate live: `count(design)`, then pipe into `mutate(pct = n / sum(n) * 100)`.
  - Then `summarise(yi = mean(yi))` gives one number. Add `group_by(design)` before it and you get one number per design.
  - Key idea: `group_by` changes nothing visible on its own. It changes how the *next* verb behaves.
  - Hand over: "Work through Part 1 in pairs. You have about 18 minutes."

### Slide 6 — Part 1 debrief: what did we find out?
- On slide: the grouped `summarise` output table
- Script:
  - Ask 2–3 pairs: which design has the largest average effect? Is a simple mean of `yi` the right summary for a meta-analysis? (No, it ignores precision: `vi`.) This is a hook for later weeks.
  - Common errors to name: forgetting to assign the tibble, and `summarise` returning one row because `group_by` was left out.

### Slide 7 — Teaching moment 2: what is tidy data?
- On slide: three rules: each variable is a column · each observation is a row · each value is a cell. Diagram of a wide vs long table
- Script:
  - The World Bank file is a classic example of "human-friendly" data: one row per country and one column per year.
  - The problem is that "year" is a variable, but here it's hidden in the column names. You can't filter by year or plot over time easily.
  - Tidy data is the format most tidyverse functions expect. Most real-world cleaning is about getting there.

### Slide 8 — Wide ⇄ long
- On slide: small 3-country × 3-year example; `pivot_longer(-country_name, names_to = "year", values_to = "lifeexp")` with arrows; `pivot_wider()` as the inverse
- Script:
  - `pivot_longer` asks three questions: which columns should be stacked (everything except the country), where the old column names go (`year`), and where the values go (`lifeexp`).
  - After pivoting, `year` is text ("1960"). `parse_number()` turns it into a number.
  - `pivot_wider` reverses it. Wide format is often better for *presenting* a table, and long format is better for *analysing*.

### Slide 9 — Watch out: real data is messy
- On slide: example rows "World", "High income", "IDA only"; the empty 2025 column → `NA`s
- Script:
  - When you `pull(country_name)`, scroll through the list. Not every row is a country, so averaging across everything would double-count.
  - The final year column is empty. Notice what `pivot_longer` does with it, and how you'd drop those rows.
  - Hand over: "Part 2, about 25 minutes. Pick four countries you find interesting."

### Slide 10 — Part 2 debrief
- On slide: the `gt()` table from Q7 (Burkina Faso, Honduras, Niger, Suriname, 1970–2010)
- Script:
  - Ask: which country improved most? Did anyone pick a country with a dip (for example a conflict or HIV/AIDS era)?
  - Point out the full pipeline: read → rename → pivot → parse → filter → pivot back → present. That's the shape of most of the analysis work they'll do.

### Slide 11 — Teaching moment 3: lists and vectorisation
- On slide: a list as "a box of data frames"; `map(list, f)` = "do f to each one, give me a list back"
- Script:
  - Sometimes your data arrives in pieces: one file per year, one sheet per region, or here one data frame per cognitive domain.
  - Copy-pasting the same code four times is error-prone. `map()` applies one function to every element.
  - Two ways to write the function: a plain name (`map(x, colnames)`) or a formula with `~` and `.x` (`map(x, ~ select(.x, author, yi, vi))`). `.x` means "the current element".
  - Reassure students that the code which builds `split_data` is deliberately advanced and they don't need to understand it today.

### Slide 12 — From list back to one table
- On slide: `map(...) |> bind_rows(.id = "domain")` vs `map_dfr(..., .id = "domain")`
- Script:
  - `bind_rows` stacks the pieces. `.id` keeps track of which piece each row came from, so you don't lose information.
  - `map_dfr` does both steps in one. In newer purrr versions it is superseded by `map() |> list_rbind()`, but it is still widely used.
  - Hand over: "Part 3, about 17 minutes."

### Slide 13 — Wrap-up
- On slide: 3 takeaways: (1) inspect before you analyse, (2) tidy first, then analyse, (3) don't repeat yourself, `map` it
- Script:
  - Recap each part in one sentence.
  - Exit question for the chat or a sticky note: "Name one thing in your own data that isn't tidy."

### Slide 14 — Next week / resources
- On slide: R for Data Science (2e), chapters on data transformation, tidy data and iteration; dplyr/tidyr cheat sheets; where to find the completed notebook
- Script:
  - Point students to the completed notebook (release it after class) and the cheat sheets.
  - Preview Week 2.
