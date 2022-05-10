gitRootDir <- normalizePath(system("git rev-parse --show-toplevel", intern = TRUE))
if (normalizePath(getwd()) == gitRootDir) {
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

  # comment out the following line to disable auto-updates
  renv::update(intersect(utils::installed.packages()[, "Package"], pikPiamPackages))
} else {
  renv::restore(lockfile = file.path(gitRootDir, "renv.lock"))
  stopifnot(!is.null(renv::project()))
  print(normalizePath(renv::project())) # TODO remove
}

if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
}
