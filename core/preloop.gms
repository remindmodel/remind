*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/preloop.gms

***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
***                   MODEL             HYBRID
***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
*** definition of model hybrid 
model hybrid /all/;

***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
***                   GDX    stuff       
***------------------------------------------------------------------------------
***------------------------------------------------------------------------------

*** Set level values, so that reference value is available even if gdx has no level value to overwrite. Gams complains if .l was never initialized.
vm_emiMacSector.l(ttot,regi,enty)      = 0;
vm_emiTe.l(ttot,regi,enty)      = 0;
vm_emiCdr.l(ttot,regi,enty)	     = 0;
vm_prodFe.l(ttot,regi,entyFe2,entyFe2,te) = 0;
vm_prodSe.l(ttot,regi,enty,enty2,te) = 0;
vm_demSe.l(ttot,regi,enty,enty2,te) = 0;
vm_Xport.l(ttot,regi,tradePe)       = 0;
v_capDistr.l(t,regi,te,rlf)          = 0;
vm_cap.l(t,regi,te,rlf)              = 0;
vm_fuExtr.l(ttot,regi,"pebiolc","1")$(ttot.val ge 2005)  = 0;
vm_pebiolc_price.l(ttot,regi)$(ttot.val ge 2005)         = 0;
vm_emiAllMkt.l(t,regi,enty,emiMkt) = 0;
vm_co2eqMkt.l(ttot,regi,emiMkt) = 0;

v_shfe.l(t,regi,enty,sector) = 0;
v_shGasLiq_fe.l(t,regi,sector) = 0;  
pm_share_CCS_CCO2(t,regi) = 0; 
pm_taxCO2eqSum(t,regi) = 0;

*** overwrite default targets with gdx values if wanted
Execute_Loadpoint 'input' p_emi_budget1_gdx = sm_budgetCO2eqGlob;
Execute_Loadpoint 'input' vm_demPe.l = vm_demPe.l;
Execute_Loadpoint 'input' q_balPe.m = q_balPe.m;
Execute_Loadpoint 'input' qm_budget.m = qm_budget.m;
Execute_Loadpoint 'input' q_co2eq.m = q_co2eq.m;
Execute_Loadpoint 'input' pm_pvp = pm_pvp;
Execute_Loadpoint 'input' vm_demFeSector.l = vm_demFeSector.l;

if (cm_gdximport_target eq 1,
  if ( ((p_emi_budget1_gdx < 1.5 * sm_budgetCO2eqGlob) AND (p_emi_budget1_gdx > 0.5 * sm_budgetCO2eqGlob)),
  sm_budgetCO2eqGlob=p_emi_budget1_gdx;
  );
);
*MLB 07072014* ficticious budget break down for Negishi mode, not part of the optimization
pm_budgetCO2eq(regi) = 1/card(regi) * sm_budgetCO2eqGlob;
display sm_budgetCO2eqGlob;


*cb adjustment of vintages to account for fast growth in developing countries
*** adjust vintages for real FE growth in years 1995-2005
*** 2005 capacity addition (regi,"1",te) is scaled with ratio between (growth rate + 1/lifetime) and 1/lifetime, 
*** with an offset of 0.5% to account for the general growth assumed in generisdata_vintages; for  regions with declining FE, 10% is minimum ratio
*** 2000 capacity addition (regi,"6",te) is scaled with the average of the above ratio and 1
*** PE2SE technologies
loop(pe2se(enty,entySe,te)$((not sameas(entySe,"seh2")) AND (not sameas(te,"dhp")) AND (not sameas(te,"tnrs")) ),
  pm_vintage_in(regi,"1",te) = pm_vintage_in(regi,"1",te) * max(   ( (pm_histfegrowth(regi,entySe) - 0.005) + 1/fm_dataglob("lifetime",te)) / (1/fm_dataglob("lifetime",te))           , 0.1);
  pm_vintage_in(regi,"6",te) = pm_vintage_in(regi,"6",te) * max( ( ( (pm_histfegrowth(regi,entySe) - 0.005) + 1/fm_dataglob("lifetime",te)) / (1/fm_dataglob("lifetime",te)) + 1) * 0.75 , 0.2);
);
***SE2FE technologies
loop(se2fe(enty,entyFe,te)$((not sameas(enty, "seh2")) AND (not sameas(entyFe, "feelt"))),
pm_vintage_in(regi,"1",te) = pm_vintage_in(regi,"1",te) * max((pm_histfegrowth(regi,entyFe)- 0.005 + 1/fm_dataglob("lifetime",te))/(1/fm_dataglob("lifetime",te)),0.1);
pm_vintage_in(regi,"6",te) = pm_vintage_in(regi,"6",te) * max(((pm_histfegrowth(regi,entyFe)- 0.005 + 1/fm_dataglob("lifetime",te))/(1/fm_dataglob("lifetime",te)) + 1)* 0.75, 0.2);
);


