*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie/bounds.gms

*' @code{extrapage: "00_model_assumptions"}
*** -------------------------------------------------------------
*'  #### Bounds on 1st generation biomass annual production
*** -------------------------------------------------------------
*' 1st generation biofuel quantities (from sugar/starch and oil crops) are not
*' endogenously modeled but follow exogenous trajectories from IEA and FAO data
*' and some future projections for the near term (until 2030). To align data
*' with MAgPIE we mostly rely on FAO data for historic feedstock quantities, so
*' `vm_fuExtr` is fixed to values from `p30_datapebio`, coming from FAO.
*' Additionally there is the constraint to match historical capacities for the
*' respective conversion technologies in 2005 from the IEA. Thus, the bound on
*' vm_fuExtr is only applied from 2010 on (in 2005 feedstock quantities are
*' fully determined via `p05_cap0`). However, in some cases the capacities that
*' were build in 2005 or before require a feedstock supply that is higher
*' than what the FAO-based bound on `vm_fuExtr` would allow for, i.e., FAO and
*' IEA data do not match. In that case we relax the upper bound for all time
*' steps such that the 2005 capacity constraint implcitly derived from IEA can
*' still be matched. Eventually the lower bound is set to (almost) the upper
*' bound to enforce matching the historical feedstock quantities. Please note
*' that the link between capacity additions `vm_deltaCap` and the feedstock
*' quantities basically follows what happens in the equations `qm_fuel2pe`,
*' `q_balPe`, `q_transPe2se`, `q_limitCapSe` and `q_cap`. It is a bit
*' simplified here, assuming that there is a one to one mapping between PE
*' (pebios, pebioil) and the respective conversion technologies (bioeths,
*' biodiesel, respectively), which is currently the case. If this changes in
*' the future (which is unlikely), this part needs to be adapted.

*** Set exogenous trajectory for sugar/starch crop feedstocks, using a corridor
*** for lower and upper bounds of 0.99 to 1.01 for numerical flexibility
vm_fuExtr.up(t, regi, "pebios", "5")$(t.val ge 2010 AND t.val ge cm_startyear) = 1.01 * max(
  !! Use original bounds based on (mainly) FAO inpout data.
  p30_datapebio(regi,"pebios","5","maxprod",t),

  !! If historic capacities from IEA input require a larger feedstock supply,
  !! relax the bound in 2010 and in all following time steps. We assume that
  !! the bound should never fall below the feedstock supply in 2005. For that
  !! we convert the sum of all (depreciated) historic capacity additions
  !! `vm_deltaCap` in 2005 to feedstock supply quantities.
    1 / pm_eta_conv(t,regi,"bioeths") * pm_cf(t,regi,"bioeths") * pm_dataren(regi,"nur","1","bioeths")
  * sum(ttot$(ttot.val eq 2005),
      sum(opTimeYr2te("bioeths",opTimeYr) $ (tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val ge 1)),
          pm_ts(ttot - (pm_tsu2opTimeYr(ttot,opTimeYr) - 1))
        * pm_omeg(regi,opTimeYr+1,"bioeths")
        * vm_deltaCap.up(ttot - (pm_tsu2opTimeYr(ttot,opTimeYr) - 1),regi,"bioeths","1")
      )
    )
  );
vm_fuExtr.lo(t, regi, "pebios", "5")$(t.val ge 2010 AND t.val ge cm_startyear) =  0.98 * vm_fuExtr.up(t, regi, "pebios", "5");

*** Set exogenous trajectory for oil crop feedstocks, using a corridor for
*** lower and upper bounds of 0.99 to 1.01 for numerical flexibility
vm_fuExtr.up(t, regi, "pebioil", "5")$(t.val ge 2010 AND t.val ge cm_startyear) = 1.01 * max(
  !! Use original bounds based on (mainly) FAO inpout data.
  p30_datapebio(regi,"pebioil","5","maxprod",t),

  !! If historic capacities from IEA input require a larger feedstock supply,
  !! relax the bound in 2010 and in all following time steps. We assume that
  !! the bound should never fall below the feedstock supply in 2005. For that
  !! we convert the sum of all (depreciated) historic capacity additions
  !! `vm_deltaCap` in 2005 to feedstock supply quantities.
    1 / pm_eta_conv(t,regi,"biodiesel") * pm_cf(t,regi,"biodiesel") * pm_dataren(regi,"nur","1","biodiesel")
  * sum(ttot$(ttot.val eq 2005),
      sum(opTimeYr2te("biodiesel",opTimeYr) $ (tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val ge 1)),
          pm_ts(ttot - (pm_tsu2opTimeYr(ttot,opTimeYr) - 1))
        * pm_omeg(regi,opTimeYr+1,"biodiesel")
        * vm_deltaCap.up(ttot - (pm_tsu2opTimeYr(ttot,opTimeYr) - 1),regi,"biodiesel","1")
      )
    )
  );
vm_fuExtr.lo(t, regi, "pebioil", "5")$(t.val ge 2010 AND t.val ge cm_startyear) =  0.98 * vm_fuExtr.up(t, regi, "pebioil", "5");

*** Relax lower bound after 2030 in case of a 1st gen phaseout scenario.
if(cm_1stgen_phaseout=1,
  vm_fuExtr.lo(t,regi,"pebios","5")$(t.val gt 2030)  = 0;
  vm_fuExtr.lo(t,regi,"pebioil","5")$(t.val gt 2030) = 0;
);


*** -------------------------------------------------------------
*' #### Bounds on 2nd generation biomass annual production
*** -------------------------------------------------------------

