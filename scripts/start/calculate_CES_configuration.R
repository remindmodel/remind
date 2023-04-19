calculate_CES_configuration <- function(cfg, check = FALSE) {
    CESstring <- paste0("indu_", cfg$gms$industry,"-",
                        "buil_", cfg$gms$buildings,"-",
                        "tran_", cfg$gms$transport,"-",
                        "POP_",  cfg$gms$cm_POPscen, "-",
                        "GDP_",  cfg$gms$cm_GDPscen, "-",
                        "En_",   cfg$gms$cm_demScen, "-",
                        "Kap_",  cfg$gms$capitalMarket, "-",
                        if (! cfg$gms$cm_calibration_string == "off") paste0(cfg$gms$cm_calibration_string, "-"),
                        "Reg_", madrat::regionscode(cfg$regionmapping)
    )
    CESfile <- file.path(getwd(), "./modules/29_CES_parameters/load/input",
                         paste0(CESstring, ".inc"))
    if (check && nchar(CESfile) > 255) {
        stop("Filename of CES file has more than 255 characters, which will ",
             "cause GAMS to fail on loading it.\n",
             "Rename and shorten the path to your REMIND directory by ",
             (nchar(CESfile) - 255), " characters.\n",
             "Like so: '",
             substr(getwd(), 1, nchar(getwd()) - (nchar(CESfile) - 255)), "'")
    }
    return(CESstring)
}
