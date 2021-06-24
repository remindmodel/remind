# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

insertheader <- function(maindir=".",
                         header=c("(C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)",
                                  "authors, and contributors see CITATION.cff file. This file is part",
                                  "of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of",
                                  "AGPL-3.0, you are granted additional permissions described in the",
                                  "REMIND License Exception, version 1.0 (see LICENSE file).",
                                  "Contact: remind@pik-potsdam.de"),
                         donottouch=c("AUTHORS","README","LICENSE",".lhd",".mz",".rda",".opt",
                                      ".op2", ".op3", ".op4", ".op5", ".op6", ".op7", ".op8", ".op9",
                                      ".spam",".xlsx",".xls", ".sh","files",".md",".RData", ".jpg",
                                      ".png", ".PNG",".cff", ".rds", ".aux", ".log", ".out", ".pdf",
                                      ".tex", ".htm", ".css", ".bib", ".ref", ".mif", ".gmif", ".gdx",
                                      ".lst", ".git-id", ".csv", ".gcsv", ".Rdata", ".prn", ".cmd", ".put",
                                      ".IN", ".awk", ".MON", ".CFG", ".mod", ".SCEN", ".inc"),
                         comments=c(".R"="#", ".gms"="***",".cfg"="#",".csv"="*",".cs2"="*",
                                    ".cs3r"="*",".cs4r"="*",".sh"="#",".txt"="#"),
                         line_endings="notwin",
                         key = "| ",
                         oldkey = NULL,
                         test_only=FALSE,
                         blockcomments = list('.Rmd' = c('<!--', '-->'))) {


  .findheader <- function(f, key, block = NULL) {
    .escape <- function(x) {
      return(gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", x))
    }

    if (is.null(block)) {
      return(grep(paste0("^", .escape(key), " "), f))
    } else {
      tmp <- grep(paste0('^', .escape(key), ' '), f)

      if (all(head(tmp, 1) - 1 %in% grep(block[[1]], f),
              tail(tmp, 1) + 1 %in% grep(block[[2]], f))) {
        return(c(head(tmp, 1) - 1, tmp, tail(tmp, 1) + 1))
      } else {
        return(0)
      }
    }
  }

  .getExtension <- function(file) {
    return(gsub(".*(\\..*)","\\1",basename(file)))
  }

  cwd <- getwd()
  on.exit(setwd(cwd))
  setwd(maindir)

  if(is.null(oldkey)) oldkey <- key

  # create list of all files recursively
  files <- list.files(recursive = TRUE)

  cat("File extension found:")
  print(unique(gsub(".*(\\..*)","\\1",files)))

  # insert header to all files
  forbidden <- NULL
  removed   <- NULL
  done      <- NULL

  for (file in files) {
    writefile <- FALSE

    ext <- .getExtension(file)
    co <- comments[ext]

    # Ommit files that are in the "donottouch" list
    if (ext %in% donottouch) {
      forbidden <- c(forbidden,file)
      next
    }

    if (!(ext %in% c(names(comments), names(blockcomments)))) {
      warning("Unknown extension ",ext)
      next
    }

    cat("Checking",file,"\n")
    f <- readLines(file)

    # Remove old header
    if (ext %in% names(comments)) {
      tmp <- .findheader(f,paste(co,oldkey))
    } else {
      tmp <- .findheader(f, oldkey, blockcomments[[ext]])
    }

    if (length(tmp)>0){
      f <- f[-tmp]
      writefile <- TRUE
      removed <- c(removed,file)
    }

    if(length(grep("^$",f,invert=TRUE))==0) warning("Empty file: ",file ,call. = FALSE)

    # update header with current year
    header <- sub('^\\(C\\) 2006-2020',
                  paste0('(C) 2006-', format(Sys.Date(), '%Y')),
                  header)

    # insert header at the appropriate line
    if (ext %in% names(comments)) {
      withcomment <- paste(co,key,header)
    } else {
      withcomment <- c(blockcomments[[ext]][[1]],
                       paste(key, header),
                       blockcomments[[ext]][[2]])
    }

    f <- append(f,withcomment,after = ifelse(!length(tmp), 0, tmp[1] - 1))
    writefile <- TRUE
    done <- c(done,file)

    # Write file only if it was modified
    if (writefile & !test_only) {
      if (line_endings == "win") {
        lucode2:::writeLinesDOS(f,file)
      } else {
        writeLines(f,file)
      }
    }
  }

  cat("Files ommitted:\n")
  print(forbidden)
  cat("Files headers were added to:\n")
  print(done)
  cat("Files from which old header was removed:\n")
  print(removed)
}
