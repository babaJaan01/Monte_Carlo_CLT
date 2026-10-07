#!/usr/bin/env Rscript
# Quarto bundles Typst: this PDF does not require a TeX installation.
status <- system2("quarto", c("render", "summary.qmd", "--to", "typst"))
if (status != 0L) stop("Quarto PDF rendering failed.")
dir.create("output/pdf", recursive = TRUE, showWarnings = FALSE)
stopifnot(file.copy("clt_summary.pdf", "output/pdf/clt_summary.pdf", overwrite = TRUE))
