# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

######## declare functions for updating information ####
updateSets <- function(cfg) {
    map <- read.csv(cfg$regionmapping, sep=";")
    .tmp <- function(x,prefix="", suffix1="", suffix2=" /", collapse=",", n=10) {
      content <- NULL
      tmp <- lapply(split(x, ceiling(seq_along(x)/n)),paste,collapse=collapse)
      end <- suffix1
      for(i in 1:length(tmp)) {
        if(i==length(tmp)) end <- suffix2
        content <- c(content,paste0('       ',prefix,tmp[[i]],end))
      }
      return(content)
    }
    modification_warning <- c(
      '*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY',
      '*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT INPUT DOWNLOAD',
      '*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start/updateSets.R')
    content <- c(modification_warning,'','sets')
    # create iso set with nice formatting (10 countries per line)
    tmp <- lapply(split(map$CountryCode, ceiling(seq_along(map$CountryCode)/10)),paste,collapse=",")
    regions <- as.character(unique(map$RegionCode))
    # Creating sets for H12 subregions
    subsets <- remind2::toolRegionSubsets(map=cfg$regionmapping,singleMatches=TRUE,removeDuplicates=FALSE)
    if(grepl("regionmapping_21_EU11", cfg$regionmapping, fixed = TRUE)){ #add EU27 region group
      subsets <- c(subsets,list(
        "EU27"=c("ENC","EWN","ECS","ESC","ECE","FRA","DEU","ESW"), #EU27 (without Ireland)
        "NEU_UKI"=c("NES", "NEN", "UKI") #EU27 (without Ireland)
      ) )
    }
    # declare ext_regi (needs to be declared before ext_regi to keep order of ext_regi)
    content <- c(content, '')
    content <- c(content, paste('*** Several parts of the REMIND code relies in the order that the regional set is defined.'))
    content <- c(content, paste('***   Therefore, you must always abide with the below rules:'))
    content <- c(content, paste('***   - The first regional set to be declared must be the ext_regi set, which includes the model native regions and all possible regional aggregations considered in REMIND.'))
    content <- c(content, paste('***   - The ext_regi set needs to be declared in the order of more aggregated to less aggregated region order (e.g. World comes first and country regions goes last).'))
    content <- c(content, paste('***   - IMPORTANT: You CANNOT use any of the ext_regi set elements in any set definition made prior to the ext_regi set declaration in the code.'))
    content <- c(content, '')
    content <- c(content, paste('   ext_regi "extended regions list (includes subsets of H12 regions)"'))
    content <- c(content, '      /')
    content <- c(content, '        GLO,')
    content <- c(content, paste0('        ',paste(paste0(names(subsets),"_regi"),collapse=','),","))
    content <- c(content, paste0('        ',paste(regions,collapse=',')))
    content <- c(content, '      /')
    # declare all_regi
    content <- c(content, '',paste('   all_regi "all regions" /',paste(regions,collapse=','),'/',sep=''),'')
    # regi_group
    content <- c(content, '   regi_group(ext_regi,all_regi) "region groups (regions that together corresponds to a H12 region)"')
    content <- c(content, '      /')
    content <- c(content, paste0('        ',paste('GLO.(',paste(regions,collapse=','),')')))
    for (i in 1:length(subsets)){
        content <- c(content, paste0('        ', paste(c(paste0(names(subsets)[i],"_regi"))), ' .(',paste(subsets[[i]],collapse=','), ')'))
    }
    content <- c(content, '      /')
    content <- c(content, '')
    # iso countries set
    content <- c(content,'   iso "list of iso countries" /')
    content <- c(content, .tmp(map$CountryCode, suffix1=",", suffix2=" /"),'')
    content <- c(content,'   regi2iso(all_regi,iso) "mapping regions to iso countries"','      /')
    for(i in as.character(unique(map$RegionCode))) {
      content <- c(content, .tmp(map$CountryCode[map$RegionCode==i], prefix=paste0(i," . ("), suffix1=")", suffix2=")"))
    }
    content <- c(content,'      /')
    content <- c(content, 'iso_regi "all iso countries and EU and greater China region" /  EUR,CHA,')
    content <- c(content, .tmp(map$CountryCode, suffix1=",", suffix2=" /"),'')
    content <- c(content,'   map_iso_regi(iso_regi,all_regi) "mapping from iso countries to regions that represent country" ','         /')
    for(i in regions[regions %in% c("EUR","CHA",as.character(unique(map$CountryCode)))]) {
      content <- c(content, .tmp(i, prefix=paste0(i," . "), suffix1="", suffix2=""))
    }
    content <- c(content,'      /',';')
    replace_in_file('core/sets.gms',content,"SETS",comment="***")
}
