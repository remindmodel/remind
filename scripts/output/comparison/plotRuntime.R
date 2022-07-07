# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(dplyr)
library(tidyr)
library(ggplot2)
library(magclass)

getLine <- function() {
  # gets and returns characters (line) from the terminal or from a connection
  if (interactive()) {
    s <- readline()
  } else {
    s <- readLines(withr::local_connection(file("stdin")), 1, warn = FALSE)
  }
  return(s)
}

if (!exists("source_include")) {
  ## Define arguments that can be read from command line
  lucode2::readArgs("outputdirs")
}
stopifnot(length(outputdirs) >= 1)
cat("comparing the following runs:\n")
print(outputdirs)

defaultFilenameKeywords <- "Base, NDC, PkBudg900"
cat("Which filename keywords (case-insensitive regex) do you want to compare? Separate with commas. (default: ",
    defaultFilenameKeywords, ") ")
filenameKeywords <- getLine()
if (identical(filenameKeywords, "")) {
  filenameKeywords <- defaultFilenameKeywords
}
filenameKeywords <- trimws(strsplit(filenameKeywords, ",", fixed = TRUE)[[1]])

defaultComparisonProperty <- "config$gms$buildings"
cat("Which property in runstatistics.rda do you want to compare? (default: ", defaultComparisonProperty, ") ")
comparisonProperty <- getLine()
if (identical(comparisonProperty, "")) {
  comparisonProperty <- defaultComparisonProperty
}
comparisonProperty <- trimws(strsplit(comparisonProperty, "$", fixed = TRUE)[[1]])
simpleCapitalize <- function(x) {
  return(paste(toupper(substring(x, 1, 1)), substring(x, 2), sep = ""))
}
comparisonPropertyLabel <- simpleCapitalize(tail(comparisonProperty, 1))

# FUNCTIONS ===============================================================

readRun <- function(runDir) {
  loadRunStatistics <- function() {
    # new function, so load cannot pollute readRun namespace
    stats <- NULL
    load(file.path(runDir, "runstatistics.rda"))
    stopifnot(!is.null(stats))
    return(stats)
  }
  runStatistics <- loadRunStatistics()

  statsFull <- gdx::readGDX(file.path(runDir, "fulldata.gdx"), "p80_repy_iteration") %>%
    as.data.frame() %>%
    filter(Data1 == "resusd") %>%
    filter(Value > 0) %>%
    subset(select = c("Data2", "Region", "Value")) %>%
    rename(Iteration = Data2, Time = Value) %>%
    mutate(
      Time = as.difftime(Time, units = "secs"),
      Name = runStatistics$config$title,
      ComparisonProperty = runStatistics[[comparisonProperty]],
      Runtime = runStatistics$runtime,
      Preparationtime = runStatistics$timePrepareEnd - runStatistics$timePrepareStart,
      Outputtime = runStatistics$timeOutputEnd - runStatistics$timeOutputStart,
      .before = Iteration
    )
  names(statsFull)[names(statsFull) == "ComparisonProperty"] <- comparisonPropertyLabel
  return(statsFull)
}


getFilenameKeyword <- function(filenames) {
  return(unlist(lapply(filenames, function(filename) {
    matchKeyword <- function(keyword) {
      return(grepl(keyword, filename, ignore.case = TRUE))
    }
    matchingKeyword <- filenameKeywords[vapply(filenameKeywords, matchKeyword, logical(1))]
    if (length(matchingKeyword) != 1) {
      warning('Each filename must match exactly one keyword, but "', filename, '" matched ', length(matchingKeyword),
              " keywords (", paste(matchingKeyword, collapse = ", "), "), setting FilenameKeyword for this file to NA")
      return(NA)
    }
    return(matchingKeyword)
  })))
}


# LOAD AND PROCESS STATISTICS ===========================================

# read statistics from all runs

stats <- outputdirs %>%
  lapply(readRun) %>%
  bind_rows(.id = "Scenario") %>%
  mutate(
    Scenario = lapply(Scenario, basename),
    FilenameKeyword = getFilenameKeyword(Name),
    .before = .data[[comparisonPropertyLabel]]
  )

# This df lists only the max solver time (across regions) in each iteration
statsIter <- stats %>%
  group_by(Scenario, Iteration) %>%
  slice(which.max(Time)) %>%
  rename(MaxTime = Time)

# This df lists only the average max solver time (across iterations) for each run
statsRun <- statsIter %>%
  group_by(across(-c(Region, Iteration, MaxTime))) %>%
  summarise(
    AvgTime = mean(MaxTime),
    Iterations = max(as.numeric(Iteration)),
    .groups = "drop"
  ) %>%
  mutate(InterSolveTime = Runtime / Iterations - AvgTime)


# PLOT ====================================================================


