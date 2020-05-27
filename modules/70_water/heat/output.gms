*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/heat/output.gms
***-------------------------------------------------------------------------------
*** *IM*2015-05-14* Estimation of electricity water demand
***-------------------------------------------------------------------------------

***------------*Estimate vintage-related information*-----------------------------
*---------------------------------------------------------------------------------
p70_cap_vintages(ttot,regi,te,ttot2)$( ttot.val ge 2005 )
  =
    (1 - vm_capEarlyReti.l(ttot,regi,te))
  * 
    sum(te2rlf(te,rlf),
***      pm_correctcap(ttot,regi,te,rlf)
    + sum((opTimeYr2te(te,opTimeYr),tsu2opTimeYr(ttot,opTimeYr))$(
             opTimeYr.val gt 1 AND opTimeYr.val eq (ttot.val - ttot2.val + 1) ),
        pm_ts(ttot2)
      * pm_omeg(regi,opTimeYr+1,te)
      * vm_deltaCap.l(ttot2,regi,te,rlf)
      )$( ttot.val gt ttot2.val )
    + (
        pm_dt(ttot) / 2
      * pm_omeg(regi,"2",te)
      * vm_deltaCap.l(ttot,regi,te,rlf)
      )$( ttot.val eq ttot2.val )
    )
;

p70_cap_vintages_share(ttot,regi,te_elcool70,ttot2)$((ttot.val ge 2005) AND (sum(te2rlf(te_elcool70,rlf), vm_cap.l(ttot,regi,te_elcool70,rlf))))
  =
    p70_cap_vintages(ttot,regi,te_elcool70,ttot2) / sum(te2rlf(te_elcool70,rlf), vm_cap.l(ttot,regi,te_elcool70,rlf))
;

***------------*Estimate  heat-related information*-------------------------------
*---------------------------------------------------------------------------------
p70_heat(ttot,regi,enty,"seel",te_elcool70) 
  = 
  vm_demPe.l(ttot,regi,enty,"seel",te_elcool70) 
  - vm_prodSe.l(ttot,regi,enty,"seel",te_elcool70) 
  - vm_demPe.l(ttot,regi,enty,"seel",te_elcool70) *  i70_losses(te_elcool70)
;

p70_water_con(regi,te_elcool70,coolte70) 
  =  
    (i70_water_con(te_elcool70, coolte70) 
      * pm_eta_conv("2005", regi, te_elcool70) 
      / (1 - pm_eta_conv("2005", regi, te_elcool70) - i70_losses(te_elcool70)))$(te_coolnoren70(te_elcool70) AND teEtaConst(te_elcool70))
  + i70_water_con(te_elcool70, coolte70)$te_coolren70(te_elcool70)
  + (i70_water_con(te_elcool70, coolte70) 
      * sum(ttot2, pm_dataeta(ttot2, regi, te_elcool70) * p70_cap_vintages_share("2005",regi,te_elcool70,ttot2)) 
      / (1 - (sum(ttot2, pm_dataeta(ttot2, regi, te_elcool70) * p70_cap_vintages_share("2005",regi,te_elcool70,ttot2))) - i70_losses(te_elcool70)))$(te_coolnoren70(te_elcool70) AND teEtaIncr(te_elcool70)) 
  + (i70_water_con(te_elcool70, coolte70) 
      * pm_dataeta("2005", regi, te_elcool70) 
      / (1 - pm_dataeta("2005", regi, te_elcool70) - i70_losses(te_elcool70)))$(te_coolnoren70(te_elcool70) AND teEtaIncr(te_elcool70) AND sum(ttot2, p70_cap_vintages_share("2005",regi,te_elcool70,ttot2)) eq 0)  
;

