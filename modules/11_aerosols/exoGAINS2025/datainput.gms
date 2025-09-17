*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS2025/datainput.gms

*** AP scenario and SSP selection -----------------------------------------------------------------------
*** if cm_APssp is set to FROMGDPSSP, set it to the value of cm_GDPpopScen
$ifthen.derivessp1 "%cm_APssp%" == "FROMGDPSSP"
$setGlobal cm_APssp  "%cm_GDPpopScen%"
$endif.derivessp1
*** if cm_APscen is set to MTFR or SMIPVLLO, set cm_APssp accordingly
$ifthen.derivessp2 "%cm_APscen%" == "MTFR"
$setGlobal cm_APssp  "MTFR"
$elseIf.derivessp2 "%cm_APscen%" == "SMIPVLLO"
$setGlobal cm_APssp  "SMIPVLLO"
$endif.derivessp2
*** SSP4 not available for SMIPbySSP scenario
$ifthen.checkscen1 "%cm_APscen%" == "SMIPbySSP"
$ifthen.checkssp1  "%cm_APssp%" == "SSP4"
abort "SSP4 not available for SMIPbySSP scenario. Please select another scenario x ssp combination."
$endif.checkssp1
$endif.checkscen1
*** GAINSlegacy not available in exoGAINS2025
$ifthen.checkssp2  "%cm_APssp%" == "GAINSlegacy"
abort "GAINSlegacy not supported by exoGAINS2025. Please switch to exoGAINS for using GAINSlegacy.";
$endif.checkssp2

*** initialize p11_share_trans with the global value, will be updated after each negishi/nash iteration
p11_share_trans("2005",regi) = 0.617;
p11_share_trans("2010",regi) = 0.625;
p11_share_trans("2015",regi) = 0.626;
p11_share_trans("2020",regi) = 0.642;
p11_share_trans("2025",regi) = 0.684;
p11_share_trans("2030",regi) = 0.710;
p11_share_trans("2035",regi) = 0.727;
p11_share_trans("2040",regi) = 0.735;
p11_share_trans("2045",regi) = 0.735;
p11_share_trans("2050",regi) = 0.742;
p11_share_trans("2055",regi) = 0.736;
p11_share_trans("2060",regi) = 0.751;
p11_share_trans("2070",regi) = 0.774;
p11_share_trans("2080",regi) = 0.829;
p11_share_trans("2090",regi) = 0.810;
p11_share_trans("2100",regi) = 0.829;
p11_share_trans("2110",regi) = 0.818;
p11_share_trans("2130",regi) = 0.865;
p11_share_trans("2150",regi) = 0.872;

*** GAINS2025 emission factors --------------------------------------------------------------------------
parameter f11_emifacs_sectREMIND_sourceCEDS(tall,all_regi,all_enty,all_enty,all_te,all_sectorEmi,emisForEmiFac,all_APscen,all_APssp)     "GAINS2025 emission factors weighted by CEDS emissions"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS2025/input/f11_emifacs_sectREMIND_sourceCEDS.cs4r"
$offdelim
/
;
parameter f11_emifacs_sectREMIND_sourceGAINS(tall,all_regi,all_enty,all_enty,all_te,all_sectorEmi,emisForEmiFac,all_APscen,all_APssp)     "GAINS2025 emission factors weighted by GAINS emissions"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS2025/input/f11_emifacs_sectREMIND_sourceGAINS.cs4r"
$offdelim
/
;
p11_emiFacAP(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac)$(ttot.val ge 2005) = 0.0;
if (cm_APsource eq 1,  !! CEDS
  p11_emiFacAP(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac)$(ttot.val ge 2005) = f11_emifacs_sectREMIND_sourceCEDS(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac,"%cm_APscen%","%cm_APssp%");
elseIf cm_APsource  eq 2,  !! GAINS
  p11_emiFacAP(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac)$(ttot.val ge 2005) = f11_emifacs_sectREMIND_sourceGAINS(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac,"%cm_APscen%","%cm_APssp%");
else 
  abort "cm_APsource must be either CEDS or GAINS"
);

*** load emission data from land use change 
*** TODO this is outdated and not used anymore in coupled runs, should be replaced to correctly account for air pollutant emissions in MAgPIE
parameter f11_emiAPexoAgricult(tall,all_regi,all_enty,all_exogEmi,all_rcp_scen)     "ECLIPSE emission factors of air pollutants"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS2025/input/f11_emiAPexoAgricult.cs4r"
$offdelim
/
;
p11_emiAPexoAgricult(t,regi,enty,all_exogEmi) = f11_emiAPexoAgricult(t,regi,enty,all_exogEmi,"%cm_rcp_scen%");