*** The N2O emissions generated during biomass production in agriculture (in MAgPIE)
*** are represented in REMIND by applying the n2obio emission factor (zero in coupled runs)
*** in q_macBase. In standaolne runs the resulting emissions need to be subtracted (see below)
*** from the exogenous emission baseline read from MAgPIE, since the baseline already implicitly 
*** includes the N2O emissions from biomass. In q_macBase in core/equations.gms the N2O 
*** emissions resulting from the actual biomass demand in REMIND are then added again. 
*** In case some inconsistencies between pm_pebiolc_demandmag and pm_macBaseMagpie lead to
*** negative values, set the value to 0 instead, since negative values may lead to 
*** infeasibilities.
display pm_macBaseMagpie;
pm_macBaseMagpie(t,regi,"n2ofertin") = max(0, pm_macBaseMagpie(t,regi,"n2ofertin") - (p_efFossilFuelExtr(regi,"pebiolc","n2obio") * pm_pebiolc_demandmag(t,regi)));
display pm_macBaseMagpie;


$IFTHEN.scaleEmiHist %c_scaleEmiHistorical% == "on"
*** Re-scale MAgPie reference CH4 and N2O emissions to be inline with eurostat
*** data (depending on the region MAgPIE non-CO2 GHG emissions can be up to 
*** twice as high as historic emissions). This involves different emission variables in
*** pm_macBaseMagpie and additionall agwaste variables from p_macBaseExo
display p_macBaseExo;

*** Define rescale factor for MAgPIE CH4 emissions
p_aux_scaleEmiHistorical_ch4(regi)$p_histEmiSector("2005",regi,"ch4","agriculture","process") =
  (p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")) !!no rescaling needed - REMIND-internal unit is Mt CH4
    /
  (sum(enty$emiMacMagpieCH4(enty), pm_macBaseMagpie("2005",regi,enty)) + p_macBaseExo("2005",regi,"ch4agwaste"));
*** Rescale CH4 emissions so that all subtypes add up to the historic values
*** pm_macBaseMagpie
pm_macBaseMagpie(ttot,regi,enty)$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_ch4(regi) AND emiMacMagpieCH4(enty)) =
  pm_macBaseMagpie(ttot,regi,enty) * p_aux_scaleEmiHistorical_ch4(regi);
*** p_macBaseExo
p_macBaseExo(ttot,regi,"ch4agwaste")$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_ch4(regi)) =
  p_macBaseExo(ttot,regi,"ch4agwaste") * p_aux_scaleEmiHistorical_ch4(regi);

*** Define rescale factor for MAgPIE N2O emissions
p_aux_scaleEmiHistorical_n2o(regi)$p_histEmiSector("2005",regi,"n2o","agriculture","process") =
  p_histEmiSector("2005",regi,"n2o","agriculture","process")/( 44 / 28) !! rescaling to Mt N (internal unit for N2O emissions), since eurostat uses 298 to convert N2O to CO2eq
    /
  (sum(enty$emiMacMagpieN2O(enty), pm_macBaseMagpie("2005",regi,enty)) + p_macBaseExo("2005",regi,"n2oagwaste"));
*** Rescale N2O emissions so that all subtypes add up to the historic values
*** pm_macBaseMagpie
pm_macBaseMagpie(ttot,regi,enty)$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_n2o(regi) AND emiMacMagpieN2O(enty)) =
  pm_macBaseMagpie(ttot,regi,enty) * p_aux_scaleEmiHistorical_n2o(regi);
*** p_macBaseExo
p_macBaseExo(ttot,regi,"n2oagwaste")$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_n2o(regi)) =
  p_macBaseExo(ttot,regi,"n2oagwaste") * p_aux_scaleEmiHistorical_n2o(regi);

display pm_macBaseMagpie;
$ENDIF.scaleEmiHist

!! all net negative co2luc
p_macBaseMagpieNegCo2(t,regi) = pm_macBaseMagpie(t,regi,"co2luc")$(pm_macBaseMagpie(t,regi,"co2luc") < 0);

*** Rescale agricultural emissions baseline if c_agricult_base_shift switch is activated
$IFTHEN.agricult_base_shift not "%c_agricult_base_shift%" == "off"

p_macBaseMagpie_beforeShift(t,regi,enty)=pm_macBaseMagpie(t,regi,enty);
*** gradual phase-in of rescaling until 2040
p_agricult_shift_phasein(t) = 0;
p_agricult_shift_phasein("2025") = 0.25;
p_agricult_shift_phasein("2030") = 0.5;
p_agricult_shift_phasein("2035") = 0.75;
p_agricult_shift_phasein(t)$(t.val ge 2040) = 1;

