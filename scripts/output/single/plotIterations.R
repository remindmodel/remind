# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

symbolNames <- paste("pm_FEPrice_iter")
plotMappingDefault <- 'xAxis = "year", color = "iteration", facets = "region", slider = NULL'
plotMapping <- list()
generateHtml <- "y"
combineDims <- list()

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
  for (s in symbolNames) {
  cat("\n\nHow do you want to map the dimensions of ", s, "in the plot?",
      "Unused aesthetics need to be set to NULL. Combine dimensions with +.\n(default: ", plotMappingDefault, ")\n")
  answer <- getLine()
  if (!identical(trimws(answer), "")) {
    pm <- answer
    if (grepl("\\+", pm)) {
      cd <- strsplit(pm, ",")[[1]]
      cd <- cd[grepl("\\+", cd)]
      cd <- gsub(" |\"|\'", "", cd)
      cd <- setNames(gsub(".*=", "", cd),
                              gsub("=.*", "", cd))
      cd <- lapply(cd, function(x) strsplit(x, "\\+")[[1]])
      for (i in seq_along(cd)) {
        pm <- gsub(
          paste0("[\"\']", paste(cd[i][[1]], collapse = ".*"), "[\"\']"),
          paste0("\"", names(cd)[i], "\""),
          pm)
      }
      for (i in seq_along(cd)) {
        cd[i] <- paste0(s, 'Clean <- tidyr::unite(', s, 'Clean, "',
                        names(cd)[i], '", "',
                        paste0(cd[i][[1]], collapse = "\", \""),
                        '", sep = ".")\n')
      }
      cd <- paste0(
        '\n# Combine dimensions\n',
        paste0(cd, collapse = '\n')
      )
      combineDims[[s]] <- cd
      plotMapping[[s]] <- pm
    }
  } else {
    plotMapping[[s]] <- plotMappingDefault
    combineDims[[s]] <- ""
  }
}

rmdHeader <- paste0(
  "---\n",
  "output:\n",
  "  html_document:\n",
  "    toc: true\n",
  "    toc_float: true\n",
  "title: plotIterations - ", paste(symbolNames, collapse = ", "), "\n",
  "---\n",
  "\n",
  "## Setup\n",
  "```{r setup}\n",
  'runPath <- "', gsub("\\", "\\\\", outputdir, fixed = TRUE), '"\n',
  "```"
)

rmdChunksForSymbol <- function(symbolName) {

  # BEGIN TEMPLATE -------------------------
  return(paste0('
## ', symbolName, '

### Read Data from gdx
```{r ', symbolName,'___READ}
', symbolName, 'Raw <- mip::getPlotData("', symbolName, '", runPath)
str(', symbolName, 'Raw)
```

### Clean Data
```{r ', symbolName,'___CLEAN}
', symbolName, 'Clean <- ', symbolName, 'Raw
', 
combineDims[[symbolName]],
'
# filter and fix data here if needed
str(', symbolName, 'Clean)
```

### Create Plots
```{r ', symbolName,'___PLOT, results = "asis"}
', symbolName, 'Plots <- mip::mipIterations(
  plotData = ', symbolName, 'Clean, returnGgplots = TRUE,
  ', plotMapping[[symbolName]], '
)

# customize plots here if needed

# convert up to 20 plots via plotly::ggplotly and render
lapply(head(', symbolName, 'Plots, 20), print)
```'))
  # END TEMPLATE -------------------------
}

rmdFooter <- if (length(symbolNames) >= 2) {
  paste0(
    "\n",
    "## Show Plots side-by-side for Comparison\n",
    '```{r ', symbolNames[[1]], '_VS_', symbolNames[[2]], ', results = "asis"}\n',
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
