suppressMessages(library(tidyverse))
suppressMessages(library(gdx))
suppressMessages(library(modelstats))
options(width = 160)
vars <- c("pm_gmt_conv", "pm_sccConvergenceMaxDeviation")
argv <- commandArgs(trailingOnly = TRUE)
if (length(argv) > 0 && ! isTRUE(argv == "")) vars <- strsplit(argv, ",")[[1]]
folder <- if (sum(file.exists(c("output", "output.R", "start.R", "main.gms"))) == 4) "output" else "."
dirs <- grep(".*-rem-[0-9]+$", dir(folder), value = TRUE)
if (length(dirs) == 0) {
  message("No run found in ", normalizePath(folder))
  q()
}
maxrem <- max(as.numeric(gsub(".*-rem-", "", dirs)))
runs <- unique(gsub("-rem-[0-9]+$", "", dirs))
message("\nNumbers in parentheses indicate runs currently in slurm.")
message("A minus sign indicates that run does not exist.")
for (v in vars) {
  message("\n### ", v)
  results <- matrix(nrow = length(runs), ncol = maxrem + 1)
  colnames(results) <- c("run", paste0("rem", seq(maxrem)))
  results <- as_tibble(results)
  for (r in seq_along(runs)) {
    results[[r, "run"]] <- runs[[r]]
    for (m in seq(maxrem)) {
      rfolder <- file.path(folder, paste0(runs[r], "-rem-", m))
      gdx <- file.path(rfolder, "fulldata.gdx")
      data <- NA
      if (file.exists(gdx)) {
        data <- try(gdx::readGDX(gdx, v, react = "silent"), silent = TRUE)
        if (inherits(data, "try-error")) data <- "-"
        if (is.null(data)) data <- "null"
        if (is.numeric(data)) data <- if (data < 10) signif(data, 2) else round(data, 2)
        data <- paste(data, collapse = ",")
      }
      if (! modelstats::foundInSlurm(rfolder) == "no") {
        data <- paste0("(", data, ")")
      }
      results[[r, paste0("rem", m)]] <- data
    }
  }
  results[is.na(results)] <- "-"
  print(results, width = 160)
}
