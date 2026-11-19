# MY202 · Lab 8 — Finding groups: k-means and DBSCAN

Lesson plan and slide outline, based on the notebooks of 19 November 2026: the student workbook `W8/notebooksanddata/my202-08-lab-student (1).qmd` (232 lines; **all line numbers on the slides and in this plan refer to this file**) and the solutions `my202-08-lab-solutions (1).qmd` (227 lines). The workbook mixes given chunks (setup, the workflow for finding *k*, the DBSCAN call and its plot, the `eps` chunk) with four things students write: the first scatter plot (lines 51–55), `optimal_k` and the coloured scatter (107–114), the list of cluster members (122–126) and the list of clusters and noise (182–186).

Both notebooks read `data/mca-week-7.csv`. The file was delivered as `mca-week-7 (1).csv` next to the notebooks; a copy sits in `W8/notebooksanddata/data/mca-week-7.csv` so that the deck renders. The whole folder is git-ignored. The render takes about 20 seconds; nothing is cached. `dbscan` was not installed on the machine this deck was built on and was added from CRAN.

Last year's DS202 Week 8 lab (`DS202 Winter/week8ds202.pptx`, 41 slides) had three 10-minute intuition blocks: k-means on a line of countries by happiness (12 slides), then the elbow and the silhouette; k-means++ and k-medoids; DBSCAN on two nested rings (11 slides of screenshots). This deck keeps the same order of ideas for k-means and DBSCAN but builds each one click by click on a single picture, and drops k-means++ and k-medoids: the notebook has no code for them. (Last year's Week 9 deck, anomaly detection, was looked at for the handover only: DBSCAN's noise points are where it starts.)

## Lesson plan

