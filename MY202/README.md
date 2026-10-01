# MY202 lab slides

Quarto revealjs decks in the LSE style from `slidereference/`. Standalone: no R needed to render.

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
| `_extensions/lse/` | Theme copied from `slidereference/`, plus `components.scss` (cards, "your turn" layout, mini tables) and `timer.html` (countdowns) |

## Coding slides and timers

Give a slide the `.yourturn` class and put a timer in it:

```html
<div class="timer" data-minutes="18"></div>
```

Click the timer or press `T` to start or pause it. Double-click resets it. It turns dark red with 2 minutes left, and keeps running if you move to another slide.
