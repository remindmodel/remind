# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
files_path = list.files(".",recursive = T,pattern = "files$")
paths_input = NULL

for (.file in files_path){
  content_file = readLines(.file)
  .path_file = gsub("/files$","",.file)
  .paths_input = paste0(.path_file,"/",content_file)
  paths_input = c(paths_input, .paths_input)
}

#Git ignore
write(x = c(".*.un~",
            ".*.swp",
            "input/",
            "output/*",
            "main.lst",
            "doc/doc.rds",
            "doc/documentation.*",
            "doc/goxygen_pdflatex.log",
            "doc/html/",
            "doc/markdown/",
            "Rplots.pdf",
            paths_input),
      ".gitignore")