**Format:** 90-minute computer lab. Each part runs **concept** (a hand-sized everyday example, built up click by click) → **code or run together** (the notebook chunk, with an anatomy slide for the line that matters) → **your turn** (in pairs, a timer, then the answers on the notebook's own plots).

| Block | Concept | Together | Your turn |
|---|---|---|---|
| What | Thirty people on a lawn: how many groups, and how did you know? | Setup (38–45); the overview and table (9–34) | |
| I · k-means | Three ice-cream carts: start, assign, update, repeat · the total squared walk and `nstart` · the elbow · the silhouette | The first plot, typed together (47–57); the workflow for *k*, read together (59–96) | **A** choose *k*, colour the map, list and name the clusters (98–130) |
| II · DBSCAN | A queue curving round a picnic: where k-means fails · core, border and noise in six steps | `dbscan()` and its plot (136–176); what is a noise point (147) | **B** list clusters and noise, then turn `eps` (178–232) |
| Wrap-up | k-means or DBSCAN: the notebook's table in plain words | | |

**Running examples.**

- *The park* (Part I). Thirty made-up people in three groups on a lawn (`set.seed(1)`), positions in metres. The deck runs k-means by hand on it: three carts next to three random people, everyone to the nearest cart, each cart to the mean of its customers, 8 people switch, the carts move once more, nobody switches. The same lawn then carries the three follow-ups: the **total squared walk** (677 for the good run; a second random start gets stuck at 5,296 with two carts in one group, which is what `nstart = 25` is for), the **elbow** (9,296 → 4,642 → 677 → 515 → 394 for 1 to 5 carts) and the **silhouette** (one person: a = 4.3 m, b = 30.0 m, s = 0.85; the person between two groups: 0.48; the average peaks at k = 3).
- *The festival field* (Part II). A queue of 24 people curving round a picnic of 14, and three people on their own. k-means with k = 2 cuts the queue in half and colours the loners. DBSCAN with `eps` = 6 m and `minPts` = 5 finds the queue, the picnic and three noise points, over three slides. Slide 17, who stands in a crowd: count inside a circle for three example people with everyone else faded (13, 3 and 1), give those three their verdict (one core point, two not), then apply the same test to everyone. Slide 18, growing: start at one core point in the middle of the queue, colour everyone in its circle, let the new core points do the same, hop by hop; it stops because the picnic is 8.9 m away and the border points at the ends pass nothing on; then the picnic grows the same way from its own starting point (two clicks, the queue faded), then noise. Slide 19 is live: two sliders for `eps` and `minPts` run DBSCAN in the browser on the same field (it opens with plain grey dots; clicking step 1 sends the circle from person to person to count and mark the core points, clicking step 2 grows the clusters, and a play button runs both; nothing happens by itself).

Every claim the slides make about these pictures and about the lab data is checked with `stopifnot()` in the deck's setup (three rounds of k-means, the stuck start is at least 1.5 times worse, DBSCAN finds exactly queue, picnic and three loners, k-means on the lab data gives exactly the four families of answers, the five noise points are the five named), so a changed seed or file fails the render instead of showing a wrong reading.

**Learning objectives.** The notebook lists four skill areas (lines 15–21). By the end, students can:

1. Say what clustering does and why its result cannot be scored like a prediction (slides 3, 26)
2. Explain k-means as assign, update, repeat, and why it needs several starts and a seed (slides 5–6)
3. Choose *k* with the elbow and the silhouette, and say why neither decides alone (slides 7–8, 10, 12)
4. Fit k-means in R, attach the clusters to the data and describe them by content (slides 11, 13–14)
5. Explain DBSCAN through `eps`, `minPts`, core, border and noise points (slides 16–21)
6. Run DBSCAN, read its noise points, and argue for a value of `eps` (slides 19–20, 22–25)
7. Compare the two methods and say when each is appropriate (slide 26)

**Before class**

- Check on Nuvolos that the Week 8 workspace has the student workbook and `data/mca-week-7.csv` (in a `data/` folder, without the " (1)"), and that the setup chunk (lines 38–45) runs. **`cluster` and `dbscan` are new this week.** The solutions also call `ggsci::scale_colour_uchicago()`, used before in Lab 2.
- Nothing is slow: every chunk runs in under a second.
- Render once (`quarto render W8/slides/W8-lab-slides.qmd` from `MY202/`).

**Timing**

| Time | Block | Mode | Notebook lines |
|---|---|---|---|
| 0:00–0:03 | Welcome, overview, run the setup chunk | Whole class | 38–45 |
| 0:03–0:06 | **What is clustering?** | Concept | 9–34 |
| 0:06–0:20 | **k-means concept.** The carts (5) · how good is a grouping (3) · the elbow (3) · the silhouette (3) | Concept | |
| 0:20–0:28 | **Together.** The first plot (4) · the workflow for *k* (4) | Code, then run | 47–96 |
| 0:28–0:46 | **Your turn A** (10-minute timer) · which *k* (3) · the code (2) · what is in each cluster (3) | Pairs | 98–130 |
| 0:46–0:49 | Slack inside Part I | | |
| 0:49–1:00 | **DBSCAN concept.** Where k-means goes wrong (3) · who is a core point (2) · growing hop by hop (4) · live sliders for `eps` and `minPts` (2) | Concept | 132–134 |
| 1:00–1:06 | **Run together.** The call and the plot (4) · what is a noise point, MCQ (1½) | Together | 136–176 |
| 1:06–1:24 | **Your turn B** (9-minute timer) · clusters and noise (3) · turning `eps` (4) · how to choose `eps` and `minPts` (2) | Pairs, then concept | 178–232 |
| 1:24–1:30 | **Wrap-up.** k-means or DBSCAN (3) · summary and exit question (3) | Whole class | |
| 1:30 | Feedback form: put the QR code up as students pack (1 minute is all that is spare) | | |

**Will it fit?** 89 minutes planned, 1 spare. There is effectively no margin, against Lab 7's 9 minutes: this week students write code as well as read plots, the DBSCAN concept takes three slides, and slide 25 on choosing `eps` adds 2 minutes. Expect to use the skip list. Checkpoints: data plotted by 0:25, your turn A started by 0:30, Part II started by 0:49, your turn B started by 1:06. **If behind, skip in this order:** (1) the noise MCQ, 1½ minutes (say its answer on the previous slide); (2) on the live slide show `eps` only and leave `minPts` alone, 1; (3) the "unlucky start" click, 1 (say `nstart` in a sentence); (4) the silhouette's third click, the person between two groups, 1; (5) shorten your turn B from 9 to 7. That recovers 6½ minutes on top of the spare 1. The carts and the hop-by-hop DBSCAN slide carry the two intuitions and should not be cut. **If ahead**, use the fast-finisher tasks; do not add content.

**For fast finishers:** rerun exercise A with `optimal_k <- 3` (the two `_n` groups merge into one cluster of 18); print `final_kmeans$centers`; keep `eps = 0.25` and try `minPts = 3` and `minPts = 8`; `kNNdistplot(mca_coords[, 1:2], k = 4)`, the plot from slide 25.

**Fix before release** (the notebooks of 19 November)

*Student workbook*

- **The title says "Student Solutions"** (line 2), the heading says "(DS202)" (line 9) and the date is 17 November 2025.
- **The overview promises k-medoids and "k-means variants"** (lines 13 and 15). There is no code for either. Remove the two mentions, or students will look for the missing part.
- **The part timings add up to 90 minutes of exercises** (10 + 50 + 30, lines 23, 27, 47, 132) and leave no room for teaching. The deck's split is 6 + 43 + 29 + 6.
- **Nothing says what the data are.** One sentence would do: the 36 rows are the answer categories of last week's MCA (18 questions × y or n), and `dim_1`, `dim_2` are their coordinates on the first two dimensions. Slide 9 says it.
- **Task numbering starts at "Task 4"** (line 136); Part 2 has unnumbered tasks.
- Task 5's chunk (lines 198–230) overwrites `db_result`, `clustered_points` and `noise_points`. A student who does Task 5 before the listing task gets the list for `eps = 0.5`. Slide 20's "stuck" box covers it.
- The line at 134 runs four bullet points together into one paragraph (the hyphens are not at line starts), as do the "Key Questions" at line 196.

*Solutions*

- **Cluster numbers do not match the output.** The answer at lines 116–119 calls the permissive private-life answers "Cluster 1", the law-abiding answers "Cluster 2", their opposites "Cluster 3" and the conservative answers "Cluster 4". With the notebook's seed on this machine (R's `kmeans()`, `nstart = 25`) the order is: 1 = n on harm and cheating, 2 = n on private life, 3 = y on harm and cheating, 4 = y on private life. Numbers depend on the random starts, so the answer should name clusters by content. Slides 13–14 do, and say why.
- **The noise list is one short** (line 185). At `eps = 0.25` the five noise points are `death_penalty_y`, `death_penalty_n`, `divorce_n`, `avoid_transport_fare_y` and `violence_against_child_y`. The answer names the first four.
- **"What k works best"** (line 80): the silhouette "peaks at 4" by 0.656 against 0.647 at k = 3. Worth saying that this is nearly a tie and that interpretability is what settles it. Slide 12 does.
- "Opposition to the death penalty" (line 119): `death_penalty_n` means "at or below the median on how justifiable", as with every `_n`. Last week's caveat about what y and n mean still applies.

