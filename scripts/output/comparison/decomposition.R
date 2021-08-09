# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(magpie)
library(remind2)
library(luplot)

rm(list = ls())

# settings ----
change_agr <- FALSE # change aggregation

# map old regions to new regions
# pattern:
re_map <- list("ROX" = c("EUR", "CHN", "OAS", "RUS", "ROW", "LAM", "MEA", "JPN", "USA", "IND"))

# define baseline and policy scenarios
# ATTENTION: at the moment this needs to fit exactly the contents of the output folder
compare <- list(CLB_NE_EX_BAU = c("CLB_NE_EX_450BGT","CLB_NE_EX_450CC","CLB_NE_EX_550BGT"))

# general pattern
# compare <- list(first_bau  = c("policy1", "policy2", ...),
#                 second_bau = c("policy1", "policy3", ...))

# define path where to look for REMIND results
path <- "../../../output/"

# plot settings
plot.width <- 297 # millimeters
plot.height <- 210 # millimeters

# define years to be plotted
y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040",
            "y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")


# this is just a workaround:
# between Nash and Negishi previous to version XXXX, e.g. prices are defined over different time sets
# this function is used below when reading in to correct the calcPrice function (and other functions)
.setTime <- function(gdx, func, ...){
  t <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040",
         "y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
  return(func(gdx,...)[, t, ])
}

# another workaround
# between Nash and Negishi previous to version XXXX, current accounts are defined over different time and regional sets
.setTimeRegi <- function(gdx, func, ...){
  t <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040",
         "y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
  r <- c("ROW", "EUR", "CHN", "IND", "JPN", "RUS", "USA", "OAS", "MEA", "LAM", "AFR")
  return(func(gdx,...)[r, t, ])
}

# define and (if necessary) create plot directory
dir.create("plots")

# look if there are zipped gdxes and unzip them
gdx.zipped <- dir(path, recursive=TRUE, full.names = TRUE, pattern="last_optim.gdx.gz")

for(gdx.z in gdx.zipped){
  gunzip(gdx.z)
}

# find all gdxes and config files
gdxlist <- dir(path, recursive=TRUE, full.names = TRUE, pattern="last_optim.gdx")
cfglist <- dir(path, recursive=TRUE, full.names = TRUE, pattern="config.Rdata")

# match the scenario names to the respective GDXes
for(gdx in gdxlist){
  load(file.path(dirname(gdx), "config.Rdata"))
  names(gdxlist)[gdxlist == gdx] <- cfg$title
}

# check if all scenarios scheduled for comparison are available (NR: work in progress)
scenarios <- names(gdxlist)
wanted <- paste(names(compare), unlist(compare))

# read in data from GDXes
tsw <- collapseNames(read_all(gdxlist, readTimeStepWeight, as.list = FALSE))
cons <- collapseNames(read_all(gdxlist, readConsumption, as.list = FALSE)) / 1000
gdp <- collapseNames(read_all(gdxlist, readGDPMER, as.list = FALSE))

# regional current accounts; no global values in Nash, but they should be zero anyway
currac.reg <- collapseNames(read_all(gdxlist, .setTimeRegi, readCurrentAccount, as.list = FALSE))
# global current accounts for compatibility
currac <- mbind(currac.reg, dimSums(currac.reg, dims=1))

pgood <- collapseNames(read_all(gdxlist, .setTime, calcPrice, enty="good", type="raw", as.list = FALSE))
tcoal <- collapseNames(read_all(gdxlist, .setTime, calcNetTrade, "pecoal", as.list = FALSE))
pcoal <- collapseNames(read_all(gdxlist, .setTime, calcPrice, enty="pecoal", type="raw", as.list = FALSE))
toil <- collapseNames(read_all(gdxlist, .setTime, calcNetTrade, "peoil", as.list = FALSE))
poil <- collapseNames(read_all(gdxlist, .setTime, calcPrice, enty="peoil", type="raw", as.list = FALSE))
tgas <- collapseNames(read_all(gdxlist, .setTime, calcNetTrade, "pegas", as.list = FALSE))
pgas <- collapseNames(read_all(gdxlist, .setTime, calcPrice, enty="pegas", type="raw", as.list = FALSE))
tbio <- collapseNames(read_all(gdxlist, .setTime, calcNetTrade, "pebiolc", as.list = FALSE))
pbio <- collapseNames(read_all(gdxlist, .setTime, calcPrice, enty="pebiolc", type="raw", as.list = FALSE))
turan <- collapseNames(read_all(gdxlist, .setTime, calcNetTrade, "peur", as.list = FALSE))
puran <- collapseNames(read_all(gdxlist, .setTime, calcPrice, enty="peur", type="raw", as.list = FALSE))
tperm <- collapseNames(read_all(gdxlist, .setTime, calcNetTrade, "perm", as.list = FALSE))
pperm <- collapseNames(read_all(gdxlist, .setTime, calcPrice, enty="perm", type="raw", as.list = FALSE))
fuel <- collapseNames(read_all(gdxlist, readFuelSupplyCosts, as.list = FALSE))
oam <- collapseNames(read_all(gdxlist, readOandMcosts, as.list = FALSE))
einv <- collapseNames(read_all(gdxlist, readEnergyInvestments, as.list = FALSE))
inv <- collapseNames(read_all(gdxlist, readInvestmentsNonESM, as.list = FALSE))
abat <- collapseNames(read_all(gdxlist, readNonEnergyAbatementCosts, as.list = FALSE))

