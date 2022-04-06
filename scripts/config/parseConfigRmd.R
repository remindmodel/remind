#' Parse a Config Rmd File
#'
#' Reads in a config-Rmd-file and parses its content to obtain a nested list
#' object containing the information in the file, including config parameter
#' names, default values, and their descriptions. It requires the Rmd to have a
#' specific structure, see below.
#'
#' The input Rmd must use three levels of sections (#, ##, and ###). The first
#' two structure the content. Each parameter is a depth 3 section (###).
#'
#' Each parameter section starts with \code{### <NAME> {-}} followed by a
#' one-line short description (without markdown) followed by an R-code chunk
#' setting its default value. The right hand side of the first assignment via
#' \code{<-} in the first code chunk of the subsubsection is treated as the
#' default (an expression, which evaluated is the default value). Thereafter
#' further documentation may be written and may contain markdown.
#'
#' @param path A single string. The path to the config-Rmd-file.
#' @return A nested list resembling the section structure of the input document.
#'   The return value is a list with the entries \code{head} and \code{content}.
#'   \code{head} is the text that comes before the first section. \code{content}
#'   is a list representing the sections. The section and subsection
#'   representations have the entries \code{name}, \code{head}, and
#'   \code{content} which contain the title, the text before the first nested
#'   (sub)subsection, and the representation of the nested (sub)subsections,
#'   respectively. The representation of the subsubsections, is a list
#'   containing the information on the parameters. It has the entries
#'   \code{name} (title of the section and name of the parameter),
#'   \code{default} (the default value from the R-code chunk), \code{short} (the
#'   one line short description), and \code{further} (everything below the first
#'   R-code-chunk).
parseConfigRmd <- function(path) {
  lines <- readLines(path)
  line <- paste0(lines, collapse="\n")
  sections <- strsplit(line, "\\n# ")[[1]]
  head <- trimws(sections[1])
  res <- lapply(sections[-1], parseSection)
  nms <- sapply(res, function(x) x$name)
  names(res) <- nms
  return(list(head = head, content = res))
}

parseSection <- function(section) {
  sec_lines <- strsplit(section, "\\n")[[1]]
  title <- trimws(sec_lines[1])
  subsections <- strsplit(section, "\\n## ")[[1]]
  head <- strsplit(subsections[1], "\\n")[[1]][-1]
  head <- trimws(paste0(head, collapse="\n"))
  res <- lapply(subsections[-1], parseSubsection)
  nms <- sapply(res, function(x) x$name)
  names(res) <- nms
  return(list(name = title, head = head, content = res))
}

parseSubsection <- function(subsection) {
  subsec_lines <- strsplit(subsection, "\\n")[[1]]
  subtitle <- subsec_lines[1]
  subsubsections <- strsplit(subsection, "\\n### ")[[1]]
  head <- strsplit(subsubsections[1], "\\n")[[1]][-1]
  head <- trimws(paste0(head, collapse="\n"))
  res <- lapply(subsubsections[-1], parseSubsubsection)
  nms <- sapply(res, function(x) x$name)
  names(res) <- nms
  return(list(name = subtitle, head = head, content = res))
}


parseSubsubsection <- function(subsubsection) {
  lns <- trimws(strsplit(subsubsection, "\\n")[[1]])

  # Get name from title of subsection, remove the markdown code "{-}".
  name <- gsub("\\s*\\{-\\}\\s*$", "", trimws(lns[1]))

  # Extract the R-code chunk and get the default value (as text) from the R-Code.
  chunkStart <- which(startsWith(lns, "```{r"))[1]
  if (is.na(chunkStart)) stop("Did not find an R-code-chunk in subsubsection ", name)
  chunkEnd <- which(startsWith(lns, "```") & seq_along(lns) > chunkStart)[1]
  chunkInner <- lns[(chunkStart+1):(chunkEnd-1)]
  chunkExprs <- rlang::parse_exprs(paste0(chunkInner, collapse="\n"))
  isAssign <- sapply(
    chunkExprs,
    function(ex) identical(ex[[1]], rlang::expr(`<-`)))
  assignIdx <- which(isAssign)[1]
  if (is.na(assignIdx)) stop("Did not find assignment (<-) in subsubsection ", name)
  assignExpr <- chunkExprs[[assignIdx]]
  lhs <- rlang::expr_text(assignExpr[[2]])
  lhsName <- sub("^cfg\\$", "", lhs)
  lhsName <- sub("^gms\\$", "", lhsName)
  expectedName <- sub("^\\d{2}_", "", name) # Remove leading digits for modules.
  if (lhsName != expectedName) {
    stop("Name derived from title (",
         expectedName,
         ") is not eqaual to assigned variable (",
         lhsName,
         ").")
  }
  default <- rlang::expr_text(assignExpr[[3]])

  # Get the one line description, which is located before the code chunk.
  if (chunkStart <= 2) {
    short <-  ""
  } else {
    short <- paste0(lns[2:(chunkStart-1)], collapse="\n")
    short <- trimws(short)
  }
  if (grepl("\"", short)) {
    warning("Short description of ", name, " contains \". Replaced by '.", call. = FALSE)
    short <- gsub("\"", "'", short)
  }
  if (grepl("\n", short)) {
    warning("Short description of ", name, " contains a new line character. Replaced by space.", call. = FALSE)
    short <- gsub("\n", " ", short)
  }
  if (nchar(short) > 253) { # Max length is 255, but may need 2 for quotes.
    warning("Short description of ", name, " has more than 253 characters. Cutting it.", call. = FALSE)
    short <- substr(short, 1, 253)
  }
  if (!grepl("[a-zA-Z]", short)) {
    warning("Short description of ", name, " does not contain any letters. Is it missing?", call. = FALSE)
  }

  # Get everything below the first code chunk, i.e., any further description.
  further <- trimws(paste0(lns[(chunkEnd+1):length(lns)], collapse="\n"))

  # Return gathered values as a list.
  res <- list(
    name = name,
    default = default,
    short = short,
    further = further)
  return(res)
}
