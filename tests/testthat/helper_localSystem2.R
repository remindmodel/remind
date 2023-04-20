# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
localSystem2 <- function(command, args = character(),
                         stdout = TRUE, stderr = TRUE, stdin = "", input = NULL,
                         env = character(), wait = TRUE,
                         minimized = FALSE, invisible = TRUE, timeout = 0) {
    # Call via system2 in remind main folder in conditions as if we were not running
    # in tests.
    env <- paste0("unset R_PROFILE_USER;unset TESTTHAT;", env)
    withr::with_dir("../..", {
        suppressWarnings({
            output <- system2(command, args, stdout, stderr, stdin, input, env,
                              wait, minimized, invisible, timeout)
        })
    })
    # add status attribute which is missing if the exit code was 0
    if (is.null(attr(output, 'status', exact = TRUE))) {
        attr(output, 'status') <- 0
    }
    return(output)
}
