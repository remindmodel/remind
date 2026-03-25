# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
############################# LOAD LIBRARIES #############################
library(dplyr,   quietly = TRUE,warn.conflicts =FALSE)
library(readr,   quietly = TRUE,warn.conflicts =FALSE)
library(ggplot2, quietly = TRUE,warn.conflicts =FALSE)
library(hms,     quietly = TRUE,warn.conflicts =FALSE)

if (!exists("source_include")) lucode2::readArgs("outputdirs")

# -----------------------------------------------------------------------
# ----------- Function: Read runtime from NEW coupled runs --------------
# -----------------------------------------------------------------------

# The automatic date parser from the tibble package used in read_csv gets 
# confused, because there are mixed types of date formates in the logfile. 
# The lines written by the R scripts are correctly formatted, the lines
# written by GAMS are missing leading zeros. Thus, the parser does not 
# recognize them and chooses "character" as column type for start.

# Funtion reading the runtime.log of a single run

readRun <- function(runDir) {
 a <- readr::read_csv(paste0(runDir,"/runtime.log"), 
                 col_names = c("start","phase", "iteration")) |> 
        mutate(start = gsub(" ([0-9]:)"," 0\\1", start))      |> # insert leading zero for hours   in malformed entries from GAMS 9:8:15    --> 09:8:15 
        mutate(start = gsub(":([0-9]:)",":0\\1", start))      |> # insert leading zero for minutes in malformed entries from GAMS 9:8:15    --> 9:08:15
        mutate(start = gsub("-([1-9]) ","-0\\1 ", start))     |> # insert leading zero for days    in malformed entries from GAMS 2025-11-1 --> 2025-11-01
        mutate(start = gsub("-([1-9])-","-0\\1-", start))     |> # insert leading zero for months  in malformed entries from GAMS 2025-2-1  --> 2025-02-1
        mutate(start = gsub(" ([0-9]{2}).([0-9]{2}).", " \\1:\\2:", start)) |> # in a few log time from R scripts was malformed 15.04.23 --> 15:04:23
        mutate(start = parse_datetime(start))                 |>
        suppressMessages()                                    |> 
        mutate(run = basename(runDir), .before = start)
}

# Read and process the runtime.logs of outputdirs

shapeData <- function(outputdirs) {
  data <- outputdirs |>
    lapply(readRun) |>
    bind_rows() |>
    group_by(run) |> 
    arrange(start) |> 
    ungroup() |>
    mutate(start = start - first(start)) |> # Calculate the start of each step relative to the start of the first step of the first run. 
    group_by(run) |>
    mutate(end = lead(start)) |> # make the start of n+1 ('lead(start') the end of n (end)
    mutate(start = hms::as_hms(start), end = hms::as_hms(end)) |>
    na.omit() # remove the last entry that has no "end" entry
}

# -----------------------------------------------------------------------
# --------------- Function: Read runtime from OLD coupled runs ----------
# -----------------------------------------------------------------------

# Bring old data to the same shape as new data

shapeOldData <- function(path_to_runtime_rds) {
  old <- readRDS(path_to_runtime_rds) |>
    as_tibble() |>
    mutate(iteration = 0) |> # dummy, not used in plot but required since the new runtime also has it
    mutate(phase = paste0(type,"-",section)) |>
    mutate(phase = gsub("rem-prep"  , "prepare", phase)) |>
    mutate(phase = gsub("rem-output", "output" , phase)) |>
    mutate(phase = gsub("rem-GAMS"  , "GAMS"   , phase)) |>
    mutate(phase = gsub("mag-GAMS"  , "MAgPIE" , phase)) |>
    mutate(run   = gsub("-(rem|mag)-[0-9]",""  , run))   |>
    group_by(run) |>
    arrange(start)

  # pick last entry of output and put end to start to have the end point availalbe when calculating the durations below
  end <- old |>
    filter(phase == "output") |> 
    slice_tail() |> 
    mutate(start = end)
    
  # append end to the rest of old and proceed with calcualting
  old <- bind_rows(old, end) |>
    select(c(run,start,phase,iteration)) |>
    ungroup() |>
    mutate(start = start - first(start)) |> # Calculate the start of each step relative to the start of the first step of the first run.
    group_by(run) |>
    mutate(end = lead(start)) |>
    mutate(start = hms::as_hms(start), end = hms::as_hms(end)) |>
    na.omit() # remove the last entry that has no "end" entry
}

