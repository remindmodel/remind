failed <- FALSE

expect_success_status <- function(output) {
    if (output$status != 0) {
        failed <<- TRUE
    }
    expect_equal(output$status, 0)
}

skip_if_previous_failed <- function(status) {
    if (failed) {
        skip("A previous test failed.")
    } else {
        return(invisible(TRUE))
    }
}
