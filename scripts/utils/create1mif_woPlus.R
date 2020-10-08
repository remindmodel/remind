# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
############################################################################################
##R script to create one mif file with the latest version of each scenario included in output
############################################################################################

# library(magclass)
# only functional in the magclass version
# # check if cutoffyear was given to call of R script
# cutoffyear <- commandArgs(trailingOnly = TRUE)[1]
# #if not, set cutoffyear to default 2100
# if (is.na(cutoffyear)){  cutoffyear <- 2100 } #

folder <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(folder)){
folder <- "output"
}  

#complete list of folders
dirs <-list.files(folder)
#get rid of csv and mif and sh files
dirs <- dirs[!substr(dirs,nchar(dirs)-3,nchar(dirs))==".csv" & !substr(dirs,nchar(dirs)-3,nchar(dirs))==".mif" & !substr(dirs,nchar(dirs)-2,nchar(dirs))==".sh"]
#make df with separte columns for scenario name and time stamp
df <- data.frame(directory = dirs, scenario = substr(dirs,1,nchar(dirs)-20), time = substr(dirs,nchar(dirs)-18,nchar(dirs)))

#create vector of strings with mif location
mifs <- c()
for (scen in unique(df$scenario)){
  #get rid of duplicates and only take the newest one
  df <- rbind(df[!df$scenario==scen,], df[df$time==max(as.character(df[df$scenario ==scen,]$time)),])
  #add the mif file location contained in the newest folder, if there is none, the scenario will not be represented in the aggregate file
  if(file.exists(paste0(folder,"/",df[df$scenario==scen,]$directory,"/REMIND_generic_",df[df$scenario==scen,]$scenario,"_withoutPlus.mif"))){
    mifs <- c(mifs,paste0(folder,"/",df[df$scenario==scen,]$directory,"/REMIND_generic_",df[df$scenario==scen,]$scenario,"_withoutPlus.mif"))
  }
}
#reading in data one after the other, converting the values to characters instead of factors (numeric for some strange reason does not work), and get rid of post-2100
data <- read.csv2(mifs[1],colClasses=(c("factor","factor","factor","factor","factor",rep("character",16),rep("NULL",4))),check.names=F)
for(i in seq(2,length(mifs))){
  data <- rbind(data,read.csv2(mifs[i],colClasses=(c("factor","factor","factor","factor","factor",rep("character",16),rep("NULL",4))),check.names=F))
}
date <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")
write.csv2(data,file=paste0(folder,"/REMIND_generic",date,".csv"),row.names=F,quote=F)
write.csv2(mifs,file=paste0(folder,"/REMIND_mifs",date,".csv"),row.names=F,quote=F)

# MAGCLASS route works locally but for some strange reason not on the cluster
# Anyone with an idea of why this is the case, please let me know (Christoph Bertram)
# cat(mifs[1])
# #read in data
# data <- read.report(mifs[1])
# cat(mifs[2])
# #reduce temporal dimension
# times <- getYears(data[[1]][[1]])
# times <- times[substr(times,2,5) <=cutoffyear]
# for (n in names(data)) {#for all scenarios
#   for (m in names(data[[n]])) {#for all models (only REMIND in this case)
#     data[[n]][[m]] <- data[[n]][[m]][,times,]
#   }
# }
# 
# #write out data into output folder
# write.report(data,file=paste0("output/REMIND_generic",format(Sys.time(), "_%Y-%m-%d_%H.%M.%S"),".csv"))

