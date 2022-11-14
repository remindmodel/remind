source("renv/activate.R")

if (!"https://rse.pik-potsdam.de/r/packages" %in% getOption("repos")) {
  options(repos = c(getOption("repos"), pik = "https://rse.pik-potsdam.de/r/packages"))
}

# bootstrapping, will only run once after remind is freshly cloned
if (isTRUE(rownames(installed.packages(priority = "NA")) == "renv")) {
  message("R package dependencies are not installed in this renv, installing now...")
  renv::install("yaml", prompt = FALSE) # yaml is required to find dependencies in Rmd files
  renv::hydrate() # auto-detect and install all dependencies
  renv::snapshot(prompt = FALSE) # create renv.lock
  message("Finished installing R package dependencies.")
}

# bootstrapping python venv, will only run once after remind is freshly cloned
if (!dir.exists(".venv/") && Sys.which("python3") != "") {
  local({
    source("scripts/utils/pythonBinPath.R")
    message("Python venv is not available, setting up now...")
    # use system python to set up venv
    system2("python3", c("-mvenv", ".venv"))
    # use venv python to install dependencies in venv
    system2(pythonBinPath(".venv"), c("-mpip", "install", "--upgrade", "pip", "wheel"))
    system2(pythonBinPath(".venv"), c("-mpip", "install", "-r", "requirements.txt"))
  })
}

# source global .Rprofile (very important to load user specific settings)
# DO NOT EDIT THIS LINE!
if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
}
