*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/SectorAggregates/preloop.gms


*' ### Preparation of emissions-related values before the model loop
*'
*** The preloop performs the following steps:
***   1. Restore CO2-equivalent marginal values from the input data.
***   2. Adapt Pe2Se emissions factors using conversion efficiencies.
***   3. In policy runs, restore pm_emifac from the reference run 


*** ==================================================================
*' #### 1. Restore emissions-equivalent marginal values
*** ==================================================================

Execute_Loadpoint 'input' qm_co2eq.m = qm_co2eq.m;

*** ==================================================================
*' #### 2. Adapt Pe2Se emissions factors
*** ==================================================================

*' Pe2Se emissions factors are reduced by the carbon content of the
*' secondary-energy output. The output carbon content is calculated as the
*' FE emissions factor, weighted by the se2fe conversion efficiencies and
*' converted to one unit of PE input with the pe2se efficiency.
loop(entySe$(sameas(entySe,"segafos") OR sameas(entySe,"seliqfos") OR sameas(entySe,"sesofos")),
  pm_emifac(ttot,regi,entyPe,entySe,te,"co2")$pm_emifac(ttot,regi,entyPe,entySe,te,"co2")
    = pm_emifac(ttot,regi,entyPe,entySe,te,"co2")
    - pm_eta_conv(ttot,regi,te)
    * ( sum(se2fe(entySe,entyFe2,te2)$pm_emifac(ttot,regi,entySe,entyFe2,te2,"co2"),
              pm_emifac(ttot,regi,entySe,entyFe2,te2,"co2")
              * pm_eta_conv(ttot,regi,te2))
        / sum(se2fe(entySe,entyFe2,te2)$pm_emifac(ttot,regi,entySe,entyFe2,te2,"co2"),1) );
);


*** ==================================================================
*' #### 3. Restore pm_emifac from the reference run in policy runs
*** ==================================================================

*' Make sure that emissions factors in policy runs are still the same as in reference run
*' as InitialCap model only runs in reference run
*** TODO: Check whether this can be removed as pm_emifac is meanwhile always the same in policy and reference run, but it is not clear whether this is always the case for all emissions factors.
if (cm_startyear gt 2005,
  Execute_Loadpoint 'input_ref' pm_emifac = pm_emifac;
);


*** initialize pm_share_CCS_CCO2
pm_share_CCS_CCO2(t,regi) = 0;


*** EOF ./modules/10_emissions/SectorAggregates/preloop.gms