*** rescaling all ext_regi provided by c_agricult_base_shift
loop((ext_regi)$(p_agricult_base_shift(ext_regi)), 
 loop(regi$regi_groupExt(ext_regi,regi),

    pm_macBaseMagpie(t,regi,enty)$( emiMac2sector(enty,"agriculture","process","ch4") 
                                    OR emiMac2sector(enty,"agriculture","process","n2o"))
    = p_macBaseMagpie_beforeShift(t,regi,enty)
      * (1 + p_agricult_shift_phasein(t)
           * p_agricult_base_shift(ext_regi));

  );
);


display pm_macBaseMagpie;
$ENDIF.agricult_base_shift  

$IFTHEN.out "%cm_debug_preloop%" == "on" 
option limrow = 70;
option limcol = 70;
$ELSE.out
option limrow = 0;
option limcol = 0;
$ENDIF.out


*** load PE, SE, FE price parameters from reference gdx to have prices in time steps before cm_startyear
if (cm_startyear gt 2005,
execute_load "input_ref.gdx", pm_PEPrice, pm_SEPrice, pm_FEPrice;
);

*** load vm_capEarlyReti(ttot,regi,te) from reference gdx to have a reference point for q_smoothphaseoutCapEarlyReti and q_limitCapEarlyReti
if (cm_startyear gt 2005,
Execute_Loadpoint 'input_ref' vm_capEarlyReti.l = vm_capEarlyReti.l;
);

*** initialize the carrier subtype shares in final energy demand such that the starting point for the model is "all sectors have the same bio/fos/syn shares for a given carrier type" when cm_seFeSectorShareDevMethod is enabled
p_shSeFe(t,regi,entySe)$((entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe)) AND sum(seAgg$seAgg2se(seAgg,entySe), sum((sector,emiMkt)$sector2emiMkt(sector,emiMkt), sum(entySe2$seAgg2se(seAgg,entySe2), sum(entyFe$(sefe(entySe2,entyFe) AND entyFe2Sector(entyFe,sector)), vm_demFeSector.l(t,regi,entySe2,entyFe,sector,emiMkt))))) ) =
  sum((sector,emiMkt)$(sector2emiMkt(sector,emiMkt) AND (NOT(sameas(sector,"CDR")))), sum(entyFe$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector)), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))
  /
  sum(seAgg$seAgg2se(seAgg,entySe), sum((sector,emiMkt)$(sector2emiMkt(sector,emiMkt)  AND (NOT(sameas(sector,"CDR")))), sum(entySe2$seAgg2se(seAgg,entySe2), sum(entyFe$(sefe(entySe2,entyFe) AND entyFe2Sector(entyFe,sector)), vm_demFeSector.l(t,regi,entySe2,entyFe,sector,emiMkt)))));
v_shSeFe.l(t,regi,entySe)$p_shSeFe(t,regi,entySe) = p_shSeFe(t,regi,entySe);

$ifthen.penSeFeSectorShareDevCost not "%cm_seFeSectorShareDevMethod%" == "off"
vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)$(
  ( p_shSeFe(t,regi,entySe) ) AND
  (t.val ge 2025) AND  !!disable share incentives for historical years in buildings, industry and CDR as this should be handled by historical bounds
  ( entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe) ) AND !! only redefine vm_demFeSector for entySeBio, entySeSyn and entySeFos items
  ( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ) AND !!only create the equation for valid cobinations of entySe, entyFe, sector and emiMkt
  ( (entySeBio(entySe) OR entySeSyn(entySe)) ) AND !!share incentives only need to be applied to n-1 secondary energy carriers
  ( NOT(sameas(sector,"build") AND (sameas(entyFE,"fesos"))) ) AND !!disable buildings solids share incentives
  ( NOT(sameas(sector,"CDR"))) !! disable share incentives for CDR sector as it leads to solver problems
) =
  sum(entySe2$sefe(entySe2,entyFe), vm_demFeSector.l(t,regi,entySe2,entyFe,sector,emiMkt))
  * p_shSeFe(t,regi,entySe);  
vm_demFeSector_afterTax.l(t,regi,entySe,entyFe,sector,emiMkt) = vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt);
$endif.penSeFeSectorShareDevCost

p_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt)$((entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe)) AND (sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)) AND sum(entySe2$sefe(entySe2,entyFe), vm_demFeSector.l(t,regi,entySe2,entyFe,sector,emiMkt)) ) =
  vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)
  /
  sum(entySe2$sefe(entySe2,entyFe), vm_demFeSector.l(t,regi,entySe2,entyFe,sector,emiMkt))
;
v_shSeFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)$(p_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt) AND NOT(sameas(sector,"CDR"))) = p_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt);
v_shSeFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)$(p_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt) AND (sameas(sector,"CDR"))) = 0;

*** EOF ./core/preloop.gms
