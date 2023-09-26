# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
if (as.numeric(R.version$major) < 4) {
  warning("R 4.0 or later is required. If problems arise please update R first.")
}
message("Running gams without args...")
system2("gams")

stopifnot(`pdflatex not found, check your LaTeX installation` = Sys.which("pdflatex") != "")
message("checking for pdflatex executable on your PATH - ok")

message("checking if required R packages are installed")
missingDeps <- Filter(function(x) !requireNamespace(x, quietly = TRUE),
                      setdiff(renv::dependencies(dev = TRUE)[, "Package"], "R"))
if (length(missingDeps) > 0) {
  stop("Some required R packages are missing, install them with `renv::install(",
       paste(capture.output(dput(missingDeps)), collapse = ""), ")`")
} else {
  message("all required R packages are installed")
}

if (Sys.which("python3") != ""
    || (Sys.which("python.exe") != ""
        && suppressWarnings(isTRUE(startsWith(system2("python.exe", "--version", stdout = TRUE), "Python 3"))))) {
  message("checking for Python 3 - ok")
} else {
  message("Python 3 not found, some non-default configurations of REMIND will not work")
}

message("Finished setup checks. Your system is ready to run REMIND if there were no errors/warnings.")
