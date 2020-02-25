# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

require(rmarkdown)
require(lucode)

if(!exists("source_include")) {
  ## Define arguments that can be read from command line
  readArgs("outputdir","gdx_name","gdx_ref_name")
}

load(file.path(outputdir, "config.Rdata"))

## run EDGE transport validation output if required
if(cfg$gms$transport == "edge_esm"){
  md_template <- "EDGETransportReport.Rmd"
  file.copy(file.path("./scripts/output/single/notebook_templates", md_template), outputdir)
  rmarkdown::render(path(outputdir, md_template), output_format="pdf_document")
  if(cfg$gms$c_keep_iteration_gdxes == 1){
    md_template <- "EDGETransportMultiIterationAnalysis.Rmd"
    file.copy(file.path("./scripts/output/single/notebook_templates", md_template), outputdir)
    rmarkdown::render(path(outputdir, md_template), output_format="pdf_document")
  }
}
