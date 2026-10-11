#!/usr/bin/env Rscript
# Quarto bundles Typst: this PDF does not require a TeX installation.
status <- system2("quarto", c("render", "summary.qmd", "--to", "typst"))
if (status != 0L) stop("Quarto PDF rendering failed.")
stopifnot(file.exists("clt_summary.pdf"), file.info("clt_summary.pdf")$size > 0)