if ( (cm_startyear gt 2005),
Execute_Loadpoint 'input_ref' p11_emiAPexo =  p11_emiAPexo;
);

p11_emiAPexo(t,regi,enty,"Agriculture")      = p11_emiAPexoAgricult(t,regi,enty,"Agriculture");
p11_emiAPexo(t,regi,enty,"AgWasteBurning")   = p11_emiAPexoAgricult(t,regi,enty,"AgWasteBurning");
p11_emiAPexo(t,regi,enty,"ForestBurning")    = p11_emiAPexoAgricult(t,regi,enty,"ForestBurning");
p11_emiAPexo(t,regi,enty,"GrasslandBurning") = p11_emiAPexoAgricult(t,regi,enty,"GrasslandBurning");

*** this parameter is not part of the optimization, but just used in remind2::reportEmiAirPol() to for emissions only accounted at the global level
*** TODO updated to account for updated calculation of aviation and international shipping emissions in reportExtraEmissions
parameter f11_emiAPexoGlob(tall,all_rcp_scen,all_enty,all_exogEmi)                     "exogenous emissions for aviation and international shipping from RCP scenarios"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS2025/input/f11_emiAPexoGlob.cs4r";
$offdelim
/;
p11_emiAPexoGlob(ttot,enty,all_exogEmi) = f11_emiAPexoGlob(ttot,"rcp60",enty,all_exogEmi);

*** TODO updated to account for updated calculation of waste emissions
parameter f11_emiAPexo(tall,all_regi,all_rcp_scen,all_enty,all_exogEmi)    "exogenous emissions from RCP scenarios"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS2025/input/f11_emiAPexo.cs4r"
$offdelim
/;
p11_emiAPexo(ttot,regi,enty,"Waste") = f11_emiAPexo(ttot,regi,"rcp60",enty,"Waste");
display p11_emiAPexoGlob,p11_emiAPexo;

*** Initialize p11_emiAPexsolve to zero 
*** TODO Could be improved by using values from previous run if available
p11_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP) = 0;

*JS* exogenous air pollutant emissions from land use, land use change, and industry processes
*** TODO These emissions are outdated, needs to be updated to include outputs from MAgPIE
pm_emiExog(t,regi,"SO2") = p11_emiAPexo(t,regi,"SO2","AgWasteBurning")
                         + p11_emiAPexo(t,regi,"SO2","Agriculture")
                         + p11_emiAPexo(t,regi,"SO2","ForestBurning")
                         + p11_emiAPexo(t,regi,"SO2","GrasslandBurning")
                         + p11_emiAPexo(t,regi,"SO2","Waste")
                         + p11_emiAPexsolve(t,regi,"solvents","SOx")
                         + p11_emiAPexsolve(t,regi,"extraction","SOx")
                         + p11_emiAPexsolve(t,regi,"indprocess","SOx");
pm_emiExog(t,regi,"BC") = p11_emiAPexo(t,regi,"BC","AgWasteBurning")
                        + p11_emiAPexo(t,regi,"BC","Agriculture")
                        + p11_emiAPexo(t,regi,"BC","ForestBurning")
                        + p11_emiAPexo(t,regi,"BC","GrasslandBurning")
                        + p11_emiAPexo(t,regi,"BC","Waste")
                        + p11_emiAPexsolve(t,regi,"solvents","BC")
                        + p11_emiAPexsolve(t,regi,"extraction","BC")
                        + p11_emiAPexsolve(t,regi,"indprocess","BC");
pm_emiExog(t,regi,"OC") = p11_emiAPexo(t,regi,"OC","AgWasteBurning")
                        + p11_emiAPexo(t,regi,"OC","Agriculture")
                        + p11_emiAPexo(t,regi,"OC","ForestBurning")
                        + p11_emiAPexo(t,regi,"OC","GrasslandBurning")
                        + p11_emiAPexo(t,regi,"OC","Waste")
                        + p11_emiAPexsolve(t,regi,"solvents","OC")
                        + p11_emiAPexsolve(t,regi,"extraction","OC")
                        + p11_emiAPexsolve(t,regi,"indprocess","OC");

display p11_emiFacAP;
display pm_emiExog;

