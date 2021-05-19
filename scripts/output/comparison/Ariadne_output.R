
# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

require(quitte)
require(mip)
library(quitte)

if(!exists("source_include")) {
  ## Define arguments that can be read from command line
  readArgs("outputdirs")
}

## create string with date and time
time = gsub(":",".",gsub(" ","_",Sys.time()))
## create output folder
outdir = paste0("output/compareRunAriadne_", time)
dir.create(outdir)

print(outputdirs)
## list all mif files that have to be transferred
mifs = list.files(path = outputdirs, pattern = "REMIND_generic", full.names = F)
mifs = mifs[!grepl("withoutPlu", mifs)]
mifs = paste0("./", outputdirs, "/",  mifs)

hist = list.files(path = outputdirs[1], pattern = "historical", full.names = F)
hist = paste0("./", outputdirs[1], "/",  hist)
mifs = c(mifs, hist)
print(mifs)
file.copy(file.path(mifs), outdir)

## names of the output files
md_template = "AriadneComparison.Rmd"

## create a txt file containing the run names
write.table(outputdirs, paste0(outdir, "/run_names.txt"), append = FALSE, sep = " ", quote = FALSE,
            row.names = FALSE, col.names = FALSE)

## copy the markdown file
file.copy(file.path("./scripts/output/comparison/notebook_templates", md_template), outdir)
## run the markdown file
rmarkdown::render(path(outdir, md_template), output_format="pdf_document")

