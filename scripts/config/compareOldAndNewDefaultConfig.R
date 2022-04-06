#setwd("../..") # set wd to remind folder
source("scripts/config/readCfgFromRmd.R")
source("scripts/config/parseConfigRmd.R")
source("scripts/config/subTemplateWithConfig.R")
source("scripts/config/writeConfigRmd.R")

configRmdPath <- "config/defaultConfig.Rmd"




# Example Usage ---------------------------------------------------------------------------------------------------

# The usual cfg-object.
cfg <- readCfgFromRmd(configRmdPath)

# An object containing all info in the Rmd including descriptions of the parameters.
configDescr <- parseConfigRmd(configRmdPath)

# From configDescr one can create the Rmd again.
writeConfigRmd(configDescr, "config/defaultConfig2.Rmd")

# The configDescr object can be used to create main_old.gms from a template.
subTemplateWithConfig(
  templatePath = "main_template.gms",
  configRmdPath = configRmdPath,
  output = "main.gms")





# Test Correctness ------------------------------------------------------------------------------------------------


# parseConfigRmd -> writeConfigRmd -> parseConfigRmd does not loose information.
configDescr <- parseConfigRmd(configRmdPath)
writeConfigRmd(configDescr, "config/defaultConfig2.Rmd")
configDescr2 <- parseConfigRmd("config/defaultConfig2.Rmd")
stopifnot(identical(configDescr, configDescr2))


# The cfg-object from defaultConfig.Rmd has the same values as from default.cfg
source("config/default_old.cfg") # get cfg from default.cfg
cfgNew <- readCfgFromRmd(configRmdPath) # get cfg from defaultConfig.Rmd

## check same list entry names
stopifnot(identical(sort(names(cfgNew)), sort(names(cfg))))
nms <- names(cfgNew)

## check list entries without "files2export", "gms" to be identical
x <- sapply(setdiff(nms, c("files2export", "gms")), function(nm) identical(cfgNew[[nm]], cfg[[nm]]))
stopifnot(all(x))

## check files2export
stopifnot(identical(sort(cfgNew$files2export$start), sort(cfg$files2export$start)))
stopifnot(is.null(cfgNew$files2export$end), is.null(cfg$files2export$end))

## check gms

### all params from old cfg contained in new one
stopifnot(all(names(cfg$gms) %in% names(cfgNew$gms)))
# names(cfg$gms)[!names(cfg$gms) %in% names(cfgNew$gms)] # missing

### additional variables in new cfg
setdiff(names(cfgNew$gms), names(cfg$gms)) # these flags were defined in main.gms but not in default.cfg

### check values
nms <- names(cfg$gms)
x <- sapply(nms, function(nm) identical(cfgNew$gms[[nm]], cfg$gms[[nm]]))
stopifnot(all(x))



# test flags are the same between main_old.gms and main.gms
extractFlags <- function(lines) { # based on lines starting with $setglobal
  isFlagLine <- startsWith(tolower(trimws(lines)), "$setglobal")
  flagsLines <- trimws(substring(lines[isFlagLine], 11)) # without $setglobal
  sapply(strsplit(flagsLines, "\\s", fixed=FALSE), function(x) x[[1]])
}
oldFlags <- tolower(extractFlags(readLines("main_old.gms")))
newFlags <- tolower(extractFlags(readLines("main.gms")))
setdiff(newFlags, oldFlags) # Flags in defaultConfig.Rmd / main.gms but not in main_old.gms
setdiff(oldFlags, tolower(names(cfg$gms))) # Flags in main_old.gms but not in default.cfg
setdiff(oldFlags, newFlags) # Flags in main_old.gms but not in defaultConfig.Rmd / main.gms


# test switches are the same between main_old.gms and main.gms
extractSwitches <- function(lines) { # based on lines between "PARAMETERS" and ";"
  switchStart <- which(tolower(trimws(lines)) == "parameters")[1]
  switchEnd <- which((trimws(lines) == ";") & (seq_along(lines) > switchStart))[1]
  switchLines <- lines[(switchStart+1):(switchEnd-1)]
  switchLines <- switchLines[!startsWith(trimws(switchLines), "\"") & trimws(switchLines) != ""]
  sapply(strsplit(switchLines, "\\s", fixed=FALSE), function(x) x[[1]])
}
oldSwitches <- tolower(extractSwitches(readLines("main_old.gms")))
newSwitches <- tolower(extractSwitches(readLines("main.gms")))
setdiff(newSwitches, oldSwitches) # switches in main.gms but not in main_old.gms
setdiff(oldSwitches, newSwitches) # switches in main_old.gms but not in main.gms
setdiff(setdiff(oldSwitches, newSwitches), oldFlags) # switches in main_old.gms but not in main.gms are actually flags


