# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
require(data.table)
require(gdx)
require(gdxdt)

inputgdx <- "../../../../config/input.gdx"

## years
ttot <- readgdx(inputgdx, "ttot")[[1]]

## regions
regi <- readgdx(inputgdx, "regi")[[1]]

## ces nodes
ppfen <- c("entrp_pass_sm", "entrp_pass_lo", "entrp_frgt_sm", "entrp_frgt_lo")

## technologies
tees <- c(
    "te_espet_pass_sm",
    "te_esdie_pass_sm",
    "te_eselt_pass_sm",
    "te_esdie_pass_lo",
    "te_esdie_frgt_sm",
    "te_eselt_frgt_sm",
    "te_esdie_frgt_lo")

## fes
enty <- c("fedie", "fepet", "feelt")

## prices
prices <- CJ(tall=ttot,all_regi=regi,all_in=ppfen)
prices[, value := 0]

## efficiencies
effcs <- CJ(tall=ttot,all_regi=regi,all_tees=tees)
effcs[, value := 1]

## shares
fedem <- readgdx(inputgdx, "p29_fedemand")
## uetypes
ues <- c("ueHDVt", "ueLDVt", "ueelTt")

scen <- "gdp_SSP2"

fedem <- fedem[all_in %in% ues & all_GDPscen == scen]
techmap <- data.table(
    all_in=c("ueelTt", "ueLDVt", "ueHDVt", "ueHDVt", "ueHDVt"),
    ces=c("entrp_pass_sm", "entrp_pass_sm", "entrp_pass_lo", "entrp_frgt_sm", "entrp_frgt_lo"))
## apply map
fedem <- techmap[fedem, on="all_in", allow.cartesian=T]
fedem[, ces_share := value/sum(value), by=.(tall, all_regi, ces)]

femap = data.table(all_enty=enty, all_in=ues)
out <- femap[fedem, on="all_in"][, .(tall, all_regi, all_enty, all_in=ces, value=ces_share)]

## csv for initialCap
fwrite(prices, "esCapCost.cs4r", col.names = F)
fwrite(effcs, "fe2es.cs4r", col.names = F)
fwrite(out, "shFeCes.cs4r", col.names = F)

## write gdxes
## writegdx.parameter("esCapCost.gdx", prices, "p35_esCapCost", "value", c("tall", "all_regi", "all_in"))
## writegdx.parameter("fe2es.gdx", effcs, "p35_fe2es", "value", c("tall", "all_regi", "all_tees"))
## writegdx.parameter("shFeCes.gdx", out, "p35_shFeCes", "value", c("tall", "all_regi", "all_enty", "all_in"))
