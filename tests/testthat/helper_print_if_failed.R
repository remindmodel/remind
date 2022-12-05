print_if_failed <- function(output) {
    if (0 != output$status) {
        cat("Command stdout:")
        cat(output$stdout)
        cat("Command stderr:")
        cat(output$stderr)
    }
}
