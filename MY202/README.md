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