*** In REMIND there are two grades for fuel extraxtion from pebiolc. The first
*** grade is purpose grown bioenergy, the second grade are residues. The
*** residue grade of pebiolc (pebiolc.2) in REMIND is roughly MAgPIE's residue
*** potential (plus some extra demand for traditional biomass, see below).

***-------------------------------------------------------------
*' 1. Bound on residues
*** Already in the initial years there are technologies in REMIND that demand
*** biomass. pm_pedem_res contains the biomass demand as it would evolve if all
*** these biomass technologies that are present in 2005 would phase out (phase-
*** out-trajectory). When calculating the maximal residue potential
*** p30_maxprod_residue we make sure (by applying the max operator) that the
*** resulting residue potential is big enough to feed these technologies so
*** they do not need to demand purpose-grown biomass. This is necessary,
*** because in the early years MAgPIE's residue potential is smaller than the
*** initial demand from REMIND's technologies. Except for "biotr" all
*** technologies present in 2005 are allowed to expand, but the resulting
*** additional demand for biomass (exceeding the phase-out-trajectory) can then
*** be supplied  from purpose-grown biomass.
p30_maxprod_residue(ttot,regi)     = max(p30_datapebio(regi,"pebiolc","2","maxprod",ttot), sum(teBioPebiolc, pm_pedem_res(ttot,regi,teBioPebiolc)));
vm_fuExtr.up(t,regi,"pebiolc","2") = p30_maxprod_residue(t,regi)*1.0001;
*'

***-------------------------------------------------------------
*' 2. Bound on purpose grown biomass
*** The bound on purpose grown biomass is disabled by default, it is only
*** applied according to a switch.
$ifthen.bioenergymaxscen not %cm_maxProdBiolc% == "off"
*** Set bound on global annual pebiolc production and convert from EJ to TWa
p30_max_pebiolc_path_glob(t) = %cm_maxProdBiolc% * sm_EJ_2_TWa;

*** Reduce the global upper bound on purpose grown bio-energy by residues,
*** since the total bound as defined in cm_maxProdBiolc applies to the sum of
*** residues and purpose grown.
p30_max_pebiolc_path_glob(t) = p30_max_pebiolc_path_glob(t) - sum(regi, p30_maxprod_residue(t,regi));
display p30_max_pebiolc_path_glob;

*' Calclate regional bounds with equal marginal costs from global bound
*** (inverting the supply curve)
loop(ttot$(ttot.val ge cm_startyear),
*** initialization
     p30_max_pebiolc_dummy = 0;
     p30_pebiolc_price_dummy = 0.01;
     while(p30_max_pebiolc_dummy < p30_max_pebiolc_path_glob(ttot),
*** Exclude JPN to avoid UNDF in p30_max_pebiolc_dummy
           loop(regi$(NOT sameas(regi,'JPN')),
*** Avoid execution errors for x**y with x<0 by applying the if-clause
                if( p30_pebiolc_price_dummy > (i30_bioen_price_a(ttot,regi)) * 1.01,
                      p30_fuelex_dummy(regi) = (p30_pebiolc_price_dummy - i30_bioen_price_a(ttot,regi)) / i30_bioen_price_b(ttot,regi);
                 else
                      p30_fuelex_dummy(regi) = 0;
                );
           ); 
           p30_max_pebiolc_dummy = sum(regi, p30_fuelex_dummy(regi));
           p30_pebiolc_price_dummy = p30_pebiolc_price_dummy + 0.001;
     );
     p30_max_pebiolc_path(regi,ttot) = p30_fuelex_dummy(regi);
);
display p30_max_pebiolc_path;

*' According to EMF guidelines, the upper bound on total (residues+purpose)
*' global biomass production does not include traditional biomass use. Since
*' the demand for traditional biomass is already supplied by the residue grade
*' we expand the purpose-grown grade by the demand for traditional biomass.
vm_fuExtr.up(t,regi,"pebiolc","1") = p30_max_pebiolc_path(regi,t) + pm_pedem_res(t,regi,"biotr");
$endif.bioenergymaxscen


*** -------------------------------------------------------------
*' #### Phase out capacities of bioenergy technologies that use
*' #### pebiolc as feedstock, if defined in config
*** -------------------------------------------------------------
if (cm_phaseoutBiolc eq 1,
    loop(t$(t.val ge max(2025, cm_startyear)),
        loop(regi,
            loop(te(teBioPebiolc),
                loop(rlf,
                    if(vm_deltaCap.up(t,regi,te,rlf) eq INF,
                       vm_deltaCap.up(t,regi,te,rlf) = 1e-6;
                    );
                );
            );
        );
    );
);

*' @stop

*** FS: limit biomass domestic production from 2035 onwards to regional upper value defined by cm_bioprod_regi_lim
$IFTHEN.bioprod_regi_lim not "%cm_bioprod_regi_lim%" == "off"
loop( ext_regi$(p30_bioprod_regi_lim(ext_regi)),
  loop(regi$regi_groupExt(ext_regi,regi),
    v30_BioPEProdTotal.up(t,regi)$(t.val ge max(2010, cm_startyear))= p30_bioprod_regi_lim(ext_regi)*sm_EJ_2_TWa
*** distribute across regions in a region group by share in 2005 biomass production as the model is initialized in 2005 with fixed historic production
                                                    * v30_BioPEProdTotal.l("2005",regi) 
                                                    / sum(regi2$regi_groupExt(ext_regi,regi2), 
                                                        v30_BioPEProdTotal.l("2005",regi2));
  );
);
$ENDIF.bioprod_regi_lim

*** EOF ./modules/30_biomass/magpie/bounds.gms
