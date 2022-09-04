if (as.numeric(R.version$major) < 4) {
  warning("R 4.0 or later is required. If problems arise please update R first.")
}
message("Running gams without args...")
system2("gams")

stopifnot(`pdflatex not found, check your LaTeX installation` = Sys.which("pdflatex") != "")
message("checking for pdflatex executable on your PATH - ok")

message("checking if required R packages are installed")
missingDeps <- Filter(function(x) !requireNamespace(x, quietly = TRUE),
                      renv::dependencies(dev = TRUE)[, "Package"])
if (length(missingDeps) > 0) {
  stop("Some required R packages are missing, install them with `renv::install(",
       paste(capture.output(dput(missingDeps)), collapse = ""), ")`")
} else {
  message("all required R packages are installed")
}

message("Finished setup checks. Your system is ready to run REMIND if there were no errors/warnings.")
