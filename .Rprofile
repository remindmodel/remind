source("renv/activate.R")

# TODO determine pikPiamPackages dynamically
pikPiamPackages <- c("GDPuc", "HARr", "MagpieNCGains", "citation", "demystas", "edgeTransport",
                    "edgeTrpLib", "gdx", "gdxrrw", "gms", "goxygen", "iamc", "limes",
                    "lpjclass", "lucode2", "luplot", "luscale", "lusweave", "madrat",
                    "magclass", "magpie4", "magpiesets", "mip", "modelstats", "mrcommons",
                    "mrdrivers", "mredgebuildings", "mrfable", "mrfeed", "mrfish",
                    "mrland", "mrmagpie", "mrremind", "mrsoil", "mrtutorial", "mrvalidation",
                    "mrvalidnitrogen", "mrwaste", "mrwater", "mstools", "piamModelTests",
                    "piktests", "quitte", "regressionworlddata", "remind", "remind2",
                    "remulator", "rmndt", "shinyresults", "trafficlight")


# TODO should this be on or off by default?
# comment out the following line to disable auto-updates
renv::update(intersect(utils::installed.packages()[, "Package"], pikPiamPackages))

# TODO is this coming last ok?
if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
}
