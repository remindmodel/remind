# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
calculate_CES_configuration <- function(cfg, path = getwd(), check = FALSE) {
    CESstring <- paste0("indu_",   cfg$gms$industry,ifelse(cfg$gms$cm_subsec_model_steel=="ces","CesSteel",""),"-",  # remove CesSteel suffix after process-based has been default for some months
                        "buil_",   cfg$gms$buildings,"-",
                        "tran_",   cfg$gms$transport,"-",
                        "GDPpop_", cfg$gms$cm_GDPpopScen, "-",
                        "En_",     cfg$gms$cm_demScen, "-",
                        "Kap_",    cfg$gms$capitalMarket, "-",
                        if (! cfg$gms$cm_calibration_string == "off") paste0(cfg$gms$cm_calibration_string, "-"),
                        "Reg_", madrat::regionscode(file.path(path, cfg$regionmapping))
    )
    CESfile <- file.path(path, "./modules/29_CES_parameters/load/input",
                         paste0(CESstring, ".inc"))
    if (check && nchar(CESfile) > 255) {
        stop("Filename of CES file has more than 255 characters, which will ",
             "cause GAMS to fail on loading it.\n",
             "Rename and shorten the path to your REMIND directory by ",
             (nchar(CESfile) - 255), " characters.\n",
             "Like so: '",
             substr(path, 1, nchar(path) - (nchar(CESfile) - 255)), "'")
    }
    return(CESstring)
}