p70_water_wtd(regi,te_elcool70,coolte70) 
  =  
    (i70_water_wtd(te_elcool70, coolte70) 
      * pm_eta_conv("2005", regi, te_elcool70) 
      / (1 - pm_eta_conv("2005", regi, te_elcool70) - i70_losses(te_elcool70)))$(te_coolnoren70(te_elcool70) AND teEtaConst(te_elcool70))
  + i70_water_wtd(te_elcool70, coolte70)$te_coolren70(te_elcool70)
  + (i70_water_wtd(te_elcool70, coolte70) 
      * sum(ttot2, pm_dataeta(ttot2, regi, te_elcool70) * p70_cap_vintages_share("2005",regi,te_elcool70,ttot2)) 
      / (1 - (sum(ttot2, pm_dataeta(ttot2, regi, te_elcool70) * p70_cap_vintages_share("2005",regi,te_elcool70,ttot2))) - i70_losses(te_elcool70)))$(te_coolnoren70(te_elcool70) AND teEtaIncr(te_elcool70)) 
  + (i70_water_wtd(te_elcool70, coolte70) 
      * pm_dataeta("2005", regi, te_elcool70) 
      / (1 - pm_dataeta("2005", regi, te_elcool70) - i70_losses(te_elcool70)))$(te_coolnoren70(te_elcool70) AND teEtaIncr(te_elcool70) AND sum(ttot2, p70_cap_vintages_share("2005",regi,te_elcool70,ttot2)) eq 0)     
;

p70_water_con(regi,te_elcool70,coolte70) = p70_water_con("USA",te_elcool70,coolte70);  
p70_water_wtd(regi,te_elcool70,coolte70) = p70_water_wtd("USA",te_elcool70,coolte70);  

display i70_losses, p70_heat, p70_water_con, p70_water_wtd;

***------------*Estimate water demand output*-------------------------------------
*---------------------------------------------------------------------------------
***Per technology***--------------------------------------------------------------
o70_se_production(ttot,regi,te_elcool70)
  =
    sum(enty,
      vm_prodSe.l(ttot,regi,enty,"seel",te_elcool70) * pm_conv_TWa_EJ
    )
;

