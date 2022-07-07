# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

symbolNames <- paste("pm_FEPrice_iter")
plotMapping <- 'xAxis = "year", color = "iteration", facets = "region", slider = "all_enty"'
generateHtml <- "y"

if (!exists("source_include")) {
  outputdir <- file.path("output", "B-putty_SSP2-NDC_restartWithAllIterationResults")
  lucode2::readArgs("outputdir", "symbolNames", "generateHtml")
}

outputdir <- normalizePath(outputdir)


getLine <- function() {
  # gets characters (line) from the terminal of from a connection
  # and stores it in the return object
  if (interactive()) {
    s <- readline()
  } else {
    con <- file("stdin")
    on.exit(close(con))
    s <- readLines(con, 1, warn = FALSE)
    if (identical(length(s), 0L)) {
      s <- ""
    }
  }
  stopifnot(identical(length(s), 1L))
  return(s)
}

now <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
rmdPath <- file.path(outputdir, paste0("plotIterations_", now, ".Rmd"))

# choose variables
cat("\n\nWhich variables/parameters do you want to plot? Separate with comma. (default: ", symbolNames, ") ")
answer <- getLine()
if (!identical(trimws(answer), "")) {
  symbolNames <- answer
}
symbolNames <- trimws(strsplit(symbolNames, ",")[[1]])

# choose plot mapping
cat("\n\nHow do you want to map the variable dimensions in the plot?",
    "Unused aesthetics need to be set to NULL. \n(default: ", plotMapping, ")\n")
answer <- getLine()
if (!identical(trimws(answer), "")) {
  plotMapping <- answer
}

rmdHeader <- paste0(
  "---\n",
  "output: html_document\n",
  "title: plotIterations - ", paste(symbolNames, collapse = ", "), "\n",
  "---\n",
  "\n",
  "## Setup\n",
  "```{r}\n",
  'runPath <- "', gsub("\\", "\\\\", outputdir, fixed = TRUE), '"\n',
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
  plotData = ', symbolName, 'Clean, returnGgplots = TRUE,
  ', plotMapping, '
)

# customize plots here if needed

# convert up to 10 plots via plotly::ggplotly and render
htmltools::tagList(lapply(head(', symbolName, 'Plots, 10), plotly::ggplotly))
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
if (!identical(trimws(answer), "")) {
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
