*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/presolve.gms

* defining the CO2 price parameter that sums up the 3 CO2eq tax components
pm_taxCO2eqSum(ttot,regi) = pm_taxCO2eq(ttot,regi) + pm_taxCO2eqRegi(ttot,regi) + pm_taxCO2eqSCC(ttot,regi);

$ifThen.cm_CO2PriceLimit not "%cm_CO2PriceLimit%" == "off"
*** limit CO2 prices in target year according to switch cm_CO2PriceLimit
  loop(regi$(pm_CO2PriceLimit("2030",regi) > 0),
  pm_taxCO2eqSum("2030",regi) = min(
    pm_taxCO2eqSum("2030",regi),
    pm_CO2PriceLimit("2030",regi) * sm_DptCO2_2_TDpGtC
  );
);                                  
$endif.cm_CO2PriceLimit

*AJS* we need those in nash
pm_capCum0(ttot,regi,teLearn)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_capCum.l(ttot,regi,teLearn);
pm_co2eq0(ttot,regi)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_co2eq.l(ttot,regi);


*** Calculate total FE demand of previous iteration or input gdx.
*** Required as a weight for penalty terms
p_demFeSector0(ttot,regi,entySe,entyFe,sector,emiMkt) = vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt);

pm_demFeTotal0(ttot, regi)
  = sum((entySe,entyFe,sector,emiMkt)$( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ),
  p_demFeSector0(ttot,regi,entySe,entyFe,sector,emiMkt))
;

***--------------------------------------
*** calculate some emission factors
***--------------------------------------
*** calculate global emission factor (excluding pebiolc)
loop (emi2fuel(entyPe,enty),
  pm_PeProdEmifacGlo(entyPe,enty)
  = sum(regi, pm_emiFossilFuelExtr(regi,entyPe))
  / sum((rlf,regi), vm_fuExtr.l("%cm_emifacs_baseyear%",regi,entyPe,rlf));

  loop (regi,
    sm_tmp =  sum(rlf, vm_fuExtr.l("%cm_emifacs_baseyear%",regi,entyPe,rlf));

    pm_PeProdEmifac(regi,entyPe,enty)$( sm_tmp )
      = pm_emiFossilFuelExtr(regi,entyPe) / sm_tmp;

    pm_PeProdEmifac(regi,entyPe,enty)$( NOT sm_tmp )
      = pm_PeProdEmifacGlo(entyPe,enty);
  );
);

loop(regi,
   if ( pm_PeProdEmifac(regi,"pecoal","ch4coal") ge 50,
        pm_PeProdEmifac(regi,"pecoal","ch4coal") = pm_PeProdEmifacGlo("pecoal","ch4coal");
   );
  if ( pm_PeProdEmifac(regi,"pegas","ch4gas") ge 50,
        pm_PeProdEmifac(regi,"pegas","ch4gas") = pm_PeProdEmifacGlo("pegas","ch4gas");
   );
   if ( pm_PeProdEmifac(regi,"peoil","ch4oil") ge 25,
        pm_PeProdEmifac(regi,"peoil","ch4oil") = pm_PeProdEmifacGlo("peoil","ch4oil");
   );
);
display pm_PeProdEmifac;


***--------------------------------------
***    MAgPIE coupling: run MAgPIE
***--------------------------------------

*** Decide whether MAgPIE should be executed. Also triggers the update of MAgPIE data in multiple locations.
if(magpieIter(iteration) AND cm_MAgPIE_Nash eq 1,
    sm_updateMagpieData = 1; !! Run MAgPIE in this Nash iteration
else
    sm_updateMagpieData = 0; !! Don't run MAgPIE in this Nash iteration
);

*** Run MAgPIE
if (sm_updateMagpieData eq 1,
*** Track runtime: done in magpie.R
*** Temporarily change numeric round format (nr) and number of decimals (nd) of the
*** outpt of the put_utility such that the arguments passed to magpie.R have integer format
  sm_tmp  = logfile.nr;
  sm_tmp2 = logfile.nd;
  logfile.nr = 1;
  logfile.nd = 0;
  sm_magpieIter = sm_magpieIter + 1;
  put_utility  "exec.checkErrorLevel" / "Rscript magpie.R " sm_magpieIter " " ord(iteration);
  logfile.nr = sm_tmp;
  logfile.nd = sm_tmp2;
*** Track runtime
  putclose runtime gyear(jnow):0:0 "-" gmonth(jnow):0:0 "-" gday(jnow):0:0 " " ghour(jnow):0:0 ":" gminute(jnow):0:0 ":" gsecond(jnow):0:0 ",GAMS," iteration.val:0;
*** In coupled runs overwrite pebiolc production from look-up table with actual MAgPIE values
*** Read production of 2nd gen. purpose grown bioenergy from MAgPIE (given to MAgPIE from previous Remind run)
  Execute_Loadpoint 'magpieData.gdx' pm_pebiolc_demandmag;
);


*** ACM initialise se-fe shares in CDR sector (from CDR module: dac, OAE, EW) from other sector se-fe shares
*** This is necessary as hydrocarbon FE demand for CDR sector may be zero or small and then leads to solver issues
v_shSeFeSector.l(ttot,regi,entySe,"fedie","CDR","ETS") =  v_shSeFeSector.l(ttot,regi,entySe,"fedie","trans","ES");
v_shSeFeSector.l(ttot,regi,entySe,"fegas","CDR","ETS") =  v_shSeFeSector.l(ttot,regi,entySe,"fegas","indst","ETS");

*** Save values for tracking across Nash iterations
o_pm_pebiolc_demandmag(iteration,ttot,regi)  = pm_pebiolc_demandmag(ttot,regi);

*** EOF ./core/presolve.gms
