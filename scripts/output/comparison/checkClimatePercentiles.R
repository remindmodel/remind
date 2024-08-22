# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# This script is used to check the temperature outcomes of MAGICC when run inside
# REMIND
# The In-GAMS version of MAGICC can only run only one configuration (that is, parametrization)
# of MAGICC at a time, picked in cfg$climate_assessment_magicc_prob_file_iteration
# The available configuration files were designed to roughly reproduce a certain quantile outcome
# of 2100 temperature for scenarios that are as similar as possible to an RCP (hence the nomenclature
# of the config files e.g. RCP20_50.json will be close to the 50th percentile outcome in a RCP2.0-like
# scenario)
# This quantile outcome is of course not guaranteed, so this script helps check the validity of
# the assumed quantile against the 600-member MAGICC7 AR6 assessment that is run by default
# at the end of each run. Therefore, for it to work, the output script MAGICC7_AR6.R must
# have already run and added the `MAGICC7 AR6|**` variables to `REMIND_generic_*.mif`.
#
# To verify the output, check the figures in `check_output_figures.pdf` and the table in
# `check_output_summary.csv`

require(tidyverse)
require(quitte)
require(gdx)
require(yaml)

cat("===================== STARTING checkClimatePercentiles.R", "\n")
cat("===================== see output for final location of output files", "\n")
lucode2::readArgs("outputdirs")
runfolders <- outputdir

checkscenarios <- basename(runfolders)
cat("checkscenarios", checkscenarios, "\n")


# Get a value from the cfg file in a folder
get_cfgval <- function(runfolder, name) {
    read_yaml(paste0(runfolder,"/cfg.txt"))[[name]]
}

# Get the configuration names to have as a reference
usedconfigs <- bind_rows(lapply(1:length(runfolders),
    # \(i) read_yaml(paste0(runfolders,"/cfg.txt")[i])$climate_assessment_magicc_prob_file_iteration %>% basename %>% str_remove(".json$")
    \(i) tibble(
        scenario = get_cfgval(runfolders[i], "title"), 
        usedconfig = get_cfgval(runfolders[i], "climate_assessment_magicc_prob_file_iteration") %>% basename %>% str_remove(".json$")
        )
))

# Read pm_globalMeanTemperature from the MAGICC gdxs
tempgdxs <- paste0(runfolders,"/p15_magicc_temp.gdx")
gdxdata <- bind_rows(
    lapply(
    1:length(checkscenarios),
    \(i) mutate(read.gdx(tempgdxs[i], "pm_globalMeanTemperature"),scenario = get_cfgval(dirname(tempgdxs[i]), "title")
    ))) %>%
    rename(period = tall) %>%
    mutate(variable = "pm_globalMeanTemperature", region = "World", unit = "K") %>%
    mutate(model = "MAGICC7 In-GAMS")



# Read reporting data. Requires MAGICC7_AR6 to have been successfully run
filelist <- list.files(runfolders, pattern = ".mif", full.names = TRUE) 
miflist <- filelist[str_detect(filelist, "REMIND_generic_.*")&!str_detect(filelist, "withoutPlus")]

mifdata <- read.quitte(miflist)
miftempdata <- mifdata %>% 
    filter(region == "World", variable %in% c(
        "MAGICC7 AR6|Surface Temperature (GSAT)|10.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|33.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|50.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|66.0th Percentile",
        "MAGICC7 AR6|Surface Temperature (GSAT)|90.0th Percentile"
        )) %>%
        mutate(model = "MAGICC7 AR6") %>%
        mutate(variable = str_split_i(variable,"\\|",3))


# Concatenate all data, joining the usedconfigs as an extra column for reference
alldata <- bind_rows(left_join(usedconfigs,miftempdata), left_join(usedconfigs,gdxdata))

# Basic comparison plot
alldata %>%
    ggplot(aes(x = period, y = value, color = variable, linetype = model)) +
    geom_path() +
    facet_wrap(~scenario + usedconfig, scales = "free") +
    xlim(2000,2100) +
    theme(legend.position = "bottom")
outpdffname <- "check_outcomes_plots.pdf"
cat("===================== Writing comparison plots to: ", outpdffname, "\n")
ggsave(outpdffname, width = 210, height = 297, units = "mm")
cat("===================== written in location: ", normalizePath(outpdffname), "\n")

# Summary table
summarytable <- alldata %>%
    filter(period %in% c(2050,2100)) %>%
    select(-model) %>%
    pivot_wider(names_from = variable, values_from = value) 
outtablefname <- "check_outcomes_summary.csv"
cat("===================== Writing comparison table to: ", outtablefname, "\n")
write.table(summarytable, outtablefname, row.names = F)
cat("===================== written in location: ", normalizePath(outtablefname), "\n")

