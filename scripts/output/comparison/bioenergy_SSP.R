# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(luplot)
library(lucode)
library(gdx)
library(magpie)
library(remind2)
library(ggplot2)

############################# BASIC CONFIGURATION #############################
gdx_name <- "fulldata.gdx"        # name of the gdx   

if(!exists("source_include")) {
  setwd("~/Documents/0_SVN/REMIND2.0/output/")
  outputdirs <- c(#"rem7885_SSP2-20-tax150-rem-10",
                  # "rem7885_SSP2-26-tax000-rem-10",
                  # "rem7885_SSP2-26-tax050-rem-10",
                  # "rem7885_SSP2-26-tax100-rem-10",
                  # "rem7885_SSP2-26-tax120-rem-10",
                  ## "rem7885_SSP2-26-tax150-CCSlim-20-rem-10",
                  ## "rem7885_SSP2-26-tax150-CCSlim-50-rem-10",
                  ## "rem7885_SSP2-26-tax150-rem-10",
                  ## "rem7885_SSP2-26-tax150-CCSlim-150-rem-10",
                  ## "rem7885_SSP2-26-tax150-CCSlim-inf-rem-10")
                  # "rem7885_SSP2-26-tax150-noaff-rem-10",
                  # "rem7885_SSP2-26-tax200-rem-10",
                  # "rem7885_SSP2-26-tax300-rem-10",
                  # "rem7885_SSP2-26-tax400-rem-10",
                  # "rem7885_SSP2-Base-rem-15",
                  #"rem7383_SSP2-26-CDLINKS", # original name "remc_NPi2020_1000-rem-5",
                  # "SSP2-26-SPA0-V17",
                  # "SSP2-26-SPA2-V17",
                  # "rem6192_SSP2-26-SPA0-rem-5",
                  #"rem6192_SSP2-26-SSP") # original name "rem6192_SSP2-26-SPA2-rem-5",
                  "r8134_Base-rem-10",
                  "r8134_Budg1500-rem-10")
  
  # path to the output folder
  readArgs("outputdirs","gdx_name")
} 


read.reportEntry <- function(outputdir,entry,type=NULL){
  fname <- file.path(outputdir,paste0("REMIND_generic_",getScenNames(outputdir)))
  if(is.null(type)){
    if (file.exists(paste0(fname,".mif"))) {
      mif_path <- paste0(fname,".mif")
    } else {
      mif_path <- paste0(fname,".csv")
    }
  }else{
    mif_path <- paste0(fname,type)
  }  
  mif <- read.report(mif_path,as.list=FALSE)
  mif <- collapseNames(mif)
  out <- mif[,,1] + NA # fill with first variable and set to NA
  if (entry %in% getNames(mif,dim = "variable")) out <- mif[,,entry]
  return(out)
}


################################
read_all<-function(gdx,func,as.list=TRUE,...){
  if(!is.list(gdx))gdx<-as.list(gdx)
  if(identical(names(gdx),c("aliases","sets","equations","parameters","variables"))) gdx<-list(gdx)
  
  out<-list()
  for(i in 1:length(gdx)){
    out[[i]]<-func(gdx[[i]],...)
    if(!is.null(names(gdx))){
      names(out)[i]<-names(gdx)[i]
    }
  }
  
  if(!all(lapply(out,ndata)==ndata(out[[1]]))) stop("ERROR: different data dimensions. Can't read_all")
  
  if(as.list==TRUE){
    return(out)
  } else if(length(out)==1) {
    out <- setNames(out[[1]],paste(names(out),getNames(out[[1]]),sep="."))
    getNames(out) <- sub("\\.$","",getNames(out))
    getNames(out) <- sub("^\\.","",getNames(out))
    return(out)
    print("no")
  } else {
    inp<-out
    if(is.null(names(inp))) names(inp) <- 1:length(inp)
    # DK: do all list elements have GLO?
    all_have_GLO <- all(unlist((lapply(inp,function(x) "GLO" %in% getRegions(x)))))
    out<-NULL
    for(i in 1:length(inp)){
      tmp<-inp[[i]]
      if (!all_have_GLO) tmp <- tmp["GLO",,invert=TRUE] # DK: if not all list elements have GLO, remove GLO from those who have it (to make mbind work)
      getNames(tmp)<-paste(names(inp)[i],getNames(tmp),sep=".")
      out<-mbind(out,tmp)
    }
    getNames(out) <- sub("\\.$","",getNames(out))
    return(out)
  }
}

# Set gdx path
gdx_path       <- path(outputdirs,gdx_name)

