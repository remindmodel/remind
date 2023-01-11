# Source everything from scripts/start so that all functions are available everywhere
invisible(sapply(list.files("../../scripts/start", pattern = "\\.R$", full.names = TRUE), source))
