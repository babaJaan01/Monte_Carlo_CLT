# AI Interaction Log

## Actual revision: October 6, 2026

**My objective:** Make the project emphasize the professor's rubric: a clear table, defensible Normal-approximation arguments, issues and surprises, and understanding the AI-generated code.

**My prompt:** I shared the professor's four questions, asked for a more concise repository in my voice, and requested questions and a plan. I then explicitly asked AI to implement the agreed plan.

**My choices:** A 3–4 page PDF plus GitHub; direct first-person writing; a practical visual approximation; two distributions reviewed at a time; a decision table and boundary plots; a brief AI reflection plus this log.

**Problems identified by AI during inspection:** The sensitivity run overwrote primary sample-mean vectors; plots could therefore disagree with tables. Refinement grids were unnecessarily shared across populations. Earlier selected n values lacked adequate smaller-n rejection arguments, and the overview contradicted the age-mixture selection.

**Corrections implemented by AI:** Separate seed directories, population-specific refinement, compact evidence reports, vector-to-table validation, aligned histogram bins for discrete means, and a complete renv setup.

**Automated checks:** The corrected simulation ran with B = 10,000; both seeds' saved vectors were checked against their means, SDs, and Q-Q RMSE in the diagnostic CSVs.

**My current understanding:** I initially described n as sample size and B as replication. We clarified that B counts fresh simulated samples. We also clarified that the Cauchy population mean and variance are undefined, while finite sample averages remain calculable.

**Status at that point:** Paired review was pending. The later entries record what actually occurred; no complete line-by-line mastery is claimed.

### First paired review: Normal and die

I said the die at n = 20 was convincing and the remaining Q-Q steps were acceptable. My explanation of exact Normality was initially uncertain ("because the mapping between them is exact?? idk"). AI clarified that independent Normal observations have an exactly Normal average for every positive n. The die choice remains provisional until smaller nearby values are inspected; accepting n = 20 alone does not establish it as the smallest defensible value.

Use this file to document actual AI-assisted iterations. Do not add invented prompts or interactions.

## Entry template

### Objective / question

<!-- What were you trying to accomplish? -->

### Initial prompt

<!-- Paste the actual prompt or summarize it faithfully. -->

### Useful response

<!-- What was genuinely useful? Include code or reasoning only when helpful. -->

### Weakness or error noticed

<!-- What required checking, correction, or rejection? -->

### Follow-up prompt

<!-- Record the actual follow-up prompt. -->

### Correction / improvement

<!-- What changed after iteration? -->

### Independent check

<!-- Explain how you checked the result with R, theory, source material, or a clean rerun. -->
## Boundary review follow-up, October 6, 2026

- **Actual student feedback:** “They looked better. But I didn't know ... we need the smallest defensible n. Maybe then going off visually isn't right?”
- **Clarification:** Visual evidence is appropriate, but “looks better” is not a rejection argument for a smaller candidate. Adjacent values can be practically indistinguishable; the report must acknowledge a transition region instead of inventing a sharp cutoff.
- **Correction prompted by this exchange:** Added smaller, population-specific boundary experiments for both seeds, preserving B = 10,000. Generated tighter histogram/Q-Q comparisons. The proposed summary distinguishes borderline ranges from approved final selections.
- **Independent checks:** `Rscript scripts/validate_results.R` passed after the new experiments; both seeds' saved vectors reproduce their CSV means, SDs and Q-Q RMSE. The dependent model has bounded conditional second moments, but this does not justify an iid SE or establish a dependent CLT.
- **Status at that point:** Tolerance for residual tail bends and discrete steps still needed review. The following entry records the later practical-standard approval; it does not imply independent confirmation of every integer.

### Practical-standard approval and visual revision

- **Actual follow-up:** After being asked about small tail bends and discrete steps, I replied: “Sure. Whatever fulfills all of the assignment reqs! But make the pdf much more visually pleasing. Like 'Apple Keynote' esque ...”.
- **What I approved:** A practical approximation rather than exact Normality or precise extreme-tail accuracy. I delegated completion and asked for clearer visual presentation.
- **What AI did:** Selected evidence-backed working boundaries under that standard, retained explicit borderline-neighbor uncertainty, and generated the summary from actual rows. I did not independently specify or confirm every boundary integer.
- **Presentation change:** Four-page Quarto/Typst PDF with larger typography, a concise acceptance/smaller-n table, consistent color, boundary plots and seed comparisons.
- **Understanding claim:** The log does not assert complete line-by-line mastery. Important generator and simulation lines are explained in the separate investigations for my review.

## Complete-PDF revision: October 7, 2026

**Actual prompt:** I asked where the PDF directly answered the three major questions and whether AI iteration evidence was only in the repository. I then requested: “EVERYTHING should be in the pdf pertaining to the instructions.”

**Weakness identified:** The attractive four-page summary was not a self-contained grading submission. Several cases' plots, full diagnostics, code explanation and the detailed AI record required browsing other files.

**Correction:** AI re-read all seven attached instructor sources and expanded the same Quarto PDF to include explicit answers, eight case investigations, actual diagnostic rows for every tested n, both seeds' boundary metrics, special-process checks, code walkthroughs and actual prompt/correction examples. The updated scope remains five required and three extra-credit cases. Older unrelated lesson activities were not added as requirements.

**Honesty limit:** Theory-based expectations are retrospective; no personal prediction made before the original run or unrecorded reaction is fabricated. AI selected the working boundary integers under my approved practical standard.

**Validation:** The same saved-vector guard links PDF plots to diagnostic rows. Cauchy plots now label a conditional central histogram window while Q-Q plots and numerical diagnostics retain all means; finite-value checks reject failed vectors rather than silently dropping them. Final rendering and page inspection are recorded in `VALIDATION.md`.

## Concise final-report revision: October 10, 2026

**Actual prompt:** I said the previous approximately 35-page report was unacceptable and required a polished 13–14-page summary, at most 15 pages. I specified a professor-friendly page guide, actual result tables, compact distribution cards, explanations of smaller-n choices, special cases, seed checks, AI iteration and the file map. I prohibited invented results, predictions and AI interactions.

**Follow-up:** When asked about attribution for the working integers, I emphasized that I really interacted with AI and repeated the professor's questions: did AI help with a complicated project, did I correct/modify it, and do I understand it? The report uses our real exchanges and separates my input from AI-generated code and boundary proposals; this is not a fabricated independent audit or a claim of complete mastery.

**Weakness / improvement:** Dumping all diagnostic rows and code made the grading argument difficult to find. AI rebuilt the same Quarto source around a 14-page summary and used the existing saved results, not new or estimated conclusions. During visual inspection, raw Markdown tables and a clipped Q-Q label were discovered and corrected before delivery.

**Validation:** R smoke/model checks and both seeds' saved-vector checks were rerun. Summary generation asserts agreement with the executed diagnostic rows. The rendered PDF is inspected page by page; a Typst assertion prevents accepting a layout other than the reviewed 14 pages. The full simulation was not rerun for a presentation-only revision. See `VALIDATION.md` for final checks.
