local_system2 <- function(command, args = character(),
                          stdout = "", stderr = "", stdin = "", input = NULL,
                          env = character(), wait = TRUE,
                          minimized = FALSE, invisible = TRUE, timeout = 0) {
    # Call via system2 in remind main folder in conditions as if we were not running
    # in tests.
    env <- paste0(env, "unset R_PROFILE_USER;unset TESTTHAT;")
    withr::with_dir("../..", {
        system2(command, args, stdout, stderr, stdin, input, env, wait, minimized,
                invisible, timeout)
    })
}
