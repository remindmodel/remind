library(tidyverse)

getGox <- function(f) {
  lines <- readLines(f)
  goxygen <- grep("^\\s*\\*'", lines, value=TRUE)
  goxygen <- trimws(sub("^\\s*\\*'", "", goxygen))
  breaks <- unique(sort(c(1, length(goxygen)+1, which(nchar(goxygen) == 0), grep("^@", goxygen))))
  goxParts <- sapply(1:(length(breaks)-1), function(i) paste(goxygen[breaks[i]:(breaks[i+1]-1)], collapse=" "))
  goxParts <- trimws(goxParts)
  goxParts <- goxParts[nchar(goxParts) > 0]
}

goxExtract <- function(gox, id) {
  ln <- grep(paste0("^@", id, " "), gox, value=TRUE)[1]
  trimws(sub(paste0("^@", id, " "), "", ln))
}

moduleFolders <- grep("^\\d{2}_", dir("modules"), value=TRUE)
gox <- lapply(paste0("modules/", moduleFolders, "/module.gms"), getGox)
title <- sapply(gox, goxExtract, id = "title")
descr <- sapply(gox, goxExtract, id = "description")

for (m in moduleFolders)
  descr <- gsub(m, paste0("[", m, "]"), descr)


res <- tibble(
  module = moduleFolders,
  title = title,
  description = descr)

configDescr <- parseConfigRmd("config/defaultConfig.Rmd")
modulesCfg <- configDescr$content$Modules$content$General$content
stopifnot(all(names(modulesCfg) == moduleFolders))

shortCfg <- map_chr(modulesCfg, "short")
furtherCfg <- map_chr(modulesCfg, "further")
shortGox <- res$title
names(shortGox) <- res$module
descrGox <- res$description
names(descrGox) <- res$module

for (m in moduleFolders) {
  modulesCfg[[m]]$short <- shortGox[[m]]
  modulesCfg[[m]]$further <- sub("**Description:**\n\n--", paste0("**Description:**\n\n", descrGox[[m]]), modulesCfg[[m]]$further, fixed=TRUE)
}

configDescr$content$Modules$content$General$content <- modulesCfg

writeConfigRmd(configDescr, "config/defaultConfigNewAuto.Rmd")

configDescrNew <- parseConfigRmd("config/defaultConfigNewAuto.Rmd")