**Consistency check of the deck against the notebook:** every line reference on the slides points at the right lines of the student workbook. Every chunk in the workbook is on a slide: setup (2), the first plot (9), the workflow for *k* (10, 12), the final clustering and scatter (11, 13), the member list (11, 13–14), the DBSCAN call (18), its plot (18, 21), the cluster and noise lists (20–21), the `eps` chunk (20, 22). All six discussion prompts are on a slide: "can we see clusters" (9), "what k" (11–12), "what is in each cluster" (11, 14), "what are noise points" (19), "which attitudes are harder to categorise" (20–21), the four key questions on `eps` (20, 22). The plots of lab data are drawn with the notebook's code; the changes are text sizes for the room, a legend at the bottom, labels for a few points (slides 9, 14, 21) and five panels side by side for `eps` (slide 22). Terms match the notebook: cluster, centre (centroid), elbow method, silhouette width, `eps`, `minPts`, noise points.

**Key numbers** (seed 123, as in the notebook)

*k-means on the MCA map.* 36 answers, two coordinates.

| k | `tot.withinss` | Mean silhouette |
|---|---|---|
| 2 | 8.17 | 0.577 |
| 3 | 3.44 | 0.647 |
| 4 | 1.71 | 0.656 |
| 5 | 1.18 | 0.624 |
| 6 | 0.95 | 0.600 |

