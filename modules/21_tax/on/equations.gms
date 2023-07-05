*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/equations.gms

***---------------------------------------------------------------------------
*'  The dynamic bioenergy sustainability tax is calculated: it scales linearly
*'  with the bioenergy demand starting at 0 at 0EJ to the level defined in
*'  cm_bioenergy_SustTax at 200 EJ.
***---------------------------------------------------------------------------
  q21_tau_bio(t)$(t.val ge max(2010,cm_startyear))..
    v21_tau_bio(t)
    =e=
    cm_bioenergy_SustTax / (200 * sm_EJ_2_TWa) * (sum(regi,vm_fuExtr(t,regi,"pebiolc","1") + pm_fuExtrForeign(t,regi,"pebiolc","1")))
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
  =e=
    v21_taxrevGHG(t,regi)
  + sum(emi_sectors, v21_taxrevCO2Sector(t,regi,emi_sectors))
  + v21_taxrevCO2luc(t,regi)
  + v21_taxrevCCS(t,regi) 
  + v21_taxrevNetNegEmi(t,regi)
  + sum(entyPe, v21_taxrevPE(t,regi,entyPe))
  + v21_taxrevFE(t,regi)
  + sum(in, v21_taxrevCES(t,regi,in))
  + v21_taxrevResEx(t,regi)   
  + v21_taxrevPE2SE(t,regi)
  + v21_taxrevTech(t,regi)
  + v21_taxrevXport(t,regi)
  + v21_taxrevSO2(t,regi)
  + v21_taxrevBio(t,regi)
  - vm_costSubsidizeLearning(t,regi)
  + v21_implicitDiscRate(t,regi)
  + sum(emiMkt, v21_taxemiMkt(t,regi,emiMkt))  
  + v21_taxrevFlex(t,regi)
  + sum(tradePe, v21_taxrevImport(t,regi,tradePe))  
  + v21_taxrevChProdStartYear(t,regi)
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
  + vm_taxrevimplicitQttyTargetTax(t,regi)
$endif.cm_implicitQttyTarget 
$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
  + sum((entySe,entyFe,sector)$(entyFe2Sector(entyFe,sector)),vm_taxrevimplicitPriceTax(t,regi,entySe,entyFe,sector))
$endIf.cm_implicitPriceTarget
$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
  + sum(entyPe,vm_taxrevimplicitPePriceTax(t,regi,entyPe))
$endIf.cm_implicitPePriceTarget
;

***---------------------------------------------------------------------------
*'  Calculation of greenhouse gas taxes: tax rate (combination of 4 components) times ghg emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevGHG(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevGHG(t,regi) =e= pm_taxCO2eqSum(t,regi) * (vm_co2eq(t,regi) - vm_emiMacSector(t,regi,"co2luc")$(cm_multigasscen ne 3))
                           - pm_taxrevGHG0(t,regi);


***---------------------------------------------------------------------------
*' Calculation of sectoral CO2 taxes as markup to GHG taxes (combination of 4 components)
*' Sectoral CO2 emissions are multiplied by a predefined factor
***---------------------------------------------------------------------------

q21_taxrevCO2Sector(t,regi,emi_sectors)$(t.val ge max(2010,cm_startyear))..
v21_taxrevCO2Sector(t,regi,emi_sectors) =e= p21_CO2TaxSectorMarkup(t,regi,emi_sectors) * pm_taxCO2eqSum(t,regi) * vm_emiCO2Sector(t,regi,emi_sectors)
                             - pm_taxrevCO2Sector0(t,regi,emi_sectors);

