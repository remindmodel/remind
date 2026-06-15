*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi2025/datainput.gms

***----------------------------
*** CO2 Tax level growing exponentially from 2025 value taken from input data
***----------------------------

*** for years up to 2025 take CO2 price defined by fm_taxCO2eqHist 
*** fm_taxCO2eqHist reflects historical carbon prices and
*** assumptions on current aggregate effect of other policies
pm_taxCO2eq(ttot,regi)$(ttot.val le 2025) = fm_taxCO2eqHist(ttot,regi) * sm_DptCO2_2_TDpGtC;

*** for years after 2025, constant carbon prices (2025-2100)
!! In mid to long-term the REMIND current policy scenario is more optimistic than other projections like UNEP or CAT
!! Therefore, a constant carbon price beyond 2025 represents more realistic trajectories for the NPi scenario to this date (source: IEA Current Policies)
pm_taxCO2eq(t,regi)$(t.val gt 2025) = sum(ttot, pm_taxCO2eq(ttot,regi)$(ttot.val eq 2025)) ;

*** for EU, take carbon price from fm_taxCO2eqHist up to 2030
!! In case of the EU, a more stringent political landscape feeds the assumption that the carbon price would increase in the short- and mid-term. 
!! The carbon price in 2030-2050 is aligned with the binding targets and credible policies included in the PBL protocol 2025 (source: NewClimate). 
!! In particular, this includes reaching the FF55 -55% GHG reduction in 2030, and the assumption that the EU would get close but miss the net-zero ETS emissions in 2040.
loop(ext_regi$sameas(ext_regi, "EUR_regi"),
*** 1. add 2030
  pm_taxCO2eq(t,regi)$(t.val = 2030 AND regi_group(ext_regi,regi))
    = fm_taxCO2eqHist("2030",regi) * sm_DptCO2_2_TDpGtC;

*** 2. linear interpolation from 2030 value to 200 in 2050
  pm_taxCO2eq(t,regi)$(t.val > 2030 AND t.val < 2050 AND regi_group(ext_regi,regi))
    = fm_taxCO2eqHist("2030",regi) * sm_DptCO2_2_TDpGtC
      * (2050 - t.val) / (2050 - 2030)
    + 200 * sm_DptCO2_2_TDpGtC
      * (t.val - 2030) / (2050 - 2030);

*** 3. constant after 2050
  pm_taxCO2eq(t,regi)$(t.val ge 2050 AND regi_group(ext_regi,regi))
    = 200 * sm_DptCO2_2_TDpGtC;

);

*** for USA drop carbon pricing to 0 due roll back policies
!! In case of the US, the carbon price is dropped completely, to reflect government decisions of withdrawing from the IRA and Paris Agreement,
!! also in line with the PBL protocol 2025 (source: NewClimate).
loop(ext_regi$sameas(ext_regi,"USA_regi"),
   pm_taxCO2eq(t,regi)$(t.val ge 2030 AND regi_group(ext_regi,regi)) 
      = 0;
);
*** after 2100, keep CO2 price constant at 2100 level
pm_taxCO2eq(t,regi)$(t.val gt 2100) = pm_taxCO2eq("2100",regi);

*** switch off MAC abatement of land emissions, scenario should only have Magpie baseline emissions
pm_macSwitch(ttot,regi,emiMacMagpie) = 0;

*** EOF ./modules/45_carbonprice/NPi2025/datainput.gms
