# MY202 lab slides

Quarto revealjs decks in the LSE style from `slidereference/`.

The solution slides run real R code, so rendering needs R with `tidyverse`, `psymetadata` and `gt`, and the lab data in `W*/notebooksanddata/`. That folder is git-ignored, so only a machine that has the data can re-render a deck.

## Render

From this folder:

```bash
quarto render W1_R_Intro/slides/W1-lab-slides.qmd
```

Open the `.html` next to the `.qmd`. Press `S` for speaker notes (timing and script).

## Where things live

| File | What |
|---|---|
| `W*/slides/*.qmd` | One deck per week |
| `W*/selfpaced/*.qmd` | Self-paced lab guides for students working on their own (format `lse-html`) |
| `W*/notebooksanddata/` | Lab notebooks and data. Local only (git-ignored) |
| `_extensions/lse/` | Theme copied from `slidereference/`, plus `components.scss` (cards, "your turn" layout, mini tables), `timer.html` (countdowns), `walk.html` (solution walkthroughs) and `lse-logo.svg` (public domain, from Wikimedia Commons) |

## Solution slides

Solution slides (class `.solution`) walk through the code one step at a time: the code sits on the left, and each click highlights the lines that step adds and shows the output up to that point on the right.

```markdown
## Solutions: Part 1 · Q8–9 {.solution}

:::: {.walk}
::: {.walk-code}
(the full code as a plain r code block)
:::
::: {.walk-out}
::: {.fragment fragment-index=0 lines="1"}
(an R chunk with `#| echo: false` that runs line 1)
:::
::: {.fragment fragment-index=1 lines="1-2"}
(an R chunk that runs lines 1–2)
:::
:::
::::
```

`lines` takes ranges such as `1-4` or `1,3-4`. The behaviour is in `_extensions/lse/walk.html`.

## Coding slides and timers

Give a slide the `.yourturn` class and put a timer in it:

```html
<div class="timer" data-minutes="18"></div>
```

Click the timer or press `T` to start or pause it. Double-click resets it. It turns dark red with 2 minutes left, and keeps running if you move to another slide.

## Self-paced guides

`W*/selfpaced/*.qmd` use `format: lse-html`: a single scrolling page that walks absolute beginners through the lab notebook step by step, with the real output of every step. Students run the code in RStudio; the page explains it and shows what they should see. Render like the decks:

```bash
quarto render W1_R_Intro/selfpaced/W1-selfpaced-lab.qmd
```

Styles are in `_extensions/lse/guide.scss`, behaviour in `_extensions/lse/guide.html`. Chunks are hidden by default (`echo: false`) and data frames print as paged tables, like RStudio's notebook output.

| Markup | What it does |
|---|---|
| `### Title {.step}` | A step with a **Mark as done** button. Ticks are saved in the browser and drive the progress bar and the ticks in the table of contents |
| `::: {.doit q="Part 1 · Q4"}` | Blue "Your turn" box: what to type and run in RStudio |
| `::: {.expect}` | Labels the R output inside as "What you should see". `data-label="…"` changes the label |
| `::: {.idea}` | "Big idea" box. `data-label="…"` changes the label |
| `::: {.anatomy}` | One line of code made of `` [`part`]{.tok} `` spans, followed by a numbered list: item *n* explains token *n* |
| `::::: {.walk}` | Step-through: a `.walk-code` block, then one `.walk-step lines="1-2"` per step holding the explanation and an R chunk. An optional `.walk-intro` replaces the default intro |
| `::: {.quiz}` | Multiple choice: one `.opt` block per answer, the right one with `.right`, each with an optional `.fb` feedback block |
| `::: {.glossary}` around a table | Terms in bold, meanings next to them. Each term is underlined across the page (once per step); clicking it opens a drawer (right side on wide screens, bottom sheet on phones) with the meaning and the paragraph where the term is first explained in bold. Add `[]{match="…"}` in a term's cell to control which words match: a regular expression, with `;` for "or" |
| `[Ctrl]{.kbd .mod}` | A key. `.mod` shows Cmd on a Mac; `.opt-key` shows Option instead of Alt |