# change regional aggregation ----
if(change_agr){
  tmp <- dimSums(cons[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  cons <- mbind(tmp, cons[c("GLO", "AFR"),,])
  
  tmp <- dimSums(gdp[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  gdp <- mbind(tmp, gdp[c("GLO", "AFR"),,])
  
  tmp <- dimSums(currac[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  currac <- mbind(tmp, currac[c("GLO", "AFR"),,])
  
  tmp <- dimSums(tcoal[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  tcoal <- mbind(tmp, tcoal[c("GLO", "AFR"),,])
  
  tmp <- dimSums(toil[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  toil <- mbind(tmp, toil[c("GLO", "AFR"),,])
  
  tmp <- dimSums(tgas[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  tgas <- mbind(tmp, tgas[c("GLO", "AFR"),,])
  
  tmp <- dimSums(tbio[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  tbio <- mbind(tmp, tbio[c("GLO", "AFR"),,])
  
  tmp <- dimSums(turan[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  turan <- mbind(tmp, turan[c("GLO", "AFR"),,])
  
  tmp <- dimSums(tperm[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  tperm <- mbind(tmp, tperm[c("GLO", "AFR"),,])
  
  tmp <- dimSums(fuel[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  fuel <- mbind(tmp, fuel[c("GLO", "AFR"),,])
  
  tmp <- dimSums(oam[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  oam <- mbind(tmp, oam[c("GLO", "AFR"),,])
  
  tmp <- dimSums(einv[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  einv <- mbind(tmp, einv[c("GLO", "AFR"),,])
  
  tmp <- dimSums(inv[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  inv <- mbind(tmp, inv[c("GLO", "AFR"),,])
  
  tmp <- dimSums(abat[re_map[[1]],,], dims=1)
  getCells(tmp) <- names(re_map[1])
  abat <- mbind(tmp, abat[c("GLO", "AFR"),,])
}

for(c in 1:length(compare)){
  
  bau <- names(compare)[c]
  pol <- unlist(compare[c])
  
  # normalize energy and permit prices
  pcoaln <- pcoal[,y_plot,c(pol,bau)] / pgood[,y_plot,c(pol,bau)]
  poiln <- poil[,y_plot,c(pol,bau)] / pgood[,y_plot,c(pol,bau)]
  pgasn <- pgas[,y_plot,c(pol,bau)] / pgood[,y_plot,c(pol,bau)]
  pbion <- pbio[,y_plot,c(pol,bau)] / pgood[,y_plot,c(pol,bau)]
  purann <- puran[,y_plot,c(pol,bau)] / pgood[,y_plot,c(pol,bau)]
  ppermn <- pperm[,y_plot,c(pol,bau)] / pgood[,y_plot,c(pol,bau)]
  
  # discount and sum over time ----
  sconsd <- dimSums(cons[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  sgdpd <- dimSums(gdp[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  scurracd <- dimSums(currac[ ,y_plot, c(pol,bau)] * setNames(pgood[,y_plot, bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  scoald <- dimSums(tcoal[ ,y_plot, c(pol,bau)] * pcoaln[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  soild <- dimSums(toil[,y_plot,c(pol,bau)] * poiln[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  sgasd <- dimSums(tgas[,y_plot,c(pol,bau)] * pgasn[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  sbiod <- dimSums(tbio[,y_plot,c(pol,bau)] * pbion[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  surand <- dimSums(turan[,y_plot,c(pol,bau)] * purann[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  spermd <- dimSums(tperm[,y_plot,c(pol,bau)] * ppermn[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  sfueld <- dimSums(fuel[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  seinvd <- dimSums(einv[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  sinvd <- dimSums(inv[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  sabatd <- dimSums(abat[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  soamd <- dimSums(oam[,y_plot,c(pol,bau)] * setNames(pgood[,y_plot,bau], NULL) * setNames(tsw[,y_plot,bau], NULL), dims = 2)
  
  # calculate differences between policy and bau ####

  # consider current account effect 
  sconscurrd <- sconsd[,,bau] + scurracd[,,bau] 

  # consumption differences
  dcons <- collapseNames((sconsd[,,pol] - sconsd[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(dcons) <- paste(getNames(dcons), "Policy_cost", sep=".")
  
  # gdp effect
  gdpeff <- collapseNames((sgdpd[,,pol] - sgdpd[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(gdpeff) <- paste(getNames(gdpeff), "GDP_effect", sep=".")
  
  # current account
  dcurrac <- collapseNames((scurracd[,,pol] - scurracd[,,bau]) / (sconscurrd[,,bau]) * (-100))
  getNames(dcurrac) <- paste(getNames(dcurrac), "Current_account", sep=".")
  
  # fuel supply costs
  dfuel <- collapseNames((sfueld[,,pol] - sfueld[,,bau]) / sconscurrd[,,bau] * 100)
  getNames(dfuel) <- paste(getNames(dfuel), "ESM_var", sep=".")
  
  # coal trade
  dcoal <- collapseNames((scoald[,,pol] - scoald[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(dcoal) <- paste(getNames(dcoal), "Coal_trade", sep=".")
  
  # oil trade
  doil <- collapseNames((soild[,,pol] - soild[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(doil) <- paste(getNames(doil), "Oil_trade", sep=".")
  
  # gas trade
  dgas <- collapseNames((sgasd[,,pol] - sgasd[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(dgas) <- paste(getNames(dgas), "Gas_trade", sep=".")
  
  # uranium trade
  duran <- collapseNames((surand[,,pol] - surand[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(duran) <- paste(getNames(duran), "Uranium_trade", sep=".")
  
  # biomass trade
  dbio <- collapseNames((sbiod[,,pol] - sbiod[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(dbio) <- paste(getNames(dbio), "Biomass_trade", sep=".")
  
  # permit trade
  dperm <- collapseNames((spermd[,,pol] - spermd[,,bau]) / sconscurrd[,,bau] * (-100))
  getNames(dperm) <- paste(getNames(dperm), "Permit_trade", sep=".")
  
  # macro investments
  dinv <- collapseNames((sinvd[,,pol] - sinvd[,,bau]) / sconscurrd[,,bau] * 100)
  getNames(dinv) <- paste(getNames(dinv), "Investments", sep=".")
  
  # non-energy abatement costs
  dabat <- collapseNames((sabatd[,,pol] - sabatd[,,bau]) / sconscurrd[,,bau] * 100)
  getNames(dabat) <- paste(getNames(dabat), "non-Energy_Abatement", sep=".")
  
  # energy system investments
  deinv <- collapseNames((seinvd[,,pol] - seinvd[,,bau]) / sconscurrd[,,bau] * 100)
  #   getNames(deinv) <- paste(getNames(deinv), "ESM_Investments", sep=".")
  
  # operation and maintenance
  doam <- collapseNames((soamd[,,pol] - soamd[,,bau]) / sconscurrd[,,bau] * 100)
  #   getNames(doam) <- paste(getNames(doam), "Operation_Maintenance", sep=".")
  
  # energy system + operation and maintenance (ESM fixed costs)
  esmfix <- deinv + doam
  getNames(esmfix) <- paste(getNames(deinv), "ESM_fixed", sep=".")

  # difference between commodity price in BAU and policy
  #   dpgood <- collapseNames(pgood[,,bau] - pgood[,,pol])
  dpgood <- setNames(pgood[,,bau], NULL) - pgood[,,pol]
  
  #   # capital market effect
  capeff <- dimSums(dpgood[,y_plot,] *(cons[,y_plot, pol] + inv[,y_plot, pol] + fuel[,y_plot, pol] + abat[,y_plot, pol] - gdp[,y_plot, pol]) * setNames(tsw[,y_plot,bau], NULL), dims = 2) * 100 #setNames(pgood[,y_plot,bau], NULL)
  getNames(capeff) <- paste(getNames(capeff), "Capital_market_effect", sep=".")

  # correct policy costs by current account 
  polcost <- dcons + dcurrac 
  getNames(polcost) <- paste(getNames(polcost), "Policy_cost", sep=".")


  plot.data <- mbind(gdpeff, dinv, esmfix, dfuel, dabat, dcoal, dgas, doil, duran, dbio, dperm, capeff) # 
  splot.data <- dimSums(plot.data, dims = 4)
  getNames(splot.data) <- getNames(polcost)
  
  magpie2ggplot2(plot.data,stack=TRUE, geom="bar", fill="Data2", xaxis="Data1",ylab="%",xlab="",
#                title = paste("Decomposition of policy costs, baseline:", bau)) +
                title = paste("Decomposition of policy costs")) +
    geom_point(data=as.ggplot(polcost), size=3, shape=1) +
    geom_point(data=as.ggplot(splot.data), size=3, shape=3) +
    guides(fill=guide_legend(title=NULL))
  ggsave(file=file.path("plots", paste0("decomp_", bau, ".png")),
         width=plot.width, height=plot.height, units="mm")

  magpie2ggplot2(polcost, stack=T, geom="bar", fill="Data2", xaxis="Data1",
                 title = paste("Policy costs, baseline:", bau))
  ggsave(file=file.path("plots", paste0("polcost_", bau, ".png")),
         width=plot.width, height=plot.height, units="mm")
  
}



