symbolNames <- paste(
  "p36_techCosts, p36_shFeCes, p36_shUeCes, p36_demFeForEs, p36_prodEs, p36_fe2es,",
  "v36_deltaProdEs, v36_ProdEs"
)
generateHtml <- "y"

if (!exists("source_include")) {
  outputdir <- file.path("output", "B-putty_SSP2-NDC_restartWithAllIterationResults")
  lucode2::readArgs("outputdir", "symbolNames", "generateHtml")
}

outputdir <- sub('[/\\]+$', '', normalizePath(outputdir))

getLine <- function() {
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
rmdPath <- file.path(outputdir, paste0("plotIterations_", now, ".Rmd"))

cat("Which variables/parameters do you want to plot? Separate with comma. (default: ", symbolNames, ") ")
answer <- getLine()
if (!identical(answer, "")) {
  symbolNames <- answer
}
symbolNames <- trimws(strsplit(symbolNames, ",")[[1]])

rmdHeader <- paste0(
  "---\n",
  "output: html_document\n",
  "title: plotIterations - ", paste(symbolNames, collapse = ", "), "\n",
  "---\n",
  "\n",
  "## Setup\n",
  "```{r}\n",
  'runPath <- "', outputdir, '"\n',
  "```"
)

rmdChunksForSymbol <- function(symbolName) {
  # BEGIN TEMPLATE -------------------------
  return(paste0('
## ', symbolName, '

### Read Data from gdx
```{r}
', symbolName, 'Raw <- mip::getPlotData("', symbolName, '", runPath)
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

# customize plots here if needed

# convert up to 5 plots via plotly::ggplotly and render
htmltools::tagList(lapply(head(', symbolName, 'Plots, 5), plotly::ggplotly))
```'))
  # END TEMPLATE -------------------------
}

rmdFooter <- if (length(symbolNames) >= 2) {
  paste0(
    "\n",
    "## Show Plots side-by-side for Comparison\n",
    '```{r, results = "asis"}\n',
    "mip::sideBySidePlots(list(", symbolNames[[1]], "Plots[[1]], ", symbolNames[[2]], "Plots[[1]]))\n",
    "```"
  )
} else {
  NULL
}

writeLines(paste0(c(rmdHeader, vapply(symbolNames, rmdChunksForSymbol, character(1)), rmdFooter),
  collapse = "\n\n"
), rmdPath)

cat("Render plots to html? (default: ", generateHtml, ") ")
answer <- getLine()
if (!identical(answer, "")) {
  generateHtml <- tolower(answer)
}
if (generateHtml %in% c("y", "yes")) {
  if (rmarkdown::pandoc_available("1.12.3")) {
    rmarkdown::render(rmdPath, output_file = file.path(outputdir, paste0("plotIterations_", now, ".html")))
  } else {
    warning(
      "Rendering to html failed: Could not find pandoc (>=1.12.3), please add it to your PATH environment variable.",
      "Run `Sys.getenv(\"RSTUDIO_PANDOC\")` in an RStudio console to get the path to RStudio's pandoc."
    )
  }
}
