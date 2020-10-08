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
    eni     2.5
      enhi  3.0

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

*** Don't use more than 25/50% H2/district heat in industry
pm_ppfen_shares("enhi","feh2i") = 0.25;

pm_ppfen_shares("enhi","fehei") = 0.5;

*** Don't use more H2 than gas in industry
*** FIXME release this constraint when matching to subsectors implementation
pm_ppfen_ratios("feh2i","fegai") = 1;

Table p37_shIndFE(all_regi,all_in,secInd37)   "share of industry sub-sectors in FE use [ratio]"
$ondelim
$include "./modules/37_industry/fixed_shares/input/p37_shIndFE.cs3r";
$offdelim
;

$include "./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms";

*** fill in share of other industry sector
loop ((all_regi,all_in)$(    sameas(all_in,"fesoi") OR sameas(all_in,"fehoi")
                          OR sameas(all_in,"fegai") ),
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

*** EOF ./modules/37_industry/fixed_shares/datainput.gms

