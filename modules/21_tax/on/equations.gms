*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/equations.gms

***---------------------------------------------------------------------------
*'  The bioenergy tax is calculated: it scales linearly with the bioenergy demand starting at 0 at 0EJ to the level defined in cm_bioenergy_tax at 200 EJ.
***---------------------------------------------------------------------------
  q21_tau_bio(t)$(t.val ge max(2010,cm_startyear))..
    v21_tau_bio(t)
    =e=
    cm_bioenergy_tax / (200 * sm_EJ_2_TWa) * (sum(regi,vm_fuExtr(t,regi,"pebiolc","1") + pm_fuExtrForeign(t,regi,"pebiolc","1")))
    ;


***---------------------------------------------------------------------------
*'  Calculation of the value of the overall tax revenue vm_taxrev, that is included in the qm_budget equation. 
*'  Overall tax revenue is the sum of various components which are calculated in the following equations, each of those with similar structure:
*'  The tax revenue is the difference between the product of an activity level (a variable) and a tax rate (a parameter), 
*'  and this product in the last iteration (which is loaded as a parameter).
*'  After converging Negishi/Nash iterations, the value approaches 0, as the activity levels between the current and last iteration don't change anymore. 
*'  This means, taxes are budget-neutral: the revenue is always recycled back and still available for the economy. 
*'  Nevertheless, the marginal of the (variable of) taxed activities is impacted by the tax which leads to the adjustment effect.
***---------------------------------------------------------------------------
  q21_taxrev(t,regi)$(t.val ge max(2010,cm_startyear))..
    vm_taxrev(t,regi)
    =g=
      v21_taxrevGHG(t,regi)
    + v21_taxrevCO2luc(t,regi)
    + v21_taxrevCCS(t,regi) 
    + v21_taxrevNetNegEmi(t,regi)  
    + v21_taxrevFEtrans(t,regi) 
    + v21_taxrevFEBuildInd(t,regi) 
    + v21_taxrevFE_Es(t,regi) 
    + v21_taxrevResEx(t,regi)   
    + v21_taxrevPE2SE(t,regi)
    + v21_taxrevXport(t,regi)
    + v21_taxrevSO2(t,regi)
    + v21_taxrevBio(t,regi)
    - vm_costSubsidizeLearning(t,regi)
    + v21_implicitDiscRate(t,regi)
    + v21_taxrevFlex(t,regi)
 ;


