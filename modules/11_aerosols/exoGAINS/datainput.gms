*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS/datainput.gms
***----------------------------------
*** Using EDGE-downscaling procedure
***----------------------------------

*** SSP/ECLIPSE emission factors
parameter f11_emiFacAP(tall,all_regi,all_enty,all_enty,all_te,all_sectorEmi,emisForEmiFac,all_APscen)     "ECLIPSE emission factors of air pollutants"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS/input/f11_emiFacAP.cs4r"
$offdelim
/
;
p11_emiFacAP(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac)$(ttot.val ge 2005) = 0.0;
p11_emiFacAP(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac)$(ttot.val ge 2005) = f11_emiFacAP(ttot,regi,enty,enty2,te,sectorEndoEmi,emisForEmiFac,"%cm_APscen%");

*** load emission data from land use change
parameter f11_emiAPexoAgricult(tall,all_regi,all_enty,all_exogEmi,all_rcp_scen)     "ECLIPSE emission factors of air pollutants"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS/input/f11_emiAPexoAgricult.cs4r"
$offdelim
/
;
p11_emiAPexoAgricult(t,regi,enty,all_exogEmi) = f11_emiAPexoAgricult(t,regi,enty,all_exogEmi,"%cm_rcp_scen%");


if ( (cm_startyear gt 2005),
Execute_Loadpoint 'input_ref' pm_emiAPexo =  pm_emiAPexo;
);

pm_emiAPexo(t,regi,enty,"Agriculture")      = p11_emiAPexoAgricult(t,regi,enty,"Agriculture");
pm_emiAPexo(t,regi,enty,"AgWasteBurning")   = p11_emiAPexoAgricult(t,regi,enty,"AgWasteBurning");
pm_emiAPexo(t,regi,enty,"ForestBurning")    = p11_emiAPexoAgricult(t,regi,enty,"ForestBurning");
pm_emiAPexo(t,regi,enty,"GrasslandBurning") = p11_emiAPexoAgricult(t,regi,enty,"GrasslandBurning");


parameter f11_emiAPexoGlob(tall,all_rcp_scen,all_enty,all_exogEmi)                     "exogenous emissions for aviation and international shipping from RCP scenarios"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS/input/f11_emiAPexoGlob.cs4r";
$offdelim
/;
pm_emiAPexoGlob(ttot,enty,all_exogEmi) = f11_emiAPexoGlob(ttot,"rcp60",enty,all_exogEmi);

parameter f11_emiAPexo(tall,all_regi,all_rcp_scen,all_enty,all_exogEmi)    "exogenous emissions from RCP scenarios"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS/input/f11_emiAPexo.cs4r"
$offdelim
/;
pm_emiAPexo(ttot,regi,enty,"Waste") = f11_emiAPexo(ttot,regi,"rcp60",enty,"Waste");
display pm_emiAPexoGlob,pm_emiAPexo;

parameter pm_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP) "???";
parameter f11_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP,all_APscen) "ECLIPSE emission factors of air pollutants"
/
$ondelim
$include "./modules/11_aerosols/exoGAINS/input/f11_emiAPexsolve.cs4r"
$offdelim
/
;
pm_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP) = f11_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP,"%cm_APscen%");

*JS* exogenous air pollutant emissions from land use, land use change, and industry processes
pm_emiExog(t,regi,"SO2") = pm_emiAPexo(t,regi,"SO2","AgWasteBurning")
                         + pm_emiAPexo(t,regi,"SO2","Agriculture")
                         + pm_emiAPexo(t,regi,"SO2","ForestBurning")
                         + pm_emiAPexo(t,regi,"SO2","GrasslandBurning")
                         + pm_emiAPexo(t,regi,"SO2","Waste")
                         + pm_emiAPexsolve(t,regi,"solvents","SOx")
                         + pm_emiAPexsolve(t,regi,"extraction","SOx")
                         + pm_emiAPexsolve(t,regi,"indprocess","SOx");
pm_emiExog(t,regi,"BC") = pm_emiAPexo(t,regi,"BC","AgWasteBurning")
                        + pm_emiAPexo(t,regi,"BC","Agriculture")
                        + pm_emiAPexo(t,regi,"BC","ForestBurning")
                        + pm_emiAPexo(t,regi,"BC","GrasslandBurning")
                        + pm_emiAPexo(t,regi,"BC","Waste")
                        + pm_emiAPexsolve(t,regi,"solvents","BC")
                        + pm_emiAPexsolve(t,regi,"extraction","BC")
                        + pm_emiAPexsolve(t,regi,"indprocess","BC");
pm_emiExog(t,regi,"OC") = pm_emiAPexo(t,regi,"OC","AgWasteBurning")
                        + pm_emiAPexo(t,regi,"OC","Agriculture")
                        + pm_emiAPexo(t,regi,"OC","ForestBurning")
                        + pm_emiAPexo(t,regi,"OC","GrasslandBurning")
                        + pm_emiAPexo(t,regi,"OC","Waste")
                        + pm_emiAPexsolve(t,regi,"solvents","OC")
                        + pm_emiAPexsolve(t,regi,"extraction","OC")
                        + pm_emiAPexsolve(t,regi,"indprocess","OC");

display p11_emiFacAP;
display pm_emiExog;