parameter p11_share_ind_fehos(tall,all_regi)               "Share of heating oil used in the industry (rest is residential)"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS2025/input/p11_share_ind_fehos.cs4r"
$offdelim
/
;


if (cm_startyear eq 2005,
  Execute_Loadpoint 'input'      p11_cesIO = vm_cesIO.l;
else
  Execute_Loadpoint 'input_ref'  p11_cesIO = vm_cesIO.l;
);

*** Initialise sector shares to 1
p11_share_sector(ttot,sectorEndoEmi2te(enty,enty2,te,sectorEndoEmi),regi) = 1.0;

*** Compute sector shares
loop ((t,regi)$( t.val ge 2005 ),
  !! share in solids
  if (sum(fe2ppfEn("fesos",in), p11_cesIO(t,regi,in)) gt 0,
    p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi)
    = sum(fe_tax_sub_sbi("fehos",in), p11_cesIO(t,regi,in))
    / sum(fe2ppfEn("fesos",in), p11_cesIO(t,regi,in));

    p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi)
    = p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi);
  else
    p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi)
    = pm_share_ind_fesos(t,regi);

    !! When calibrating to a new region set with insufficient data coverage in
    !! the gdx, vm_cesIO will be all zero.  In that case, simply split 50/50.
    p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi) = 0.5;
  );

  p11_share_sector(ttot,"pecoal","sesofos","coaltr","res",regi)
  = 1 - p11_share_sector(ttot,"pecoal","sesofos","coaltr","indst",regi);

  p11_share_sector(ttot,"pebiolc","sesobio","biotr","res",regi)
  = 1 - p11_share_sector(ttot,"pebiolc","sesobio","biotr","indst",regi);

  !! share in liquids
  p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi)
    = p11_share_ind_fehos(t,regi);

  p11_share_sector(t,"seliqfos","fehos","tdfoshos","res",regi)
  = 1 - p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","trans",regi)
  = p11_share_trans(t,regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","indst",regi)
  = (1 - p11_share_trans(t,regi))
  * p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","res",regi)
  = (1 - p11_share_trans(t,regi))
  * (1 - p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi));

  !! share in gases
  p11_share_sector(t,"pegas","segafos","gastr","indst",regi)
    = p11_share_ind_fehos(t,regi);

  p11_share_sector(t,"pegas","segafos","gastr","res",regi)
  = 1 - p11_share_sector(t,"pegas","segafos","gastr","indst",regi);
);


display p11_share_sector;

*** Allocate emission factors for species whose emissions are part of the core equations (SO2, BC, OC).
*** This is required by the box model (although a different implementation could be done)
*** Emissions resulting from these EF should be computed in the external R script
***-- SO2/BC/OC -----
loop(emiExog,
***-- Coal/Power ---
  pm_emifac(ttot,regi,"pecoal",enty2,te,emiExog)$emi2te("pecoal",enty2,te,emiExog) =
    p11_emiFacAP(ttot,regi,"pecoal",enty2,te,"power",emiExog);
***-- Coal/Other ---
  pm_emifac(ttot,regi,"pecoal",enty2,"coaltr",emiExog)$emi2te("pecoal",enty2,"coaltr",emiExog) =
         pm_share_ind_fesos(ttot,regi)  * p11_emiFacAP(ttot,regi,"pecoal",enty2,"coaltr","indst",emiExog)
    + (1-pm_share_ind_fesos(ttot,regi)) * p11_emiFacAP(ttot,regi,"pecoal",enty2,"coaltr","res",  emiExog);
***-- Oil/Power ---
  pm_emifac(ttot,regi,"peoil",enty2,"dot",emiExog)$emi2te("peoil",enty2,"dot",emiExog) =
    p11_emiFacAP(ttot,regi,"peoil",enty2,"dot","power",emiExog);
);

***-- SO2 specific ----
***-- Oil/Other ---
pm_emifac(ttot,regi,"peoil",enty2,"refliq","SO2") =
  p11_share_trans(ttot,regi) * p11_emiFacAP(ttot,regi,"peoil",enty2,"refliq","trans","SO2")
  + (1-p11_share_trans(ttot,regi))
  * (
         p11_share_ind_fehos(ttot,regi)  * p11_emiFacAP(ttot,regi,"peoil",enty2,"refliq","indst","SO2")
    + (1-p11_share_ind_fehos(ttot,regi)) * p11_emiFacAP(ttot,regi,"peoil",enty2,"refliq","res",  "SO2")
  );