# retrieve run titles
scenNames_path <- path(outputdirs,"config.Rdata")
scenNames      <- c()
for (i in scenNames_path) {
  load(i)
  scenNames[i] <- cfg$title
}
names(gdx_path)   <- scenNames
names(outputdirs) <- scenNames # needed in read.reportEntry that reads variables from csv file

# function to read variable from gdx file
readvar <- function(gdx,name,enty=NULL) {
  if (is.null(enty)) {
	out <- readGDX(gdx,name, format="first_found", field="l")
  getNames(out) <- "dummy" # something has to be here, will be removed by collapseNames anyway
  } else {
	out <- readGDX(gdx,name=name, format="first_found", field="l")[,,enty]
  }
  out <- collapseNames(out)
  return(out)
}

# function to read parameter from gdx file
readpar <- function(gdx,name) {
  out <- readGDX(gdx, name)#, format="first_found")
  getNames(out) <- "dummy" # something has to be here, will be removed by collapseNames anyway
  out <- collapseNames(out)
  return(out)
}

# function to create dummies for missing scenarios
# since the plot function distinguishes SSP by line type and policy case by color it requires the same number of input scenarios for each SSP
# if there are not the same scenario runs for each SSP availabe this function will produce dummy objects for them so that the plot function works properly
fill_missing_scenarios <- function(rawdata) {
  # create new dimensions that can be plotted with different colors and linetypes
  if (all(!grepl("SSP",getNames(rawdata)))) {
    # if there is NO "SSP" in the scenario names, replace the first "_" with "."
    getNames(rawdata) <- gsub("^([^_]+)_","\\1.",getNames(rawdata))
  } else {
    # replace hyphen after SSPX with dots
    getNames(rawdata)  <- gsub("(SSP[0-9])-","\\1.",getNames(rawdata))
  }

  getNames(rawdata)  <- gsub("(-rem-[0-9]{1,2})","",getNames(rawdata))             # remove -rem-X from name
  names              <- fulldim(rawdata)[[2]]                                      # get all names of third dimension
	names              <-as.vector(outer(names[[3]],names[[4]],FUN = paste,sep=".")) # build all combinations of names
	rawdata_all        <-new.magpie(getCells(rawdata),getYears(rawdata),names)       # create empty magpie object of the form and with the names of fuelx_bio
	rawdata_all[,,getNames(rawdata)]<-rawdata                                        # fill empty magpie opject with data from rawdata
	return(rawdata_all)
}

# x<-pedem
# # nur Iterationszahl l?schen, damit Namen nach dem L?schen von "pattern" nicht identisch sind
# # sonst w?ren SSP2-26-nix-rem-10 und SSP2-26-exo-rem-10 nach Entfernen von -rem-10 identisch
# # Die Zahlen gar nicht zu entfernen f?hrt dazu, dass zu SSP2-26-exo-rem-10 ein unfertiger Lauf
# # SSP2-26-exo-rem-9 nicht gefunden w?rde 
# getNames(x)  <- gsub("(-rem-[0-9]{1,2})","-rem",getNames(x))             # remove -rem-X from name
# pattern <- "-exo"
# counterpart <- "-endo"
# 
# ind <- grep(pattern,getNames(x))
# for(i in ind) {
#   # suche den zum aktuellen Lauf (dessen Namen pattern enth?lt: SSP2-26-exo-rem)
#   # korrespondierenden Lauf, der "pattern" nicht enth?lt (SSP2-26-rem)
#   ind_correspondent <- grep(gsub(pattern,"",getNames(x)[i]),getNames(x))
#   # und ersetzte diesen Namen (SSP2-26-rem) durch den Namen des aktuellen Laufs (SSP2-26-exo-rem), in dem pattern (-exo) durch counterpart (-endo) ersetzt wurde ((SSP2-26-endo-rem))
#   getNames(x)[ind_correspondent] <- gsub(pattern,counterpart,getNames(x)[i])
# }
# # jetz kann -rem entfertn werden
# getNames(x)  <- gsub("-rem$","",getNames(x))             # remove -rem-X from name
# cat(sort(getNames(x)),sep="\n")

##################### GENERAL SETTINGS ###################################
TWa2EJ <- 31.5576      # TWa to EJ (1 a = 365.25*24*3600 s = 31557600 s)
txtsiz <- 20
y      <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
#r      <- c("AFR","CHN","EUR","IND","JPN","LAM","MEA","OAS","ROW","RUS","USA")
r      <- c("SSA","CHA","EUR","NEU","IND","JPN","LAM","MEA","OAS","CAZ","REF","USA")
#r_sub  <- c("AFR","CHN","EUR","IND",      "LAM",      "OAS",      "RUS","USA") #c("CHN","IND","USA","OAS","LAM","AFR")
r_sub  <- c(      "CHA","EUR",                  "LAM",      "OAS",      "REF","USA")



