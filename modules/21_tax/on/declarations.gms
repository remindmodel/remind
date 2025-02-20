*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/declarations.gms
Parameters
pm_taxrevGHG0(ttot,all_regi)                                        "reference level value of GHG emission tax"
pm_taxrevCO2Sector0(ttot,all_regi,emi_sectors)                      "reference level value of CO2 sector markup tax"
pm_taxrevCO2LUC0(ttot,all_regi)                                     "reference level value of co2luc emission tax"
p21_taxrevCCS0(ttot,all_regi)                                       "reference level value of CCS tax"
pm_taxrevNetNegEmi0(ttot,all_regi)                                  "reference level value of net-negative emissions tax"
p21_emiALLco2neg0(ttot,all_regi)                                    "reference level value of negative CO2 emissions for taxes"
p21_taxrevPE0(ttot,all_regi,all_enty)                               "reference level value of primary energy tax"
p21_taxrevFE0(ttot,all_regi)                                        "reference level value of final energy tax"
p21_taxrevCES0(ttot,all_regi,all_in)                                "reference level value of ces production tax"
p21_taxrevResEx0(ttot,all_regi)                                     "reference level value of resource extraction tax"
p21_taxrevPE2SE0(ttot,all_regi)                                     "reference level value of pe2se technologies tax"
p21_taxrevSO20(ttot,all_regi)                                       "reference level value of SO2 tax"
p21_taxrevBio0(ttot,all_regi)                                       "reference level value of bioenergy tax"
p21_taxemiMkt0(ttot,all_regi,all_emiMkt)                            "reference level value of co2 emission taxes per emission market"
p21_taxrevFlex0(ttot,all_regi)                                      "reference level value of flexibility tax"
p21_taxrevImport0(ttot,all_regi,all_enty,tax_import_type_21)        "reference level value of energy import tax"
p21_taxrevChProdStartYear0(ttot,all_regi)                           "reference level value of tax to limit changes compared to reference run in cm_startyear"
p21_taxrevSE0(ttot,all_regi)                                        "reference level value of tax on SE electricity demand"

p21_taxrevGHG_iter(iteration,ttot,all_regi)                         "track reference level value of GHG emission tax revenue over iterations"
p21_taxrevCCS_iter(iteration,ttot,all_regi)                         "track reference level value of CCS tax revenue over iterations"
p21_taxrevNetNegEmi_iter(iteration,ttot,all_regi)                   "track reference level value of net-negative emissions tax revenue over iterations"
p21_taxrevPE_iter(iteration,ttot,all_regi,all_enty)                 "track reference level value of primary energy tax revenue over iterations"
p21_taxrevFE_iter(iteration,ttot,all_regi)                          "track reference level value of final energy tax revenue over iterations"
p21_taxrevCES_iter(iteration,ttot,all_regi,all_in)                  "track reference level value of ces production tax revenue over iterations"
p21_taxrevResEx_iter(iteration,ttot,all_regi)                       "track reference level value of resource extraction tax revenue over iterations"
p21_taxrevPE2SE_iter(iteration,ttot,all_regi)                       "track reference level value of pe2se technologies tax revenue over iterations"
p21_taxrevSO2_iter(iteration,ttot,all_regi)                         "track reference level value of SO2 tax revenue over iterations"
p21_taxrevBio_iter(iteration,ttot,all_regi)                         "track reference level value of bioenergy tax revenue over iterations"
p21_taxrevFlex_iter(iteration,ttot,all_regi)                        "track reference level value of flexibility tax revenue over iterations"
p21_taxrevImport_iter(iteration,ttot,all_regi,all_enty)             "track reference level value of energy import tax over iterations"
p21_taxrevChProdStartYear_iter(iteration,ttot,all_regi)             "track reference level value of tax to limit changes compared to reference run in cm_startyear over iterations"
p21_taxrevSE_iter(iteration,ttot,all_regi)                          "track reference level value of tax on SE electricity demand over iterations"

p21_deltarev(iteration,all_regi)                                    "convergence criteria for iteration on tax revenue recycling"

p21_tau_CO2_tax_gdx(ttot,all_regi)                                  "tax path from gdx, may overwrite default values"
p21_tau_CO2_tax_gdx_bau(ttot,all_regi)                              "tax path from gdx, may overwrite default values"

