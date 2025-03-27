require(magclass)
require(quitte)
require(piamutils)
require(lucode2)
require(stringr)
require(dplyr)


# TESTING
outputdir <- "./output/SSP2-NPi2025-AMT_2025-03-21_22.16.32"
# TESTING

message("### reportExtraEmissions: started adding extra emission variable at ", round(Sys.time()))

scenario <- getScenNames(outputdir)
# Reads, uses and appends to the default REMIND reporting mifs
remind_reporting_file <- file.path(outputdir, paste0("REMIND_generic_", scenario, ".mif"))

######################################################## ACTUAL CALCULATIONS

# Read full report
message("### reportExtraEmissions: Reading mif from ", remind_reporting_file, " at ", round(Sys.time()))
inreport <- read.report(remind_reporting_file, as.list = FALSE)
# Delete "+" and "++" from variable names
inreport <- deletePlus(inreport)

# Drop the global region. convertCEDS2024 already spreaded aviation and shipping emissions
# to all regions equally, so totals are preserved
inreport <- inreport[setdiff(getItems(inreport, dim = "region"), "GLO"), , ]
# Also drop scenario and model, but save them first
mifmodel <- getItems(inreport, "model")
mifscenario <- getItems(inreport, "scenario")
inreport <- dimReduce(inreport)

str(inreport)


# Loads CEDS 2020 emissions from the input data, at both CEDS and IAMC sectoral levels
cedsceds <- read.magpie("./core/input/p_emissions4ReportExtraCEDS.cs4r")
cedsiamc <- read.magpie("./core/input/p_emissions4ReportExtraIAMC.cs4r")

# Calculate emissions that are based on emission factors. Derive EFs based on
# CEDS 2020 emissions and REMIND 2020 activities

MtN_to_ktN2O <- 44 / 28 * 1000 # conversion from MtN to ktN2O
# Output magclass object
out <- NULL

# N2O from international shipping
ef <- setYears(
  dimReduce(cedsiamc[, 2020, "International Shipping.n2o_n"]) /
    inreport[, 2020, "ES|Transport|Bunkers|Freight (billion tkm/yr)"], NULL
)
out <- mbind(
  out,
  setNames(
    inreport[, , "ES|Transport|Bunkers|Freight (billion tkm/yr)"] * ef * MtN_to_ktN2O,
    "Emi|N2O|Extra|Transport|Bunkers|Freight (kt N2O/yr)"
  )
)
# CH4 from international shipping (should be very small)
ef <- setYears(
  dimReduce(cedsiamc[, 2020, "International Shipping.ch4"]) /
    inreport[, 2020, "ES|Transport|Bunkers|Freight (billion tkm/yr)"], NULL
)
out <- mbind(
  out,
  setNames(
    inreport[, , "ES|Transport|Bunkers|Freight (billion tkm/yr)"] * ef,
    "Emi|CH4|Extra|Transport|Bunkers|Freight (Mt CH4/yr)"
  )
)
# N2O from domestic+international aviation
ef <- setYears(
  dimReduce(cedsiamc[, 2020, "Aircraft.n2o_n"]) /
    inreport[, 2020, "ES|Transport|Pass|Aviation (billion pkm/yr)"], NULL
)
out <- mbind(
  out,
  setNames(
    inreport[, , "ES|Transport|Pass|Aviation (billion pkm/yr)"] * ef * MtN_to_ktN2O,
    "Emi|N2O|Extra|Transport|Pass|Aviation (kt N2O/yr)"
  )
)
# CH4 from residential+commercial, assume most of it is from gas use. Requires CEDS detail
ef <- setYears(
  dimReduce(cedsceds[, 2020, "1A4a_Commercial-institutional.ch4"] + cedsceds[, 2020, "1A4b_Residential.ch4"]) /
    inreport[, 2020, "FE|Buildings|Gases|Fossil (EJ/yr)"], NULL
)
out <- mbind(
  out,
  setNames(
    inreport[, , "FE|Buildings|Gases|Fossil (EJ/yr)"] * ef,
    "Emi|CH4|Extra|Buildings|Gases|Fossil (Mt CH4/yr)"
  )
)
# N2O from residential+commercial. Requires CEDS detail, assume it's all from fuel burning byproducts.
# Common solid fuels tend to have higher N2O EFs than common gaseous and liquid fuels, but here
# we are implicitly assuming the 2020 mix Solids+Liquids+Gases determines the EF.
# See https://www.epa.gov/system/files/documents/2024-02/ghg-emission-factors-hub-2024.pdf
tmp <- dimSums(inreport[, , c("FE|Buildings|Gases (EJ/yr)", "FE|Buildings|Liquids (EJ/yr)", "FE|Buildings|Solids (EJ/yr)")], dim = 3)
ef <- setYears(
  dimReduce(cedsceds[, 2020, "1A4a_Commercial-institutional.ch4"] + cedsceds[, 2020, "1A4b_Residential.ch4"]) /
    tmp[, 2020, ], NULL
)
out <- mbind(
  out,
  setNames(
    tmp * ef,
    "Emi|N2O|Extra|Buildings|Gases|Fossil (Mt CH4/yr)"
  )
)

# Aggregate to global. Since all variables are emissions, we can just sum them
out <- mbind(out, setItems(dimSums(out, dim = 1), dim = 1, value = "GLO"))
######################################################## END ACTUAL CALCULATIONS

# Already convert to quitte and ensure it has the same model and scenario as the original report
outmif <- as.quitte(out)
outmif$region <- as.character(outmif$region)
outmif[outmif$region == "GLO", "region"] <- "World"

# To make sure we don't have duplicates, we have to write the inreport part again
# Removing generated variables from inreport
# keepvars <- setdiff(getItems(inreport, "variable"), getItems(out, "variable"))
# inreport <- inreport[,,keepvars]

# # Before we convert to quitte, we have to handle some nonstandard units
# allvars <- getItems(inreport, "variable")
# getItems(inreport, "variable") <- str_replace(allvars, "\\(p\\|t\\)", "9999REPLACEME9999")

# # Do the the quitte conversion and replace back the units
# inmif <- as.quitte(inreport)
# inmif$unit <- str_replace(inmif$unit, "9999REPLACEME9999", "(p|t)")

# To avoid unsafe conversions from quitte to magclass, read the mif again already as a quitte
message("### reportExtraEmissions: Reading mif again to remove duplicates at ", round(Sys.time()))
inmif <- read.quitte(remind_reporting_file)
inmif <- filter(inmif, variable %in% setdiff(unique(inmif$variable),unique(outmif$variable)))

# Append the mifs, now that we don't have duplicates,
# and add the model and scenario back
fullmif <- rbind(inmif, outmif)
fullmif$scenario <- mifscenario
fullmif$model <- mifmodel

# Rewrite the calculated emissions to the REMIND reporting
# We can't do a simple append, because we had to remove the duplicates first
message("### reportExtraEmissions: Writing mif to ", remind_reporting_file, " at ", round(Sys.time()))
write.mif(fullmif, remind_reporting_file, append = FALSE)
# Redo the _withoutPlus.mif
piamutils::deletePlus(remind_reporting_file, writemif = TRUE)
message("### reportExtraEmissions: done adding extra emission variable at ", round(Sys.time()))