# -----------------------------------------------------------------------
# ------------------------ Execute functions ----------------------------
# -----------------------------------------------------------------------

# Use this to let all runs start at minute 0, independent of their real sequence
#data <- outputdirs |>
#        lapply(shapeData) |>
#        bind_rows()

# Use this to keep the sequence of runs in time
data <- shapeData(outputdirs)

# Use this code to compare runtime to old coupled mode
#
# pathsNewCoupled <- c(
# "output/C_SSP2-NPi2025_2025-11-27_21.03.53",
# "output/C_SSP2-PkBudg1000_2025-11-28_08.08.09",
# "output/C_SSP2-PkBudg650_2025-11-28_21.27.26"
# )
# 
# pathsNewStandalone <- c(
# "output/SSP2-NPi2025_2025-11-27_21.02.51",
# "output/SSP2-PkBudg1000_2025-11-28_00.41.58",
# "output/SSP2-PkBudg650_2025-11-28_00.41.51"
# )
# 
# path_to_runtime_rds <- "/p/tmp/dklein/remMagNash-Comp/remind-before/runtime.rds"
# 
# oldCoupled    <- shapeOldData(path_to_runtime_rds)
# newCoupled    <- shapeData(pathsNewCoupled)
# newStandalone <- shapeData(pathsNewStandalone)
# 
# data <- bind_rows(newCoupled, newStandalone, oldCoupled)

# -----------------------------------------------------------------------
# ------------------------------ Plot -----------------------------------
# -----------------------------------------------------------------------
  
# Define order for proper ordering in the legend
#data <- data |> mutate(phase = factor(phase, levels=c("prepare","GAMS","solve","exoGAINS","iterativeEdgeTransport","MAgPIE","output",
#                                                      "rem-prep","rem-GAMS","rem-output","mag-prep","mag-GAMS","mag-output")))

data <- data |> mutate(phase = factor(phase, levels = c("prepare",
                                                        "GAMS",
                                                        "convGDX2MIF_REMIND2MAgPIE",
                                                        "MAgPIE",
                                                        "getMagpieData",
                                                        "solve",
                                                        "exoGAINS",
                                                        "iterativeEdgeTransport",
                                                        "output",
                                                        "mag-prep",     # old coupling only
                                                        "mag-output"))) # old coupling only

# Remove timestamp from scenario name
#datetimepattern <- "_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}\\.[0-9]{2}\\.[0-9]{2}"
#data$run <- gsub(datetimepattern, "_new", data$run)

#data$Phase_ordered <- factor(data$Phase,levels=c("SD","DD","CD","PC","CA"))
#data$Project_ordered <- reorder(data$Project,data$StartDate)

data$run <- factor(data$run, levels = rev(basename(outputdirs)))

data <- data |> mutate(run = factor(.data$run, levels = rev(unique(.data$run))))

p <- ggplot(data,aes(x=start, y=run, color=phase)) +
  geom_segment(aes(x=start,xend=end,yend=run), linewidth = 8) +
  scale_colour_discrete(guide=guide_legend(override.aes=list(size = 2))) +
  scale_color_manual(values = c("prepare"    = "#84A1E0", # "#4E84C4", # "#F4EDCA",
                                "GAMS"       = "#435BB5", # "#293352",
                                "getMagpieData" = "red",
                                "convGDX2MIF_REMIND2MAgPIE" = "yellow",
                                "solve"      = "#2D4175", # "#4E84C4",
                                "exoGAINS"   = "#C4961A",
                                "iterativeEdgeTransport" = "#D16103",
                                "output"     = "#84A1E0",
                                "MAgPIE"     = "#52854C",
                                "mag-prep"   = "#C3D7A4",
                                "mag-output" = "#C3D7A4")) +
  scale_x_time(sec.axis = dup_axis()) +
  ylab("") +
  xlab("")

ggsave("output/runtime.png", p, width = 16, height = 5)