p21_tau_so2_tax(tall,all_regi)                                      "so2 tax path"
p21_tau_pe2se_tax(tall,all_regi,all_te)                             "tax path for PE2SE technologies"
p21_tau_pe2se_sub(tall,all_regi,all_te)                             "subsidy path for PE2SE technologies"
p21_max_fe_sub(tall,all_regi,all_enty)                              "maximum final energy subsidy levels from REMIND version prior to rev. 5429 [$/TWa]"
p21_prop_fe_sub(tall,all_regi,all_enty)                             "subsidy proportional cap to avoid liquids increasing dramatically"
p21_tau_fuEx_sub(tall,all_regi,all_enty)                            "subsidy path for fuel extraction [$/TWa]"
p21_bio_EF(ttot,all_regi)                                           "bioenergy emission factor, which is used to calculate the emission-factor-based tax level [GtC/TWa]"
p21_tau_Import(ttot,all_regi,all_enty,tax_import_type_21)           "tax on energy imports, only works on energy carriers traded on nash markets, tax defined as share of world market price pm_pvp [Unit: share]"
pm_tau_pe_tax(ttot,all_regi,all_enty)                               "tax path for primary energy"
pm_tau_ces_tax(ttot,all_regi,all_in)                                "ces production tax to implement CES mark-up cost in a budget-neutral way"
p21_tau_SE_tax(ttot,all_regi,all_te)                                "maximum tax rate for SE electricity tax, used for taxes on electrolysis"
p21_tau_fe_tax(ttot,all_regi,emi_sectors,all_enty)                  "tax path for final energy"
p21_tau_fe_sub(ttot,all_regi,emi_sectors,all_enty)                  "subsidy path for final energy"
p21_CO2TaxSectorMarkup(ttot,all_regi,emi_sectors)                   "path for CO2 tax markup in building, industry or transport sector"


p21_tau_SE_tax_rampup(ttot,all_regi,all_te,teSeTax_coeff)           "Parameters of logistic function to describe relationship between SE electricity tax rate and share of technology in total electricity demand"
$ifThen.SEtaxRampUpParam not "%cm_SEtaxRampUpParam%" == "off" 
  p21_SEtaxRampUpParameters(ext_regi,all_te,teSeTax_coeff)          "config values for SE electricity tax rate tech specific ramp up logistic function parameters" / %cm_SEtaxRampUpParam% /
$endif.SEtaxRampUpParam
;

$ifThen.import not "%cm_import_tax%" == "off" 
Parameter
  p21_import_tax(ext_regi,all_enty,tax_import_type_21)              "parameter to read in configurations from import tax switch" 
  / %cm_import_tax% /
;
$endif.import

$ifthen.importtaxrc "%cm_taxrc_RE%" == "REdirect"
Parameters 
  p21_ref_costInvTeDir_RE(ttot,all_regi,all_te)                     "RE direct investment volume in reference scenario"
  p21_ref_costInvTeAdj_RE(ttot,all_regi,all_te)                     "RE adjustment cost investment volume in reference scenario"
;
$endif.importtaxrc

$ifthen.fetax not "%cm_FEtax_trajectory_abs%" == "off" 
Parameters
    p21_FEtax_trajectory_abs(ttot,emi_sectors,all_enty)             "absolute final energy tax level of the end year set by cm_FEtax_trajectory_abs switch [USD/MWh]"  / %cm_FEtax_trajectory_abs% /   
;
$endif.fetax

$ifthen.fetaxRel not "%cm_FEtax_trajectory_rel%" == "off" 
Parameters
    p21_FEtax_trajectory_rel(ttot,emi_sectors,all_enty)             "factor to scale final energy tax level of the end year from cm_FEtax_trajectory_rel switch"  / %cm_FEtax_trajectory_rel% /   
;
$endif.fetaxRel

Scalars
s21_so2_tax_2010                                                    "SO2 tax value in 2010 in 10^12$/TgS = 10^6 $/t S"
s21_tax_time                                                        "time when final tax level is reached"
s21_tax_value                                                       "target level of tax, sub, inconv in $/GJ, must always be rescaled after setting"
;

