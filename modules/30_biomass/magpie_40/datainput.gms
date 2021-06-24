*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_40/datainput.gms

*** read in regional maxprod of pebioil and pebios (1st generation) biomass.
table p30_bio1stgen(tall,all_regi,all_enty)     "regional maximal production potential for 1st generation crops only (pebioil, pebios)"
$ondelim
$include "./modules/30_biomass/magpie_40/input/p30_bio1stgen.cs3r"
$offdelim
;

*** read in regional maxprod of pebiolc residues
table p30_biolcResidues(tall,all_regi,all_LU_emi_scen)  "regional potential for pebiolc residues"
$ondelim
$include "./modules/30_biomass/magpie_40/input/p30_biolcResidues.cs3r"
$offdelim
;

*** costs: use global costs for all regions ($/GJ -> T$/TWa)
*** define costs for pebiolc residues (2nd grade) 
*** and for pebios, pebioil (defined only for 5th grade)
p30_datapebio(regi,"pebios","5","cost",ttot)$(ttot.val ge 2005)  = 12.4 * s30_D2TD / sm_GJ_2_TWa;
p30_datapebio(regi,"pebioil","5","cost",ttot)$(ttot.val ge 2005) = 15.8 * s30_D2TD / sm_GJ_2_TWa;
p30_datapebio(regi,"pebiolc","2","cost",ttot)$(ttot.val ge 2005) =    1 * s30_D2TD / sm_GJ_2_TWa;

*** maxprod pebiolc: choose SSP and convert from PJ/yr to TWa/yr
p30_datapebio(regi,"pebiolc",rlf,"maxprod",ttot)$(ttot.val ge 2005) = p30_biolcResidues(ttot,regi,"%cm_LU_emi_scen%") * sm_EJ_2_TWa / 1000;

*** maxprod 1st gen: use regional maxprod data from MAgPIE for 1st generation energy carriers (pebios, pebioil)
p30_datapebio(regi,"pebios","5","maxprod",ttot)$(ttot.val ge 2005) = p30_bio1stgen(ttot,regi,"pebios") * sm_EJ_2_TWa / 1000;
p30_datapebio(regi,"pebioil","5","maxprod",ttot)$(ttot.val ge 2005) = p30_bio1stgen(ttot,regi,"pebioil") * sm_EJ_2_TWa / 1000;
display p30_datapebio;

*DK* Read prices and costs for 2nd gen. purpose grown bioenergy from MAgPIE (calculated with demnad from previous Remind run)
p30_pebiolc_pricemag(ttot,regi) = 0;
$if %cm_MAgPIE_coupling% == "on"  table p30_pebiolc_pricemag_coupling(tall,all_regi)     "prices and costs for 2nd gen. purpose grown bioenergy from MAgPIE"
$if %cm_MAgPIE_coupling% == "on"  $ondelim
$if %cm_MAgPIE_coupling% == "on"  $include "./modules/30_biomass/magpie_40/input/p30_pebiolc_pricemag_coupling.csv";
$if %cm_MAgPIE_coupling% == "on"  $offdelim
$if %cm_MAgPIE_coupling% == "on"  ;
$if %cm_MAgPIE_coupling% == "on"  p30_pebiolc_pricemag(ttot,regi) = p30_pebiolc_pricemag_coupling(ttot,regi);

*** Read production of ligno-cellulosic purpose grown bioenergy from look-up table (used to calculate bioenergy costs in standalone runs and substract them from budget equation)
parameter p30_biolcProductionLookup(tall,all_regi,all_LU_emi_scen,all_rcp_scen)  "regional production of pebiolc purpose grown"
/
$ondelim
$include "./modules/30_biomass/magpie_40/input/p30_biolcProductionLookup.cs4r"
$offdelim
/
;

*** select pebiolc productoion from look-up table according to SSP and RCP
p30_pebiolc_demandmag(ttot,regi) = p30_biolcProductionLookup(ttot,regi,"%cm_LU_emi_scen%","%cm_rcp_scen%");