With k = 4: four clusters of 9. Harm and cheating (fare dodging, stealing, tax cheating, bribes, violence against a spouse, violence against a child, social violence, terrorism, political violence), `_n` and `_y`; private life (homosexuality, sex work, abortion, divorce, sex before marriage, suicide, euthanasia, casual sex, death penalty), `_n` and `_y`. Centres: (−0.45, −0.24), (−0.50, 0.38), (0.95, 0.51), (0.60, −0.45). With k = 3 the two `_n` clusters merge (sizes 9, 18, 9).

*DBSCAN, `minPts = 5`.*

| `eps` | Clusters | Noise points |
|---|---|---|
| 0.1 | 1 | 28 |
| 0.2 | 4 | 8 |
| 0.25 | 4 | 5 |
| 0.3 | 4 | 4 |
| 0.4 | 3 | 2 |
| 0.5 | 2 | 0 |

At 0.25 the four clusters are the four k-means families minus the five noise points (sizes 9, 7, 7, 8). At 0.5 the two clusters are every `_n` and every `_y`.

---

## Slides

29 slides. Every slide was checked at 16:9 (1200 × 675) in headless Chrome with all fragments revealed: content stays above the footer. The click sequences of slides 5, 7, 8, 13, 16, 17, 18 and 25 were also checked step by step, and the live slide 19 in six slider settings. The script is in the speaker notes (press `S`). The tracker bar reads: What · I k-means · II DBSCAN · Wrap-up.

- **1 Title · 2 Lab overview**: parts, notebook lines, minutes; run the setup chunk.
- **3 What is clustering?** (9–34): thirty people on a lawn, grouped by eye; a new column, no accuracy.
- **4 Divider · 5 k-means: three carts in a park**: five clicks from grey dots to the final grouping; start, assign, update, repeat.
- **6 How good is a grouping?**: the total squared walk (`tot.withinss`); a start that gets stuck; `nstart = 25`.
- **7 How many groups? The elbow**: one more cart per click, the curve grows beside the lawn.
- **8 A second opinion: the silhouette**: a, b and s for one person, someone between groups, the average by *k*.
- **9 The data: last week's map** (36–57): the first plot, typed together; what the 36 dots are.
- **10 Find k: read the workflow** (59–96): anatomy of `eval_kmeans()` and `map(2:10, ...)`.
- **11 Your turn A** (98–130, 10 min) · **12 Answers: which k?** · **13 Solutions: fit, plot, list** (walk-through) · **14 Answers: what is in each cluster?**
- **15 Divider · 16 Where k-means goes wrong** (132–134): the queue and the picnic, by k-means and by DBSCAN.
- **17 DBSCAN 1: who stands in a crowd?**: three circles and their counts, the verdict for those three, then the same test for everyone.
- **18 DBSCAN 2: grow a cluster, hop by hop**: seven pictures; the colour starts at one core point and is passed on circle by circle.
- **19 DBSCAN 3: now you choose eps and minPts**: live sliders; needs no internet, runs in the deck.
- **20 Run DBSCAN on the map** (136–176): anatomy of the call; cluster 0.
- **21 Class discussion: what is a noise point?** (147): MCQ.
- **22 Your turn B** (178–232, 9 min) · **23 Answers: clusters and noise** · **24 Answers: turning eps**.
- **25 How do you choose eps and minPts?** (190–232): three pictures. Each person's distance to their 4th-nearest neighbour on the field (2.3, 8.8 and 18.1 m for the three example people); all 41 distances sorted, with `eps` = 6 m at the bend; the same plot for the lab map, a soft bend between 0.2 and 0.3. `kNNdistplot()` is not in the workbook.
- **26 k-means or DBSCAN?** · **27 Summary** with exit question · **28 Further reading** · **29 Feedback**.
