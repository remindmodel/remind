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
