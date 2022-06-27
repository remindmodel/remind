source("renv/activate.R")
message("renv activated, libPaths: ", paste0("'", .libPaths(), "'", collapse = ", "))

# source global .Rprofile (very important to load user specific settings)
# DO NOT EDIT THIS LINE!
if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
}

if (!"https://pik-piam.r-universe.dev" %in% getOption("repos")) {
  options(repos = c(getOption("repos"), pikpiam = "https://pik-piam.r-universe.dev"))
}
