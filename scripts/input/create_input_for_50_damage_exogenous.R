# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

create_input_for_50_damage_exogenous<-function(gdx){

  library(luplot,quietly=TRUE,warn.conflicts =FALSE)
  library(gms,quietly=TRUE,warn.conflicts =FALSE)
  require(remind2,quietly = TRUE,warn.conflicts =FALSE)
  library(quitte,quietly=TRUE,warn.conflicts=FALSE)

  p_fpath <- "./modules/50_damages/exogenous/input/p50_damage_exo.inc"

  # ---- Read data ----

  if (file.exists(gdx)) {
    pr <- read.gdx(gdx,"pm_damage")
  } else {
    stop("No gdx file found to take the damage factor from - please provide gdx from a reference run in path_gdx_damage in scenario_config file.")
  }

  if (! dir.exists(dirname(p_fpath))) dir.create(dirname(p_fpath), recursive = TRUE)

  # ---- Export data ----

  # Header
  cat("*** SOF ",p_fpath,"\n", file = p_fpath, sep = "", append = FALSE)
  cat("*=============================================================*\n", file = p_fpath, append = TRUE)
  cat("*=              Exogenous damage parameter                   =*\n", file = p_fpath, append = TRUE)
  cat("*=============================================================*\n", file = p_fpath, append = TRUE)
  cat("*= author: piontek@pik-potsdam.de                             =*\n", file = p_fpath, append = TRUE)
  cat(paste("*= date  : ", Sys.time(), "                               =*\n", sep=""), file = p_fpath, append = TRUE)
  cat("*= generated with:                                           =*\n", file = p_fpath, append = TRUE)
  cat("*= scripts/input/create_input_for_50_damage_exogenous.R =*\n", file = p_fpath, append = TRUE)
  cat(paste0("*= from file: ", normalizePath(gdx), " =*\n"), file = p_fpath, append = TRUE)
  cat("*= unit: pp                                 =*\n", file = p_fpath, append = TRUE)
  cat("*=============================================================*\n", file = p_fpath, append = TRUE)
  cat("\n", file = p_fpath, append = TRUE)

  # Content
  # Loop over time dimension
  for (d in 1:dim(pr)[1]) {
      cat("pm_damage(\"",as.integer(pr[d,1]),"\",\"",as.character(pr[d,2]),"\")=",as.double(pr[d,3]),";\n", sep = "", file = p_fpath, append = TRUE)
  }

  cat("*** EOF ",p_fpath,"\n", file = p_fpath, sep = "", append = TRUE)

}
