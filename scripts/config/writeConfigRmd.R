#' Create a config-Rmd form a config description object.
#'
#' @param configDescr A nested list as returned by \code{parseConfigRmd()}.
#' @param output A single string. The path to the output file.
writeConfigRmd <- function(configDescr, output) {
  rmd <- configDescrRmd(configDescr)
  writeLines(rmd, output)
}

configDescrRmd <- function(descr) {
  paste0(
    descr$head, "\n\n",
    paste0(sapply(descr$content, sectionRmd), collapse = "\n\n"),
    "\n\n")
}

sectionRmd <- function(descr) {
  gms <- !startsWith(descr$name, "R ")
  paste0(
    "# ", descr$name, "\n\n",
    descr$head, "\n\n",
    paste0(sapply(descr$content, subsectionRmd, gms=gms), collapse = "\n\n"),
    "\n\n")
}

subsectionRmd <- function(descr, gms) {
  paste0(
    "## ", descr$name, "\n\n",
    descr$head, "\n\n",
    paste0(sapply(descr$content, paramConfigDescr, gms=gms), collapse = "\n\n"),
    "\n\n")
}

paramConfigDescr <- function(descr, gms) {
  fullName <- descr$name
  name <- sub("^[0-9]{2}_", "", fullName) # Remove leading digits (for modules).
  paste0(
    "### ", fullName, " {-}\n",
    "\n",
    descr$short, "\n", # one line description to be copied into GAMS
    "\n",
    "```{r}\n",
    "cfg$", if (gms) "gms$", name, " <- ", descr$default, "\n",
    "```\n",
    "\n",
    descr$further, "\n",
    "\n",
    "\n")
}