*DK* In coupled runs overwrite pebiolc production from look-up table with actual MAgPIE values.
*DK* Read production of 2nd gen. purpose grown bioenergy from MAgPIE (given to MAgPIE from previous Remind run)
$if %cm_MAgPIE_coupling% == "on"  table p30_pebiolc_demandmag_coupling(tall,all_regi)     "production of 2nd gen. purpose grown bioenergy from MAgPIE"
$if %cm_MAgPIE_coupling% == "on"  $ondelim
$if %cm_MAgPIE_coupling% == "on"  $include "./modules/30_biomass/magpie_40/input/p30_pebiolc_demandmag_coupling.csv";
$if %cm_MAgPIE_coupling% == "on"  $offdelim
$if %cm_MAgPIE_coupling% == "on"  ;
$if %cm_MAgPIE_coupling% == "on"  p30_pebiolc_demandmag(ttot,regi) = p30_pebiolc_demandmag_coupling(ttot,regi);

*** Read parameters for bioenergy supply curve
parameter f30_bioen_price(tall,all_regi,all_LU_emi_scen,all_rcp_scen,all_charScen)  "time dependent fit coefficients for bioenergy price formula"
/
$ondelim
$include "./modules/30_biomass/magpie_40/input/f30_bioen_price.cs4r"
$offdelim
/
;

*** Select bioenergy bioenergy supply curve according to SSP scenario
i30_bioen_price_a(ttot,regi) = f30_bioen_price(ttot,regi,"%cm_LU_emi_scen%","%cm_rcp_scen%","a");
i30_bioen_price_b(ttot,regi) = f30_bioen_price(ttot,regi,"%cm_LU_emi_scen%","%cm_rcp_scen%","b");

*** FS: scale bioenergy supply curves of EU regions such that it matches with EUR bioenergy potential of H12/MagPIE runs
i30_bioen_price_b(ttot,regi)$(regi_group("EUR_regi",regi)) = cm_BioSupply_Adjust_EU * i30_bioen_price_b(ttot,regi)$(regi_group("EUR_regi",regi));

*RP* in 2005 and 2010, we always want to use bau values
loop(ttot$( (ttot.val = 2005) OR (ttot.val = 2010) ),
    i30_bioen_price_a(ttot,regi)  =  f30_bioen_price(ttot,regi,"%cm_LU_emi_scen%","none","a");
    i30_bioen_price_b(ttot,regi)  =  f30_bioen_price(ttot,regi,"%cm_LU_emi_scen%","none","b");
);
display i30_bioen_price_a, i30_bioen_price_b;

*** -------------------------------------------------------------
*** Bounds on pedem
*** -------------------------------------------------------------

*** To prevent RUS and MEA from demanding high amounts of biomass 
*** just because of their capacity to store negative emissions a
*** general rule for all regions is applied that limits the PE 
*** demand of BECCS technologies in policy runs to 30% of the total 
*** PE of the baseline scenario (see q30_limitTeBio)

***if(cm_emiscen ne 1,
***Execute_Loadpoint 'input_ref' v30_pedem_BAU=vm_demPe;
***Execute_Loadpoint 'input_ref' v30_seprod_BAU=vm_prodSe;
***
***p30_pedem_BAU(ttot,regi) =
***  sum(pe2se(enty,enty2,te)$(sameas(enty,"peoil") OR sameas(enty,"pecoal") OR sameas(enty,"pegas") OR sameas(enty,"pebiolc") OR sameas(enty,"pebios") OR sameas(enty,"pebioil")),
***    v30_pedem_BAU.l(ttot,regi,enty,enty2,te)
***  ) 
***  + sum(entySe,
***      sum(te,
***          v30_seprod_BAU.l(ttot,regi,"pegeo",entySe,te)
***        + v30_seprod_BAU.l(ttot,regi,"pehyd",entySe,te)
***        + v30_seprod_BAU.l(ttot,regi,"pewin",entySe,te)
***        + v30_seprod_BAU.l(ttot,regi,"pesol",entySe,te)
***        + v30_seprod_BAU.l(ttot,regi,"peur",entySe,te)
***      )
***    ) * 100/40  !!! substitution method
***;
***
***p30_pedemBio_BAU(ttot,regi) =
***  sum(pe2se(enty,enty2,te)$(sameas(enty,"pebiolc") OR sameas(enty,"pebios") OR sameas(enty,"pebioil")),
***    v30_pedem_BAU.l(ttot,regi,enty,enty2,te)
***  );
***);

*** EOF ./modules/30_biomass/magpie_40/datainput.gms
