*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/datainput.gms

*** load carbon price trajectory from reference run (NPi scenario)
Execute_Loadpoint "input_ref" p45_taxCO2eq_bau = pm_taxCO2eq;

*** initialize carbon price trajectory before target adjustment iterations by setting carbon price to NPi
pm_taxCO2eq(t,regi) = p45_taxCO2eq_bau(t,regi);


*** load NDC emissions targets (only fraction of emissions in REMIND region from countries with NDC targets)
Table f45_EmiTargetAbs(tall,all_regi,NDC_version,all_GDPpopScen) "Table for all NDC versions with absolute NDC emissions targets, emissions from countries without targets are not included [Mt CO2eq/yr]"
$offlisting
$ondelim
$include "./modules/45_carbonprice/NDC/input/fm_EmiTargetAbs.cs3r"
$offdelim
$onlisting
;

Parameter p45_EmiTargetAbs(ttot,all_regi) "Absolute NDC emissions targets, emissions from countries without targets are not included [Mt CO2eq/yr]";
p45_EmiTargetAbs(t,all_regi) = f45_EmiTargetAbs(t,all_regi,"%cm_NDC_version%","%cm_GDPpopScen%");

display p45_EmiTargetAbs;

*** >> PRISMA Asymetric rollback: 
**   the delay of NDC targets of "10, 20, or 30 years" per region would be assigned as:
**       10 years delay for Transition leaders: EUR, NEU, JPN (e.g. 2030 NDC shifted to 2040, 2035 target shifter to 2045, and 2050 target shifted to 2060)
**       20 years delay for Diversifying economies: LAM, USA, CAZ, IND, CHA, SSA, OAS
**       30 years delay for Fossil-dependant: REF, MEA

$ifThen "%cm_targetDelay%" == "prisma"


** Test: display delayed NDC targets before delay
display p45_EmiTargetAbs;

Parameter p45_delay(all_regi) /
    EUR 10, NEU 10, JPN 10,
    LAM 20, USA 20, CAZ 20, IND 20, CHA 20, SSA 20, OAS 20,
    REF 35, MEA 35
/;

** For 2026_cond: copy 2030 and 2035 targets to later years based on region delay, set 2030 and 2035 targets to 0
p45_EmiTargetAbs(t,regi)$(t.val eq 2030 + p45_delay(regi)) = p45_EmiTargetAbs("2030",regi);
p45_EmiTargetAbs(t,regi)$(t.val eq 2035 + p45_delay(regi)) = p45_EmiTargetAbs("2035",regi);
p45_EmiTargetAbs(t,regi)$(t.val eq 2030) = 0;
p45_EmiTargetAbs(t,regi)$(t.val eq 2035) = 0;

** Test: display delayed NDC targets after delay
display p45_EmiTargetAbs;

$ENDIF
** << PRISMA Asymetric rollback

Table f45_shareTarget(tall,all_regi,NDC_version,all_GDPpopScen) "Table for all NDC versions with estimated target year GHG emissions share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years [0..1]"
$offlisting
$ondelim
$include "./modules/45_carbonprice/NDC/input/fm_shareTarget.cs3r"
$offdelim
$onlisting
;

Parameter p45_shareTarget(ttot,all_regi) "Estimated target year GHG emissions share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years [0..1]";
p45_shareTarget(t,all_regi) = f45_shareTarget(t,all_regi,"%cm_NDC_version%","%cm_GDPpopScen%");

*** >> PRISMA Asymetric rollback: 
$ifThen "%cm_targetDelay%" == "prisma"

** Test: display delayed NDC sharetargets before delay
display p45_shareTarget;

** For 2026_cond: copy 2030 and 2035 targets to later years based on region delay, set 2030 and 2035 targets to 0
p45_shareTarget(t,regi)$(t.val eq 2030 + p45_delay(regi)) = p45_shareTarget("2030",regi);
p45_shareTarget(t,regi)$(t.val eq 2035 + p45_delay(regi)) = p45_shareTarget("2035",regi);
p45_shareTarget(t,regi)$(t.val eq 2030) = 0;
p45_shareTarget(t,regi)$(t.val eq 2035) = 0;