############### READ DATA: TOTAL BIOMASS ################################
pedem <- read_all(outputdirs,read.reportEntry,entry="PE|+|Biomass (EJ/yr)",as.list=FALSE)
pedem <- collapseNames(pedem,collapsedim=2)
if(length(fulldim(pedem)[[2]][[3]])>1)  pedem <- collapseNames(pedem) # only if there is more than one scenario, otherwise keep single scenarionamepedem <- collapseNames(pedem)

#### PLOT REGIONAL TOTAL BIOMASS #####
pedem_all <- fill_missing_scenarios(pedem)
y_limreg  <- c(0,max(pedem[,y,]["GLO",,,invert=TRUE]))
y_limglo  <- c(0,max(pedem[,y,]))

p0g <- magpie2ggplot2(pedem_all["GLO",y,],geom='line',group=NULL,
                      ylab='EJ/yr',color='Data2',linetype="Data1",
                      scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
                      title=paste0("Total bioenergy consumption"))

p0r <- magpie2ggplot2(pedem_all[r,y,],geom='line',group=NULL,
                      ylab='EJ/yr',color='Data2',linetype="Data1",
                      scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
                      title=paste0("Total bioenergy consumption"))

############### READ DATA: FUELEX PEBIOLC ################################
fuelex <- read_all(gdx_path,readvar,name=c("vm_fuExtr","vm_fuelex"),enty="pebiolc",as.list=FALSE)

	##### PLOT TOTAL BIOENERGY (purpose + residues) #####
	fuelex_bio       <- dimSums(fuelex,dims=4) * TWa2EJ # grades are in fourth dimension
  fuelex_bio       <- mbind(fuelex_bio,colSums(fuelex_bio))
	fuelex_bio_all   <- fill_missing_scenarios(fuelex_bio)
	y_limreg         <- c(0,max(fuelex_bio[,y,]["GLO",,,invert=TRUE]))

	p1g <- magpie2ggplot2(fuelex_bio_all["GLO",y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=paste0("Lignocellulosic biomass production (residues + purpose grown)"))

	p1r <- magpie2ggplot2(fuelex_bio_all[r,y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=paste0("Total biomass: production"))
	#p1r <- p1r + guides(color = guide_legend(nrow = length(scenNames)))
    #p1r <- p1r + theme(legend.position="none")
    #p1r <- p1r + theme(legend.direction = "vertical", legend.position = "top", legend.box = "horizontal")

  ##### PLOT PURPOSE GROWN BIOENERGY #####
  fuelex_bio <- collapseNames(fuelex[,,"1"],collapsedim=2) * TWa2EJ# get rid of grades
  if(length(fulldim(fuelex)[[2]][[3]])>1)	fuelex_bio <- collapseNames(fuelex_bio) # only if there is more than one scenario, otherwise keep single scenarioname
	fuelex_bio       <- mbind(fuelex_bio,colSums(fuelex_bio))
  
	fuelex_bio_all   <- fill_missing_scenarios(fuelex_bio)
	y_limreg         <- c(0,max(fuelex_bio[,y,]["GLO",,,invert=TRUE]))

	p2g <- magpie2ggplot2(fuelex_bio_all["GLO",y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=paste0("Purpose grown bio: production"))

	p2r <- magpie2ggplot2(fuelex_bio_all[r_sub,y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=paste0("Purpose grown bio: production"))

	##### PLOT RESIDUE BIOENERGY #####
	fuelex_bio       <- collapseNames(fuelex[,,"2"],collapsedim=2) * TWa2EJ
  if(length(fulldim(fuelex)[[2]][[3]])>1)	fuelex_bio <- collapseNames(fuelex_bio) # only if there is more than one scenario, otherwise keep single scenarioname
	fuelex_bio       <- mbind(fuelex_bio,colSums(fuelex_bio))
	fuelex_bio_all   <- fill_missing_scenarios(fuelex_bio)
    y_limreg         <- c(0,max(fuelex_bio[,y,]["GLO",,,invert=TRUE]))
	
	p3g <- magpie2ggplot2(fuelex_bio_all["GLO",y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=paste0("Biomass residues: production"))

	p3r <- magpie2ggplot2(fuelex_bio_all[r,y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=paste0("Biomass residues: production"))


############### READ DATA: TRADITIONAL BIOMASS ################################
pedem <- read_all(outputdirs,read.reportEntry,entry="PE|Biomass|Traditional (EJ/yr)",as.list=FALSE)
pedem <- collapseNames(pedem,collapsedim=2)
if(length(fulldim(pedem)[[2]][[3]])>1)	pedem <- collapseNames(pedem) # only if there is more than one scenario, otherwise keep single scenarionamepedem <- collapseNames(pedem)

	#### PLOT REGIONAL TRADITIONAL BIOMASS #####
	pedem_all <- fill_missing_scenarios(pedem)
	y_limreg  <- c(0,max(pedem[,y,]["GLO",,,invert=TRUE]))

	p6g <- magpie2ggplot2(pedem_all["GLO",y,],geom='line',group=NULL,
                     ylab='EJ/yr',color='Data2',linetype="Data1",
                     scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
                     title=paste0("Traditional bioenergy consumption"))
					 
	p6r <- magpie2ggplot2(pedem_all[r,y,],geom='line',group=NULL,
                     ylab='EJ/yr',color='Data2',linetype="Data1",
                     scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
                     title=paste0("Traditional bioenergy consumption"))

############### READ DATA: FUELEX PEBIOIL ################################
fuelex <- read_all(gdx_path,readvar,name=c("vm_fuExtr","vm_fuelex"),enty="pebioil",as.list=FALSE)

	##### PLOT #####
	fuelex_bio       <- dimSums(fuelex,dims=4) * TWa2EJ # grades are in fourth dimension
	fuelex_bio       <- mbind(fuelex_bio,colSums(fuelex_bio))
	fuelex_bio_all   <- fill_missing_scenarios(fuelex_bio)
	y_limglo         <- c(0,max(fuelex_bio[,y,]))
	y_limreg         <- c(0,max(fuelex_bio[,y,]["GLO",,,invert=TRUE]))

	p1stg <- magpie2ggplot2(fuelex_bio_all["GLO",y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=paste0("1st gen biomass: pebioil"))

	p1str <- magpie2ggplot2(fuelex_bio_all[r,y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=paste0("1st gen biomass: pebioil"))

############### READ DATA: FUELEX PEBIOIL ################################
fuelex <- read_all(gdx_path,readvar,name=c("vm_fuExtr","vm_fuelex"),enty="pebios",as.list=FALSE)

	##### PLOT #####
	fuelex_bio       <- dimSums(fuelex,dims=4) * TWa2EJ # grades are in fourth dimension
	fuelex_bio       <- mbind(fuelex_bio,colSums(fuelex_bio)) # add global sum
	fuelex_bio_all   <- fill_missing_scenarios(fuelex_bio)
	y_limglo         <- c(0,max(fuelex_bio[,y,]))
	y_limreg         <- c(0,max(fuelex_bio[,y,]["GLO",,,invert=TRUE]))

	p1stsg <- magpie2ggplot2(fuelex_bio_all["GLO",y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=paste0("1st gen biomass: pebios"))

	p1stsr <- magpie2ggplot2(fuelex_bio_all[r,y,],geom='line',group=NULL,
						 ylab='EJ/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=paste0("1st gen biomass: pebios"))

					 
############### READ DATA: PRICE & SHIFT ################################
price <- read_all(gdx_path,readvar,name="vm_pebiolc_price",as.list=FALSE)
price <- setNames(price,gsub(".","",getNames(price),fixed=TRUE))
if(length(fulldim(price)[[2]][[3]])>1)  price <- collapseNames(price) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT REGIONAL BIOENERGY PRICES (purpose) #####
	price_bio       <- price / TWa2EJ * 1000
	price_bio       <- mbind(price_bio,colSums(price_bio))
	price_bio_all   <- fill_missing_scenarios(price_bio)

	p4p <- magpie2ggplot2(price_bio_all[r_sub,y,],geom='line',group=NULL,
						 ylab='$/GJ',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,
						 title=paste0("Purpose grown bioenergy price: shifted, without tax"))
             
############### READ DYNAMIC BIO TAX ################################
dyntax <- read_all(gdx_path,readpar,name="p21_tau_bioenergy_tax",as.list=FALSE)
#dyntax <- read_all(gdx_path,readvar,name="v21_tau_bio",as.list=FALSE)
#dyntax <- setNames(dyntax,gsub(".","",getNames(dyntax),fixed=TRUE))
if(length(fulldim(dyntax)[[2]][[3]])>1) dyntax <- collapseNames(dyntax) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT REGIONAL BIOENERGY PRICES (purpose) #####
	price_bio       <- price / TWa2EJ * 1000 * (1 + dyntax)
	#price_bio       <- mbind(price_bio,colSums(price_bio))
	price_bio_all   <- fill_missing_scenarios(price_bio)

	price_incl_tax <- magpie2ggplot2(price_bio_all[r_sub,y,],geom='line',group=NULL,
	                      ylab='$/GJ',color='Data2',linetype="Data1",
	                      scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,
	                      title=paste0("Purpose grown bioenergy price: shifted, including tax"))

	p_dyntax <- magpie2ggplot2(fill_missing_scenarios(dyntax["GLO",y,]),geom='line',group=NULL,
	                           color='Data2',linetype="Data1",ylab='factor',
	                           scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,
	                           title=paste0("Demand-dependent bioenergy tax"))

############### READ DATA: PEBIOLC MARGINAL ################################
	marginal <- read_all(outputdirs,read.reportEntry,entry="Price|Biomass|Primary Level (US$2005/GJ)",as.list=FALSE)
	marginal <- collapseNames(marginal,collapsedim=2)
	if(length(fulldim(marginal)[[2]][[3]])>1)	marginal <- collapseNames(marginal) # only if there is more than one scenario, otherwise keep single scenarioname
	
	#### PLOT #####
	marginal_all <- fill_missing_scenarios(marginal)

	p_marginal <- magpie2ggplot2(marginal_all[r_sub,y,],geom='line',group=NULL,
	                      ylab='$/GJ',color='Data2',linetype="Data1",
	                      scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,
	                      title=paste0("Marginal of pebiolc"))

############### READ DATA: EMULATOR MULTIPLICATION FACTOR ################################
	mult <- read_all(outputdirs,read.reportEntry,entry="Price|Biomass|Multfactor ()",as.list=FALSE)
	mult <- collapseNames(mult,collapsedim=2)
	if(length(fulldim(mult)[[2]][[3]])>1)	mult <- collapseNames(mult) # only if there is more than one scenario, otherwise keep single scenarioname
	
	#### PLOT #####
	mult_all <- fill_missing_scenarios(mult)

	#p_mult <- magpie2ggplot2(mult_all[r,y,],geom='line',group=NULL,
	#                      ylab='factor',color='Data2',linetype="Data1",
	#                      scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,
	#                      title=paste0("Emulator multiplication factor"))

	p_mult <- ggplot(as.ggplot(mult_all[r,y,]), aes(x=Year,y=Value,colour=Data2,linetype=Data1)) + geom_line() + geom_point() + 
	  facet_wrap(~Region,scales = "free_y") + labs(title=paste0("Emulator multiplication factor",y="Factor")) +
	  coord_cartesian(ylim = c(0,10)) + scale_y_continuous(breaks=seq(0,10,1)) +
    theme(#panel.background = element_rect(fill="white", colour="black"),
          #panel.grid.minor=element_line(colour="white"),
          text=element_text(size=txtsiz),axis.text.x=element_text(size=txtsiz))
                        
############### READ DATA: STATIC BIOENERGY TAX ################################
ptax <- read_all(outputdirs,read.reportEntry,entry="Price|Biomass|Bioenergy tax (US$2005/GJ)",as.list=FALSE)
ptax <- collapseNames(ptax,collapsedim=2)
if(length(fulldim(ptax)[[2]][[3]])>1)	ptax <- collapseNames(ptax) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT #####
	ptax_all <- fill_missing_scenarios(ptax)
	y_limreg  <- c(0,max(ptax[,y,]["GLO",,,invert=TRUE]))
	
	p4t <- magpie2ggplot2(ptax_all[r,y,],geom='line',group=NULL,
	                      ylab='US$2005/GJ',color='Data2',linetype="Data1",
	                      scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
	                      title=paste0("Purpose grown bioenergy price: tax only"))
	# Price|Biomass|Primary Level
	# Price|Biomass|Multfactor

############### READ COST ################################
cost <- read_all(gdx_path,readvar,name="v30_pebiolc_costs",as.list=FALSE)
cost <- setNames(cost,gsub(".","",getNames(cost),fixed=TRUE))
if(length(fulldim(cost)[[2]][[3]])>1)  cost <- collapseNames(cost) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT REGIONAL BIOENERGY costS (purpose) #####
	cost_bio       <- cost / TWa2EJ * 1000
	cost_bio       <- mbind(cost_bio,colSums(cost_bio))
	cost_bio_all   <- fill_missing_scenarios(cost_bio)
	#y_limreg        <- c(min(cost_bio[,y,]["GLO",,,invert=TRUE]),max(cost_bio[,y,]["GLO",,,invert=TRUE]))
	#y_limreg       <- c(min(cost_bio[,y,]["GLO",,,invert=TRUE]),25)

	#r_sub <- c("CHN","IND","USA","OAS","LAM","AFR")
	p4c <- magpie2ggplot2(cost_bio_all[r,y,],geom='line',group=NULL,
						 ylab='$/GJ',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=2,text_size=txtsiz,#ylim=y_limreg,
						 title=paste0("Purpose grown bioenergy cost"))

						 
############### READ DATA: CO2 PRICE ################################
prCO2 <- read_all(gdx_path,readpar,name=c("pm_taxCO2eq","pm_tau_CO2_tax"),as.list=FALSE) * (1000*12/44)
if(length(fulldim(prCO2)[[2]][[3]])>1) prCO2 <- collapseNames(prCO2) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT GLOBAL CO2 PRICE #####
	prCO2_all   <- fill_missing_scenarios(prCO2)
	y_limreg        <- c(min(prCO2[,y,]["GLO",,,invert=TRUE]),max(prCO2[,y,]["GLO",,,invert=TRUE]))

	p10g <- magpie2ggplot2(prCO2_all["SSA",y,],geom='line',group=NULL,
						 ylab='$/tCO2',color='Data2',linetype="Data1",
						 scales='free_y',show_grid=TRUE,ncol=3,text_size=txtsiz,#ylim=y_limreg,
						 title=paste0("Carbon tax 2005-2100"))

prCO2 <- read_all(gdx_path,calcPrice,level="reg",enty="perm",type="present",as.list=FALSE) * (1000*12/44)
prCO2 <- collapseNames(prCO2,collapsedim=2)
if(length(fulldim(prCO2)[[2]][[3]])>1) prCO2 <- collapseNames(prCO2) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT REGIONAL CO2 PRICES #####
	prCO2_all   <- fill_missing_scenarios(prCO2)
	y_limreg        <- c(min(prCO2[,y,]["GLO",,,invert=TRUE]),max(prCO2[,y,]["GLO",,,invert=TRUE]))

	p10r <- magpie2ggplot2(prCO2_all[r,y,],geom='line',group=NULL,
						 ylab='$/tCO2',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=3,text_size=txtsiz,ylim=y_limreg,
						 title=paste0("Carbon price 2005-2100"))


############### READ DATA: CO2LUC ################################
v <- "Emi|CO2|Land-Use Change (Mt CO2/yr)"
co2luc <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2luc <- collapseNames(co2luc,collapsedim=2)
if(length(fulldim(co2luc)[[2]][[3]])>1) co2luc <- collapseNames(co2luc) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT #####
	co2luc_all   <- fill_missing_scenarios(co2luc)
	y_limglo     <- c(min(co2luc[,y,]),max(co2luc[,y,]))
	y_limreg     <- c(min(co2luc[,y,]["GLO",,,invert=TRUE]),max(co2luc[,y,]["GLO",,,invert=TRUE]))

	p5g <- magpie2ggplot2(co2luc_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

	p5r <- magpie2ggplot2(co2luc_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)

############### READ DATA: CO2LUC Cumulated ################################
v <- "Emi|CO2|Land-Use Change|Cumulated (Mt CO2/yr)"
co2luc_c <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2luc_c <- collapseNames(co2luc_c,collapsedim=2)
if(length(fulldim(co2luc_c)[[2]][[3]])>1) co2luc_c <- collapseNames(co2luc_c) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT #####
	co2luc_c_all   <- fill_missing_scenarios(co2luc_c)
	y_limglo     <- c(min(co2luc_c[,y,]),max(co2luc_c[,y,]))
	y_limreg     <- c(min(co2luc_c[,y,]["GLO",,,invert=TRUE]),max(co2luc_c[,y,]["GLO",,,invert=TRUE]))

	p5g_c <- magpie2ggplot2(co2luc_c_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

	p5r_c <- magpie2ggplot2(co2luc_c_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)

############### READ DATA: CO2 from BECCS ################################
v <- "Emi|CO2|Carbon Capture and Storage|Biomass (Mt CO2/yr)"
co2beccs <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2beccs <- collapseNames(co2beccs,collapsedim=2)
if(length(fulldim(co2beccs)[[2]][[3]])>1) co2beccs <- collapseNames(co2beccs) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT CO2 BECCS #####
	co2beccs_all <- fill_missing_scenarios(co2beccs)
	y_limreg  <- c(0,max(co2beccs[,y,]["GLO",,,invert=TRUE]))
	y_limglo  <- c(0,max(co2beccs[,y,]))

	p7g <- magpie2ggplot2(co2beccs_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

    p7r <- magpie2ggplot2(co2beccs_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)
						 
############### READ DATA: CO2 from BECCS Cumulated ################################
v <- "Emi|CO2|Carbon Capture and Storage|Biomass|Cumulated (Mt CO2/yr)"
co2beccs_c <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2beccs_c <- collapseNames(co2beccs_c,collapsedim=2)
if(length(fulldim(co2beccs_c)[[2]][[3]])>1) co2beccs_c <- collapseNames(co2beccs_c) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT CO2 BECCS #####
	co2beccs_c_all <- fill_missing_scenarios(co2beccs_c)
	y_limreg  <- c(0,max(co2beccs_c[,y,]["GLO",,,invert=TRUE]))
	y_limglo  <- c(0,max(co2beccs_c[,y,]))

	p7g_c <- magpie2ggplot2(co2beccs_c_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

    p7r_c <- magpie2ggplot2(co2beccs_c_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)

############### COMBINE negative CO2 emissions ################################
#eneg <- co2luc_all
tmp1 <- add_dimension(co2luc_all,  dim=3.3,nm="co2luc",add="sink")
tmp2 <- add_dimension(co2beccs_all,dim=3.3,nm="beccs", add="sink")
tmp2 <- -tmp2
eneg <- mbind(tmp2,tmp1[,getYears(tmp2),])

eneg_forline <- dimSums(eneg,dim = 3.3)

getNames(eneg) <- gsub("^([^\\.]*)(\\.)(.*$)","\\1_\\3",getNames(eneg))
getSets(eneg) <- getSets(eneg)[-4]

# separate pos and neg values for area plot
enegP <- gginput(eneg["GLO",,],verbose=FALSE)
enegN <- gginput(eneg["GLO",,],verbose=FALSE)
enegP$.value[enegP$.value<0]  <- 0
enegN$.value[enegN$.value>=0] <- 0

# calculate total
enegT <- gginput(dimSums(eneg["GLO",,],dim = 3.2),verbose=FALSE)

pNEGgs <- ggplot() + 
  geom_area(aes(y = .value, x = year, fill = sink), data = enegP) +
  geom_area(aes(y = .value, x = year, fill = sink), data = enegN) +
  geom_line(aes(y = .value, x = year), data = enegT, size=1) +
  labs(title = "Negatvie emissions by source",y="Gt CO2/yr")  + xlim(2000,2100) +
  facet_wrap(~data1,scales = "fixed")

pNEGg <- magpie2ggplot2(eneg_forline["GLO",y],geom='line',group=NULL,
                      ylab='GtCO2/yr',color='Data2',linetype="Data1",
                      scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,#ylim=y_limglo,
                      title="Total negative emissions")

pNEGr <- magpie2ggplot2(eneg_forline[r,y],geom='line',group=NULL,
                        ylab='GtCO2/yr',color='Data2',linetype="Data1",
                        scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,#ylim=y_limglo,
                        title="Total negative emissions")

############### READ DATA: CO2 from CCS ################################
v   <- "Emi|CO2|Carbon Capture and Storage (Mt CO2/yr)"
co2ccs <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2ccs <- collapseNames(co2ccs,collapsedim=2)
if(length(fulldim(co2ccs)[[2]][[3]])>1) co2ccs <- collapseNames(co2ccs) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT CO2 BECCS #####
	co2ccs_all <- fill_missing_scenarios(co2ccs)
	y_limreg  <- c(0,max(co2ccs[,y,]["GLO",,,invert=TRUE]))
	y_limglo  <- c(0,max(co2ccs[,y,]))

	p8g <- magpie2ggplot2(co2ccs_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

	p8r <- magpie2ggplot2(co2ccs_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)
						 
############### READ DATA: CO2 from CCS Cumulated ################################
v   <- "Emi|CO2|Carbon Capture and Storage|Cumulated (Mt CO2/yr)"
co2ccs_c <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2ccs_c <- collapseNames(co2ccs_c,collapsedim=2)
if(length(fulldim(co2ccs_c)[[2]][[3]])>1) co2ccs_c <- collapseNames(co2ccs_c) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT #####
	co2ccs_c_all <- fill_missing_scenarios(co2ccs_c)
	y_limreg  <- c(0,max(co2ccs_c[,y,]["GLO",,,invert=TRUE]))
	y_limglo  <- c(0,max(co2ccs_c[,y,]))

	p8g_c <- magpie2ggplot2(co2ccs_c_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

	p8r_c <- magpie2ggplot2(co2ccs_c_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)

############### READ DATA: CO2 from FFI ################################
v <- "Emi|CO2|Fossil Fuels and Industry (Mt CO2/yr)"
co2ffi <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2ffi <- collapseNames(co2ffi,collapsedim=2)
if(length(fulldim(co2ffi)[[2]][[3]])>1) co2ffi <- collapseNames(co2ffi) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT CO2 BECCS #####
	co2ffi_all <- fill_missing_scenarios(co2ffi)
	y_limreg  <- c(min(co2ffi[,y,]["GLO",,,invert=TRUE]),max(co2ffi[,y,]["GLO",,,invert=TRUE]))
	y_limglo  <- c(min(co2ffi[,y,]),max(co2ffi[,y,]))

	p9g <- magpie2ggplot2(co2ffi_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

	p9r <- magpie2ggplot2(co2ffi_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)

############### READ DATA: CO2 from FFI Cumulated ################################
v <- "Emi|CO2|Fossil Fuels and Industry|Cumulated (Mt CO2/yr)"
co2ffi_c <- read_all(outputdirs,read.reportEntry,entry=v,as.list=FALSE)/1000
co2ffi_c <- collapseNames(co2ffi_c,collapsedim=2)
if(length(fulldim(co2ffi_c)[[2]][[3]])>1) co2ffi_c <- collapseNames(co2ffi_c) # only if there is more than one scenario, otherwise keep single scenarioname

	#### PLOT #####
	co2ffi_c_all <- fill_missing_scenarios(co2ffi_c)
	y_limreg  <- c(min(co2ffi_c[,y,]["GLO",,,invert=TRUE]),max(co2ffi_c[,y,]["GLO",,,invert=TRUE]))
	y_limglo  <- c(min(co2ffi_c[,y,]),max(co2ffi_c[,y,]))

	p9g_c <- magpie2ggplot2(co2ffi_c_all["GLO",y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limglo,
						 title=v)

	p9r_c <- magpie2ggplot2(co2ffi_c_all[r,y,],geom='line',group=NULL,
						 ylab='GtCO2/yr',color='Data2',linetype="Data1",
						 scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=y_limreg,
						 title=v)

######################### PRINT TO PDF ################################
library(lusweave)
out<-swopen(template="david")
#out<-swopen(outfile=paste0("bioenergy_glob_comp.pdf"),template="template.tex")
swfigure(out,print,p0g,sw_option="height=9,width=16")
swfigure(out,print,p0r,sw_option="height=9,width=16")
swfigure(out,print,p1g,sw_option="height=9,width=16")
swfigure(out,print,p1r,sw_option="height=9,width=16")
swfigure(out,print,p2g,sw_option="height=9,width=16")
swfigure(out,print,p2r,sw_option="height=9,width=16")
swfigure(out,print,p1stg,sw_option="height=9,width=16")
swfigure(out,print,p1str,sw_option="height=9,width=16")
swfigure(out,print,p1stsg,sw_option="height=9,width=16")
swfigure(out,print,p1stsr,sw_option="height=9,width=16")
swfigure(out,print,p3g,sw_option="height=9,width=16")
swfigure(out,print,p3r,sw_option="height=9,width=16")
swfigure(out,print,p6g,sw_option="height=9,width=16")
swfigure(out,print,p6r,sw_option="height=9,width=16")
swfigure(out,print,p4p,sw_option="height=9,width=16")
swfigure(out,print,price_incl_tax,sw_option="height=9,width=16")
swlatex(out,"\\clearpage")
swfigure(out,print,p_dyntax,sw_option="height=9,width=16")
swfigure(out,print,p_marginal,sw_option="height=9,width=16")
swfigure(out,print,p_mult,sw_option="height=9,width=16")
swfigure(out,print,p4t,sw_option="height=9,width=16")
swfigure(out,print,tax_only,sw_option="height=9,width=16")
swfigure(out,print,p4c,sw_option="height=23,width=16")
swfigure(out,print,p5g,sw_option="height=9,width=16")
swfigure(out,print,p5r,sw_option="height=9,width=16")
swfigure(out,print,p5g_c,sw_option="height=9,width=16")
swfigure(out,print,p5r_c,sw_option="height=9,width=16")
swfigure(out,print,p7g,sw_option="height=9,width=16")
swfigure(out,print,p7r,sw_option="height=9,width=16")
swfigure(out,print,p7g_c,sw_option="height=9,width=16")
swfigure(out,print,p7r_c,sw_option="height=9,width=16")
swfigure(out,print,pNEGgs,sw_option="height=9,width=16")
swlatex(out,"\\clearpage")
swfigure(out,print,pNEGg,sw_option="height=9,width=16")
swfigure(out,print,pNEGr,sw_option="height=9,width=16")
swfigure(out,print,p8g,sw_option="height=9,width=16")
swfigure(out,print,p8r,sw_option="height=9,width=16")
swfigure(out,print,p8g_c,sw_option="height=9,width=16")
swfigure(out,print,p8r_c,sw_option="height=9,width=16")
swfigure(out,print,p9g,sw_option="height=9,width=16")
swfigure(out,print,p9r,sw_option="height=9,width=16")
swfigure(out,print,p9g_c,sw_option="height=9,width=16")
swfigure(out,print,p9r_c,sw_option="height=9,width=16")
swfigure(out,print,p10g,sw_option="height=9,width=16")
swfigure(out,print,p10r,sw_option="height=9,width=16")
swclose(out,outfile=paste0("bioenergy_glob_comp.pdf"),clean_output=TRUE)