variables
v21_taxrevReal(ttot,all_regi)                                       "difference between volume of real taxes and subsidies in current and previous iteration"
v21_taxrevPseudo(ttot,all_regi)                                     "difference between volume of pseudo taxes and subsidies in current and previous iteration"
v21_tau_bio(ttot)                                                   "demand-dependent bioenergy tax"
v21_taxrevGHG(ttot,all_regi)                                        "tax on greenhouse gas emissions"
v21_taxrevCO2Sector(ttot,all_regi,emi_sectors)                      "sector markup tax on CO2 emissions"
v21_taxrevCO2luc(ttot,all_regi)                                     "tax on co2luc emissions"
v21_taxrevCCS(ttot,all_regi)                                        "tax on CCS (to reflect leakage risk)"
v21_taxrevNetNegEmi(ttot,all_regi)                                  "tax on net-negative emissions (to reflect climate damages due to overshoot)"
v21_taxrevPE(ttot,all_regi,all_enty)                                "tax on primary energy"
v21_taxrevFE(ttot,all_regi)                                         "tax on final energy (?)"
v21_taxrevCES(ttot,all_regi,all_in)                                 "tax on ces production function"
v21_taxrevResEx(ttot,all_regi)                                      "tax on resource extraction (?)"
v21_taxrevPE2SE(ttot,all_regi)                                      "tax on pe2se technologies (?)"
v21_taxrevSO2(ttot,all_regi)                                        "tax on SO2 (to reflect health impacts)"
v21_taxrevBio(ttot,all_regi)                                        "tax on bioenergy (to reflect sustainability constraints on bioenergy production)"
v21_taxrevFlex(ttot,all_regi)                                       "tax on technologies with flexible or inflexible electricity input"
v21_taxemiMkt(ttot,all_regi,all_emiMkt)                             "tax on greenhouse gas emissions"
v21_taxrevImport(ttot,all_regi,all_enty)                            "net change vs. last iteration of tax revenues from energy import tax"
v21_taxrevChProdStartYear(ttot,all_regi)                            "tax to limit changes compared to reference run in cm_startyear"
v21_taxrevSE(ttot,all_regi)                                         "tax on SE electricity demand, used for taxes on electrolysis"
;

Positive Variable
vm_emiALLco2neg(ttot,all_regi)                                      "negative part of total CO2 emissions"
v21_emiALLco2neg_slack(ttot,all_regi)                               "dummy variable to extract negatice CO2 emissions from emiAll"
v21_tau_SE_tax(ttot,all_regi,all_te)                                "tax rate of tax on SE electricity demand, used for taxes on electrolysis"
;

equations 
q21_taxrev(ttot,all_regi)                                           "calculation of difference in total tax volume"
q21_taxrevReal(ttot,all_regi)                                       "calculation of difference in volume of real taxes and subsidies"
q21_taxrevPseudo(ttot,all_regi)                                     "calculation of difference in volume of pseudo taxes and subsidies"
q21_emiAllco2neg(ttot,all_regi)                                     "calculates negative part of CO2 emissions"
q21_tau_bio(ttot)                                                   "calculation of demand-dependent bioenergy tax"
q21_taxrevGHG(ttot,all_regi)                                        "calculation of tax on greenhouse gas emissions"
q21_taxrevCO2Sector(ttot,all_regi,emi_sectors)                      "calculation of sector markup tax on CO2 emissions"
q21_taxrevCO2luc(ttot,all_regi)                                     "calculation of tax on co2luc emissions"
q21_taxrevCCS(ttot,all_regi)                                        "calculation of tax on CCS"
q21_taxrevNetNegEmi(ttot,all_regi)                                  "calculation of tax on net-negative emissions"
q21_taxrevPE(ttot,all_regi,all_enty)                                "calculation of tax on primary energy"
q21_taxrevFE(ttot,all_regi)                                         "calculation of tax on final energy"
q21_taxrevCES(ttot,all_regi,all_in)                                 "calculation of tax on ces production function"
q21_taxrevResEx(ttot,all_regi)                                      "calculation of tax on resource extraction"
q21_taxrevPE2SE(ttot,all_regi)                                      "calculation of tax on pe2se technologies"
q21_taxrevSO2(ttot,all_regi)                                        "calculation of tax on SO2"
q21_taxrevBio(ttot,all_regi)                                        "calculation of tax on bioenergy"
q21_taxrevFlex(ttot,all_regi)                                       "tax on technologies with flexible or inflexible electricity input"
q21_taxemiMkt(ttot,all_regi,all_emiMkt)                             "calculation of specific emission market tax on CO2 emissions"
q21_taxrevImport(ttot,all_regi,all_enty)                            "calculation of import tax"
q21_taxrevChProdStartYear(ttot,all_regi)                            "calculation of tax to limit changes compared to reference run in cm_startyear"
q21_taxrevSE(ttot,all_regi)                                         "calculation of tax on SE electricity demand, used for taxes on electrolysis"
q21_SeTaxRate(ttot,all_regi,all_te)                                 "calculation of SE tax rate, used for taxes on electrolysis"
;

$ifthen.importtaxrc "%cm_taxrc_RE%" == "REdirect"
equations
q21_rc_tau_import_RE(ttot,trade_regi)                                "revenue recycling of import tax to RE investments (wind, solar, storage): investments in wind, solar and storage equal (i) investments from reference scenario with tax and no revenue recycling plus (ii) the revenues received from the tax"
;
$endif.importtaxrc
*** EOF ./modules/21_tax/on/declarations.gms
