*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_4/equations.gms
***---------------------------------------------------------------------------
***                      FUEL COSTS FOR BIOENERGY
***---------------------------------------------------------------------------

*' @equations
*' 
*' **Total fuel costs for biomass**  
*' The first part, summing over *peren2rlf30*, represents costs for biomass with fixed prices.
*' The second part that includes *v30_pebiolc_costs* represents costs for biomass with continous 
*' supply curves from MAgPIE. In coupled runs *v30_multcost* is a cost markup factor improving 
*' the convergence by penalizing large jumps in the demand between two coupling 
*' iterations. It converges to 1 and therefore does not affect the outcome. The last part, containing 
*' *pm_costsTradePeFinancial*, represents additional tradecosts (only for purpose grown lignocellulosic biomass).

q30_costFuBio(ttot,regi)$(ttot.val ge cm_startyear).. 
         vm_costFuBio(ttot,regi)
         =e= sum(peren2rlf30(enty,rlf), p30_datapebio(regi,enty,rlf,"cost",ttot) * vm_fuExtr(ttot,regi,enty,rlf))
         +
$if %cm_MAgPIE_coupling% == "on"  (v30_pebiolc_costs(ttot,regi) * v30_multcost(ttot,regi))
$if %cm_MAgPIE_coupling% == "off" (v30_pebiolc_costs(ttot,regi))
         - p30_pebiolc_costs_emu_preloop(ttot,regi) !! Need to be substracted since they are also inculded in the total agricultural production costs
         + 
         sum(peren2cont30(enty,rlf), vm_fuExtr(ttot,regi,enty,rlf) * pm_costsTradePeFinancial(regi,"use",enty));

***---------------------------------------------------------------------------
***                      MAgPIE EMULATOR
***---------------------------------------------------------------------------

*' **MAgPIE EMULATOR: PRICE**  
*' This equation calculates the price for purpose grown lignocellulosic biomass as a (linear) function of demand according to the supplycurve as it was derived
*' from MAgPIE. The equation is used by the shift factor calculation in the preloop stage. In the main solve stage the price is only 
*' used to apply the bioenergy tax. It contains optional shift and scaling of supply curves in coupled runs. 

q30_pebiolc_price(ttot,regi)$(ttot.val ge cm_startyear)..
         vm_pebiolc_price(ttot,regi)
         =e=
         (v30_priceshift(ttot,regi) 
       + i30_bioen_price_a(ttot,regi) 
       + i30_bioen_price_b(ttot,regi) * (vm_fuExtr(ttot,regi,"pebiolc","1") + sm_eps) )
       * v30_pricemult(ttot,regi)
;

*' **MAgPIE EMULATOR: COST**  
*' Calculates bioenergy costs of purpose grown lignocellulosic biomass by integrating the linear price supply curve (see above).
*' It contains optional shift and scaling of supply curves in coupled runs. 
*' The equation is used both in preloop and main solve.

q30_pebiolc_costs(ttot,regi)$(ttot.val ge cm_startyear)..
         v30_pebiolc_costs(ttot,regi) 
         =e=
        (v30_priceshift(ttot,regi)
       + i30_bioen_price_a(ttot,regi)
       + i30_bioen_price_b(ttot,regi) / 2 * (vm_fuExtr(ttot,regi,"pebiolc","1") + sm_eps) )
       * v30_pricemult(ttot,regi)
       * vm_fuExtr(ttot,regi,"pebiolc","1")
;

***---------------------------------------------------------------------------
***                   SHIFT FACTOR CALCULATOIN
***---------------------------------------------------------------------------

*' **Calculate shift factor for bioenergy costs**  
*' This applies in coupled runs only to shift the supplycurve according to the price response of MAgPIE. The factor is computed 
*' by minimizing least squares (*v30_shift_r2*) of price differences between actual MAgPIE output (from coupled runs) and the 
*' supply curve (aka MAgPIE emulator). 
*' It is solved in presolve (*s30_switch_shiftcalc* = 1) and deactivated in main solve (*s30_switch_shiftcalc* = 0).
*' *pm_ts* is used as a weight factor, representing the time step length.

q30_priceshift$(s30_switch_shiftcalc eq 1)..
         v30_shift_r2
         =e=
         sum(regi, sum(ttot$(ttot.val ge 2005 AND p30_pebiolc_pricemag(ttot,regi) gt 0), power((p30_pebiolc_pricemag(ttot,regi) - vm_pebiolc_price(ttot,regi))*pm_ts(ttot),2)))
;

***---------------------------------------------------------------------------
***                      COUPLING CONVERGENCE
***---------------------------------------------------------------------------

*' **Calculate cost markup factor for coupled runs**  
*' Improve convergence of the REMIND-MAgPIE coupling by penalizing deviations from last coupling iteration. 
*' This applies in coupled runs only to prevent large jumps in bioenergy demand between coupling iterations. 
*' It penalizes deviations in the demand for purpose grown bioenergy from the previous coupling iteration 
*' by increasing the costs proportional to the deviation. The factor converges to 1, as the 
*' difference between *vm_fuExtr* and *p30_pebiolc_demandmag* vanishes when the coupling converges over 
*' iterations.

q30_costAdj(ttot,regi)$(ttot.val ge cm_startyear)..
         v30_multcost(ttot,regi)
         =e=
         power((vm_fuExtr(ttot,regi,"pebiolc","1")-p30_pebiolc_demandmag(ttot,regi))/ (p30_pebiolc_demandmag(ttot,regi) + 0.15),2) * 0.4 + 1
;

***---------------------------------------------------------------------------
***          Definition of resource constraints for biomass
***---------------------------------------------------------------------------

*' **Limit export of biomass**  
*' Only purpose grown lignocellulosic biomass may be exported, no residues.

q30_limitXpBio(t,regi)..
         vm_Xport(t,regi,"pebiolc")
         =l=
         vm_fuExtr(t,regi,"pebiolc","1")
;

*** Limit BECCS in policy runs to 35% of total PE in BAU or to 130% of bioenergy demand in BAU
q30_limitTeBio(t,regi)$(cm_emiscen ne 1)..
        sum(pe2se(enty,enty2,teBio)$(teCCS(teBio)), vm_demPe(t,regi,enty,enty2,teBio))
        =l=
        0.5 * p30_demPe(t,regi);

*** FS: calculate total biomass production
q30_BioPEProdTotal(t,regi)..
        v30_BioPEProdTotal(t,regi)
        =e=
        sum(peren2rlf30(enty,rlf),
          vm_fuExtr(t,regi,enty,rlf)) +
        sum(peren2cont30(enty,rlf),
          vm_fuExtr(t,regi,enty,rlf))
;


*** FS: limit biomass domestic production from cm_startyear or 2020 onwards to cm_bioprod_histlim * 2015-level in a EU subregion
q30_limitProdtoHist(t,regi)$(cm_bioprod_histlim ge 0 AND t.val ge cm_startyear AND t.val gt 2015 AND regi_group("EUR_regi",regi))..
        v30_BioPEProdTotal(t,regi)
        =l=
        cm_bioprod_histlim*v30_BioPEProdTotal("2015",regi)
;


 
*** EOF ./modules/30_biomass/magpie_4/equations.gms
