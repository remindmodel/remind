if (!exists("source_include")) {
  outputdir <- "output/B-putty_SSP2-NDC_restartWithAllIterationResults"
  lucode2::readArgs("outputdir")
}

scenario <- lucode2::getScenNames(outputdir)

get_line <- function() {
  # gets characters (line) from the terminal of from a connection
  # and stores it in the return object
  if (interactive()) {
    s <- readline()
  } else {
    con <- file("stdin")
    s <- readLines(con, 1, warn = FALSE)
    on.exit(close(con))
  }
  return(s)
}

outputFile <- file.path(outputdir, "plotIterations.Rmd")
if (file.exists(outputFile)) {
  cat(outputFile, " already exists, overwrite? (y/n): ")
  if (!identical(get_line(), "y")) {
    stop("aborting, because file already exists")
  }
}

cat("Which variables/parameters do you want to plot? Separate with commas. (default: p36_shUeCes_iter) ")
symbolNames <- get_line()
if (identical(symbolNames, "")) {
  symbolNames <- "p36_shUeCes_iter, p36_techCosts, p36_fe2es"
}
symbolNames <- trimws(strsplit(symbolNames, ",")[[1]])

rmdHeader <- paste0('---
output: html_document
title: plotIterations - ', paste(symbolNames, collapse = ", "), '
---')

rmdChunksForSymbol <- function(symbolName) {
  return(paste0('## ', symbolName, '

### Read Data from gdx
```{r}
', symbolName, 'Raw <- mip::getPlotData(
  "', symbolName, '",
  "/home/pascal/dev/remind/output/B-putty_SSP2-NDC_restartWithAllIterationResults"
)
str(', symbolName, 'Raw)
```
### Clean Data
```{r}
', symbolName, 'Clean <- ', symbolName, 'Raw
# filter and fix data here if needed
str(', symbolName, 'Clean)
```

### Create Plots
```{r, results = "asis"}
', symbolName, 'Plots <- mip::mipIterations(
  ', symbolName, 'Clean, returnGgplots = TRUE,
  xAxis = "year", slider = "iteration", facets = "region", color = NULL
)

renderPlot <- function(plot) {
  # customize plot here
  plot <- plot + ggplot2::theme_minimal()
  return(htmltools::tagList(plotly::ggplotly(plot)))
}

# show first plot outside of the loop because of quirky interaction between plotly and knitr
renderPlot(', symbolName, 'Plots[[1]])
lapply(', symbolName, 'Plots[-1], renderPlot)
```'))
}

writeLines(paste0(c(rmdHeader, sapply(symbolNames, rmdChunksForSymbol)), collapse = "\n\n"), outputFile)
# p36_shUeCes, p36_techCosts, p36_fe2es
