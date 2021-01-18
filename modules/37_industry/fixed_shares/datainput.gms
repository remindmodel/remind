*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/datainput.gms

vm_macBaseInd.l(ttot,regi,entyFE,secInd37) = 0;

*** substitution elasticities
Parameter 
  p37_cesdata_sigma(all_in)  "substitution elasticities"
  /
    eni    2.5
    enhi   3.0
    enhgai 5.0
  /
;

pm_cesdata_sigma(ttot,in)$p37_cesdata_sigma(in) = p37_cesdata_sigma(in);

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "eni")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "eni")) = 0.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "eni")) = 0.6;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "eni")) = 1.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "eni")) = 1.7;

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "enhi")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "enhi")) = 0.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "enhi")) = 0.6;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "enhi")) = 1.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "enhi")) = 2.0;

pm_cesdata_sigma(ttot,"enhgai")$ (ttot.val le 2020) = 0.1;
pm_cesdata_sigma(ttot,"enhgai")$ (ttot.val eq 2025) = 0.6;
pm_cesdata_sigma(ttot,"enhgai")$ (ttot.val eq 2030) = 1.2;
pm_cesdata_sigma(ttot,"enhgai")$ (ttot.val eq 2035) = 2;
pm_cesdata_sigma(ttot,"enhgai")$ (ttot.val eq 2040) = 3;

$IFTHEN.cm_INNOPATHS_eni not "%cm_INNOPATHS_eni%" == "off" 
  pm_cesdata_sigma(ttot,"eni")$pm_cesdata_sigma(ttot,"eni") = pm_cesdata_sigma(ttot,"eni") * %cm_INNOPATHS_eni%;
  pm_cesdata_sigma(ttot,"eni")$( (pm_cesdata_sigma(ttot,"eni") gt 0.8) AND (pm_cesdata_sigma(ttot,"eni") lt 1)) = 0.8; !! If complementary factors, sigma should be below 0.8
  pm_cesdata_sigma(ttot,"eni")$( (pm_cesdata_sigma(ttot,"eni") ge 1) AND (pm_cesdata_sigma(ttot,"eni") lt 1.2)) = 1.2; !! If substitution factors, sigma should be above 1.2
$ENDIF.cm_INNOPATHS_eni

*** assuming a maximum 20% of heat pumps in heat industry to be more in line with industry subsectors
pm_ppfen_shares(t,regi,"enhi","fehei") = 0.2;
*** exception or the above: REF. Assuming a maximum 30% of heat pumps in heat industry. reduced lineraly from initial year levels to be more in line with industry subsectors (2030 and afterwards = 30% maximum, 2005 = 50% to avoid infeasiblities)
pm_ppfen_shares(t,"REF","enhi","fehei") = 0.3;
pm_ppfen_shares(t,"REF","enhi","fehei")$(t.val le 2030) = 0.50 - (0.20/25)*(t.val-2005);

Table p37_shIndFE(all_regi,all_in,secInd37)   "share of industry sub-sectors in FE use [ratio]"
$ondelim
$include "./modules/37_industry/fixed_shares/input/p37_shIndFE.cs3r";
$offdelim
;

$include "./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms";

$IFTHEN.Industry_CCS_markup not "%cm_INNOPATHS_Industry_CCS_markup%" == "off" 
	pm_abatparam_Ind(ttot,regi,all_enty,steps)$pm_abatparam_Ind(ttot,regi,all_enty,steps) = (1/%cm_INNOPATHS_Industry_CCS_markup%)*pm_abatparam_Ind(ttot,regi,all_enty,steps);
$ENDIF.Industry_CCS_markup

*** fill in share of other industry sector
p37_shIndFE(regi,"feh2i",secInd37) = p37_shIndFE(regi,"fegai",secInd37);

***loop ((all_regi,all_in)$(    sameas(all_in,"fesoi") OR sameas(all_in,"fehoi")
***                          OR sameas(all_in,"fegai") ),
loop ((all_regi,ppfen_industry_dyn37(all_in)),
  p37_shIndFE(all_regi,all_in,"otherInd")
  = 1
  - sum(secInd37$( NOT sameas(secInd37,"otherInd") ),
      p37_shIndFE(all_regi,all_in,secInd37)
    );
);

display "calculated FE share of 'other' industry sector", p37_shIndFE;

p37_fctEmi("fesos") = fm_dataemiglob("pecoal","sesofos", "coaltr","co2");
p37_fctEmi("fehos") = fm_dataemiglob("peoil", "seliqfos","refliq","co2");
p37_fctEmi("fegas") = fm_dataemiglob("pegas", "segafos", "gastr", "co2");

*** CCS for industry is off by default
emiMacSector(emiInd37_fuel) = NO;
pm_macSwitch(emiInd37)      = NO;

*** turn on CCS for industry emissions
if (cm_IndCCSscen eq 1,
  if (cm_CCS_cement eq 1,
    emiMacSector("co2cement") = YES;
    pm_macSwitch("co2cement") = YES;
    pm_macSwitch("co2cement_process") = YES;
    emiMac2mac("co2cement","co2cement") = YES;
    emiMac2mac("co2cement_process","co2cement") = YES;
  );

  if (cm_CCS_chemicals eq 1,
    emiMacSector("co2chemicals") = YES;
    pm_macSwitch("co2chemicals") = YES;
    emiMac2mac("co2chemicals","co2chemicals") = YES;
  );

  if (cm_CCS_steel eq 1,
    emiMacSector("co2steel") = YES;
    pm_macSwitch("co2steel") = YES;
    emiMac2mac("co2steel","co2steel") = YES;
  );
);

*** CCS for other industry is off in any case
emiMacSector("co2otherInd") = NO;
pm_macSwitch("co2otherInd") = NO;
emiMac2mac("co2otherInd","co2otherInd") = NO;

pm_macCostSwitch(enty) = pm_macSwitch(enty);

*** additional H2 cost parameters
s37_costAddH2Inv = cm_indst_H2costAddH2Inv;
s37_costDecayStart = cm_indst_costDecayStart;
s37_costDecayEnd = cm_indst_H2costDecayEnd;


*** EOF ./modules/37_industry/fixed_shares/datainput.gms

