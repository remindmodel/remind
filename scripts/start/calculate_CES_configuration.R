calculate_CES_configuration <- function(cfg) {
    paste0("indu_", cfg$gms$industry,"-",
           "buil_", cfg$gms$buildings,"-",
           "tran_", cfg$gms$transport,"-",
           "POP_",  cfg$gms$cm_POPscen, "-",
           "GDP_",  cfg$gms$cm_GDPscen, "-",
           "En_",   cfg$gms$cm_demScen, "-",
           "Kap_",  cfg$gms$capitalMarket, "-",
           if (cfg$gms$cm_calibration_string == "off") {
               ""
           } else {
               paste0(cfg$gms$cm_calibration_string, "-")
           },
           "Reg_", madrat::regionscode(cfg$regionmapping)
    )
}