***---------------------------------------------------------------------------
*'  Calculation of greenhouse gas taxes: tax rate (combination of 3 components) times ghg emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevGHG(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevGHG(t,regi) =g= ( pm_taxCO2eq(t,regi)  + pm_taxCO2eqSCC(t,regi) + pm_taxCO2eqHist(t,regi)) * (vm_co2eq(t,regi) - vm_emiMacSector(t,regi,"co2luc")$(cm_multigasscen ne 3))
                           - p21_taxrevGHG0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of greenhouse gas taxes: tax rate (combination of 3 components) times land use co2 emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevCO2luc(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevCO2luc(t,regi) =g= ( pm_taxCO2eq(t,regi)  + pm_taxCO2eqSCC(t,regi) + pm_taxCO2eqHist(t,regi))* cm_cprice_red_factor * vm_emiMacSector(t,regi,"co2luc")$(cm_multigasscen ne 3)
                           - p21_taxrevCO2LUC0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of CCS tax: tax rate (defined as fraction(or multiplier) of O&M costs) times amount of CO2 sequestration
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevCCS(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevCCS(t,regi) 
=g= cm_frac_CCS * pm_data(regi,"omf","ccsinje") * pm_inco0_t(t,regi,"ccsinje") 
    * ( sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS(t,regi,enty,enty2,te,rlf) ) ) )
    * (1/sm_ccsinjecrate) * sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS(t,regi,enty,enty2,te,rlf) ) ) / pm_dataccs(regi,"quan","1")	!! fraction of injection constraint per year
	- p21_taxrevCCS0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of net-negative emissions tax: tax rate (defined as fraction of carbon price) times net-negative emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevNetNegEmi(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevNetNegEmi(t,regi) =g=  cm_frac_NetNegEmi * pm_taxCO2eq(t,regi) * v21_emiALLco2neg(t,regi)
                                 - p21_taxrevNetNegEmi0(t,regi);

***---------------------------------------------------------------------------
*'  Auxiliary calculation of net-negative emissions: 
*'  v21_emiAllco2neg and v21_emiAllco2neg_slack are defined as positive variables
*'  so as long as vm_emiAll is positive, v21_emiAllco2neg_slack adjusts so that sum is zero
*'  if vm_emiAll is negative, in order to minimize tax v21_emiAllco2neg_slack becomes zero
***---------------------------------------------------------------------------
q21_emiAllco2neg(t,regi)..
v21_emiALLco2neg(t,regi) =e= -vm_emiAll(t,regi,"co2") + v21_emiALLco2neg_slack(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of final Energy taxes in Transports: effective tax rate (tax - subsidy) times FE use in transport
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevFEtrans(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevFEtrans(t,regi) 
=g=  SUM(feForEs(enty),
        (p21_tau_fe_tax_transport(t,regi,feForEs) + p21_tau_fe_sub_transport(t,regi,feForEs) ) * SUM(se2fe(enty2,enty,te), vm_prodFe(t,regi,enty2,enty,te))
      ) +
     SUM(feForUe(enty),
        (p21_tau_fe_tax_transport(t,regi,feForUe) + p21_tau_fe_sub_transport(t,regi,feForUe) ) * SUM(se2fe(enty2,enty,te), vm_prodFe(t,regi,enty2,enty,te))
      )
  - p21_taxrevFEtrans0(t,regi) ;


***---------------------------------------------------------------------------
*'  Calculation of final Energy taxes in Buildings_Industry or Stationary: effective tax rate (tax - subsidy) times FE use in sector
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevFEBuildInd(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevFEBuildInd(t,regi) 
=g= SUM(ppfen(in)$( NOT ppfenFromUe(in)),
          (p21_tau_fe_tax_bit_st(t,regi,ppfen) + p21_tau_fe_sub_bit_st(t,regi,ppfen) ) * vm_cesIO(t,regi,ppfen)
        )
	- p21_taxrevFEBuildInd0(t,regi) ;
	
***---------------------------------------------------------------------------
*'  Calculation of final Energy taxes in Buildings_Industry or Stationary sector with energy service representation: effective tax rate (tax - subsidy) times FE use in sector
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevFE_Es(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevFE_Es(t,regi) 
=g= SUM(fe2es(entyFe,esty,teEs),
          (pm_tau_fe_tax_ES_st(t,regi,esty) + pm_tau_fe_sub_ES_st(t,regi,esty) ) * vm_demFeForEs(t,regi,entyFe,esty,teEs)
        )
	- p21_taxrevFE_Es0(t,regi) ;
    
***---------------------------------------------------------------------------
*'  Calcuation of ressource extraction subsidies: subsidy rate times fuel extraction
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevResEx(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevResEx(t,regi) =g=  sum(pe2rlf(peEx(enty),rlf), p21_tau_fuEx_sub(t,regi,enty) * vm_fuExtr(t,regi,enty,rlf))
                             - p21_taxrevResEx0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of pe2se taxes (Primary to secondary energy technology taxes, specified by technology): effective tax rate (tax - subsidy) times SE output of technology 
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevPE2SE(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevPE2SE(t,regi) 
=g= SUM(pe2se(enty,enty2,te),
          (p21_tau_pe2se_tax(t,regi,te) + p21_tau_pe2se_sub(t,regi,te) + p21_tau_pe2se_inconv(t,regi,te)) * vm_prodSe(t,regi,enty,enty2,te)
       )
	- p21_taxrevPE2SE0(t,regi) ; 

***---------------------------------------------------------------------------
*'  Calculation of export taxes: tax rate times export volume
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevXport(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevXport(t,regi) =g= SUM(tradePe(enty), p21_tau_XpRes_tax(t,regi,enty) * vm_Xport(t,regi,enty))
                            - p21_taxrevXport0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of so2 tax: tax rate times emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevSO2(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevSO2(t,regi) =g= p21_tau_so2_tax(t,regi) * vm_emiTe(t,regi,"so2") 
                          - p21_taxrevSO20(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of bioenergy tax: tax rate (calculated as multiple of bioenergy price) times PE use of pebiolc
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevBio(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevBio(t,regi) =g= v21_tau_bio(t) * vm_fuExtr(t,regi,"pebiolc","1") * vm_pebiolc_price(t,regi)
                          - p21_taxrevBio0(t,regi);
						  
***---------------------------------------------------------------------------
*'  Calculation of High implicit discount rates in energy efficiency capital 
*'  which is also modeled as a tax to mirror the lack of incentive for cost-efficient renovations.
*'  calculation is done via additional discount rate times input of capital at different levels
***---------------------------------------------------------------------------
q21_implicitDiscRate(t,regi)$(t.val ge max(2010,cm_startyear))..
 v21_implicitDiscRate(t,regi) 
 =g= sum(ppfKap(in),
        p21_implicitDiscRateMarg(t,regi,in) 
        * vm_cesIO(t,regi,in)
        ) - p21_implicitDiscRate0(t,regi);
;    

***---------------------------------------------------------------------------
*'  FS: Calculation of tax/subsidy on technologies with inflexible/flexible electricity input
***---------------------------------------------------------------------------

q21_taxrevFlex(t,regi)$(t.val ge max(2010,cm_startyear))..
  v21_taxrevFlex(t,regi)
  =e=
  sum(en2en(enty,enty2,te)$(teFlexTax(te)),
*** vm_flexAdj is electricity price reduction/increases for flexible/inflexible technologies
*** change sign such that flexible technologies get subsidy
      -vm_flexAdj(t,regi,te) * vm_demSe(t,regi,enty,enty2,te))           
  - p21_taxrevFlex0(t,regi)
;

 
*** EOF ./modules/21_tax/on/equations.gms
