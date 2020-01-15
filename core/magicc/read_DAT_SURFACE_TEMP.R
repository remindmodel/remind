# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# Load GAMS to R library
library(gdxrrw)

# Load GAMS path
igdx(system("dirname $( which gams )", intern = TRUE))

file <- "./magicc/DAT_SURFACE_TEMP.OUT"

# Parse MAGICC output file holding temperature
x <- read.fwf(file, skip = 20,
              col.names = read.table(file, skip = 19, nrows = 1, as.is = TRUE),
              widths = c(-6, 4, -6, 14, -6, 14, -6, 14, -6, 14, -6, 14))

# Get relevant years
years <- x[x$YEARS >= 1860 & x$YEARS <= 2300,1]

# Write global radiative foring to special .gdx file
wgdx.lst("p15_magicc_temp",
         list(list(name    = "pm_globalMeanTemperature",
                   type    = "parameter",
                   dim     = 1,
                   val     = cbind(1:length(years), x[x$YEARS %in% years,2]),
                   form    = "sparse",
                   uels    = list(years),
                   domains = "tall")))