** Test: display delayed NDC sharetargets after delay
display p45_shareTarget;

$ENDIF
** << PRISMA Asymetric rollback

display p45_shareTarget;

Parameter p45_BAU_reg_emi_wo_LU_wo_bunkers(ttot,all_regi) "regional GHG emissions (without LU and without bunkers) in BAU scenario [MtCO2eq/yr]"
  /
$ondelim
$ifthen exist "./modules/45_carbonprice/NDC/input/pm_BAU_reg_emi_wo_LU_wo_bunkers.cs4r"
$include "./modules/45_carbonprice/NDC/input/pm_BAU_reg_emi_wo_LU_wo_bunkers.cs4r"
$endif
$offdelim
  /             ;

*** --------------------------------------------------------------------------
*** use new GAMS internal variables for total GHG excl LULUCF and excl bunkers

*** overwrite BAU emissions with emissions in GAMS variable from reference GDX
p45_BAU_reg_emi_wo_LU_wo_bunkers(ttot,regi) = 0;
Execute_Loadpoint 'input_ref' p45_BAU_reg_emi_wo_LU_wo_bunkers = v_emiGHG_exclLULUCF_exclBunkers.l;
*** convert from GtCeq/yr to MtCO2eq/yr
p45_BAU_reg_emi_wo_LU_wo_bunkers(ttot,regi) = p45_BAU_reg_emi_wo_LU_wo_bunkers(ttot,regi) * sm_c_2_co2 * 1000;

*** --------------------------------------------------------------------------

*** parameters for selecting NDC years
Set t_NDC_targetYear(ttot)                          "Years for which NDC emissions targets can be applied [0 or 1]" / %cm_NDC_targetYear% /;
Scalar p45_minRatioOfCoverageToMax                  "only targets whose coverage is this times p45_bestNDCcoverage are considered. Use 1 for only best [0..1]" /0/;
Scalar p45_useSingleYearCloseTo                     "if 0: use all. If > 0: use only one single NDC target per country closest to this year (use 2030.4 to prefer 2030 over 2035 over 2025) [year]" /0/;
Set p45_NDCyearSet(ttot,all_regi)                   "YES for years whose NDC targets is used";
Parameter p45_bestNDCcoverage(all_regi)             "highest coverage of NDC targets within region [0..1]";
Parameter p45_distanceToOptyear(ttot,all_regi)      "distance to p45_useSingleYearCloseTo to favor years in case of multiple equally good targets [year]";
Parameter p45_minDistanceToOptyear(all_regi)        "minimal distance to p45_useSingleYearCloseTo per region [year]";


p45_bestNDCcoverage(regi) = smax(t$(t_NDC_targetYear(t)), p45_shareTarget(t,regi));
display p45_bestNDCcoverage;

p45_NDCyearSet(t,regi)$(t_NDC_targetYear(t)) = p45_shareTarget(t,regi) >= p45_minRatioOfCoverageToMax * p45_bestNDCcoverage(regi);

if(p45_useSingleYearCloseTo > 0,
  p45_distanceToOptyear(p45_NDCyearSet(t,regi)) = abs(t.val - p45_useSingleYearCloseTo);
  p45_minDistanceToOptyear(regi) = smin(t$(p45_NDCyearSet(t,regi)), p45_distanceToOptyear(t,regi));
  p45_NDCyearSet(t,regi) = p45_distanceToOptyear(t,regi) = p45_minDistanceToOptyear(regi);
);

*** first and last NDC year as a number
Parameter p45_firstNDCyear(all_regi) "last year with NDC coverage within region [year]";
p45_firstNDCyear(regi) = smin( p45_NDCyearSet(t, regi), t.val );
Parameter p45_lastNDCyear(all_regi)  "last year with NDC coverage within region [year]";
p45_lastNDCyear(regi)  = smax( p45_NDCyearSet(t, regi), t.val );

display p45_NDCyearSet,p45_firstNDCyear,p45_lastNDCyear;

*** switch off MAC abatement of land emissions, scenario should only have Magpie baseline emissions
pm_macSwitch(ttot,regi,emiMacMagpie) = 0;

*** EOF ./modules/45_carbonprice/NDC/datainput.gms
