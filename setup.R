if (as.numeric(R.version$major) < 4) {
  warning("R 4.0 or later is required. If problems arise please update R first.")
}
system2("gams")
stopifnot(`pdflatex not found, check your LaTeX installation` = Sys.which("pdflatex") != "")

renv::install("yaml", prompt = FALSE) # yaml is required to find dependencies in Rmd files
renv::hydrate() # auto-detect and install all dependencies
renv::snapshot(prompt = FALSE) # create renv.lock

library(gdxrrw)
library(remind2)

message("If there were no errors/warnings your system is ready to run REMIND.")
