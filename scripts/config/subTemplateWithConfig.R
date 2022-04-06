#' Substitute / Fill a Template File with Info from a Config-Rmd
#'
#' Replaces lines with \code{[:TITLE:]}, \code{[:MODULES:]},
#' \code{[:DECLARATION:]}, \code{[:SWITCHES:]}, \code{[:FLAGS:]} in the template
#' by information from a config-Rmd-file and writes the result into a new file.
#'
#' @param templatePath A single string. The path to the template file.
#' @param configRmdPath A single string. The path to the config-Rmd-file.
#' @param output A single string. The path to the output file.
subTemplateWithConfig <- function(
  templatePath = "main_template.gms",
  configRmdPath = "config/defaultConfig.Rmd",
  output = "main.gms"
) {

  lines <- readLines(templatePath)

  iTitl <- grep("[:TITLE:]", lines, fixed = TRUE)
  iModu <- grep("[:MODULES:]", lines, fixed = TRUE)
  iDecl <- grep("[:DECLARATION:]", lines, fixed = TRUE)
  iSwit <- grep("[:SWITCHES:]", lines, fixed = TRUE)
  iFlag <- grep("[:FLAGS:]", lines, fixed = TRUE)

  configDescr <- parseConfigRmd(configRmdPath)

  extractSubsubsectionList <- function(section) {
    unlist(
      lapply(section$content, function(x) x$content),
      recursive=FALSE,
      use.names=FALSE)
  }
  params <- extractSubsubsectionList(configDescr$content$`R Parameters`)
  modules <- extractSubsubsectionList(configDescr$content$Modules)
  switches <- extractSubsubsectionList(configDescr$content$`GAMS Switches`)
  flags <- extractSubsubsectionList(configDescr$content$`GAMS Compiler Flags`)

  titleGmsText <- gmsTitle(params)
  lines[iTitl] <- titleGmsText

  modulesGmsText <- paste0(sapply(modules, gmsModule), collapse="")
  lines[iModu] <- modulesGmsText

  declarationsGmsText <- paste0(
    "PARAMETERS\n",
    paste0(sapply(switches, gmsDeclaration), collapse=""),
    ";\n")
  lines[iDecl] <- declarationsGmsText

  switchesGmsText <- paste0(sapply(switches, gmsSwitch), collapse="")
  lines[iSwit] <- switchesGmsText

  flagsGmsText <- paste0(sapply(flags, gmsFlag), collapse="")
  lines[iFlag] <- flagsGmsText

  writeLines(lines, output)
}

# Removes first and/or last character if it is a single or double quotation mark.
removeQuotes <- function(x) {
  x <- gsub("^[\"\']", "", x)
  x <- gsub("[\"\']$", "", x)
  return(x)
}

gmsTitle <- function(params) {
  names(params) <- sapply(params, function(x) x$name)
  paste0(
    "$setGlobal c_expname ", removeQuotes(params$title$default), "\n",
    "$setGlobal c_description ", params$description$default, "\n")
}


gmsModule <- function(moduleDescr) {
  fullName <- moduleDescr$name
  num <- substr(fullName, 0, 2)
  name <- substr(fullName, 4, nchar(fullName))
  default <- removeQuotes(moduleDescr$default)
  paste0(
    "***----------   ", fullName, "   ----------\n",
    "$setGlobal ", name, " ", default,
    " !! def = ",  default, "\n")
}

gmsDeclaration <- function(switchDescr) {
  paste0(switchDescr$name, " \"", switchDescr$short, "\"\n")
}

gmsSwitch <- function(switchDescr) {
  default <- removeQuotes(switchDescr$default)
  paste0(
    switchDescr$name, " = ", default,
    "; !! def = ", default, "\n")
}

gmsFlag <- function(flagDescr) {
  default <- removeQuotes(flagDescr$default)
  paste0(
    "$setGlobal ", flagDescr$name, " ", default,
    " !! def = ", default, "\n")
}
