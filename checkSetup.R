if (as.numeric(R.version$major) < 4) {
  warning("R 4.0 or later is required. If problems arise please update R first.")
}
system2("gams")
stopifnot(`pdflatex not found, check your LaTeX installation` = Sys.which("pdflatex") != "")

missingDeps <- Filter(function(x) !requireNamespace(x, quietly = TRUE), renv::dependencies(dev = TRUE)[, "Package"])
if (length(missingDeps) > 0) {
  stop("Some dependencies are missing, install the with `renv::install(",
       paste(capture.output(dput(missingDeps)), collapse = ""), ")`")
}

library(gdxrrw) # check gams initialization

message("Finished setup checks. Your system is ready to run REMIND if there were no errors/warnings.")