$IFTHEN.sectorshares %CES_structure% == "stationary_transport"
*** Define sector shares
p11_share_sector(ttot,sectorEndoEmi2te(enty,enty2,te,sectorEndoEmi),regi) = 1.0;
p11_share_sector(ttot,"seliqfos","fehos","tdfoshos","indst",regi)  = pm_share_ind_fehos(ttot,regi);
p11_share_sector(ttot,"seliqfos","fehos","tdfoshos","res",regi)    = 1-pm_share_ind_fehos(ttot,regi);
p11_share_sector(ttot,"pebiolc","sesobio","biotr","indst",regi) = pm_share_ind_fesos_bio(ttot,regi);
p11_share_sector(ttot,"pebiolc","sesobio","biotr","res",regi)   = 1-pm_share_ind_fesos_bio(ttot,regi);
p11_share_sector(ttot,"pecoal","sesofos","coaltr","indst",regi) = pm_share_ind_fesos(ttot,regi);
p11_share_sector(ttot,"pecoal","sesofos","coaltr","res",regi)   = 1-pm_share_ind_fesos(ttot,regi);
p11_share_sector(ttot,"pegas","segafos","gastr","indst",regi)   = pm_share_ind_fehos(ttot,regi);
p11_share_sector(ttot,"pegas","segafos","gastr","res",regi)     = 1-pm_share_ind_fehos(ttot,regi);
p11_share_sector(ttot,"peoil","seliqfos","refliq","trans",regi) = pm_share_trans(ttot,regi);
p11_share_sector(ttot,"peoil","seliqfos","refliq","indst",regi) = (1-pm_share_trans(ttot,regi))*pm_share_ind_fehos(ttot,regi);
p11_share_sector(ttot,"peoil","seliqfos","refliq","res",regi)   = (1-pm_share_trans(ttot,regi))*(1-pm_share_ind_fehos(ttot,regi));

$ELSE.sectorshares


if (cm_emiscen eq 1,
  Execute_Loadpoint 'input'      p11_cesIO = vm_cesIO.l;
else
  Execute_Loadpoint 'input_ref'  p11_cesIO = vm_cesIO.l;
);

*** Initialise sector shares to 1
p11_share_sector(ttot,sectorEndoEmi2te(enty,enty2,te,sectorEndoEmi),regi) = 1.0;

*** Compute sector shares
loop ((t,regi)$( t.val ge 2005 ),
  !! share in solids
  if (sum(fe2ppfen("fesos",in), p11_cesIO(t,regi,in)) gt 0,
    p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi)
    = sum(fe_tax_sub_sbi("fehos",in), p11_cesIO(t,regi,in))
    / sum(fe2ppfen("fesos",in), p11_cesIO(t,regi,in));

    p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi)
    = p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi);
  else 
    p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi)
    = pm_share_ind_fesos(t,regi);

    if (sum(fe_tax_sub_sbi("fesoi",in), p11_cesIO("2005",regi,in)) gt 0,
      p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi)
      = pm_share_ind_fesos_bio(t,regi)
      * sum(fe_tax_sub_sbi("fesoi",in), p11_cesIO(t,regi,in))
      / sum(fe_tax_sub_sbi("fesoi",in), p11_cesIO("2005",regi,in));
    else
      !! When calibrating to a new region set with insufficient data coverage in
      !! the gdx, vm_cesIO will be all zero.  In that case, simply split 50/50.
      p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi) = 0.5;
    );
  );

  p11_share_sector(ttot,"pecoal","sesofos","coaltr","res",regi)
  = 1 - p11_share_sector(ttot,"pecoal","sesofos","coaltr","indst",regi);

  p11_share_sector(ttot,"pebiolc","sesobio","biotr","res",regi)
  = 1 - p11_share_sector(ttot,"pebiolc","sesobio","biotr","indst",regi);

  !! share in liquids
  if (sum(fe2ppfen("fehos",in), p11_cesIO(t,regi,in)) gt 0,
    p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi)
    = sum(fe_tax_sub_sbi("fehoi",in), p11_cesIO(t,regi,in))
    / sum(fe2ppfen("fehos",in), p11_cesIO(t,regi,in));
  else
    p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi)
    = pm_share_ind_fehos(t,regi)
  );

  p11_share_sector(t,"seliqfos","fehos","tdfoshos","res",regi)
  = 1 - p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","trans",regi)
  = pm_share_trans(t,regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","indst",regi)
  = (1 - pm_share_trans(t,regi))
  * p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","res",regi)
  = (1 - pm_share_trans(t,regi))
  * (1 - p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi));

  !! share in gases
  if (sum(fe2ppfen("fegas",in), p11_cesIO(t,regi,in)) gt 0,
    p11_share_sector(t,"pegas","segafos","gastr","indst",regi)
    = sum(fe_tax_sub_sbi("fegai",in), p11_cesIO(t,regi,in))
    / sum(fe2ppfen("fegas",in), p11_cesIO(t,regi,in));
  else
    p11_share_sector(t,"pegas","segafos","gastr","indst",regi)
    = pm_share_ind_fehos(t,regi);
  );

  p11_share_sector(t,"pegas","segafos","gastr","res",regi)
  = 1 - p11_share_sector(t,"pegas","segafos","gastr","indst",regi);
);
$ENDIF.sectorshares

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
  pm_share_trans(ttot,regi) * p11_emiFacAP(ttot,regi,"peoil",enty2,"refliq","trans","SO2")
  + (1-pm_share_trans(ttot,regi)) 
  * (
         pm_share_ind_fehos(ttot,regi)  * p11_emiFacAP(ttot,regi,"peoil",enty2,"refliq","indst","SO2")
    + (1-pm_share_ind_fehos(ttot,regi)) * p11_emiFacAP(ttot,regi,"peoil",enty2,"refliq","res",  "SO2")
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
         pm_share_ind_fehos(ttot,regi)  * p11_emiFacAP(ttot,regi,"seliqfos","fehos","tdfoshos","indst", emiAP)
    + (1-pm_share_ind_fehos(ttot,regi)) * p11_emiFacAP(ttot,regi,"seliqfos","fehos","tdfoshos","res",   emiAP);
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

*** EOF ./modules/11_aerosols/exoGAINS/datainput.gms
