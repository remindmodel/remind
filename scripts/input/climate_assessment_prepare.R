# require(tidyverse)
require(madrat)
require(remind2)
require(quitte)
require(piamInterfaces)
require(yaml)
# require(reticulate)

# Rscript climate_assessment_run_all.sh [gdxpath] [cfgpath] [temppath]

args <- commandArgs(trailingOnly = T)
# args <- c("fulldata.gdx", "cfg.txt", "climate-temp")

gdxpath <- args[1]
cfgpath <- args[2]
outputdir <- args[3] 

# Get the scenario name from the cfg
cfg <- read_yaml(cfgpath)

# Create the output directory if it doesn't exist
# outputdir="output_all/"
cat(date()," climate_assessment_prepare.R: Attempting to create climate temp directory ",outputdir," \n")
dir.create(outputdir, showWarnings = F)

# Read the GDX and run reportEmi
# gdxpath <- "fulldata.gdx"
cat(date()," climate_assessment_prepare.R: Running reportEmi \n")
emimag <- reportEmi(gdxpath)

# Convert to quitte and add metadata
emimif <- as.quitte(emimag)
emimif["scenario"] <- cfg$title #TODO: Get scenario name from cfg

# Write the raw emissions mif
cat(date()," climate_assessment_prepare.R: Writing raw emissions mif \n")
emimifpath <- paste0(outputdir,"/","emimif.mif")
write.mif(emimif,emimifpath)

# Get the emissions in AR6 format
# This seems to work with just the reportEmi mif
cat(date()," climate_assessment_prepare.R: Running generateIIASASubmission to generate AR6 mif\n")
generateIIASASubmission(emimifpath, mapping = "AR6", outputDirectory = outputdir, outputFilename = "emimif_ar6.mif", logFile = paste0(outputdir, "/missing.log"))

# Read in AR6 mif
cat(date()," climate_assessment_prepare.R: Reading AR6 mif and preparing csv for climate-assessment\n")
ar6mif <- read.quitte(paste0(outputdir,"/","emimif_ar6.mif"))

# Get it ready for climate-assessment: capitalized titles, just World, comma separator
colnames(ar6mif) <- paste(toupper(substr(colnames(ar6mif), 1, 1)), substr(colnames(ar6mif), 2, nchar(colnames(ar6mif))), sep="")
ar6mif <- ar6mif[ar6mif$Region=="GLO",]
ar6mif$Region = "World"

# Long to wide
# ar6mif$Period=as.factor(ar6mif$Period)
outcsv <- reshape(as.data.frame(ar6mif), direction = "wide", timevar = "Period", v.names = "Value", idvar = c("Model","Variable","Scenario","Region","Unit"))
colnames(outcsv) <- gsub("Value.","",colnames(outcsv))

# Write output in csv for climate-assessment
cat(date()," climate_assessment_prepare.R: Writing csv for climate-assessment\n")
write.csv(outcsv, paste0(outputdir,"/","emimif_ar6.csv"), row.names=F, quote=F)

