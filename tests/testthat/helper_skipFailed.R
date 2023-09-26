# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
helperSkipFailed <- FALSE

expectSuccessStatus <- function(output) {
    status <- attr(output, "status", exact = TRUE)
    if (0 != status) {
        helperSkipFailed <<- TRUE
    }
    expect_equal(status, 0)
}
expectFailStatus <- function(output) {
    status <- attr(output, "status", exact = TRUE)
    if (1 != status) {
        helperSkipFailed <<- TRUE
    }
    expect_equal(status, 1)
}

skipIfPreviousFailed <- function() {
    if (helperSkipFailed) {
        skip("A previous test failed.")
    } else {
        return(invisible(TRUE))
    }
}
