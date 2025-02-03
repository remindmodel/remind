
# Use this script to preserve scenario configuration in all config/scenario_config*.csv files if 
# you want to change the default values in main.gms. It adjusts the scenario_config files so that
# the scenarios will still be configured in the same way as before the defaults changed in main.gms.
# Author: David Klein

# What this script does:
# The script performs the following steps for all config/scenario_config*.csv files:
# 0. It lists the switches and their values that differ between main.gms and the new default
# 1. It lists the switches and the number of cases where these switches
#    1a. use the defaults from main.gms (are empty) before the change. 
#        (these switches are affected if the defaults in the main.gms change)
#    1b. already use the value that will become the new default after the change
#        (these switches can be set empty)
# 2. It then updates all config/scenario_config*.csv files in two steps:
#    2a. Find empty cells, meaning that they currently use the (old) defaults from the main.gms and set them to the old default.
#    2b. Find cells that already use the values that are about to become the new defaults and set them to empty.

# How to run it:
# Run this script *before* you change the default values in main.gms. This script only updates the scenario_config*.csv 
# files, not the main.gms. Please change the defaults in main.gms manually only after running this script.
# Enter the three pieces of information under user settings below and then run this script in the REMIND main folder.

# ---- User settings ----

path_remind        <- "~/0_GIT-models/remind-develop"  # path to the REMIND main folder
config.file        <- "config/scenario_config.csv"     # path to the scenario_config file you want to choose the new default from
newDefaultScenario <- "SSP2-NPi2025"                   # scenario that defines the new default
updateConfigs      <- FALSE                            # FALSE: show diagnostics only, TRUE: update all scenario_config*.csv files

# ---- Script ---- 

library(tidyverse)
library(readr)

setwd(path_remind)

# source all start scripts
invisible(sapply(list.files("scripts/start", pattern = "\\.R$", full.names = TRUE), source))

settings <- readCheckScenarioConfig(config.file, ".")
scenarios <- selectScenarios(settings = settings, interactive = FALSE, startgroup = "1")

flags <- "" # secretly required in configureCfg()

cfgDefaultOLD <- readDefaultConfig(".")
cfgDefaultNEW <- configureCfg(cfgDefaultOLD, newDefaultScenario, scenarios)

comp <- mapply("%in%", cfgDefaultOLD$gms, cfgDefaultNEW$gms)

if (all(comp)) stop("No differences found between main.gms and SSP2-NPi2025.")

# settings that are different between old default (main.gms) and new default (e.g. SSP2-NPi2025) 
different <- rbind(data.frame(cfgDefaultOLD$gms[!comp], row.names = "old"), 
                   data.frame(cfgDefaultNEW$gms[!comp], row.names = "new"))

# let readr::type_convert guess the column types. Numbers need to be numeric and no string
# because they will replace numeric values in the scenario configs later on
different |> 
  rownames_to_column(var = "name") |> # add new column "name" and fill it with rownames otherwise they get lost
  tibble()                         |> # convert to tibble
  type_convert()                   |> # guess column types
  suppressMessages() ->               # suppress the column specification message
  different

# we need to know the line number in which the "old" / "new" defaults are stored 
# to be able to access them in the the 'mutate' commands below
old <- which(different$name == "old")
new <- which(different$name == "new")

# initialize empty tibbles that will be filled with diagnostics
usingDefaults_OLD <- tibble()
usingDefaults_NEW <- tibble()

# ---- Loop over all scenario_config*.csv files

# list scenario_config files
scenfiles <- grep(pattern = "^scenario_config.*.csv$", value = T, x = dir("config/"))

for (filename in scenfiles) {
  # load complete scenario config including commented lines
  scenConf <- read_delim(file.path("config",filename), delim = ";", show_col_types = FALSE)
  
  filemameShort <- gsub(pattern = "scenario_config_|.csv","", filename)
  
  # keep original scenConf and at the end update it with what has changed
  updated <- scenConf 
  
  # if it does not exist attach dummy column "copyConfigFrom" (will be dropped later by 'select(...)')
  # to make the procedure further down work also for scenario config that don't have this column
  if (! "copyConfigFrom" %in% names(updated)) {
    updated[, "copyConfigFrom"] <- NA
  }

  # Common steps
  # 1. Drop comment lines
  # 2. Keep scenarios only that don't take their settings from another scenario

  updated <- updated              |> 
    filter(!grepl("^#", title))   |> # 1.
    filter(is.na(copyConfigFrom))    # 2.

  # ---- Diagnostics: find configs that use old defaults ----

  # Individual steps
  # 3. Only for switches whose default value will change (any_of(names(different))) count scenarios (sum()) that use the old default (is.na())
  # 4. Add a column with the name of the scenario_config*.csv
  # 5. Append row
  
  usingDefaults_OLD <- updated                 |> 
    summarize(across(any_of(names(different)),    # 3.
                     ~ sum(is.na(.x))))        |>
    add_column(name = filemameShort)           |> # 4.
    bind_rows(usingDefaults_OLD)                  # 5.

  # ---- Diagnostics: find configs that already use new defaults ----
  
  # Individual steps
  # 3. Only for switches whose default value will change (any_of(names(different))) count scenarios (sum()) that use the new default (different[new,cur_column()])
  # 4. Add a column with the name of the scenario_config*.csv
  # 5. Append row
  
  usingDefaults_NEW <- updated                 |> 
    summarize(across(any_of(names(different)),    # 3.
                     ~ sum(.x == pull(different[new,cur_column()])))) |>
    add_column(name = filemameShort)           |> # 4.
    bind_rows(usingDefaults_NEW)                  # 5.
  
  # ---- Update scenario_config*.csv file so that they work with new defaults in main.gms ----
  
  # Individual steps
  # 3. Keep switches only whose default values will change (also dropping 'copyConfigFrom' that might have been added above)
  # 4. For all columns set empty cells to old default 
  # 5. Set cells empty that already use the new default
  
  updated <- updated |> 
    select(title, any_of(names(different))) |> # 3.
    mutate(across(any_of(names(different)),    # 4.
                  ~ if_else(is.na(.x), pull(different[old,cur_column()]), .x))) |>
    mutate(across(any_of(names(different)),    # 5.
                  ~ if_else(.x == pull(different[new,cur_column()]), NA, .x)))

  # Update original scenConf with what has changed
  scenConf <- rows_update(scenConf, updated, by = "title")
  
  # Write to file
  if (updateConfigs) {
    #write_delim(scenConf, file = gsub("\\.csv", "-DK.csv", filename), delim = ";", na = "", eol = "\r\n")
    write_delim(scenConf, file = file.path("config", filename),        delim = ";", na = "", eol = "\r\n")
  }
}

# ---- Print diagnostics ----

message("The following switches differ between main.gms (old defaults) and SSP2-NPi2025 (new defaults):")
print(different)

message("The following scenario_config*.csv files use the defaults from main.gms and would be affected if defaults change in main.gms:")
print(usingDefaults_OLD |> filter(if_any(!any_of("name"), ~ !is.na(.)))) # keep rows only where there is at least one columns that is not NA (exclude the 'name' column)

message("The following scenario_config*.csv files use what is about to become the new default in main.gms and can be set empty:")
print(usingDefaults_NEW |> filter(if_any(!any_of("name"), ~ !is.na(.))))

if (updateConfigs) {
  message("Updated scenario_config*.csv files.")
} else {
  message("Only showing diagnostics. To actually update the scenario configs please set 'updateConfigs=TRUE'.")
}