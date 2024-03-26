# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# This script expects a variable `outputdirs` to be defined.
# Variable `filename_prefix` is used if defined.
if (!exists("outputdirs")) {
  stop(
    "Variable outputdirs does not exist. ",
    "Please call varListHtml.R via output.R, which defines outputdirs.")
}

timeStamp <- format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
if (!exists("filename_prefix")) filename_prefix <- ""
nameCore <- paste0(filename_prefix, ifelse(filename_prefix == "", "", "-"), timeStamp)
fullName <- paste0("varList-", nameCore)
htmlBefore <- paste0(c(
  "<h2>Runs Used</h2>",
  "<ul>",
  paste0("  <li>", outputdirs, "</li>"),
  "</ul>",
  "<h2>List of Variables</h2>"
), collapse = "\n")

mifs <- c(
  remind2::getMifScenPath(outputdirs), 
  remind2::getMifHistPath(outputdirs[1]))

details <- 
  readr::read_delim(
    "https://raw.githubusercontent.com/pik-piam/piamInterfaces/master/inst/mappings/mapping_AR6.csv",
    delim = ";",
    col_select = c(piam_variable, Definition),
    col_types = "cc"
  ) |>
  dplyr::rename(name = piam_variable)

remind2::createVarListHtml(
  x = mifs,
  outFileName = paste0(fullName, ".html"),
  title = fullName,
  htmlBefore = htmlBefore,
  usePlus = TRUE,
  details = details)