o70_water_consumption(ttot,regi,te_elcool70)
  =
    (sum(ttot2,
      sum(enty,
        p70_cap_vintages_share(ttot,regi,te_elcool70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_elcool70)
        * sum(coolte70, i70_cool_share_time(ttot2,regi,te_elcool70,coolte70) * p70_water_con(regi,te_elcool70,coolte70) / 100 * i70_efficiency(ttot,regi,te_elcool70,coolte70))
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)$te_coolnoren70(te_elcool70)
  + 
    (sum(ttot2,
      sum(enty,
        p70_cap_vintages_share(ttot,regi,te_elcool70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_elcool70)
        * sum(coolte70, i70_cool_share_time(ttot2,regi,te_elcool70,coolte70) * i70_water_con(te_elcool70,coolte70) / 100 * i70_efficiency(ttot,regi,te_elcool70,coolte70))
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)$te_coolren70(te_elcool70)      
;

o70_water_withdrawal(ttot,regi,te_elcool70)
  =
    (sum(ttot2,
      sum(enty,
        p70_cap_vintages_share(ttot,regi,te_elcool70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_elcool70)
        * sum(coolte70, i70_cool_share_time(ttot2,regi,te_elcool70,coolte70) * p70_water_wtd(regi,te_elcool70,coolte70) / 100 * i70_efficiency(ttot,regi,te_elcool70,coolte70))
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)$te_coolnoren70(te_elcool70)
  + 
    (sum(ttot2,
      sum(enty,
        p70_cap_vintages_share(ttot,regi,te_elcool70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_elcool70)
        * sum(coolte70, i70_cool_share_time(ttot2,regi,te_elcool70,coolte70) * i70_water_wtd(te_elcool70,coolte70) / 100 * i70_efficiency(ttot,regi,te_elcool70,coolte70))
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)$te_coolren70(te_elcool70)      
;

***Totals***----------------------------------------------------------------------
p70_water_output(ttot,regi,"Secondary Energy|Electricity|Full; EJ/yr;") = 	
      (sum(pe2se(enty,"seel",te), 
        vm_prodSe.l(ttot,regi,enty,"seel",te))
        + sum(se2se(enty,"seel",te), vm_prodSe.l(ttot,regi,enty,"seel",te))
        + sum(pc2te(enty,entySe(enty3),te,"seel"), max(0, pm_prodCouple(regi,enty,enty3,te,"seel")) * vm_prodSe.l(ttot,regi,enty,enty3,te))
			) * pm_conv_TWa_EJ
;
p70_water_output(ttot,regi,"Secondary Energy|Electricity|Part; EJ/yr;") = sum(te_elcool70, o70_se_production(ttot,regi,te_elcool70));
p70_water_output(ttot,regi,"Water Consumption|Electricity; km3/yr;") = sum(te_elcool70, o70_water_consumption(ttot,regi,te_elcool70));
p70_water_output(ttot,regi,"Water Withdrawal|Electricity; km3/yr;") = sum(te_elcool70, o70_water_withdrawal(ttot,regi,te_elcool70));
p70_water_output(ttot,regi,"Secondary Energy|Electricity|wo/h; EJ/yr;") = sum(te_elcool70$(NOT sameas (te_elcool70,"hydro")), o70_se_production(ttot,regi,te_elcool70)); 
p70_water_output(ttot,regi,"Water Consumption|Electricity|wo/h; km3/yr;") = sum(te_elcool70$(NOT sameas (te_elcool70,"hydro")), o70_water_consumption(ttot,regi,te_elcool70));

***Intensities***-----------------------------------------------------------------
loop(descr_water_int2ext(descr_water_int,descr_water_extn,descr_water_extd),
  loop(ttot$(ttot.val ge 2005),
    p70_water_output(ttot,regi,descr_water_int) = 
        p70_water_output(ttot,regi,descr_water_extn) * sm_giga_2_non 
      / p70_water_output(ttot,regi,descr_water_extd) / sm_EJ_2_TWa / sm_TWa_2_MWh
  );
);

***Aggregated categories***-------------------------------------------------------
p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal|w/ CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"igccc") OR sameas(te_elcool70,"pcc") OR sameas(te_elcool70,"pco")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"igcc") OR sameas(te_elcool70,"pc") OR sameas(te_elcool70,"coalchp")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal|w/ CCS; km3/yr;") + p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal|w/o CCS; km3/yr;")
;  

p70_water_output(ttot,regi,"Water Consumption|Electricity|Oil|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"dot")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Oil; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Oil|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas|w/ CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"ngccc")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"ngcc") OR sameas(te_elcool70,"ngt") OR sameas(te_elcool70,"gaschp")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas|w/ CCS; km3/yr;") + p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Fossil; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas; km3/yr;")
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Oil; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Fossil|w/ CCS; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal|w/ CCS; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas|w/ CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Fossil|w/o CCS; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Coal|w/o CCS; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Gas|w/o CCS; km3/yr;")
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Oil|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Biomass|w/ CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"bioigccc")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Biomass|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"bioigcc") OR sameas(te_elcool70,"biochp")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Biomass; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Biomass|w/ CCS; km3/yr;") + p70_water_output(ttot,regi,"Water Consumption|Electricity|Biomass|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Nuclear; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"tnrs")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Hydro; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"hydro")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Solar|PV; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"spv")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Solar|CSP; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"csp")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Solar; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Solar|PV; km3/yr;") + p70_water_output(ttot,regi,"Water Consumption|Electricity|Solar|CSP; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Wind; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"wind")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Geothermal; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"geohdr")), 
    o70_water_consumption(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Non-Biomass Renewables; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Consumption|Electricity|Hydro; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Solar; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Wind; km3/yr;")
  + p70_water_output(ttot,regi,"Water Consumption|Electricity|Geothermal; km3/yr;")
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Once Through; km3/yr;")
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"once") * p70_water_con(regi,te_coolnoren70,"once") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"once"))
        )
      )
    )  * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"once") * i70_water_con(te_coolren70,"once") / 100 * i70_efficiency(ttot,regi,te_coolren70,"once"))
        )
      )  
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Wet Tower; km3/yr;")
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"tower") * p70_water_con(regi,te_coolnoren70,"tower") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"tower"))
        )
      )
    )  * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"tower") * i70_water_con(te_coolren70,"tower") / 100 * i70_efficiency(ttot,regi,te_coolren70,"tower"))
        )
      )  
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Cooling Pond; km3/yr;") 
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"pond") * p70_water_con(regi,te_coolnoren70,"pond") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"pond"))
        )
      )
    )  * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"pond") * i70_water_con(te_coolren70,"pond") / 100 * i70_efficiency(ttot,regi,te_coolren70,"pond"))
        )
      )  
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;

