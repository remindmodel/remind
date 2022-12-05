failed <- FALSE

expect_success_status <- function(output) {
    status <- attr(output, "status", exact = TRUE)
    if (0 != status) {
        failed <<- TRUE
    }
    expect_equal(status, 0)
}

skip_if_previous_failed <- function() {
    if (failed) {
        skip("A previous test failed.")
    } else {
        return(invisible(TRUE))
    }
}