***---------------------------------------------------------------------------
*'  Calculation of greenhouse gas taxes: tax rate (combination of 4 components) times land use co2 emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevCO2luc(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevCO2luc(t,regi) =e= pm_taxCO2eqSum(t,regi) * vm_emiMacSector(t,regi,"co2luc")$(cm_multigasscen ne 3)
                           - pm_taxrevCO2LUC0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of CCS tax: tax rate (defined as fraction(or multiplier) of O&M costs) times amount of CO2 sequestration
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevCCS(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevCCS(t,regi) 
=e= cm_frac_CCS * pm_data(regi,"omf","ccsinje") * pm_inco0_t(t,regi,"ccsinje") 
    * ( sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS(t,regi,enty,enty2,te,rlf) ) ) )
    * (1/pm_ccsinjecrate(regi)) * sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS(t,regi,enty,enty2,te,rlf) ) ) / pm_dataccs(regi,"quan","1")	!! fraction of injection constraint per year
	- p21_taxrevCCS0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of net-negative emissions tax: tax rate (defined as fraction of carbon price) times net-negative emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevNetNegEmi(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevNetNegEmi(t,regi) =e= cm_frac_NetNegEmi * pm_taxCO2eqSum(t,regi) * v21_emiALLco2neg(t,regi)
                                 - pm_taxrevNetNegEmi0(t,regi);

***---------------------------------------------------------------------------
*'  Auxiliary calculation of net-negative emissions: 
*'  v21_emiAllco2neg and v21_emiAllco2neg_slack are defined as positive variables
*'  so as long as vm_emiAll is positive, v21_emiAllco2neg_slack adjusts so that sum is zero
*'  if vm_emiAll is negative, in order to minimize tax v21_emiAllco2neg_slack becomes zero
***---------------------------------------------------------------------------
q21_emiAllco2neg(t,regi)..
v21_emiALLco2neg(t,regi) =e= -vm_emiAll(t,regi,"co2") + v21_emiALLco2neg_slack(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of PE tax: tax rate times primary energy
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevPE(t,regi,entyPe)$(t.val ge max(2010,cm_startyear))..
v21_taxrevPE(t,regi,entyPe) =e= pm_tau_pe_tax(t,regi,entyPe) * vm_prodPe(t,regi,entyPe)
                          - p21_taxrevPE0(t,regi,entyPe);

***---------------------------------------------------------------------------
*'  Calculation of final Energy taxes: effective tax rate (tax - subsidy) times FE use in the specific sector
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevFE(t,regi)$(t.val ge max(2010,cm_startyear))..
  v21_taxrevFE(t,regi) 
  =e=
  sum((entyFe,sector)$entyFe2Sector(entyFe,sector),
    ( pm_tau_fe_tax(t,regi,sector,entyFe) + pm_tau_fe_sub(t,regi,sector,entyFe) ) 
    * 
    sum(emiMkt$sector2emiMkt(sector,emiMkt), 
      sum(se2fe(entySe,entyFe,te),   
        vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)
      )
    )
  )
  - p21_taxrevFE0(t,regi)
  ;

***---------------------------------------------------------------------------
*'  Calculation of CES tax: tax rate times CES inputs
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevCES(t,regi,in)$(t.val ge max(2010,cm_startyear))..
v21_taxrevCES(t,regi,in) =e= pm_tau_ces_tax(t,regi,in) * vm_cesIO(t,regi,in)
                          - p21_taxrevCES0(t,regi,in);

***---------------------------------------------------------------------------
*'  Calculation of resource extraction subsidies: subsidy rate times fuel extraction
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevResEx(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevResEx(t,regi) =e=  sum(pe2rlf(peEx(enty),rlf), p21_tau_fuEx_sub(t,regi,enty) * vm_fuExtr(t,regi,enty,rlf))
                             - p21_taxrevResEx0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of pe2se taxes (Primary to secondary energy technology taxes, specified by technology): effective tax rate (tax - subsidy) times SE output of technology 
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevPE2SE(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevPE2SE(t,regi) 
=e= SUM(pe2se(enty,enty2,te),
          (p21_tau_pe2se_tax(t,regi,te) + p21_tau_pe2se_sub(t,regi,te) + p21_tau_pe2se_inconv(t,regi,te)) * vm_prodSe(t,regi,enty,enty2,te)
       )
	- p21_taxrevPE2SE0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of technology specific subsidies and taxes. Tax incidency applied only over new capacity (deltaCap)
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevTech(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevTech(t,regi) 
=e= sum(te2rlf(te,rlf),
          (p21_tech_tax(t,regi,te,rlf) + p21_tech_sub(t,regi,te,rlf)) * vm_deltaCap(t,regi,te,rlf)
       )
	- p21_taxrevTech0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of export taxes: tax rate times export volume
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevXport(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevXport(t,regi) =e= SUM(tradePe(enty), p21_tau_XpRes_tax(t,regi,enty) * vm_Xport(t,regi,enty))
                            - p21_taxrevXport0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of so2 tax: tax rate times emissions
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevSO2(t,regi)$(t.val ge max(2010,cm_startyear))..
v21_taxrevSO2(t,regi) =e= p21_tau_so2_tax(t,regi) * vm_emiTe(t,regi,"so2") 
                          - p21_taxrevSO20(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of total bioenergy tax revenues. There are two tax types that
*'  are independent of each other:
*'     1. The global sustainability tax rate, which scales linearly with
*'        bioenergy production (the higher the demand, the higher the tax
*'        ratio v21_tau_bio).
*'        Units: v21_tau_bio(t)                                [1]
*'               vm_pebiolc_price(t,regi)                      [T$US per TWa]
*'               -> v21_tau_bio(t)  * vm_pebiolc_price(t,regi) [T$US per TWa]
*'     2. The (potentially) region-specific emission-factor-based tax, which
*'        is directly linked to the carbon price and does not directly
*'        depend on the bioenergy production level. The tax level in monetary
*'        terms per unit of bioenergy is derived by multiplying the emission
*'        factor with the CO2 price. This tax is applied to biomass consumption
*'        (i.e. after trade, applied within the region consuming the
*'        bioenergy). By default this emission-factor-based bioenergy tax is
*'        deactivated, since in coupled REMIND-MAgPIE policy runs we usually
*'        assume that emissions associated with bioenergy production are
*'        regulated (i.e. penalized) within the land-use sector with the carbon
*'        price on terrestrial carbon emissions. In the absence of direct
*'        emissions regulation within the land-use sector, however, this
*'        undifferentiated emission-factor-based energy tax can be used as a
*'        substitute for missing climate policies in the land-use sector in
*'        order to close the regulation gap.
*'        Please note that the associated emissions (bioenergy production *
*'        emission factor) do NOT enter the emissions balance equations, since
*'        land-use emissions are accounted for in MAgPIE (i.e. the emission
*'        factor is only used to inform the tax level).
*'        Units: p21_bio_EF(t,regi)                            [GtC per TWa]
*'               pm_taxCO2eq(t,regi)                           [T$US per GtC]
*'               -> p21_bio_EF(t,regi) * pm_taxCO2eq(t,regi)   [T$US per TWa]
*'  Documentation of overall tax approach is above at q21_taxrev.
***---------------------------------------------------------------------------
q21_taxrevBio(t,regi)$(t.val ge max(2010,cm_startyear))..
  v21_taxrevBio(t,regi)
  =e=
  !! 1. sustainability tax on production
    v21_tau_bio(t)  * vm_pebiolc_price(t,regi)
    * vm_fuExtr(t,regi,"pebiolc","1")
  !! 2. emission-factor-based tax on consumption
  + p21_bio_EF(t,regi) * pm_taxCO2eq(t,regi)
    * (vm_fuExtr(t,regi,"pebiolc","1") - (vm_Xport(t,regi,"pebiolc")-vm_Mport(t,regi,"pebiolc")))
  - p21_taxrevBio0(t,regi);

***---------------------------------------------------------------------------
*'  Calculation of High implicit discount rates in energy efficiency capital 
*'  which is also modeled as a tax to mirror the lack of incentive for cost-efficient renovations.
*'  calculation is done via additional discount rate times input of capital at different levels
***---------------------------------------------------------------------------
q21_implicitDiscRate(t,regi)$(t.val ge max(2010,cm_startyear))..
 v21_implicitDiscRate(t,regi) 
 =e= sum(ppfKap(in),
        p21_implicitDiscRateMarg(t,regi,in) 
        * vm_cesIO(t,regi,in)
        ) - p21_implicitDiscRate0(t,regi);
;        
						  
***---------------------------------------------------------------------------
*'  Calculation of specific emission market taxes
*'  calculation is done via additional budget emission constraints defined in regipol module
***---------------------------------------------------------------------------
q21_taxemiMkt(t,regi,emiMkt)$(t.val ge max(2010,cm_startyear))..
  v21_taxemiMkt(t,regi,emiMkt) 
  =e=
  pm_taxemiMkt(t,regi,emiMkt) * vm_co2eqMkt(t,regi,emiMkt)
  - p21_taxemiMkt0(t,regi,emiMkt); 
; 

***---------------------------------------------------------------------------
*'  FS: Calculation of tax/subsidy on technologies with inflexible/flexible electricity input 
*'  This is to emulate the effect of lower/higher electricity prices in high VRE systems on flexible/inflexible electricity demands. 
***---------------------------------------------------------------------------

q21_taxrevFlex(t,regi)$( t.val ge max(2010, cm_startyear) ) ..
  v21_taxrevFlex(t,regi)
  =e=
    sum(en2en(enty,enty2,te)$(teFlexTax(te)),
      !! vm_flexAdj is electricity price reduction/increases for flexible/
      !! inflexible technologies change sign such that flexible technologies
      !! get subsidy
      -vm_flexAdj(t,regi,te) 
    * vm_demSe(t,regi,enty,enty2,te)
    )
  - p21_taxrevFlex0(t,regi)
;


***---------------------------------------------------------------------------
*'  FS: (PE) import tax 
*'  can be used to place taxes on PE energy imports 
*'  e.g. bioenergy import taxes due to sustainability concerns by importers
***---------------------------------------------------------------------------

q21_taxrevImport(t,regi,tradePe)..
  v21_taxrevImport(t,regi,tradePe)
  =e=
*** import tax level * world market bioenergy price * bioenergy import
  p21_tau_Import(t,regi,tradePe) * pm_pvp(t,tradePe) / pm_pvp(t,"good") * vm_Mport(t,regi,tradePe)
    - p21_taxrevImport0(t,regi,tradePe)
;

***---------------------------------------------------------------------------
*'  Calculation of costs limiting the change compared to the reference run in cm_startyear.
***---------------------------------------------------------------------------
q21_taxrevChProdStartYear(t,regi)$(t.val ge max(2010,cm_startyear))..
  v21_taxrevChProdStartYear(t,regi)
  =e=
  sum(en2en(enty,enty2,te), vm_changeProdStartyearCost(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) )
  - p21_taxrevChProdStartYear0(t,regi)
;



*** EOF ./modules/21_tax/on/equations.gms