p70_water_output(ttot,regi,"Water Consumption|Electricity|Dry Cooling; km3/yr;") 
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"dry") * p70_water_con(regi,te_coolnoren70,"dry") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"dry"))
        )
      )
    )  * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"dry") * i70_water_con(te_coolren70,"dry") / 100 * i70_efficiency(ttot,regi,te_coolren70,"dry"))
        )
      )  
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;
p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal|w/ CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"igccc") OR sameas(te_elcool70,"pcc") OR sameas(te_elcool70,"pco")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"igcc") OR sameas(te_elcool70,"pc") OR sameas(te_elcool70,"coalchp")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal|w/ CCS; km3/yr;") + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal|w/o CCS; km3/yr;")
;  

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Oil|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"dot")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Oil; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Oil|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas|w/ CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"ngccc")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"ngcc") OR sameas(te_elcool70,"ngt") OR sameas(te_elcool70,"gaschp")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas|w/ CCS; km3/yr;") + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Fossil; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas; km3/yr;")
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Oil; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Fossil|w/ CCS; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal|w/ CCS; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas|w/ CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Fossil|w/o CCS; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Coal|w/o CCS; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Gas|w/o CCS; km3/yr;")
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Oil|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Biomass|w/ CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"bioigccc")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Biomass|w/o CCS; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"bioigcc") OR sameas(te_elcool70,"biochp")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Biomass; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Biomass|w/ CCS; km3/yr;") + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Biomass|w/o CCS; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Nuclear; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"tnrs")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Hydro; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"hydro")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Solar|PV; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"spv")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Solar|CSP; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"csp")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Solar; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Solar|PV; km3/yr;") + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Solar|CSP; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Wind; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"wind")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Geothermal; km3/yr;") = 
  sum(te_elcool70$(sameas(te_elcool70,"geohdr")), 
    o70_water_withdrawal(ttot,regi,te_elcool70))
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Non-Biomass Renewables; km3/yr;") = 
  p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Hydro; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Solar; km3/yr;") 
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Wind; km3/yr;")
  + p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Geothermal; km3/yr;")
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Once Through; km3/yr;") 
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"once") * p70_water_wtd(regi,te_coolnoren70,"once") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"once"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,        
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"once") * i70_water_wtd(te_coolren70,"once") / 100 * i70_efficiency(ttot,regi,te_coolren70,"once"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Wet Tower; km3/yr;") 
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"tower") * p70_water_wtd(regi,te_coolnoren70,"tower") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"tower"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,        
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"tower") * i70_water_wtd(te_coolren70,"tower") / 100 * i70_efficiency(ttot,regi,te_coolren70,"tower"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Cooling Pond; km3/yr;") 
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"pond") * p70_water_wtd(regi,te_coolnoren70,"pond") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"pond"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,        
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"pond") * i70_water_wtd(te_coolren70,"pond") / 100 * i70_efficiency(ttot,regi,te_coolren70,"pond"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;

p70_water_output(ttot,regi,"Water Withdrawal|Electricity|Dry Cooling; km3/yr;") 
  =
    (sum(ttot2,
      sum(enty,
        sum(te_coolnoren70,
          p70_cap_vintages_share(ttot,regi,te_coolnoren70,ttot2) * p70_heat(ttot,regi,enty,"seel",te_coolnoren70)
          * (i70_cool_share_time(ttot2,regi,te_coolnoren70,"dry") * p70_water_wtd(regi,te_coolnoren70,"dry") / 100 * i70_efficiency(ttot,regi,te_coolnoren70,"dry"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)
  + 
    (sum(ttot2,
      sum(enty,
        sum(te_coolren70,        
          p70_cap_vintages_share(ttot,regi,te_coolren70,ttot2) * vm_prodSe.l(ttot,regi,enty,"seel",te_coolren70)
          * (i70_cool_share_time(ttot2,regi,te_coolren70,"dry") * i70_water_wtd(te_coolren70,"dry") / 100 * i70_efficiency(ttot,regi,te_coolren70,"dry"))
        )
      )
    ) * sm_TWa_2_MWh / sm_giga_2_non)      
;



***------------Write output-------------------------------------------------------
*---------------------------------------------------------------------------------
file file_water_output / water_output.csv /;

file_water_output.pw = 32767;
file_water_output.lw =  0;
file_water_output.nw =  0;
file_water_output.nd =  3;
file_water_output.nr =  2;

put file_water_output;

***Per region***------------------------------------------------------------------
put "Model;Scenario;Region;Variable;Unit";
loop(ttot$(ttot.val ge 2005), put ";", ttot.tl);
put /;
loop((regi,pe2se(enty,"seel",te_elcool70(te))),
  put "REMIND;%c_expname%;", regi.tl, ";";
  put "Secondary Energy|Electricity|", enty.tl, "|", te.tl, "; EJ/yr";
  loop(ttot$(ttot.val ge 2005),
    put ";", o70_se_production(ttot,regi,te);
  );
  put /;
);
loop((regi,pe2se(enty,"seel",te_elcool70(te))),
  put "REMIND;%c_expname%;", regi.tl, ";";
  put "Water Consumption|Electricity|", enty.tl, "|", te.tl, "; km3/yr";
  loop(ttot$(ttot.val ge 2005),
    put ";", o70_water_consumption(ttot,regi,te);
  );
  put /;
);
loop((regi,pe2se(enty,"seel",te_elcool70(te))),
  put "REMIND;%c_expname%;", regi.tl, ";";
  put "Water Withdrawal|Electricity|", enty.tl, "|", te.tl, "; km3/yr";
  loop(ttot$(ttot.val ge 2005),
    put ";", o70_water_withdrawal(ttot,regi,te);
  );
  put /;
);

***Global***----------------------------------------------------------------------
loop(pe2se(enty,"seel",te_elcool70(te)),
  put "REMIND;%c_expname%;glob;";
  put "Secondary Energy|Electricity|", enty.tl, "|", te.tl, "; EJ/yr";
  loop(ttot$(ttot.val ge 2005),
    put ";", sum(regi, o70_se_production(ttot,regi,te));
  );
  put /;
);
loop(pe2se(enty,"seel",te_elcool70(te)),
  put "REMIND;%c_expname%;glob;";
  put "Water Consumption|Electricity|", enty.tl, "|", te.tl, "; km3/yr";
  loop(ttot$(ttot.val ge 2005),
    put ";", sum(regi, o70_water_consumption(ttot,regi,te));
  );
  put /;
);
loop(pe2se(enty,"seel",te_elcool70(te)),
  put "REMIND;%c_expname%;glob;";
  put "Water Withdrawal|Electricity|", enty.tl, "|", te.tl, "; km3/yr";
  loop(ttot$(ttot.val ge 2005),
    put ";", sum(regi, o70_water_withdrawal(ttot,regi,te));
  );
  put /;
);

***Totals***----------------------------------------------------------------------
loop(all_regi,
  loop (descr_water_ext,
    put "REMIND;%c_expname%;", all_regi.tl, ";";
    put descr_water_ext.tl:64 ;
      loop(ttot$(ttot.val ge 2005),
        put p70_water_output(ttot,all_regi,descr_water_ext):10:3 ";";
      );
      put /;
  );
);

***Intensities***-----------------------------------------------------------------
loop(all_regi,
  loop (descr_water_int,
    put "REMIND;%c_expname%;", all_regi.tl, ";";
    put descr_water_int.tl:64 ;
      loop(ttot$(ttot.val ge 2005),
        put p70_water_output(ttot,all_regi,descr_water_int):10:3 ";";
      );
      put /;
  );
);

putclose file_water_output;

*** EOF ./modules/70_water/heat/output.gms
