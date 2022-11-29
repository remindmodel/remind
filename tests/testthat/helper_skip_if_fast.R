skip_if_fast <- function() {
  if (identical(Sys.getenv("TESTTHAT_RUN_SLOW"), "")) {
    skip("Not run in default tests, use `make test-slow` to run (takes significantly longer than 10 minutes).")
  }
  else {
    return(invisible(TRUE))
  }
}
