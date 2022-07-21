# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# ---- Define set of runs that will be compared ----

# Ask user to select an element form a sequence.
chooseFromSequence <- function(sequence, title, default) {
  cat(
    "\n\n", title, 
    "\nLeave empty for: ", paste(default, collapse=", "), ".\n\n", 
    sep = "")
  cat(paste(seq_along(sequence), sequence, sep = ": "), sep = "\n")
  cat("\nNumbers, e.g, '1', '2,4', '3:5', ...:\n")
  input <- get_line()
  ids <- as.numeric(eval(parse(text = paste("c(", input, ")"))))
  if (any(!ids %in% seq_along(sequence))) {
    stop("Choose numbers between 1 and ", length(sequence))
  }
  chosenElements <- if (length(ids) == 0) default else sequence[ids]
  cat("\nchosen elements:\n  ", paste(chosenElements, collapse="\n  "), "\n\n", sep="")
  return(chosenElements)
}

# cs2 profiles
profileNamesDefault <- c("short", "default")
profilesFilePath <- normalizePath("./scripts/cs2/profiles.csv")
profiles <- read.delim(
  text = readLines(profilesFilePath, warn = FALSE), 
  header = TRUE, 
  sep = ";",
  colClasses = "character",
  comment.char = "#",
  quote = "")
profileNames <- profileNamesDefault


if (exists("outputdirs")) {
  # This is the case if this script was called via Rscript output.R
  
  profileNames <- chooseFromSequence(
    profiles$name, 
    "Choose profiles for cs2.",
    profileNamesDefault)
  
  listofruns <- list(list(
    period = "both",
    set = format(Sys.time(), "%Y-%m-%d_%H.%M.%S"),
    dirs = outputdirs))
  
} else {
  
  # This is the case if this script was called directly via Rscript
  listofruns <- list(
    list(
      period = "both",
      set = "cpl-Base",
      dirs = c("C_SDP-Base-rem-5","C_SSP1-Base-rem-5","C_SSP2-Base-rem-5","C_SSP5-Base-rem-5")),
    list(
      period = "both",
      set = "cpl-PkBudg900",
      dirs = c("C_SDP-PkBudg900-rem-5","C_SSP1-PkBudg900-rem-5","C_SSP2-PkBudg900-rem-5","C_SSP5-PkBudg900-rem-5")),
    list(
      period = "both",
      set = "cpl-PkBudg1100",
      dirs = c("C_SDP-PkBudg1100-rem-5","C_SSP1-PkBudg1100-rem-5","C_SSP2-PkBudg1100-rem-5","C_SSP5-PkBudg1100-rem-5")),
    list(
      period = "both",
      set = "cpl-PkBudg1300",
      dirs = c("C_SDP-PkBudg1300-rem-5","C_SSP1-PkBudg1300-rem-5","C_SSP2-PkBudg1300-rem-5","C_SSP5-PkBudg1300-rem-5")),
    list(
      period = "both",
      set = "cpl-NPi",
      dirs = c("C_SDP-NPi-rem-5","C_SSP1-NPi-rem-5","C_SSP2-NPi-rem-5","C_SSP5-NPi-rem-5")),
    list(
      period = "both",
      set = "cpl-SDP",
      dirs = c("C_SDP-Base-rem-5","C_SDP-NPi-rem-5","C_SDP-PkBudg1300-rem-5","C_SDP-PkBudg1100-rem-5","C_SDP-PkBudg1000-rem-5")),
    list(
      period = "both",
      set = "cpl-SSP1",
      dirs = c("C_SSP1-Base-rem-5","C_SSP1-NPi-rem-5","C_SSP1-PkBudg1300-rem-5","C_SSP1-PkBudg1100-rem-5","C_SSP1-PkBudg900-rem-5")),
    list(
      period = "both",
      set = "cpl-SSP2",
      dirs = c("C_SSP2-Base-rem-5","C_SSP2-NPi-rem-5","C_SSP2-PkBudg1300-rem-5","C_SSP2-PkBudg1100-rem-5","C_SSP2-PkBudg900-rem-5","C_SSP2-NDC-rem-5")),
    list(
      period = "both",
      set = "cpl-SSP5",
      dirs = c("C_SSP5-Base-rem-5","C_SSP5-NPi-rem-5","C_SSP5-PkBudg1300-rem-5","C_SSP5-PkBudg1100-rem-5","C_SSP5-PkBudg900-rem-5")))
  
}

