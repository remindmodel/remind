if (!exists("source_include")) {
  outputdir <- "output/B-putty_SSP2-NDC_restartWithAllIterationResults"
  lucode2::readArgs("outputdir")
}

outputdir <- normalizePath(outputdir)

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

now <- format(Sys.time(), "%Y-%m-%d_%H:%M:%S")
rmdPath <- file.path(outputdir, "plotIterations_", now, ".Rmd")

defaultSymbolNames <-
  "p36_techCosts, p36_shFeCes, p36_shUeCes, p36_demFeForEs, p36_prodEs, p36_fe2es, v36_deltaProdEs, v36_ProdEs"
cat("Which variables/parameters do you want to plot? Separate with commas. (default: ", defaultSymbolNames, ") ")
symbolNames <- get_line()
if (identical(symbolNames, "")) {
  symbolNames <- defaultSymbolNames
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
  "', outputdir, '"
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

writeLines(paste0(c(rmdHeader, sapply(symbolNames, rmdChunksForSymbol)), collapse = "\n\n"), rmdPath)

cat("Render plots to html? (y/n): ")
if (identical(get_line(), "y")) {
  if (rmarkdown::pandoc_available("1.12.3")) {
    rmarkdown::render(rmdPath, output_file = file.path(outputdir, "plotIterations_", now, ".html"))
  } else {
    warning(
      "Rendering to html failed: Could not find pandoc (>=1.12.3), please add it to your PATH environment variable.",
      "Run `Sys.getenv(\"RSTUDIO_PANDOC\")` in an RStudio console to get the path to RStudio's pandoc."
    )
  }
}
