*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/bounds.gms

loop (emiMac2mac(enty,emiInd37),
  vm_emiIndCCS.lo(ttot,regi,enty)$( ttot.val ge 2005 ) = 0;
);

loop ((secInd37,enty)$( NOT macBaseInd37(enty,secInd37) ),
  vm_macBaseInd.fx(ttot,regi,enty,secInd37)$( ttot.val ge 2005 ) = 0;
);

vm_cesIO.lo(t,regi,in_industry_dyn37(in)) = 1e-6;

*** Upper bound for exponent to avoid exponential gams overflow (if > 20 -> 3^20 > 1e10 what would cause GAMS to get an overflow x**y error) 
v37_costExponent.up(t,regi) = 20; 


*** FS: lower bound on share of carbonaceous fuels (solids, liquids, gases) in total industry FE 
*** to ensure that there are always enough for feedstocks
*** apply 35% only for DEU for now
v37_CFuelshare.lo(t,regi)$(sameas(regi,"DEU"))=0.35;


*** Upper bound for electricity share in industry
$IFTHEN.feShare not "%cm_feShareLimits%" == "off" 

$ifthen.feShareScenario "%cm_feShareLimits%" == "electric"
  pm_shfe_up(t,regi,"seel","indst")$(t.val ge 2050) = 0.6;
  pm_shfe_up("2045",regi,"seel","indst") = 0.57;
  pm_shfe_up("2040",regi,"seel","indst") = 0.52;
  pm_shfe_up("2035",regi,"seel","indst") = 0.45;
  pm_shfe_up("2030",regi,"seel","indst") = 0.40;
$elseif.feShareScenario "%cm_feShareLimits%" == "incumbents"
  pm_shfe_up(t,regi,"seel","indst")$(t.val ge 2050) = 0.4;
  pm_shfe_up("2045",regi,"seel","indst") = 0.38;
  pm_shfe_up("2040",regi,"seel","indst") = 0.33;
  pm_shfe_up("2035",regi,"seel","indst") = 0.30;
  pm_shfe_up("2030",regi,"seel","indst") = 0.27;
$elseif.feShareScenario "%cm_feShareLimits%" == "efficiency"
  pm_shfe_up(t,regi,"seel","indst")$(t.val ge 2050) = 0.5;
  pm_shfe_up("2045",regi,"seel","indst") = 0.47;
  pm_shfe_up("2040",regi,"seel","indst") = 0.42;
  pm_shfe_up("2035",regi,"seel","indst") = 0.37;
  pm_shfe_up("2030",regi,"seel","indst") = 0.35;
$endif.feShareScenario

vm_shfe.up(t,regi,entyFe,sector)$pm_shfe_up(t,regi,entyFe,sector) = pm_shfe_up(t,regi,entyFe,sector);
vm_shfe.lo(t,regi,entyFe,sector)$pm_shfe_lo(t,regi,entyFe,sector) = pm_shfe_lo(t,regi,entyFe,sector);

$endif.feShare

*** Assure that h2 penetration is not high in calibration so the extra t&d cost can be considered by the model. In case contrary, H2 is competitive against gas in buildings and industry even during calibration.
$ifthen.CES_calibration "%CES_parameters%" == "calibrate"
v37_H2share.up(t,regi) = s37_costDecayStart;
$endif.CES_calibration


*** EOF ./modules/37_industry/fixed_shares/bounds.gms

