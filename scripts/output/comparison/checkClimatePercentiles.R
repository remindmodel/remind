# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#
# This script is used to check the temperature outcomes of MAGICC when run inside REMIND
#
# The In-GAMS version of MAGICC can only run only one configuration (that is, parametrization) of MAGICC at a time, 
# picked in cfg$climate_assessment_magicc_prob_file_iteration. The available configuration files were designed to 
# roughly reproduce a certain quantile outcome of 2100 temperature for scenarios that are as similar as possible to 
# an RCP (hence the nomenclature of the config files e.g. RCP20_50.json will be close to the 50th percentile outcome in 
# a RCP2.0-like scenario). This quantile outcome is of course not guaranteed, so this script helps check the validity of
# the assumed quantile against the 600-member MAGICC7 AR6 assessment that is run by default at the end of each run. 
# Therefore, for it to work, the output script MAGICC7_AR6.R must have already run and added the `MAGICC7 AR6|**` 
# variables to `REMIND_generic_*.mif`. To verify the output, check the figures in `check_output_figures.pdf` and the 
# table in `check_output_summary.csv`
#
require(tidyverse)
require(quitte)
require(gdx)
require(yaml)

cat("===================== STARTING checkClimatePercentiles.R", "\n")
cat("===================== see output for final location of output files", "\n")
lucode2::readArgs("outputdirs")
cat("outputdirs: ",outputdirs)
runFolders <- normalizePath(outputdirs) # Remove trailing slashes
runFolders <- normalizePath(outputdirs) # Remove trailing slashes

# checkscenarios <- basename(runFolders)
cat("Checking scenarios:\n\t", paste0(basename(runFolders), collapse = "\n\t"), "\n")

# Extract RCP configuration from cfg.txt
usedRCPs <- map_dfr(runFolders, function(folder) {
    cfg <- read_yaml(file.path(folder, "cfg.txt"))
    tibble(
        scenario = cfg$title,
        rcp = basename(cfg$climate_assessment_magicc_prob_file_iteration) %>% str_remove(".json$")
    )
})

# Read pm_globalMeanTemperature from the MAGICC gdxs
gdxFiles <- file.path(runFolders, "p15_magicc_temp.gdx")
gdxAvailable <- file.exists(gdxFiles)
if (any(!gdxAvailable)) {
    warning("Missing p15_magicc_temp.gdx files in ", paste(basename(runFolders[!gdxAvailable]), collapse = ", "))
    gdxFiles <- gdxFiles[gdxAvailable]
}
gdxData <- map_dfr(gdxFiles, function(gdxFn) {
        cfg <- read_yaml(file.path(dirname(gdxFn), "cfg.txt"))
        mutate(as.tibble(read.gdx(gdxFn, "pm_globalMeanTemperature")), scenario = cfg$title)
    }) %>%
    rename(period = tall) %>%
    mutate(variable = "pm_globalMeanTemperature", region = "World", unit = "K", model = "MAGICC7 In-GAMS")

# Read reporting data. Requires MAGICC7_AR6 to have been successfully run
mifFiles <- list.files(runFolders, pattern = ".mif", full.names = TRUE) 
mifFiles <- mifFiles[str_detect(mifFiles, "REMIND_generic_.*") &! str_detect(mifFiles, "withoutPlus")]
mifData <- read.quitte(mifFiles) %>% 
    filter(region == "World", variable %in% c(
        "MAGICC7 AR6|Surface Temperature (GSAT)|10.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|33.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|50.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|67.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|90.0th Percentile"
        )) %>%
    mutate(model = "MAGICC7 AR6", variable = str_split_i(variable,"\\|",3))

# Join GDX & MIF data and filter to only the relevant scenarios
joinedData <- bind_rows(
    right_join(usedRCPs, mifData, by=join_by(scenario)),
    right_join(usedRCPs, gdxData, by=join_by(scenario))
)

# Generate and write basic comparison plot
joinedData %>%
    ggplot(aes(x = period, y = value, color = variable, linetype = model)) +
    geom_path() +
    facet_wrap(~scenario + rcp, scales = "free") +
    xlim(2000,2100) +
    theme(legend.position = "bottom")
pdfFile <- file.path(getwd(), paste0("climate_percentile_plots_", format(Sys.time(), "%y%m%dT%H%M%S"), ".pdf"))
cat("===================== Writing comparison plots to: '", pdfFile, "'\n")
ggsave(pdfFile, width = 210, height = 297, units = "mm")

# Generate and write summary table
summaryTable <- joinedData %>%
    filter(period %in% c(2050,2100)) %>%
    select(-model) %>%
    pivot_wider(names_from = variable, values_from = value) 
summaryFile <- file.path(getwd(), paste0("climate_percentile_summary_", format(Sys.time(), "%y%m%dT%H%M%S"), "csv"))
cat("===================== Writing comparison table to: '", summaryFile, "'\n")
write.table(summaryTable, summaryFile, row.names = FALSE)

cat("===================== checkClimatePercentile.R done", "\n")
