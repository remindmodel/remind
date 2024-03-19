# Load GAMS to R library
library(gdxrrw)

# Load GAMS path
igdx(system("dirname $( which gams )", intern = TRUE))

args <- commandArgs(trailingOnly = T)
# args <- c("climate-temp/emimif_ar6_harmonized_infilled_IAMC_climateassessment0000.csv")

csvpath <- args[1]

incsv <- read.csv(csvpath)

years <- as.numeric(sub("^X", "", names(incsv)[grepl("^X", names(incsv))]))

# # Relevant years in original REMIND implementation
# years <- x[x$YEARS >= 1860 & x$YEARS <= 2300,1]


# ================= Surface temperature

# Can be any percentile, as the choice of parameter set was already made
varname <- "Surface Temperature (GSAT)|MAGICCv7.5.3|50.0th Percentile"  

values <- t(as.vector(incsv[incsv$Variable == varname,grepl("^X", names(incsv))]))

# Write global surface temperature to special .gdx file
wgdx.lst("p15_magicc_temp",
         list(list(name    = "pm_globalMeanTemperature",
                   type    = "parameter",
                   dim     = 1,
                #    val     = cbind(1:length(years), x[x$YEARS %in% years,2]),
                   val     = cbind(1:length(years), values),
                   form    = "sparse",
                   uels    = list(years),
                   domains = "tall")))


# ================= Anthropogenic radiative forcing

# Can be any percentile, as the choice of parameter set was already made
varname <- "Effective Radiative Forcing|Basket|Anthropogenic|MAGICCv7.5.3|50.0th Percentile"  

values <- t(as.vector(incsv[incsv$Variable == varname,grepl("^X", names(incsv))]))

# Write global surface temperature to special .gdx file
wgdx.lst("p15_forc_magicc",
         list(list(name    = "p15_forc_magicc",
                   type    = "parameter",
                   dim     = 1,
                #    val     = cbind(1:length(years), x[x$YEARS %in% years,2]),
                   val     = cbind(1:length(years), values),
                   form    = "sparse",
                   uels    = list(years),
                   domains = "tall")))