# Boxplot: Solvertime -----------------------------------------------------
solverTimePlot <- ggplot() +
  geom_boxplot(
    aes(.data[[comparisonPropertyLabel]], Time, fill = "All"),
    stats %>%
      mutate(Time = as.numeric(Time, units = "mins"))
  ) +
  geom_boxplot(
    aes(.data[[comparisonPropertyLabel]], MaxTime, fill = "Bottleneck Region"),
    statsIter %>%
      mutate(MaxTime = as.numeric(MaxTime, units = "mins"))
  ) +
  scale_y_continuous("Solver time in each iteration and region [min]") +
  scale_fill_brewer(palette = "Greens", name = "Region Selection") +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank()
  )

# Rectangle: Runtime ------------------------------------------------------

# one green and orange rectangle per run
runtimeRectanglePlot <- statsRun %>%
  mutate(across(c(AvgTime, InterSolveTime), as.numeric, units = "mins")) %>%
  ggplot(aes(alpha = 0.25)) +
  geom_rect(aes(
    xmin = 0, ymin = 0, xmax = Iterations, ymax = AvgTime,
    fill = "Solver", color = "Solver"
  )) +
  geom_rect(aes(
    xmin = 0, ymin = AvgTime, xmax = Iterations, ymax = AvgTime + InterSolveTime,
    fill = "InterSolve", color = "InterSolve"
  )) +
  geom_text(aes(
    x = Iterations / 2, y = AvgTime + InterSolveTime / 2, label = Name
  ), size = 2.5) +
  facet_grid(~.data[[comparisonPropertyLabel]]) +
  scale_x_continuous("Iterations") +
  scale_y_continuous("Average time per iteration [min]") +
  scale_fill_brewer(
    palette = "Spectral",
    breaks = c("InterSolve", "Solver"),
    limits = c("Output", "InterSolve", "Solver", "Preparation"),
    name = "Period"
  ) +
  scale_color_brewer(
    palette = "Spectral",
    breaks = c("InterSolve", "Solver"),
    limits = c("Output", "InterSolve", "Solver", "Preparation"),
    guide = F
  ) +
  scale_alpha_continuous(guide = FALSE) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid.minor.x = element_blank()
  )

# Stacked bar: Computation time -------------------------------------------

stackedBarPlot <- statsRun %>%
  mutate(
    Preparation = Preparationtime,
    Solver = AvgTime * Iterations,
    InterSolve = InterSolveTime * Iterations,
    Output = Outputtime,
    FilenameKeyword = as.character(FilenameKeyword)
  ) %>%
  pivot_longer(c(Preparation, Solver, InterSolve, Output),
               names_to = "Time", values_to = "Value"
  ) %>%
  group_by(.data[[comparisonPropertyLabel]], FilenameKeyword, Time) %>%
  summarize(Value = mean(Value), .groups = "drop") %>%
  select(c(.data[[comparisonPropertyLabel]], FilenameKeyword, Time, Value)) %>%
  mutate(Value = as.numeric(Value, units = "mins")) %>%
  ggplot() +
  geom_bar(
    aes(.data[[comparisonPropertyLabel]], Value,
        fill = factor(Time, levels = c("Output", "InterSolve", "Solver", "Preparation"))
    ),
    stat = "identity"
  ) +
  facet_grid(FilenameKeyword ~ .) +
  scale_y_continuous("Computation time [min]", sec.axis = sec_axis(~ . / 60, name = "[h]")) +
  scale_fill_brewer(name = "Period", palette = "Spectral") +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank()
  )



# Scatter: Solver time ----------------------------------------------------
regionSolverTimePlot <- ggplot(stats, aes(x = as.numeric(Iteration),
                  y = as.numeric(Time, unit = "mins"),
                  color = Region)) +
  geom_point() +
  facet_wrap(~FilenameKeyword + .data[[comparisonPropertyLabel]]) +
  scale_y_continuous("Solver time [min]") +
  scale_x_continuous("Iteration") +
  theme_bw()

# Create Output pdf and html files
now <- format(Sys.time(), "%Y-%m-%d_%H:%M:%S")
plotRuntimePdfPath <- paste0("plotRuntime_", now, ".pdf")
withr::with_pdf(plotRuntimePdfPath, {
  print(solverTimePlot)
  print(runtimeRectanglePlot)
  print(stackedBarPlot)
  print(regionSolverTimePlot)
})

plotRuntimeHtmlPath <- paste0("plotRuntime_", now, ".html")
htmltools::save_html(htmltools::tagList(plotly::ggplotly(solverTimePlot),
                                        plotly::ggplotly(runtimeRectanglePlot),
                                        plotly::ggplotly(stackedBarPlot),
                                        plotly::ggplotly(regionSolverTimePlot)),
                     file = plotRuntimeHtmlPath,
                     libdir = "plotRuntimeDependencies")
cat("plotRuntime finished, see ", plotRuntimePdfPath, " and ", plotRuntimeHtmlPath, " in ", getwd(), "\n")