# remove the NULL element
listofruns <- listofruns[!sapply(listofruns, is.null)]

# if no path in "dirs" starts with "output/" insert it at the beginning
# this is the case if listofruns was created in the lower case above !exists("outputdirs"), i.e. if this script was not called via Rscript output.R
for (i in 1:length(listofruns)) {
  if (!any(grepl("output/", listofruns[[i]]$dirs))) {
    listofruns[[i]]$dirs <- paste0("output/", listofruns[[i]]$dirs)
  }
}

# ---- Start compareScenarios either on the cluster or locally ----

start_comp <- function(
  outputdirs,
  outfilename,
  regionList,
  mainReg,
  profileName
) {
  if (!exists("slurmConfig")) {
    slurmConfig <- "--qos=standby"
  }
  jobname <- paste0(
      "compScen",
      ifelse(outfilename == "", "", "-"), outfilename,
      "-", profileName
    )
  cat("Starting ", jobname, "\n")
  on_cluster <- file.exists("/p/projects/")
  script <- "scripts/utils/run_compareScenarios2.R"
  clcom <- paste0(
    "sbatch ", slurmConfig,
    " --job-name=", jobname,
    " --output=", jobname, ".out",
    " --error=", jobname, ".out",
    " --mail-type=END --time=200 --mem-per-cpu=8000",
    " --wrap=\"Rscript ", script,
    " outputdirs=", paste(outputdirs, collapse = ","),
    " profileName=", profileName,
    " outfilename=", jobname,
    " regionList=", paste(regionList, collapse = ","),
    " mainRegName=", mainReg,
    "\"")
  cat(clcom, "\n")
  if (on_cluster) {
    system(clcom)
  } else {
    outfilename <- jobname
    tmp.env <- new.env()
    tmp.error <- try(sys.source(script, envir = tmp.env))
    if (!is.null(tmp.error))
      warning("Script ", script, " was stopped by an error and not executed properly!")
    rm(tmp.env)
  }
}

# ---- For each list entry call start script that starts compareScenarios ----
regionSubsetList <- remind2::toolRegionSubsets(file.path(listofruns[[1]]$dirs, "fulldata.gdx"))
# ADD EU-27 region aggregation if possible
if ("EUR" %in% names(regionSubsetList)) {
  regionSubsetList <- c(regionSubsetList, list(
    "EU27" = c("ENC", "EWN", "ECS", "ESC", "ECE", "FRA", "DEU", "ESW"))) # EU27 (without Ireland)
}

for (r in listofruns) {
  # Create multiple pdf files for H12 and subregions of H12
  for (reg in c("H12", names(regionSubsetList))) {
    if (exists("filename_prefix")) {
      fileName <- paste0(filename_prefix, ifelse(filename_prefix == "", "", "-"), r$set, "-", reg)
    } else {
      fileName <- paste0(r$set, "-", reg)
    }
    if (reg == "H12")
      regionList <- c("World","LAM","OAS","SSA","EUR","NEU","MEA","REF","CAZ","CHA","IND","JPN","USA")
    else
      regionList <- c(reg, regionSubsetList[[reg]])
    if (reg == "H12")
      mainRegName <- "World"
    else
      mainRegName <- reg
    for (profileName in profileNames) {
      start_comp(
        outputdirs = r$dirs, 
        outfilename = fileName, 
        regionList = regionList, 
        mainReg = mainRegName,
        profileName = profileName)
    }

    # plot additional pdf with Germany as focus region and exclusion of non-meaningful references in that context
    if (reg == "EUR") {
      fileName <- paste0(filename_prefix, ifelse(filename_prefix == "", "", "-"), r$set, "-DEU")
      start_comp(
        outputdirs = r$dirs, 
        outfilename = fileName, 
        regionList = regionList, 
        profileName = "AriadneDEU")
    }

  }
}
