require(magclass)
require(quitte)
require(piamutils)
require(lucode2)
require(stringr)
require(dplyr)
require(magrittr)

readArgs("outputdir")

message("### reportExtraEmissions: started adding extra emission variable at ", round(Sys.time()))

scenario <- getScenNames(outputdir)
# Reads, uses and appends to the default REMIND reporting mifs
remind_reporting_file <- file.path(outputdir, paste0("REMIND_generic_", scenario, ".mif"))

######################################################## ACTUAL CALCULATIONS

# Read full report
message("### reportExtraEmissions: Reading mif from ", remind_reporting_file, " at ", round(Sys.time()))

# List here the variables used in the calculation. This is currently required to avoid converting
# the whole mif to magpie, which is both slow and introduces all sorts of metadata errors.
reportVars <- c(
  "ES|Transport|Bunkers|Freight",
  "ES|Transport|Pass|Aviation",
  "FE|Buildings|Gases|Fossil",
  "FE|Buildings|Gases",
  "FE|Buildings|Liquids",
  "FE|Buildings|Solids"
)

# We do need to read the whole mif though, to be able to remove duplicates later
inmif <- read.quitte(remind_reporting_file, check.duplicates = FALSE)
report <- deletePlus(inmif)

inreport <- report %>%
  filter(.data$variable %in% reportVars, region != "World") %>%
  as.magpie() %>%
  collapseDim()

# Loads CEDS 2020 emissions from the input data, at both CEDS and IAMC sectoral levels
cedsceds <- read.magpie("./input/p_emissions4ReportExtraCEDS.cs4r")
cedsiamc <- read.magpie("./input/p_emissions4ReportExtraIAMC.cs4r")

# Calculate emissions that are based on emission factors. Derive EFs based on
# CEDS 2020 emissions and REMIND 2020 activities

deriveEF <- function(emirefyear, actreffull, refyear = 2020, convyear = NULL) {
  # EF in the reference year
  ef2020 <- setYears(
    emirefyear /
      actreffull[, refyear, ], NULL
  )

  # Preallocate with actreffull to ensure they will multiply nicely later
  ef <- actreffull
  ef[, , ] <- ef2020

  # If convyear was given, assume linear convergence towards
  # the global emission factor in convyear
  if (!is.null(convyear)) {
    gef <- as.numeric(
      dimSums(emirefyear, dim = 1) / dimSums(actreffull[, refyear, ], dim = 1)
    )
    ef <- convergence(
      ef, gef,
      start_year = 2020, end_year = convyear, type = "linear"
    )
  }
  return(ef)
}


MtN_to_ktN2O <- 44 / 28 * 1000 # conversion from MtN to ktN2O
# Output magclass object
out <- NULL

# N2O from international shipping
# Converge to global EF in 2060
ef <- deriveEF( 
  dimReduce(cedsiamc[, 2020, "International Shipping.n2o_n"]),
  inreport[, , "ES|Transport|Bunkers|Freight"],
  refyear = 2020,
  convyear = 2060
  )

out <- mbind(
  out,
  setNames(
    inreport[, , "ES|Transport|Bunkers|Freight"] * ef * MtN_to_ktN2O,
    "Emi|N2O|Extra|Transport|Bunkers|Freight (kt N2O/yr)"
  )
)
# CH4 from international shipping (should be very small)
# Converge to global EF in 2060
ef <- deriveEF( 
  dimReduce(cedsiamc[, 2020, "International Shipping.ch4"]),
  inreport[, , "ES|Transport|Bunkers|Freight"],
  refyear = 2020,
  convyear = 2060
  )


out <- mbind(
  out,
  setNames(
    inreport[, , "ES|Transport|Bunkers|Freight"] * ef,
    "Emi|CH4|Extra|Transport|Bunkers|Freight (Mt CH4/yr)"
  )
)
# N2O from domestic+international aviation. 
# Converge to global EF in 2060
ef <- deriveEF( 
  dimReduce(cedsiamc[, 2020, "Aircraft.n2o_n"]),
  inreport[, , "ES|Transport|Pass|Aviation"],
  refyear = 2020,
  convyear = 2060
  )

out <- mbind(
  out,
  setNames(
    inreport[, , "ES|Transport|Pass|Aviation"] * ef * MtN_to_ktN2O,
    "Emi|N2O|Extra|Transport|Pass|Aviation (kt N2O/yr)"
  )
)
# CH4 from residential+commercial, assume most of it is from incomplete biomass/solids burning. Requires CEDS detail
# Don't assume convergence, as Global South EFs may be more representative of solids burning
ef <- deriveEF( 
  dimReduce(cedsceds[, 2020, "1A4a_Commercial-institutional.ch4"] + cedsceds[, 2020, "1A4b_Residential.ch4"]),
  inreport[, , "FE|Buildings|Solids"],
  refyear = 2020,
  convyear = NULL
  )
out <- mbind(
  out,
  setNames(
    inreport[, , "FE|Buildings|Solids"] * ef,
    "Emi|CH4|Extra|Buildings|Solids (Mt CH4/yr)"
  )
)
# N2O from residential+commercial. Requires CEDS detail, assume it's all from fuel burning byproducts.
# Common solid fuels tend to have higher N2O EFs than common gaseous and liquid fuels, but here
# we are implicitly assuming the 2020 mix Solids+Liquids+Gases determines the EF.
# See https://www.epa.gov/system/files/documents/2024-02/ghg-emission-factors-hub-2024.pdf
# Don't assume convergence, as Global South EFs may be more representative of solids burning
tmp <- dimSums(inreport[, , c("FE|Buildings|Gases", "FE|Buildings|Liquids", "FE|Buildings|Solids")], dim = 3)
ef <- deriveEF( 
  dimReduce(cedsceds[, 2020, "1A4a_Commercial-institutional.n2o_n"] + cedsceds[, 2020, "1A4b_Residential.n2o_n"]),
  tmp,
  refyear = 2020,
  convyear = NULL
  )
out <- mbind(
  out,
  setNames(
    tmp * ef,
    "Emi|N2O|Extra|Buildings (kt N2O/yr)"
  )
)

# Aggregate to global. Since all variables are emissions, we can just sum them
out <- mbind(out, setItems(dimSums(out, dim = 1), dim = 1, value = "GLO"))

######################################################## END ACTUAL CALCULATIONS

# Already convert to quitte and ensure it has the same model and scenario as the original report

outmif <- as.quitte(out)
outmif$region <- as.character(outmif$region)
outmif[outmif$region == "GLO", "region"] <- "World"
outmif$model <- unique(report$model)[str_detect(unique(report$model), "REMIND")][1] # Deals with REMIND-MAgPIE mifs
outmif$scenario <- unique(report$scenario)[1] # Works on only one scenario at a time

# Append to the original mif in-memory. We have do this to avoid duplicates.
inmif <- filter(inmif, !(variable %in% as.character(unique(outmif$variable))))
fullmif <- rbind(inmif, outmif)

write.mif(fullmif, remind_reporting_file, append = FALSE)
piamutils::deletePlus(remind_reporting_file, writemif = TRUE)
