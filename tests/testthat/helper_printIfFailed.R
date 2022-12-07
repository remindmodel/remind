printIfFailed <- function(output) {
    if (0 != attr(output, "status", exact = TRUE)) {
        cat("Command output:\n")
        cat(output, sep="\n")
    }
}
