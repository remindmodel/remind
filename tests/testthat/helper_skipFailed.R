# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
helperSkipFailed <- FALSE

expect_exit_status_n <- function(object, n = 0, invert = FALSE) {
    act <- quasi_label(rlang::enquo(object), arg = 'object')

    status <- attr(act[['val']], 'status', exact = TRUE)

    if (all(c('command', 'args') %in% names(attributes(act[['val']])))) {
        label <- paste0('`', attr(act[['val']], 'command', exact = TRUE), ' ',
                        paste(attr(act[['val']], 'args', exact = TRUE),
                              collapse = ' '),
                        '`')
    }
    else {
        label <- act[['lab']]
    }

    # empty trace to suppress testthat backtrace
    empty_trace <- structure(
        list(call      = list(),
             parent    = integer(0),
             visible   = logical(0),
             namespace = character(0),
             scope     = character(0)),
        row.names = integer(0),
        version   = 2L,
        class     = c('rlang_trace', 'rlib_trace', 'tbl', 'data.frame'))

    if (isFALSE(invert)) {
        if (n != status)
            helperSkipFailed <<- TRUE

        expect(n == status,
               sprintf('%s returned exit status %i, not %i', label, status, n),
               trace = empty_trace)
    }
    else {
        if (n == status)
            helperSkipFailed <<- TRUE

        expect(n != status,
               sprintf('%s returned exit status %i, which it should not',
                       label, status),
               trace = empty_trace)
    }

    invisible(act[['val']])
}

expectSuccessStatus <- function(output) {
    expect_exit_status_n(output, 0, FALSE)
}

expectFailStatus <- function(output) {
    expect_exit_status_n(output, 0, TRUE)
}

skipIfPreviousFailed <- function() {
    if (helperSkipFailed) {
        skip("A previous test failed.")
    } else {
        return(invisible(TRUE))
    }
}