***-- BC/OC specific -----
loop(emiAP,
***-- Biomass/Power ---
  pm_emifac(ttot,regi,"pebiolc",enty2,te,emiAP)$emi2te("pebiolc",enty2,te,emiAP) =
    p11_emiFacAP(ttot,regi,"pebiolc",enty2,te,"power",emiAP);
***-- Biomass/Other ---
  pm_emifac(ttot,regi,"pebiolc",enty2,"biotr",emiAP)$emi2te("pebiolc",enty2,"biotr",emiAP) =
         pm_share_ind_fesos_bio(ttot,regi)  * p11_emiFacAP(ttot,regi,"pebiolc",enty2,"biotr","indst",emiAP)
    + (1-pm_share_ind_fesos_bio(ttot,regi)) * p11_emiFacAP(ttot,regi,"pebiolc",enty2,"biotr","res",  emiAP);
***-- Mordern Biomass/All ---
  pm_emifac(ttot,regi,"pebiolc",enty2,"biotrmod",emiAP)$emi2te("pebiolc",enty2,"biotrmod",emiAP) =
    pm_emifac(ttot,regi,"pebiolc",enty2,"biotr",emiAP);
*JeS* emissions factors on final energy to be able to take into account synthetic liquids.
  pm_emifac(ttot,regi,"seliqfos","fehos","tdfoshos",emiAP) =
         p11_share_ind_fehos(ttot,regi)  * p11_emiFacAP(ttot,regi,"seliqfos","fehos","tdfoshos","indst", emiAP)
    + (1-p11_share_ind_fehos(ttot,regi)) * p11_emiFacAP(ttot,regi,"seliqfos","fehos","tdfoshos","res",   emiAP);
  pm_emifac(ttot,regi,"seliqfos","fedie","tdfosdie",emiAP) =
    p11_emiFacAP(ttot,regi,"seliqfos","fedie","tdfosdie","trans",emiAP);
  pm_emifac(ttot,regi,"seliqfos","fepet","tdfospet",emiAP) =
    p11_emiFacAP(ttot,regi,"seliqfos","fepet","tdfospet","trans",emiAP);
);

display pm_emifac;

*** calculation of air pollution costs
p11_EF_mean(enty,enty2,te,enty3)$emi2te(enty,enty2,te,enty3) = sum(regi,pm_emifac("2005",regi,enty,enty2,te,enty3))/11;

*JeS data is taken from US EPA http://www.epa.gov/ttnecas1/models/DOCumentationReport.pdf#page=1469
p11_costpollution("pc",     "SO2","power")  = 768;
p11_costpollution("coalchp","SO2","power")  = 768;
p11_costpollution("coalhp", "SO2","power")  = 768;
p11_costpollution("dot",    "SO2","power")  = 2262;

p11_costpollution("coaltr",  "SO2","indst") = 768;
p11_costpollution("coaltr",  "BC", "res")   = 117;
p11_costpollution("biOChp",  "BC", "power") = 117;
p11_costpollution("biohp",   "BC", "power") = 117;
p11_costpollution("biotr",   "BC", "indst") = 117;
p11_costpollution("biotr",   "BC", "res")   = 2000;
p11_costpollution("biotrmod","BC", "indst") = 117;
p11_costpollution("biotrmod","BC", "res")   = 2000;
p11_costpollution("tdfoshos",   "SO2","indst") = 2262;
p11_costpollution("tdfoshos",   "BC", "res")   = 110;
p11_costpollution("tdfosdie",   "BC", "trans") = 40000;
p11_costpollution("tdfospet",   "BC", "trans") = 40000;

p11_EF_uncontr(enty,enty2,te,regi,"SO2",sectorEndoEmi)$(sectorEndoEmi2te(enty,enty2,te,sectorEndoEmi)) = pm_emifac("2005",regi,enty,enty2,te,"SO2") + 0.0001;
p11_EF_uncontr(enty,enty2,te,regi,"BC",sectorEndoEmi)$(sectorEndoEmi2te(enty,enty2,te,sectorEndoEmi))  = pm_emifac("2005",regi,enty,enty2,te,"BC")  + 0.0001;
p11_EF_uncontr(enty,enty2,te,regi,"OC",sectorEndoEmi)$(sectorEndoEmi2te(enty,enty2,te,sectorEndoEmi))  = pm_emifac("2005",regi,enty,enty2,te,"OC")  + 0.0001;

*** EOF ./modules/11_aerosols/exoGAINS2025/datainput.gms
