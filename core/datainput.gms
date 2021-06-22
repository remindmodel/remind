*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/datainput.gms

*AJS* technical. initialize parameters so that they are read from gdx
vm_co2eq.l(ttot,regi) = 0;
vm_emiAll.l(ttot,regi,enty) = 0;

*AJS* initialize parameter (avoid compilation errors)
* do this at the start of datainput to prevent accidental overwriting
pm_SolNonInfes(regi) = 1; !! assume the starting point came from a feasible solution
pm_capCum0(ttot,regi,teLearn)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = 0;

pm_globalMeanTemperature(tall)              = 0;
pm_globalMeanTemperatureZeroed1900(tall)    = 0;
pm_temperatureImpulseResponseCO2(tall,tall) = 0;

pm_regionalTemperature(tall,regi)      = 0;
pm_tempScaleGlob2Reg(tall,regi)        = 1;
pm_damage(tall,regi)                   = 1;
pm_damageGrowthRate(tall,regi)         = 0;
pm_damageMarginal(tall,regi)           = 0;

*AL* Initialise to avoid compilation errors in presolve if variable not in input.gdx
vm_demFeForEs.L(t,regi,entyFe,esty,teEs) = 0;
vm_demFeForEs.L(t,regi,fe2es(entyFe,esty,teEs)) = 0.1;

if (cm_emiscen ne 8,
cm_damage = 0.0;
);

*------------------------------------------------------------------------------------
***                        calculations based on sets
*------------------------------------------------------------------------------------
pm_ttot_val(ttot) = ttot.val;
p_tall_val(tall) = tall.val;

pm_ts(ttot) = (pm_ttot_val(ttot+1)-(pm_ttot_val(ttot-1)))/2;
pm_ts("1900") = 2.5;
$if setGlobal END2110 pm_ts(ttot)$(ord(ttot) eq card(ttot)-1) =  pm_ts(ttot-1) ;
pm_ts(ttot)$(ord(ttot) eq card(ttot)) = 27;
pm_dt("1900") = 5;
pm_dt(ttot)$(ttot.val > 1900) = ttot.val - pm_ttot_val(ttot-1);
display pm_ts, pm_dt;


loop(ttot,
    loop(tall$((ttot.val le tall.val) AND (pm_ttot_val(ttot+1) ge tall.val)),
         pm_interpolWeight_ttot_tall(tall) = ( p_tall_val(tall) - pm_ttot_val(ttot) ) / ( pm_ttot_val(ttot+1) - pm_ttot_val(ttot) );
    );
);


pm_tall_2_ttot(tall, ttot)$((ttot.val lt tall.val) AND (pm_ttot_val(ttot+1) gt tall.val)) = Yes;
pm_ttot_2_tall(ttot,tall)$((ttot.val = tall.val) ) = Yes;

*** define pm_prtp according to cm_prtpScen:
if(cm_prtpScen eq 1, pm_prtp(regi) = 0.01);
if(cm_prtpScen eq 3, pm_prtp(regi) = 0.03);

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                macro-economy
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
*** load population data
table f_pop(tall,all_regi,all_POPscen)        "Population data"
$ondelim
$include "./core/input/f_pop.cs3r"
$offdelim
;
pm_pop(tall,all_regi) = f_pop(tall,all_regi,"%cm_POPscen%") / 1000;  !! rescale unit from [million people] to [billion] people

*** load labour data
table f_lab(tall,all_regi,all_POPscen)        "Labour data"
$ondelim
$include "./core/input/f_lab.cs3r"
$offdelim
;
pm_lab(tall,all_regi) = f_lab(tall,all_regi,"%cm_POPscen%") / 1000; !! rescale unit from [million people] to [billion] people

display pm_pop, pm_lab;

*** load PPP-MER conversion factor data
parameter pm_shPPPMER(all_regi)        "PPP ratio for calculating GDP|PPP from GDP|MER"
/
$ondelim
$include "./core/input/pm_shPPPMER.cs4r"
$offdelim
/
;

*** load GDP data
table f_gdp(tall,all_regi,all_GDPscen)        "GDP data"
$ondelim
$include "./core/input/f_gdp.cs3r"
$offdelim
;
pm_gdp(tall,all_regi) = f_gdp(tall,all_regi,"%cm_GDPscen%") * pm_shPPPMER(all_regi) / 1000000;  !! rescale from million US$ to trillion US$

*** load level of development
table f_developmentState(tall,all_regi,all_GDPpcScen) "level of development based on GDP per capita"
$ondelim
$include "./core/input/f_developmentState.cs3r"
$offdelim
;
p_developmentState(tall,all_regi) = f_developmentState(tall,all_regi,"%c_GDPpcScen%");


*** Load information from BAU run
Execute_Loadpoint 'input'      vm_cesIO, vm_invMacro;

pm_gdp_gdx(ttot,regi)    = vm_cesIO.l(ttot,regi,"inco");
p_inv_gdx(ttot,regi)     = vm_invMacro.l(ttot,regi,"kap");

*** permit price initilization
pm_pricePerm(ttot) = 0;


*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                ESM
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------

*** default conversion for energy services
pm_fe2es(ttot,regi,teEs) = 1;
pm_shFeCes(ttot,regi,enty,in,teEs) = 0;

*** initialize upper and lower bound to FE share parameters as zero (this will leave any FE share bounds non-activated)
*** please set FE share bounds by modying this parameter in the sectormodules, e.g. 36_buildings and 37_industry datainput files
pm_shfe_up(ttot,regi,entyFe,sector)=0;
pm_shfe_lo(ttot,regi,entyFe,sector)=0;
pm_shGasLiq_fe_up(ttot,regi,sector)=0;
pm_shGasLiq_fe_lo(ttot,regi,sector)=0;


***---------------------------------------------------------------------------
*** Import and set global data
***---------------------------------------------------------------------------
table fm_dataglob(char,all_te)  "energy technology characteristics: investment costs, O&M costs, efficiency, learning rates ..."
$include "./core/input/generisdata_tech.prn"
;

!! Modify spv and storspv parameters for optimistic VRE supply assumptions
if (cm_VRE_supply_assumptions eq 1,
  if (fm_dataglob("learn","spv") ne 0.207,
    abort "fm_dataglob('learn','spv') is to be modified, but changed externally";
  else
    fm_dataglob("learn","spv") = 0.257;
  );

  if (fm_dataglob("inco0","storspv") ne 9000,
    abort "fm_dataglob('inco0','storspv') is to be modified, but changed externally";
  else
    fm_dataglob("inco0","storspv") = 7000;
  );

  if (fm_dataglob("incolearn","storspv") ne 6240,
    abort "fm_dataglob('incolearn','storspv') is to be modified, but changed externally";
  else
    fm_dataglob("incolearn","storspv") = 4240;
  );

  if (fm_dataglob("learn","storspv") ne 0.10,
    abort "fm_dataglob('learn','storspv') is to be modified, but changed externally";
  else
    fm_dataglob("learn","storspv") = 0.12;
  );
elseif cm_VRE_supply_assumptions eq 2,
  if (fm_dataglob("incolearn","spv") ne 5060,
    abort "fm_dataglob('incolearn','spv') is to be modified, but changed externally";
  else
    fm_dataglob("incolearn","spv") = 5010;
  );
elseif cm_VRE_supply_assumptions eq 3,
  if (fm_dataglob("incolearn","spv") ne 5060,
    abort "fm_dataglob('incolearn','spv') is to be modified, but changed externally";
  else
    fm_dataglob("incolearn","spv") = 4960;
  );
);

parameter p_inco0(ttot,all_regi,all_te)     "regionalized technology costs Unit: USD$/KW"
/
$ondelim
$include "./core/input/p_inco0.cs4r"
$offdelim
/
;
*CG* setting regional technology cost to be the same for wind offshore as onshore
$IFTHEN.WindOff %cm_wind_offshore% == "1"
p_inco0(ttot,regi,"windoff") = p_inco0(ttot,regi,"wind");
$ENDIF.WindOff

*JH* SSP energy technology scenario
table f_dataglob_SSP1(char,all_te)        "Techno-economic assumptions consistent with SSP1"
$include "./core/input/generisdata_tech_SSP1.prn"
;
table f_dataglob_SSP5(char,all_te)        "Techno-economic assumptions consistent with SSP5"
$include "./core/input/generisdata_tech_SSP5.prn"
;
*JH* New nuclear assumption for SSP5
if (cm_nucscen eq 6,
  f_dataglob_SSP5("inco0","tnrs") = 6270; !! increased from 4000 to 6270 with the update of technology costs in REMIND 1.7 to keep the percentage increase between SSP2 and SSP5 constant
);
if (c_techAssumptScen eq 2,
               fm_dataglob(char,te) = f_dataglob_SSP1(char,te)
);
if (c_techAssumptScen eq 3,
               fm_dataglob(char,te) = f_dataglob_SSP5(char,te)
);

display fm_dataglob;

***INNOPATHS
$if not "%cm_INNOPATHS_incolearn%" == "off" parameter p_new_incolearn(all_te) / %cm_INNOPATHS_incolearn% /;
$if not "%cm_INNOPATHS_incolearn%" == "off" fm_dataglob("incolearn",te)$p_new_incolearn(te)=p_new_incolearn(te);
$if not "%cm_INNOPATHS_inco0Factor%" == "off" parameter p_new_inco0Factor(all_te) / %cm_INNOPATHS_inco0Factor% /;
$if not "%cm_INNOPATHS_inco0Factor%" == "off" fm_dataglob("inco0",te)$p_new_inco0Factor(te)=p_new_inco0Factor(te)*fm_dataglob("inco0",te);


*RP* the new cost data in generisdata_tech is now in $2015. As long as the model runs in $2005, these values have first to be converted to D2005 by dividing by 1.2 downwards
fm_dataglob("inco0",te)              = sm_D2015_2_D2005 * fm_dataglob("inco0",te);
fm_dataglob("incolearn",te)          = sm_D2015_2_D2005 * fm_dataglob("incolearn",te);
fm_dataglob("omv",te)                = sm_D2015_2_D2005 * fm_dataglob("omv",te);
p_inco0(ttot,regi,te)               = sm_D2015_2_D2005 * p_inco0(ttot,regi,te);

*RP* rescale the global CSP investment costs in REMIND: Originally we assume a SM3/12h setup, while the cost data from IEA for the short term seems rather based on a SM2/6h setup (with 40% average CF)
*** Accordingly, also decrease long-term costs in REMIND to 0.7 of the current values
fm_dataglob("inco0","csp")              = 0.7 * fm_dataglob("inco0","csp");
fm_dataglob("incolearn","csp")          = 0.7 * fm_dataglob("incolearn","csp");

*JH* Determine CCS injection rates
*LP* for c_ccsinjecratescen =0 the storing variable vm_co2CCS will be fixed to 0 in bounds.gms, the sm_ccsinjecrate=0 will cause a division by 0 error in the 21_tax module
sm_ccsinjecrate = 0.005
if (c_ccsinjecratescen eq 2, sm_ccsinjecrate = sm_ccsinjecrate *   0.50 ); !! Lower estimate
if (c_ccsinjecratescen eq 3, sm_ccsinjecrate = sm_ccsinjecrate *   1.50 ); !! Upper estimate
if (c_ccsinjecratescen eq 4, sm_ccsinjecrate = sm_ccsinjecrate * 200    ); !! remove flow constraint for DAC runs
if (c_ccsinjecratescen eq 5, sm_ccsinjecrate = sm_ccsinjecrate *   0.20 ); !! sustainable estimate

$include "./core/input/generisdata_flexibility.prn"

fm_dataglob("inco0",te)              = sm_DpKW_2_TDpTW       * fm_dataglob("inco0",te);
fm_dataglob("incolearn",te)          = sm_DpKW_2_TDpTW       * fm_dataglob("incolearn",te);
fm_dataglob("omv",te)                = s_DpKWa_2_TDpTWa      * fm_dataglob("omv",te);
p_inco0(ttot,regi,te)               = sm_DpKW_2_TDpTW       * p_inco0(ttot,regi,te);


table fm_dataemiglob(all_enty,all_enty,all_te,all_enty)  "read-in of emissions factors co2,cco2"
$include "./core/input/generisdata_emi.prn"
;

pm_esCapCost(tall,all_regi,all_teEs) = 0;

parameter pm_share_ind_fesos(tall,all_regi)					"Share of coal solids (coaltr) used in the industry (rest is residential)"
/
$ondelim
$include "./core/input/p_share_ind_fesos.cs4r"
$offdelim
/
;

parameter pm_share_ind_fesos_bio(tall,all_regi)				"Share of biomass solids (biotr) used in the industry (rest is residential)"
/
$ondelim
$include "./core/input/p_share_ind_fesos_bio.cs4r"
$offdelim
/
;

parameter pm_share_ind_fehos(tall,all_regi)					"Share of heating oil used in the industry (rest is residential)"
/
$ondelim
$include "./core/input/p_share_ind_fehos.cs4r"
$offdelim
/
;
*** initialize pm_share_trans with the global value, will be updated after each negishi/nash iteration
pm_share_trans("2005",regi) = 0.617;
pm_share_trans("2010",regi) = 0.625;
pm_share_trans("2015",regi) = 0.626;
pm_share_trans("2020",regi) = 0.642;
pm_share_trans("2025",regi) = 0.684;
pm_share_trans("2030",regi) = 0.710;
pm_share_trans("2035",regi) = 0.727;
pm_share_trans("2040",regi) = 0.735;
pm_share_trans("2045",regi) = 0.735;
pm_share_trans("2050",regi) = 0.742;
pm_share_trans("2055",regi) = 0.736;
pm_share_trans("2060",regi) = 0.751;
pm_share_trans("2070",regi) = 0.774;
pm_share_trans("2080",regi) = 0.829;
pm_share_trans("2090",regi) = 0.810;
pm_share_trans("2100",regi) = 0.829;
pm_share_trans("2110",regi) = 0.818;
pm_share_trans("2130",regi) = 0.865;
pm_share_trans("2150",regi) = 0.872;


*JH* CO2 capture rate of CCS technologies (new SSP5 assumptions)
if (c_ccscapratescen eq 2,
  fm_dataemiglob("pecoal","seel","igccc","co2")    = 0.2;
  fm_dataemiglob("pecoal","seel","igccc","cco2")   = 25.9;
  fm_dataemiglob("pecoal","seel","pcc","co2")      = 0.2;
  fm_dataemiglob("pecoal","seel","pcc","cco2")     = 25.9;
  fm_dataemiglob("pecoal","seel","coalh2c","co2")  = 0.2;
  fm_dataemiglob("pecoal","seel","coalh2c","cco2") = 25.9;
$ifthen "%c_SSP_forcing_adjust%" == "forcing_SSP5"
   fm_dataemiglob("pegas","seel","ngccc","co2")  = 0.1;
   fm_dataemiglob("pegas","seel","ngccc","co2")  = 0.1;
   fm_dataemiglob("pegas","seel","ngccc","co2")  = 0.1;
   fm_dataemiglob("pegas","seel","ngccc","cco2") = 15.2;
   fm_dataemiglob("pegas","seh2","gash2c","co2")  = 0.1;
   fm_dataemiglob("pegas","seh2","gash2c","cco2") = 15.2;
$endif
);
*nb* specific emissions of transformation technologies (co2 in gtc/zj -> conv. gtc/twyr):
fm_dataemiglob(enty,enty2,te,"co2")$pe2se(enty,enty2,te)       = 1/s_zj_2_twa * fm_dataemiglob(enty,enty2,te,"co2");
fm_dataemiglob(enty,enty2,te,"cco2")                           = 1/s_zj_2_twa * fm_dataemiglob(enty,enty2,te,"cco2");

table f_datarenglob(char,rlf,*)                    "global nur and ren data"
$include "./core/input/generisdata_nur_ren.prn"
;
table f_dataetaglob(tall,all_te)                      "global eta data"
$include "./core/input/generisdata_varying_eta.prn"
;

* Read in mac historical emissions to calibrate MAC reference emissions
parameter p_histEmiMac(tall,all_regi,all_enty)    "historical emissions per MAC"
/
$ondelim
$include "./core/input/p_histEmiMac.cs4r"
$offdelim
/
;
* Read in historical emissions per sector to calibrate MAC reference emissions
parameter p_histEmiSector(tall,all_regi,all_enty,emi_sectors,sector_types)    "historical emissions per sector"
/
$ondelim
$include "./core/input/p_histEmiSector.cs4r"
$offdelim
/
;


***---------------------------------------------------------------------------
*** Import and set regional data
***---------------------------------------------------------------------------

*RP* 2012-07-24: CO2-technologies don't have own emissions, but the pipeline leakage rate (s_co2pipe_leakage) is multiplied on the individual pe2se
s_co2pipe_leakage = 0.01;

loop(emi2te(enty,enty2,te,enty3)$teCCS(te),
    fm_dataemiglob(enty,enty2,te,"co2")  = fm_dataemiglob(enty,enty2,te,"co2") + fm_dataemiglob(enty,enty2,te,"cco2") * s_co2pipe_leakage ;
    fm_dataemiglob(enty,enty2,te,"cco2") = fm_dataemiglob(enty,enty2,te,"cco2") * (1 - s_co2pipe_leakage );
);

*** Allocate emission factors to pm_emifac
pm_emifac(ttot,regi,enty,enty2,te,"co2")$emi2te(enty,enty2,te,"co2")   = fm_dataemiglob(enty,enty2,te,"co2");
pm_emifac(ttot,regi,enty,enty2,te,"cco2")$emi2te(enty,enty2,te,"cco2") = fm_dataemiglob(enty,enty2,te,"cco2");
*JeS scale N2O energy emissions to EDGAR
pm_emifac(ttot,regi,enty,enty2,te,"n2o")$emi2te(enty,enty2,te,"n2o") = 0.905 * fm_dataemiglob(enty,enty2,te,"n2o");

*JeS from IPCC http://www.ipcc-nggip.iges.or.jp/public/gp/bgp/2_2_Non-CO2_Stationary_Combustion.pdf:
*JeS CH4: 300 kg/TJ = 0.3 Mt/EJ * 31.536 EJ/TWa = 9.46 Mt /TWa
*JeS N2O: 1 kg/TJ = 0.001 Mt/EJ * 31.536 EJ/TWa = 0.031536 Mt / TWa
*** coal 1.4 kg/TJ = 0.04415 Mt/TWa
*** gas 0.1 kg/TJ = 0.00315 Mt/TWa
*** oil 0.6 kg/TJ = 0.01892 Mt/TWa
*** biomass 4 kg/TJ = 0.12614 Mt/TWa;
*** EF for N2O are in generisdata_emi.prn
pm_emifac(t,regi,"pecoal","sesofos","coaltr","ch4") = 9.46 * (1-pm_share_ind_fesos("2005",regi));
pm_emifac(t,regi,"pebiolc","sesobio","biotr","ch4") = 9.46 * (1-pm_share_ind_fesos_bio("2005",regi));

display pm_emifac;

*MLB* initialization needed as include file represents only parameters that are different from zero
p_boundtmp(ttot,all_regi,te,rlf)$(ttot.val ge 2005)       = 0;
p_bound_cap(ttot,all_regi,te,rlf)$(ttot.val ge 2005)       = 0;

*NB* include data and parameters for upper bounds on fossil fuel transport
parameter f_IO_trade(tall,all_regi,all_enty,char)        "Energy trade bounds based on IEA data"
/
$ondelim
$include "./core/input/f_IO_trade.cs4r"
$offdelim
/
;
pm_IO_trade(ttot,regi,enty,char) = f_IO_trade(ttot,regi,enty,char) * sm_EJ_2_TWa;

*LB* use scaled data for export to guarantee net trade = 0 for each traded good
loop(tradePe,
    loop(t,
       if(sum(regi2, pm_IO_trade(t,regi2,tradePe,"Xport")) ne 0,
            pm_IO_trade(t,regi,tradePe,"Xport") = pm_IO_trade(t,regi,tradePe,"Xport") * sum(regi2, pm_IO_trade(t,regi2,tradePe,"Mport")) / sum(regi2, pm_IO_trade(t,regi2,tradePe,"Xport"));
       );
    );
);
display pm_IO_trade;

***nicolasb*DOT* FILE produced from D:\projekte\rose\resources\fossilGrades_nico.m; 2011,12,16;12:14:44
***nicolasb*DOT* original data from literature (Brandt 2009, Charpentier 2009)
***nicolasb*DOT* data files are available at RD3 drive roseBob_finSSP.xls
***nicolasb*DOT* tbd the script is available in the common script folder
***nicolasb*DOT* The parameter describes the extra CO2 emissions from fuel extraction on top of the PE combustion emissions
***nicolasb*DOT* the units are: GtC per TWa
***nicolasb*DOT* ATTENTION: the data given here must crrespond with the mapping emi2fuelMine(enty,enty2,rlf)
p_cint(regi,"co2","peoil","4")=0.0475647000;
p_cint(regi,"co2","peoil","5")=0.1078133200;
p_cint(regi,"co2","peoil","6")=0.1775748800;
p_cint(regi,"co2","peoil","7")=0.2283105600;
p_cint(regi,"co2","peoil","8")=0.4153983800;

$IFTHEN.WindOff %cm_wind_offshore% == "1"
*CG* set wind offshore (also its storage and grid) to be the same as wind onshore (later should be integrated into input data)
fm_dataglob(char,"windoff") = fm_dataglob(char,"wind");
fm_dataglob(char,"storwindoff") = fm_dataglob(char,"storwind");
fm_dataglob(char,"gridwindoff") = fm_dataglob(char,"gridwind");
$ENDIF.WindOff

*** Use global data as standard for regionalized data:
pm_data(all_regi,char,te) = fm_dataglob(char,te);
*NB* display

** historical installed capacity
*** read-in of pm_histCap.cs3r
$Offlisting
table   pm_histCap(tall,all_regi,all_te)     "historical installed capacity"
$ondelim
$include "./core/input/pm_histCap.cs3r"
$offdelim
;

$IFTHEN.WindOff %cm_wind_offshore% == "1"
pm_histCap(tall,all_regi,"windoff") = 0;
$ENDIF.WindOff

$Onlisting
*** historical PE installed capacity
*** read-in of p_PE_histCap.cs3r
table p_PE_histCap(tall,all_regi,all_enty,all_enty)     "historical installed capacity"
$ondelim
$include "./core/input/p_PE_histCap.cs3r"
$offdelim
;

*** installed capacity availability
*** read-in of f_cf.cs3r
$Offlisting
table   f_cf(tall,all_regi,all_te)     "installed capacity availability"
$ondelim
$include "./core/input/f_cf.cs3r"
$offdelim
;
$Onlisting


*CG* setting wind off capacity factor to be the same as onshore here (test)
$IFTHEN.WindOff %cm_wind_offshore% == "1"
f_cf(ttot,regi,"windoff") = f_cf(ttot,regi,"wind");
$ENDIF.WindOff

pm_cf(ttot,regi,te) =  f_cf(ttot,regi,te);
*RP short-term fix: set capacity factors here by hand, because the input data procudure won't be updated in time
pm_cf(ttot,regi,"apcardiefft") = 1;
pm_cf(ttot,regi,"apcardieffH2t") = 1;
***pm_cf(ttot,regi,"h2turbVRE") = 0.15;
pm_cf(ttot,regi,"elh2VRE") = 0.6;
*short-term fix for new synfuel td technologies
pm_cf(ttot,regi,"tdsyngas") = 0.65;
pm_cf(ttot,regi,"tdsynhos") = 0.6;
pm_cf(ttot,regi,"tdsynpet") = 0.7;
pm_cf(ttot,regi,"tdsyndie") = 0.7;

*RP* again, short-term fix for the update of the VRE-integration hydrogen/electrolysis parameters:
pm_cf(ttot,regi,"h2turbVRE") = 0.05;
pm_cf(ttot,regi,"h2turb") = 0.05;

*RP* phasing down the ngt cf to "peak load" cf of 0.036
pm_cf(ttot,regi,"ngt")$(ttot.val eq 2030) = 0.8 * pm_cf(ttot,regi,"ngt");
pm_cf(ttot,regi,"ngt")$(ttot.val eq 2035) = 0.7 * pm_cf(ttot,regi,"ngt");
pm_cf(ttot,regi,"ngt")$(ttot.val eq 2040) = 0.5 * pm_cf(ttot,regi,"ngt");
pm_cf(ttot,regi,"ngt")$(ttot.val ge 2045) = 0.4 * pm_cf(ttot,regi,"ngt");



*** FS: set CF of additional t&d H2 for buildings and industry to t&d H2 stationary value
pm_cf(ttot,regi,"tdh2b") = pm_cf(ttot,regi,"tdh2s");
pm_cf(ttot,regi,"tdh2i") = pm_cf(ttot,regi,"tdh2s");

table pm_earlyreti_adjRate(all_regi,all_te)  "extra retirement rate for technologies in countries with relatively old fleet"
$ondelim
$include "./core/input/p_earlyRetirementAdjFactor.cs3r"
$offdelim
;

***---------------------------------------------------------------------------
*RP* calculate omegs and opTimeYr2te
***---------------------------------------------------------------------------
*RP* use new lifetimes defined in generisdata_tech.prn:
pm_omeg(regi,opTimeYr,te) = 0;

*** FS: use lifetime of tdh2s for tdh2b and tdh2i technologies
*** which are only helper technologies for consistent H2 use in industry and buildings
pm_data(regi,"lifetime","tdh2i") = pm_data(regi,"lifetime","tdh2s");
pm_data(regi,"lifetime","tdh2b") = pm_data(regi,"lifetime","tdh2s");

loop(regi,
        p_aux_lifetime(regi,te) = 5/4 * pm_data(regi,"lifetime",te);
        loop(te,

                loop(opTimeYr,
                        pm_omeg(regi,opTimeYr,te) = 1 - ((opTimeYr.val-0.5) / p_aux_lifetime(regi,te))**4 ;
                        opTimeYr2te(te,opTimeYr)$(pm_omeg(regi,opTimeYr,te) > 0 ) =  yes;
                        if( pm_omeg(regi,opTimeYr,te) <= 0,
                                pm_omeg(regi,opTimeYr,te) = 0;
                                opTimeYr2te(te,opTimeYr) =  no;
                        );
                )
        );
);

*LB* calculate mapping tsu2opTimeYr
alias(ttot, tttot);
tsu2opTimeYr(ttot,opTimeYr) =  no;
tsu2opTimeYr(ttot,"1") =  yes;
loop(ttot,
   loop(opTimeYr,
      loop(tttot $(ord(tttot) le ord(ttot)),
         if(opTimeYr.val = pm_ttot_val(ttot)-pm_ttot_val(tttot)+1,
            tsu2opTimeYr(ttot,opTimeYr) =  yes;
         );
      );
   );
);

display pm_omeg,opTimeYr2te, tsu2opTimeYr;

p_tsu2opTimeYr_h(ttot,opTimeYr) = 0;
p_tsu2opTimeYr_h(ttot,opTimeYr) $tsu2opTimeYr(ttot,opTimeYr) = 1 ;
pm_tsu2opTimeYr(ttot,opTimeYr)$tsu2opTimeYr(ttot,opTimeYr)
= sum(opTimeYr2 $ (ord(opTimeYr2) le ord(opTimeYr)), p_tsu2opTimeYr_h(ttot,opTimeYr2));

display pm_tsu2opTimeYr;

file diagnosis_opTimeYr2te;
put diagnosis_opTimeYr2te;
put "mapping opTimeYr2te, automatically filled in generisdata.inc from the lifetimes given in generisdata.prn" //;
put "te", @15, "regi", @20, "opTimeYr", @27,  "pm_data(regi,'lifetime',te)", @60, "p_aux_lifetime"//;
loop(regi,
        loop(te,
                loop(opTimeYr2te(te,opTimeYr),
                        p_aux_tlt(te) = ord(opTimeYr);
                )
                put te.tl, @ 15, regi.tl, @20, p_aux_tlt(te):3:0, @35, pm_data(regi,"lifetime",te):3:0 , @65, p_aux_lifetime(regi,te):3:0 /;
        )
);
putclose diagnosis_opTimeYr2te;



*RP* safety check that no technology has zero life time - this should give a run-time error if omeg=0 for the first time step
*RP* also check the previous calculation that pm_omeg is not >0 for a opTimeYr value greater than contained in opTimeYr2te
*RP* for diagnosis, uncomment the putfile lines and you will find out which technologies have wrong inputs in generissets or generisdatadatacap
loop(regi,
  loop(te,
    p_aux_check_omeg(te) = 1/pm_omeg(regi,'1',te);
    p_aux_tlt_max(te) = 0;
    loop(opTimeYr$(opTimeYr2te(te,opTimeYr)),
      p_aux_tlt_max(te) = p_aux_tlt_max(te) + 1
    );
    if(p_aux_tlt_max(te) < 20,
      loop(opTimeYr$(ord(opTimeYr) = p_aux_tlt_max(te)),
        if(pm_omeg(regi,opTimeYr+1,te) > 0,
          p_aux_check_tlt(te) = 1/0;
        );
      );
    );
  );
);

*RP* calculate annuity of a technology
p_discountedLifetime(te) = sum(opTimeYr, (sum(regi, pm_omeg(regi,opTimeYr,te))/sum(regi,1)) / 1.06**opTimeYr.val );
p_teAnnuity(te) = 1/p_discountedLifetime(te) ;

display p_discountedLifetime, p_teAnnuity;

*** read in data on electric vehicles used as bound on vm_cap.up(t,regi,"apCarElT","1")
parameter pm_boundCapEV(tall,all_regi)     "installed capacity of electric vehicles"
/
$ondelim
$include "./core/input/pm_boundCapEV.cs4r"
$offdelim
/
;

*** read in data on Nuclear capacities used as bound on vm_cap.fx("2015",regi,"tnrs","1"), vm_deltaCap.fx("2020",regi,"tnrs","1") and vm_deltaCap.up("2025" and "2030")
parameter pm_NuclearConstraint(ttot,all_regi,all_te)       "parameter with the real-world capacities, construction and plans"
/
$ondelim
$include "./core/input/pm_NuclearConstraint.cs4r"
$offdelim
/
;
*** avoid negative additions requiremnet for 2020
loop(regi,
if(pm_NuclearConstraint("2020",regi,"tnrs")<0,
    pm_NuclearConstraint("2020",regi,"tnrs")=0;
);
);



*** read in data on CCS capacities used as bound on vm_co2CCS.up("2020",regi,"cco2","ico2","ccsinje","1")
parameter pm_boundCapCCS(all_regi)        "installed and planed capacity of CCS"
/
$ondelim
$include "./core/input/pm_boundCapCCS.cs4r"
$offdelim
/
;

*** read in indicators on whether CCS is used in 2025 and 2030 (0 = no)
parameter p_boundCapCCSindicator(all_regi)        "CCS used in until 2030"
/
$ondelim
$include "./core/input/p_boundCapCCSindicator.cs4r"
$offdelim
/
;

*** read in CO2 emisisons for 2010, used to fix vm_emiTe.up("2010",regi,"co2")
parameter p_boundEmi(tall,all_regi)        "domestic CO2 emissions that are allowed in 2010 Unit: GtC"
/
$ondelim
$include "./core/input/p_boundEmi.cs4r"
$offdelim
/
;
*** read in F-Gas emissions
parameter f_emiFgas(tall,all_regi,all_SSP_forcing_adjust,all_rcp_scen,all_delayPolicy,all_enty)        "F-gas emissions by single gases from IMAGE"
/
$ondelim
$include "./core/input/f_emiFgas.cs4r"
$offdelim
/
;


parameter p_abatparam_CH4(tall,all_regi,all_enty,steps)        "MAC costs for CH4 by source"
/
$ondelim
$include "./core/input/p_abatparam_CH4.cs4r"
$offdelim
/
;
parameter p_abatparam_N2O(tall,all_regi,all_enty,steps)        "MAC costs for N2O by source"
/
$ondelim
$include "./core/input/p_abatparam_N2O.cs4r"
$offdelim
/
;
parameter p_abatparam_CO2(tall,all_enty,steps)    "MAC costs for CO2 by source"
/
$ondelim
$include "./core/input/p_abatparam_CO2.cs4r"
$offdelim
/
;
p_abatparam_CH4(tall,all_regi,all_enty,steps)$(ord(steps) gt 201) = p_abatparam_CH4(tall,all_regi,all_enty,"201");
p_abatparam_N2O(tall,all_regi,all_enty,steps)$(ord(steps) gt 201) = p_abatparam_N2O(tall,all_regi,all_enty,"201");

parameter p_emiFossilFuelExtr(all_regi,all_enty)          "methane emissions, needed for the calculation of p_efFossilFuelExtr"
/
$ondelim
$include "./core/input/p_emiFossilFuelExtr.cs4r"
$offdelim
/
;

$if %cm_LU_emi_scen% == "SSP1"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0047/sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP2"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0079/sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP5"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0066/sm_EJ_2_TWa;
*BS* added SDP, copied SSP1 number
$if %cm_LU_emi_scen% == "SDP"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0047/sm_EJ_2_TWa;

*DK* In case REMIND is coupled to MAgPIE emissions are obtained from the MAgPIE reporting. Thus, emission factors are set to zero
$if %cm_MAgPIE_coupling% == "on" p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0;

display p_efFossilFuelExtr;

pm_dataren(regi,"nur",rlf,te)     = f_datarenglob("nur",rlf,te);
pm_dataren(regi,"maxprod",rlf,te) = sm_EJ_2_TWa * f_datarenglob("maxprod",rlf,te);

*RP* hydro, spv and csp get maxprod for all regions and grades from external file
table f_maxProdGradeRegiHydro(all_regi,char,rlf)                  "input of regionalized maximum from hydro [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGradeRegiHydro.cs3r"
$offdelim
;
pm_dataren(all_regi,"maxprod",rlf,"hydro") = sm_EJ_2_TWa * f_maxProdGradeRegiHydro(all_regi,"maxprod",rlf);
pm_dataren(all_regi,"nur",rlf,"hydro")     = f_maxProdGradeRegiHydro(all_regi,"nur",rlf);

*CG* separating input of wind onshore and offshore
table f_maxProdGradeRegiWindOn(all_regi,char,rlf)                  "input of regionalized maximum from wind onshore [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGradeRegiWindOn.cs3r"
$offdelim
;

pm_dataren(all_regi,"maxprod",rlf,"wind") = sm_EJ_2_TWa * f_maxProdGradeRegiWindOn(all_regi,"maxprod",rlf);
pm_dataren(all_regi,"nur",rlf,"wind")     = f_maxProdGradeRegiWindOn(all_regi,"nur",rlf);


$IFTHEN.WindOff %cm_wind_offshore% == "1"
table f_maxProdGradeRegiWindOff(all_regi,char,rlf)                  "input of regionalized maximum from wind offshore [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGradeRegiWindOff.cs3r"
$offdelim
;
pm_dataren(all_regi,"maxprod",rlf,"windoff") = sm_EJ_2_TWa * f_maxProdGradeRegiWindOff(all_regi,"maxprod",rlf);
pm_dataren(all_regi,"nur",rlf,"windoff")     = f_maxProdGradeRegiWindOff(all_regi,"nur",rlf);

p_shareWindPotentialOff2On(all_regi) = sum(rlf,f_maxProdGradeRegiWindOff(all_regi,"maxprod",rlf)) /
                      sum(rlf,f_maxProdGradeRegiWindOn(all_regi,"maxprod",rlf));

p_shareWindOff(ttot)$(ttot.val le 2015) = 0;
p_shareWindOff(ttot)$((ttot.val ge 2020) AND (ttot.val le 2025)) = 0.1;
p_shareWindOff(ttot)$((ttot.val ge 2030) AND (ttot.val le 2035)) = 0.3;
p_shareWindOff(ttot)$((ttot.val ge 2040) AND (ttot.val le 2045)) = 0.45;
p_shareWindOff(ttot)$((ttot.val ge 2050) AND (ttot.val le 2060)) = 0.65;
p_shareWindOff(ttot)$((ttot.val ge 2065) AND (ttot.val le 2080)) = 0.7;
p_shareWindOff(ttot)$((ttot.val ge 2085) AND (ttot.val le 2100)) = 0.8;
p_shareWindOff(ttot)$((ttot.val gt 2100)) = 0.9;

$ENDIF.WindOff


table f_dataRegiSolar(all_regi,char,all_te,rlf)                  "input of regionalized data for solar"
$ondelim
$include "./core/input/f_dataRegiSolar.cs3r"
$offdelim
;
pm_dataren(all_regi,"maxprod",rlf,"csp")    = sm_EJ_2_TWa * f_dataRegiSolar(all_regi,"maxprod","csp",rlf);
pm_dataren(all_regi,"maxprod",rlf,"spv")    = sm_EJ_2_TWa * f_dataRegiSolar(all_regi,"maxprod","spv",rlf);
pm_dataren(all_regi,"nur",rlf,"csp")        = f_dataRegiSolar(all_regi,"nur","csp",rlf);
pm_dataren(all_regi,"nur",rlf,"spv")        = f_dataRegiSolar(all_regi,"nur","spv",rlf);
p_datapot(all_regi,"limitGeopot",rlf,"pesol") = f_dataRegiSolar(all_regi,"limitGeopot","spv",rlf);
pm_data(all_regi,"luse","spv")              = f_dataRegiSolar(all_regi,"luse","spv","1")/1000;



table f_maxProdGeothermal(all_regi,char)                  "input of regionalized maximum from geothermal [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGeothermal.cs3r"
$offdelim
;

pm_dataren(all_regi,"maxprod","1","geohdr") = 1e-5; !!minimal production potential

pm_dataren(all_regi,"maxprod","1","geohdr")$f_maxProdGeothermal(all_regi,"maxprod") = sm_EJ_2_TWa * f_maxProdGeothermal(all_regi,"maxprod");
*** FS: temporary fix: set minimum geothermal potential across all regions to 10 PJ (still negligible even in small regions) to get rid of infeasibilities
***pm_dataren(all_regi,"maxprod","1","geohdr")$(f_maxProdGeothermal(all_regi,"maxprod") <= 0.01) = sm_EJ_2_TWa * 0.01;


*mh* set 'nur' for all non renewable technologies to '1':
pm_dataren(regi,"nur",rlf,teNoRe)    = 1;

display p_datapot, pm_dataren;

***---------------------------------------------------------------------------
*** calculate average capacity factors for renewables in 2015
*** --------------------------------------------------------------------------



loop(regi,
  loop(teReNoBio(te),
    p_aux_capToDistr(regi,te) = pm_histCap("2015",regi,te)$(pm_histCap("2015",regi,te) gt 1e-10);
    s_aux_cap_remaining = p_aux_capToDistr(regi,te);
*RP* fill up the renewable grades to calculate the total capacity needed to produce the amount calculated in initialcap2, assuming the best grades are filled first (with 20% of each grade not yet used)

    loop(teRe2rlfDetail(te,rlf)$(pm_dataren(regi,"nur",rlf,te) > 0),
      if(s_aux_cap_remaining > 0,
        p_aux_capThisGrade(regi,te,rlf) = min(s_aux_cap_remaining, ( (pm_dataren(regi,"maxprod",rlf,te) * 0.8) / pm_dataren(regi,"nur",rlf,te) ) );
        s_aux_cap_remaining         = s_aux_cap_remaining - p_aux_capThisGrade(regi,te,rlf);
      );
    );  !! teRe2rlfDetail

	p_avCapFac2015(regi,te) = sum(teRe2rlfDetail(te,rlf), p_aux_capThisGrade(regi,te,rlf) * pm_dataren(regi,"nur",rlf,te) )
								/ ( sum(teRe2rlfDetail(te,rlf), p_aux_capThisGrade(regi,te,rlf) ) + 1e-10)
  );    !! teReNoBio
);      !! regi


display p_aux_capToDistr, s_aux_cap_remaining, p_aux_capThisGrade, p_avCapFac2015, p_inco0;

parameter p_histCapFac(tall,all_regi,all_te)     "Capacity factor (fraction of the year that a plant is running) of installed capacity in 2015"
/
$ondelim
$include "./core/input/p_histCapFac.cs4r"
$offdelim
/
;


*** RP rescale wind capacity factors in REMIND to account for very different real-world CF (potentially partially due to assumed low-wind turbine set-ups in the NREL data)
*** Because of the lag effect (turbines in the 2000s were much smaller and thus yielded lower CFs), only implement half of the calculated ratio of historic to REMIND capFac as rescaling for the new CFs - realised as (x+1)/2

*cb* CF calibration analogously for wind and spv: calibrate 2015, and assume gradual phase-in of grade-based CF (until 2045 for wind, until 2030 for spv)
p_aux_capacityFactorHistOverREMIND(regi,"wind")$p_avCapFac2015(regi,"wind") =  p_histCapFac("2015",regi,"wind") / p_avCapFac2015(regi,"wind");

loop(t$(t.val ge 2015 AND t.val le 2045 ),
pm_cf(t,regi,"wind") =
(2045 - pm_ttot_val(t)) / 30 * p_aux_capacityFactorHistOverREMIND(regi,"wind") *pm_cf(t,regi,"wind")
+
(pm_ttot_val(t) - 2015) / 30 * pm_cf(t,regi,"wind")
);

*CG* set storwindoff and gridwindoff to be the same as storwind and gridwind
$IFTHEN.WindOff %cm_wind_offshore% == "1"
pm_cf(t,regi,"storwindoff") = pm_cf(t,regi,"storwind");
pm_cf(t,regi,"gridwindoff") = pm_cf(t,regi,"gridwind");
$ENDIF.WindOff

p_aux_capacityFactorHistOverREMIND(regi,"spv")$p_avCapFac2015(regi,"spv") =  p_histCapFac("2015",regi,"spv") / p_avCapFac2015(regi,"spv");
pm_cf("2015",regi,"spv") = pm_cf("2015",regi,"spv") * p_aux_capacityFactorHistOverREMIND(regi,"spv");
pm_cf("2020",regi,"spv") = pm_cf("2020",regi,"spv") * (p_aux_capacityFactorHistOverREMIND(regi,"spv")+1)/2;
pm_cf("2025",regi,"spv") = pm_cf("2025",regi,"spv") * (p_aux_capacityFactorHistOverREMIND(regi,"spv")+3)/4;

*** RP rescale CSP capacity factors in REMIND - in the DLR resource data input files, the numbers are based on a SM3/12h setup, while the cost data from IEA seems rather based on a SM2/6h setup (with 40% average CF)
*** Accordingly, decrease CF in REMIND to 2/3 of the DLR values (no need to correct maxprod, as here no miscalculation of total energy yield takes place, in contrast to wind)
loop(te$sameas(te,"csp"),
  pm_dataren(regi,"nur",rlf,te)     = pm_dataren(regi,"nur",rlf,te)     * 2/3 ;
);

display p_aux_capacityFactorHistOverREMIND, pm_dataren;


*** FS: sensitivity scenarios for renewable potentials
$ifthen.VREPot_Factor not "%c_VREPot_Factor%" == "off"
  loop(te$(p_VREPot_Factor(te)),
    pm_dataren(regi,"maxprod",rlf,te)$( NOT( p_aux_capThisGrade(regi,te,rlf))) = pm_dataren(regi,"maxprod",rlf,te) * p_VREPot_Factor(te);
  );
$endif.VREPot_Factor





*** -----------------------------------------------------------------

pm_dataeta(tall,regi,te) = f_dataetaglob(tall,te);

*RP* 20100620 adjust which technologies have time-varying etas
display f_dataetaglob;
display teEtaIncr;
loop(te,
        teEtaIncr(te) = no;
        teEtaIncr(te) = yes$(f_dataetaglob('1900',te) > 0);
);
display teEtaIncr;

*** import regionalized CCS constraints:
table pm_dataccs(all_regi,char,rlf)                       "maximum CO2 storage capacity using CCS technology. Unit: GtC"
$ondelim
$include "./core/input/pm_dataccs.cs3r"
$offdelim
;

***-----------------------------------------------------------------------------
*** adjustment cost parameter
***-----------------------------------------------------------------------------
***RP 20100531 import regional offset for adjustment cost calculations
parameter p_adj_deltacapoffset(tall,all_regi,all_te)     "adjustment cost offset to prevent delay of capacity addition"
/
$ondelim
$include "./core/input/p_adj_deltacapoffset.cs4r"
$offdelim
/
;
p_adj_deltacapoffset("2015",regi,"tnrs")= 1;

$IFTHEN.WindOff %cm_wind_offshore% == "1"
p_adj_deltacapoffset(t,regi,"windoff")= p_adj_deltacapoffset(t,regi,"wind");
$ENDIF.WindOff

***additional deltacapoffset on electric vehicles, based on latest data
p_adj_deltacapoffset("2020",regi,"apCarElT") = 0.3 * pm_boundCapEV("2019",regi);
p_adj_deltacapoffset("2025",regi,"apCarElT") = 2   * pm_boundCapEV("2019",regi);

$ifthen.vehiclesSubsidies not "%cm_vehiclesSubsidies%" == "off"
*** disabling electric vehicles delta cap offset for European regions as BEV installed capacity for these regions is a consequence of subsidies instead of a hard coded values.
p_adj_deltacapoffset("2020",regi,"apCarElT")$(regi_group("EUR_regi",regi)) = 0;
p_adj_deltacapoffset("2025",regi,"apCarElT")$(regi_group("EUR_regi",regi)) = 0;
$endIf.vehiclesSubsidies

*** share of PE2SE capacities in 2005 depends on GDP-MER
p_adj_seed_reg(t,regi) = pm_gdp(t,regi) * 1e-4;

loop(ttot$(ttot.val ge 2005),
  p_adj_seed_te(ttot,regi,te)                = 1.00;
  p_adj_seed_te(ttot,regi,teCCS)             = 0.25;
  p_adj_seed_te(ttot,regi,"igcc")            = 0.50;
  p_adj_seed_te(ttot,regi,"tnrs")            = 0.25;
  p_adj_seed_te(ttot,regi,"hydro")           = 0.25;
  p_adj_seed_te(ttot,regi,"csp")             = 0.25;
  p_adj_seed_te(ttot,regi,"spv")             = 2.00;
  p_adj_seed_te(ttot,regi,"gasftrec")        = 0.25;
  p_adj_seed_te(ttot,regi,"gasftcrec")       = 0.25;
  p_adj_seed_te(ttot,regi,"coalftrec")       = 0.25;
  p_adj_seed_te(ttot,regi,"coalftcrec")      = 0.25;
  p_adj_seed_te(ttot,regi,"coaltr")          = 4.00;
  p_adj_seed_te(ttot,regi,'apCarH2T')        = 1.00;
  p_adj_seed_te(ttot,regi,'apCarElT')        = 1.00;
  p_adj_seed_te(ttot,regi,'apCarDiEffT')     = 0.50;
  p_adj_seed_te(ttot,regi,'apCarDiEffH2T')   = 0.50;
  p_adj_seed_te(ttot,regi,'dac')             = 0.25;
*RP: for comparison of different technologies:
*** pm_conv_cap_2_MioLDV <- 650  # The world has slightly below 800million cars in 2005 (IEA TECO2), so with a global vm_cap of 1.2, this gives ~650
*** ==> 1TW power plant ~ 650 million LDV

  p_adj_coeff(ttot,regi,te)                = 0.2;
  p_adj_coeff(ttot,regi,"pc")              = 0.5;
  p_adj_coeff(ttot,regi,"ngcc")            = 0.5;
  p_adj_coeff(ttot,regi,"igcc")            = 0.5;
  p_adj_coeff(ttot,regi,"coaltr")          = 0.1;
  p_adj_coeff(ttot,regi,"tnrs")            = 1.0;
  p_adj_coeff(ttot,regi,"hydro")           = 1.0;
  p_adj_coeff(ttot,regi,teCCS)             = 1.0;
  p_adj_coeff(ttot,regi,"gasftrec")        = 0.4;
  p_adj_coeff(ttot,regi,"gasftcrec")       = 0.8;
  p_adj_coeff(ttot,regi,"coalftrec")       = 0.6;
  p_adj_coeff(ttot,regi,"coalftcrec")      = 0.8;
  p_adj_coeff(ttot,regi,"spv")             = 0.08;
  p_adj_coeff(ttot,regi,"wind")            = 0.08;

$IFTHEN.WindOff %cm_wind_offshore% == "1"
  p_adj_coeff(ttot,regi,"windoff")         = 0.08;
$ENDIF.WindOff

  p_adj_coeff(ttot,regi,"dac")             = 0.8;
  p_adj_coeff(ttot,regi,'apCarH2T')        = 1.0;
  p_adj_coeff(ttot,regi,'apCarElT')        = 1.0;
  p_adj_coeff(ttot,regi,'apCarDiT')        = 1.0;
  p_adj_coeff(ttot,regi,'apCarDiEffT')     = 2.0;
  p_adj_coeff(ttot,regi,'apCarDiEffH2T')   = 2.0;
  p_adj_coeff(ttot,regi,teGrid)            = 0.1;
  p_adj_coeff(ttot,regi,teStor)            = 0.05;
);

***Rescaling adj seed and coeff
$if not "%cm_INNOPATHS_adj_seed_multiplier%" == "off"  p_adj_seed_te(ttot,regi,te) = %cm_INNOPATHS_adj_seed_multiplier% *  p_adj_seed_te(ttot,regi,te);
$if not "%cm_INNOPATHS_adj_coeff_multiplier%" == "off"  p_adj_coeff(ttot,regi,te) = %cm_INNOPATHS_adj_coeff_multiplier% *  p_adj_coeff(ttot,regi,te);

***Overwritting adj seed and coeff
$ifthen not "%cm_INNOPATHS_adj_seed_cont%" == "off"
  p_adj_seed_te(ttot,regi,te)$p_new_adj_seed(te) = p_new_adj_seed(te);
$elseif not "%cm_INNOPATHS_adj_seed%" == "off"
  p_adj_seed_te(ttot,regi,te)$p_new_adj_seed(te) = p_new_adj_seed(te);
$endif

$ifthen not "%cm_INNOPATHS_adj_coeff_cont%" == "off"
  p_adj_coeff(t,regi,te)$p_new_adj_coeff(te) = p_new_adj_coeff(te);
$elseif not "%cm_INNOPATHS_adj_coeff%" == "off"
  p_adj_coeff(t,regi,te)$p_new_adj_coeff(te) = p_new_adj_coeff(te);
$endif

p_adj_coeff(ttot,regi,te)            = 25 * p_adj_coeff(ttot,regi,te);  !! Rescaling all adjustment cost coefficients

p_adj_coeff_Orig(ttot,regi,te)    = p_adj_coeff(ttot,regi,te);
p_adj_seed_te_Orig(ttot,regi,te)  = p_adj_seed_te(ttot,regi,te);

p_adj_coeff_glob(te)        = 0.0;
p_adj_coeff_glob('tnrs')    = 0.0;

*** Unit conversions
p_emi_quan_conv_ar4(enty) = 1;
p_emi_quan_conv_ar4(enty)$(emiMacMagpieCH4(enty)) = sm_tgch4_2_pgc * (25/s_gwpCH4);  !! need to use old GWP for MAC cost conversion as it only reverts what has been done in the calculation of the MACs
p_emi_quan_conv_ar4(enty)$(emiMacMagpieN2O(enty)) = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4(enty)$(emiMacExoCH4(enty)) = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4(enty)$(emiMacExoN2O(enty)) = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("ch4coal")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4gas")     = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4oil")     = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4wstl")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4wsts")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("n2otrans")   = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("n2oadac")    = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("n2onitac")   = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("n2owaste")   = sm_tgn_2_pgc * (298/s_gwpN2O);


*RP* Distribute ccap0 for all regions
pm_data(regi,"ccap0",te) = 1/card(regi)*fm_dataglob("ccap0",te);







*** --------------------------------------------------------------------------------
*** Adjust investment cost data
*** -------------------------------------------------------------------------------

*RP* calculate turnkey costs (which are the sum of the overnight costs in generisdata_tech and the "interest during construction” (IDC) )

*** in the version with regionalized technology costs, also use regionally differentiated financing costs
*** First read in the regional market risks:
parameter p_risk_premium_constr(all_regi)       "risk premium during construction time. Use same values as pm_risk_premium used in module 23_capital markets"
*RP* 2 parameters needed because pm_risk_premium is set to 0 in module 23 realization perfect".
/
$ondelim
$include "./core/input/pm_risk_premium.cs4r"
$offdelim
/
;

*** then calculate the financing costs during construction
loop(te$(fm_dataglob("constrTme",te) > 0),
  p_tkpremused(regi,te) = 1/fm_dataglob("constrTme",te)
    * sum(integ$(integ.val <= fm_dataglob("constrTme",te)),
$if %cm_techcosts% == "REG"  (1.03 + pm_prtp(regi) + p_risk_premium_constr(regi) )  ** (integ.val - 0.5) - 1
$if %cm_techcosts% == "GLO"  (1.03 + pm_prtp(regi) )                                 ** (integ.val - 0.5) - 1
      )
);
*** nuclear sees 3% higher interest rates during construction time due to higher construction time risk, see "The economic future of nuclear power - A study conducted at The University of Chicago" (2004)
loop(te$sameas(te,"tnrs"),
  p_tkpremused(regi,te) = 1/fm_dataglob("constrTme",te)
    * sum(integ$(integ.val <= fm_dataglob("constrTme",te)),
$if %cm_techcosts% == "REG"  (1.03 + 0.03 + pm_prtp(regi) + p_risk_premium_constr(regi) )  ** (integ.val - 0.5) - 1
$if %cm_techcosts% == "GLO"  (1.03 + 0.03 + pm_prtp(regi) )                                 ** (integ.val - 0.5) - 1
      )
);

display p_tkpremused;
***for those technologies, for which differentiated costs are available for 2015-2040, use those
***$if %cm_techcosts% == "REG"   loop(teRegTechCosts(te)$(not teLearn(te)),
***$if %cm_techcosts% == "REG"   pm_inco0_t(ttot,regi,te)$(ttot.val ge 2015 AND ttot.val lt 2040) = p_inco0(ttot,regi,te);
***$if %cm_techcosts% == "REG"   pm_inco0_t(ttot,regi,te)$(ttot.val ge 2040) = p_inco0("2040",regi,te);
***$if %cm_techcosts% == "REG"   );

***$if %cm_techcosts% == "REG"   pm_inco0_t(ttot,regi,te)$(ttot.val ge 2015 AND ttot.val lt 2040) = p_inco0(ttot,regi,te);






pm_data(regi,"inco0",te)       = (1 + p_tkpremused(regi,te) ) * pm_data(regi,"inco0",te);
pm_data(regi,"incolearn",te)   = (1 + p_tkpremused(regi,te) ) * pm_data(regi,"incolearn",te);
p_inco0(ttot,regi,teRegTechCosts)  = (1 + p_tkpremused(regi,teRegTechCosts) ) * p_inco0(ttot,regi,teRegTechCosts);
*** take region average p_tkpremused for global convergence price
fm_dataglob("inco0",te)       = (1 + sum(regi, p_tkpremused(regi,te))/sum(regi, 1)) * fm_dataglob("inco0",te);

if( cm_solwindenergyscen = 2,
    loop(te$( sameas(te,"spv") OR sameas(te,"csp") OR sameas(te,"wind") ),
        pm_data(regi,"learn",te)     = 0.8 * pm_data(regi,"learn",te);
    );
    pm_data(regi,"incolearn","csp")  = 0.7 * pm_data(regi,"incolearn","csp") ;
    pm_data(regi,"incolearn","spv")  = 0.6 * pm_data(regi,"incolearn","spv") ;
    pm_data(regi,"incolearn","wind") = 0.3 * pm_data(regi,"incolearn","wind");
);

if( cm_solwindenergyscen = 3,
    loop(te$( sameas(te,"spv") OR sameas(te,"csp") OR sameas(te,"wind") ),
        pm_data(regi,"learn",te)     = 0;
    );
);

***calculate default floor costs for learning technologies
pm_data(regi,"floorcost",teLearn(te)) = pm_data(regi,"inco0",te) - pm_data(regi,"incolearn",te);


*** In case regionally differentiated investment costs should be used the corresponding entries are revised:
$if %cm_techcosts% == "REG"   pm_data(regi,"inco0",teRegTechCosts) = p_inco0("2015",regi,teRegTechCosts);
loop(teRegTechCosts$(sameas(teRegTechCosts,"spv") ),
$if %cm_techcosts% == "REG"   pm_data(regi,"inco0",teRegTechCosts) = p_inco0("2020",regi,teRegTechCosts);
);

$if %cm_techcosts% == "REG"   pm_data(regi,"incolearn",teLearn(te)) = pm_data(regi,"inco0",te) - pm_data(regi,"floorcost",te) ;


*** Calculate learning parameters:

*** global exponent
*** parameter calculation for global level, that regional values can gradually converge to
fm_dataglob("learnExp_wFC",teLearn(te)) = fm_dataglob("inco0",te)/fm_dataglob("incolearn",te) * log(1-fm_dataglob("learn", te))/log(2);

*** regional exponent
pm_data(regi,"learnExp_woFC",teLearn(te))    = log(1-pm_data(regi,"learn", te))/log(2);
*RP* adjust exponent parameter learnExp_woFC to take floor costs into account
pm_data(regi,"learnExp_wFC",teLearn(te))     = pm_data(regi,"inco0",te) / pm_data(regi,"incolearn",te) * log(1-pm_data(regi,"learn", te))/log(2);

*** global factor
*** parameter calculation for global level, that regional values can gradually converge to
fm_dataglob("learnMult_wFC",teLearn(te)) = fm_dataglob("incolearn",te)/(fm_dataglob("ccap0",te)**fm_dataglob("learnExp_wFC", te));

*** regional factor
*NB* read in vm_capCum(t0,regi,teLearn) from input.gdx to have info available for the recalibration of 2005 investment costs
Execute_Loadpoint 'input' p_capCum = vm_capCum.l;
*** FS: in case technologies did not exist in gdx, set intial capacities to global initial value
p_capCum(tall,regi,te)$( NOT p_capCum(tall,regi,te)) = fm_dataglob("ccap0",te)/card(regi);
*RP overwrite p_capCum by exogenous values for 2020
p_capCum("2020",regi,"spv")  = 0.6 / card(regi2);  !! roughly 600GW in 2020

pm_data(regi,"learnMult_woFC",teLearn(te))   = pm_data(regi,"incolearn",te)/sum(regi2,(pm_data(regi2,"ccap0",te))**(pm_data(regi,"learnExp_woFC",te)));
*RP* adjust parameter learnMult_woFC to take floor costs into account
$if %cm_techcosts% == "GLO"   pm_data(regi,"learnMult_wFC",teLearn(te))    = pm_data(regi,"incolearn",te)/(sum(regi2,pm_data(regi2,"ccap0",te))**pm_data(regi,"learnExp_wFC",te));
*NB* this is the correction of the original parameter calibration
$if %cm_techcosts% == "REG"   pm_data(regi,"learnMult_wFC",teLearn(te))    = pm_data(regi,"incolearn",te)/(sum(regi2,p_capCum("2015",regi2,te))**pm_data(regi,"learnExp_wFC",te));
*** initialize spv learning curve in 2020
$if %cm_techcosts% == "REG"   pm_data(regi,"learnMult_wFC","spv")    = pm_data(regi,"incolearn","spv")/(sum(regi2,p_capCum("2020",regi2,"spv"))**pm_data(regi,"learnExp_wFC","spv"));

display p_capCum;
display pm_data;

*** end learning parameters

*RP* 2012-03-07: Markup for advanced technologies
table p_costMarkupAdvTech(s_statusTe,tall)              "Multiplicative investment cost markup for early time periods (until 2030) on advanced technologies (CCS, Hydrogen) that are not modeled through endogenous learning"
$include "./core/input/p_costMarkupAdvTech.prn"
;

loop(teNoLearn(te),
    pm_inco0_t(ttot,regi,te) = pm_data(regi,"inco0",te);
    loop(ttot$(ttot.val ge 2005 AND ttot.val < 2035 ),
        pm_inco0_t(ttot,regi,te) =  sum(s_statusTe$(s_statusTe.val eq pm_data(regi,"tech_stat",te) ), p_costMarkupAdvTech(s_statusTe,ttot) * pm_inco0_t(ttot,regi,te) );
    );
);
display pm_inco0_t;

***for those technologies, for which differentiated costs are available for 2015-2040, use those
$if %cm_techcosts% == "REG"   loop(teRegTechCosts(te)$(not teLearn(te)),
$if %cm_techcosts% == "REG"   pm_inco0_t(ttot,regi,te)$(ttot.val ge 2015 AND ttot.val lt 2040) = p_inco0(ttot,regi,te);
$if %cm_techcosts% == "REG"   pm_inco0_t(ttot,regi,te)$(ttot.val ge 2040) = p_inco0("2040",regi,te);
$if %cm_techcosts% == "REG"   );

*** re-insert effect of costMarkupAdvTech for IGCC in the regionalized cost data, as the IEA numbers have unrealistically low IGCC costs in 2005-2020
$if %c_techcosts% == "REG"    loop(teNoLearn(te)$(sameas(te,"igcc"),
$if %c_techcosts% == "REG"      loop(ttot$(ttot.val ge 2005 AND ttot.val < 2035 ),
$if %c_techcosts% == "REG"        pm_inco0_t(ttot,regi,te) = sum(s_statusTe$(s_statusTe.val eq pm_data(regi,"tech_stat",te) ), p_costMarkupAdvTech(s_statusTe,ttot) * pm_inco0_t(ttot,regi,te) );
$if %c_techcosts% == "REG"      );
$if %c_techcosts% == "REG"    );

***linear convergence of investment costs from 2025 on for non-learning technologies,
***so that in 2070 all regions again have the technology cost data that is given in generisdata.prn
$if %cm_techcosts% == "REG"   loop(ttot$(ttot.val ge 2020 AND ttot.val le 2070),
$if %cm_techcosts% == "REG"     pm_inco0_t(ttot,regi,teNoLearn(te)) = ((pm_ttot_val(ttot)-2020)*fm_dataglob("inco0",te)
$if %cm_techcosts% == "REG"                                            + (2070-pm_ttot_val(ttot))*pm_inco0_t("2020",regi,te))/50;
$if %cm_techcosts% == "REG"   );
$if %cm_techcosts% == "REG"   loop(ttot$(ttot.val gt 2070),
$if %cm_techcosts% == "REG"   pm_inco0_t(ttot,regi,teNoLearn(te)) = fm_dataglob("inco0",te);
$if %cm_techcosts% == "REG"   );


*** rename f_datafecostsglob
* p_esCapCost(regi,in)$f_datafecostsglob("lifetime",in)
*                        = (f_datafecostsglob("inco0",in)
*                          + f_datafecostsglob("omf",in) * f_datafecostsglob("lifetime",in)
*                          ) * f_datafecostsglob("eta",in) !! from cost per UE power to cost per FE power
*                        / (f_datafecostsglob("lifetime",in) * f_datafecostsglob("usehr",in)) !! capital costs are levelled over the yearly use
*                        * sm_day_2_hour * sm_year_2_day    !! from $/TWh to $/TWa.
*                        ;




*** -----------------------------------------------------------------------------
*** ------------ emission budgets and their time periods ------------------------
*** -----------------------------------------------------------------------------

*** definition of budgets on energy emissions in GtC and associated time period
s_t_start        = 2005;
$IFTHEN.test setglobal test_TS
sm_endBudgetCO2eq      = 2090;
$ELSE.test
sm_endBudgetCO2eq      = 2110;
$ENDIF.test
*cb single budget should cover the full modeling time, as otherwise CO2 prices show strange behaviour around 2100 (and rest of behaviour is also biased by foresight of cap-free post 2100)
if (cm_emiscen eq 6,
sm_endBudgetCO2eq      = 2150;
);

sm_budgetCO2eqGlob = 20000.0000;

*JeS values for multigasscen = 1 are only estimates which may not meet the forcing target, only those for multigasscen = 2 have already been tested.
if(cm_emiscen eq 6,
  if(cm_multigasscen eq 1,
$if  "%cm_rcp_scen%" == "rcp20"   sm_budgetCO2eqGlob = 250.0000;
$if  "%cm_rcp_scen%" == "rcp26"   sm_budgetCO2eqGlob = 273.0000;
$if  "%cm_rcp_scen%" == "rcp37"   sm_budgetCO2eqGlob = 350.0000;
$if  "%cm_rcp_scen%" == "rcp45"   sm_budgetCO2eqGlob = 420.0000;
$if  "%cm_rcp_scen%" == "rcp60"   sm_budgetCO2eqGlob = 1000.0000;
$if  "%cm_rcp_scen%" == "rcp85"   sm_budgetCO2eqGlob = 20000.0000;
$if  "%cm_rcp_scen%" == "none"    sm_budgetCO2eqGlob = 20000.0000;
  );
  if(cm_multigasscen eq 2,
$if  "%cm_rcp_scen%" == "rcp20"   sm_budgetCO2eqGlob = 500.0000;
     if(cm_ccapturescen eq 1,
$if  "%cm_rcp_scen%" == "rcp26"   sm_budgetCO2eqGlob = 530.0000;
     );
     if(cm_ccapturescen gt 1,
$if  "%cm_rcp_scen%" == "rcp26"   sm_budgetCO2eqGlob = 700.0000;
     );
$if  "%cm_rcp_scen%" == "rcp37"   sm_budgetCO2eqGlob = 1000.0000;
$if  "%cm_rcp_scen%" == "rcp45"   sm_budgetCO2eqGlob = 1273.0000;
$if  "%cm_rcp_scen%" == "rcp60"   sm_budgetCO2eqGlob = 2700.0000;
$if  "%cm_rcp_scen%" == "rcp85"   sm_budgetCO2eqGlob = 20000.0000;
$if  "%cm_rcp_scen%" == "none"    sm_budgetCO2eqGlob = 20000.0000;
  );
);

if(cm_iterative_target_adj eq 1,
***only one long budget period for scenarios with iterative adjustment of budget, so that p_referencebudgetco2 is met from 2000-2100
sm_endBudgetCO2eq      = 2150;
s_referencebudgetco2    = 1500;
sm_budgetCO2eqGlob = 700;
);
display sm_budgetCO2eqGlob;
***-----------------------------------------------------------------------------

p_datacs(regi,"peoil") = 0;   !! RP: 0 turn off the explicit calculation of non-energy use, as it is included in the oil total. Emission correction happens through rescaling of fm_dataemiglob



*cb 20120405 reference CO2eq emissions in 2030 from all Kyoto gases, in Gt CO2eq, for iterative modPol scenario
if(cm_emiscen eq 9 AND cm_iterative_target_adj eq 1, s_reference2030co2eq    = 60.8;
);

***------------------------------------------------------------------------------------
***                                ESM  MAC data
***------------------------------------------------------------------------------------
if(c_macscen eq 2,
  pm_macSwitch(emiMacSector)  = 0;
);
  pm_macSwitch("ch4wstl") = 1;
  pm_macSwitch("ch4wsts") = 1;
if(c_macscen eq 1,
  pm_macSwitch(emiMacSector) = 1;
);
*pm_macCostSwitch(enty)=pm_macSwitch(enty);

*** for NDC and NPi switch off landuse MACs
$if %carbonprice% == "NDC2018"  pm_macSwitch(emiMacMagpie) = 0;
$if %carbonprice% == "NPi2018"  pm_macSwitch(emiMacMagpie) = 0;

*DK* LU emissions are abated in MAgPIE in coupling mode
*** An alternative to the approach below could be to introduce a new value for c_macswitch that only deactivates the LU MACs
$if %cm_MAgPIE_coupling% == "on"  pm_macSwitch(enty)$emiMacMagpie(enty) = 0;
*** As long as there is hardly any CO2 LUC reduction in MAgPIE we dont need MACs in REMIND
$if %cm_MAgPIE_coupling% == "off"  pm_macSwitch("co2luc") = 0;

pm_macCostSwitch(enty)=pm_macSwitch(enty);
pm_macSwitch("co2cement_process") =0 ;
pm_macCostSwitch("co2cement_process") =0 ;

*** load econometric emission data
*** read in p3 and p4
table p_emineg_econometric(all_regi,all_enty,p)        "parameters for ch4 and n2o emissions from waste baseline and co2 emissions from cement production"
$ondelim
$include "./core/input/p_emineg_econometric.cs3r"
$offdelim
;
p_emineg_econometric(regi,"co2cement_process","p4")$(p_emineg_econometric(regi,"co2cement_process","p4") eq 0) = sm_eps;
p_emineg_econometric(regi,enty,"p1") = 0;
p_emineg_econometric(regi,enty,"p2") = 0;
*** p2 is calculated in presolve

parameter p_macBase2005(all_regi,all_enty)        "baseline emissions of mac options in 2005"
/
$ondelim
$include "./core/input/p_macBase2005.cs4r"
$offdelim
/
;
parameter p_macBase1990(all_regi,all_enty)     "baseline emissions of mac options in 1990"
/
$ondelim
$include "./core/input/p_macBase1990.cs4r"
$offdelim
/
;
parameter p_macBaseVanv(tall,all_regi,all_enty)        "baseline emissions of N2O from transport, adipic acid production, and nitric acid production based on data from van Vuuren"
/
$ondelim
$include "./core/input/p_macBaseVanv.cs4r"
$offdelim
/
;

parameter f_macBaseExo(tall,all_regi,all_enty,all_LU_emi_scen)        "baseline emissions of N2O and CH4 from landuse based on exogenous data"
/
$ondelim
$include "./core/input/f_macBaseExo.cs4r"
$offdelim
/
;
p_macBaseExo(ttot,regi,emiMacExo(enty))$(ttot.val ge 2005) = f_macBaseExo(ttot,regi,emiMacExo,"%cm_LU_emi_scen%");

$if %cm_MAgPIE_coupling% == "off" parameter f_macBaseMagpie(tall,all_regi,all_enty,all_LU_emi_scen,all_rcp_scen)    "baseline emissions of N2O and CH4 from landuse based on data from Magpie"
$if %cm_MAgPIE_coupling% == "on"  parameter f_macBaseMagpie_coupling(tall,all_regi,all_enty)                        "baseline emissions of N2O and CH4 from landuse based on data from Magpie"
/
$ondelim
$if %cm_MAgPIE_coupling% == "off" $include "./core/input/f_macBaseMagpie.cs4r"
$if %cm_MAgPIE_coupling% == "on"  $include "./core/input/f_macBaseMagpie_coupling.cs4r"
$offdelim
/
;
$if %cm_MAgPIE_coupling% == "off" p_macBaseMagpie(ttot,regi,emiMacMagpie(enty))$(ttot.val ge 2005) = f_macBaseMagpie(ttot,regi,emiMacMagpie,"%cm_LU_emi_scen%","%cm_rcp_scen%");
$if %cm_MAgPIE_coupling% == "on"  p_macBaseMagpie(ttot,regi,emiMacMagpie(enty))$(ttot.val ge 2005) = f_macBaseMagpie_coupling(ttot,regi,emiMacMagpie);

*** p_macPolCO2luc defines the lower limit for abatement of CO2 landuse change emissions in REMIND
*** The values are derived from MAgPIE runs with very strong mitigation
parameter p_macPolCO2luc(tall,all_regi)                "co2 emissions from landuse change with strong mitigation in MAgPIE"
/
$ondelim
$include "./core/input/p_macPolCO2luc.cs4r"
$offdelim
/
;

*** ----- Emission factor of final energy carriers -----------------------------------
*** demand side emission factor of final energy carriers in MtCO2/EJ
*** www.eia.gov/oiaf/1605/excel/Fuel%20EFs_2.xls
p_ef_dem(regi,entyFe) = 0;
p_ef_dem(regi,"fedie") = 69.3;
p_ef_dem(regi,"fehos") = 69.3;
p_ef_dem(regi,"fepet") = 68.5;
p_ef_dem(regi,"fegas") = 50.3;
p_ef_dem(regi,"fesos") = 90.5;

$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off"
*** demand side emission factor of final energy carriers in MtCO2/EJ
*** https://www.umweltbundesamt.de/sites/default/files/medien/1968/publikationen/co2_emission_factors_for_fossil_fuels_correction.pdf
  loop(ext_regi$altFeEmiFac_regi(ext_regi),
    p_ef_dem(regi,entyFe)$(regi_group(ext_regi,regi)) = 0;
    p_ef_dem(regi,"fedie")$(regi_group(ext_regi,regi)) = 74;
    p_ef_dem(regi,"fehos")$(regi_group(ext_regi,regi)) = 73;
    p_ef_dem(regi,"fepet")$(regi_group(ext_regi,regi)) = 73;
    p_ef_dem(regi,"fegas")$(regi_group(ext_regi,regi)) = 55;
    p_ef_dem(regi,"fesos")$(regi_group(ext_regi,regi)) = 96;
  );

*** Changing Germany and France refineries emission factors to avoid negative emissions on pe2se (changing from 18.4 to 20 zeta joule = 20/31.7098 = 0.630719841 Twa = 0.630719841 * 3.66666666666666 * 1000 * 0.03171  GtC/TWa = 73.33 GtC/TWa)
  pm_emifac(ttot,regi,"peoil","seliqfos","refliq","co2")$(sameas(regi,"DEU") OR sameas(regi,"FRA")) = 0.630719841;
*** Changing Germany and UKI solids emissions factors to be in line with CRF numbers (changing from 26.1 to 29.27 zeta joule = 0.922937989 TWa = 107.31 GtC/TWa)
  pm_emifac(ttot,regi,"pecoal","sesofos","coaltr","co2")$(sameas(regi,"DEU") OR sameas(regi,"UKI")) = 0.922937989;

$endif.altFeEmiFac

pm_emifac(ttot,regi,"segafos","fegas","tdfosgas","co2") = p_ef_dem(regi,"fegas") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"sesofos","fesos","tdfossos","co2") = p_ef_dem(regi,"fesos") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"seliqfos","fehos","tdfoshos","co2") = p_ef_dem(regi,"fehos") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"seliqfos","fepet","tdfospet","co2") = p_ef_dem(regi,"fepet") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"seliqfos","fedie","tdfosdie","co2") = p_ef_dem(regi,"fedie") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa

*** some balances are not matching by small amounts;
*** the differences are cancelled out here!!!
pm_cesdata(ttot,regi,in,"offset_quantity")$(ttot.val ge 2005)       = 0;

*** ----- MAGICC RCP scenario emission data -----------------------------------
*** load default values from the scenario depending on cm_rcp_scen
*** (0): no RCP scenario, standard setting
*** (1): RCP2.6 - this only works with emiscen = 8
*** (2): RCP3.7 - this only works with emiscen = 5
*** (3): RCP4.5 - this only works with emiscen = 5
*** (4): RCP6.0 - this only works with emiscen = 5
*** (5): RCP8.5 - this only works with emiscen = 5
*** (6): RCP2.0 - this only works with emiscen = 8

$include "./core/magicc/magicc_scen_bau.inc";
$include "./core/magicc/magicc_scen_450.inc";
$include "./core/magicc/magicc_scen_550.inc";

*** ----- Parameters needed for MAGICC ----------------------------------------

table p_regi_2_MAGICC_regions(all_regi,RCP_regions_world_bunkers)    "map REMIND to MAGICC regions"
$ondelim
$include "./core/input/p_regi_2_MAGICC_regions.cs3r"
$offdelim
;
p_regi_2_MAGICC_regions(regi,"WORLD") = 1;
p_regi_2_MAGICC_regions(regi,"BUNKERS") = 0;
display p_regi_2_MAGICC_regions ;

***-----------------------------------------------------------------
*RP* vintages
***-----------------------------------------------------------------
table p_vintage_glob_in(opTimeYr,all_te)         "read-in of global historical vintage structure. Unit: arbitrary (automatic rescaling to 1 in REMIND)"
$include "./core/input/generisdata_vintages.prn"
;

*CG* wind offshore has the same vintage structure as onshore
$IFTHEN.WindOff %cm_wind_offshore% == "1"
p_vintage_glob_in(opTimeYr,"windoff") = p_vintage_glob_in(opTimeYr,"wind");
$ENDIF.WindOff

pm_vintage_in(regi,opTimeYr,te) = p_vintage_glob_in(opTimeYr,te);

*RP* 2015-12-09: make sure that all technologies have a pm_vintage_in value > 0 in 2005. If a technology should not be built, this is modeled by
*** setting mix0 = 0, but NOT by setting the vintage value to 0!
*** Setting the vintage value to 0 is error-prone, because it would create an inconsistency between initialcap2 and the calculation of initial 2005 capacities in preloop.
loop(te,
  loop(regi,
    if(pm_vintage_in(regi,"1",te) = 0, pm_vintage_in(regi,"1",te) = 1 )
  );
);


*** -------- initial declaration of parameters for iterative target adjustment
o_reached_until2150pricepath(iteration) = 0;

*** ---- FE demand trajectories for calibration -------------------------------
*** also used for limiting secondary steel demand in baseline and policy
*** scenarios
Parameter
  pm_fedemand   "final energy demand"
  /
$ondelim
$include "./core/input/pm_fe_demand.cs4r"
$offdelim
  /
;

$ifthen.subsectors "%industry%" == "subsectors"   !! industry
*** Limit secondary steel production to 90 %.  This might be slightly off due
*** to rounding in the mrremind package.
if (9 lt smax((t,regi,all_GDPscen)$(
                           pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary") ),
           pm_fedemand(t,regi,all_GDPscen,"ue_steel_secondary")
         / pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary")
         ),
  put logfile;
  logfile.nd = 15;
  put ">>> rescaling steel production figures because of mrremind rounding" /;

  loop ((t,regi,all_GDPscen)$(
                           pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary") ),
    if (9 lt ( pm_fedemand(t,regi,all_GDPscen,"ue_steel_secondary")
             / pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary")),

      put t.tl, " ", regi.tl, " ", all_GDPscen.tl, ": ";
      put @20 "(", pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary"), ",";
      put pm_fedemand(t,regi,all_GDPscen,"ue_steel_secondary"), ") -> ";

      pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary")
      = 0.1
      * ( pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary")
        + pm_fedemand(t,regi,all_GDPscen,"ue_steel_secondary")
        );

      pm_fedemand(t,regi,all_GDPscen,"ue_steel_secondary")
      = 9 * pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary");

      put "(", pm_fedemand(t,regi,all_GDPscen,"ue_steel_primary"), ",";
      put pm_fedemand(t,regi,all_GDPscen,"ue_steel_secondary"), ")" /;
    );
  );

  logfile.nd = 3;
  putclose logfile;
);
$endif.subsectors

*** initialize global target deviation scalar
sm_globalBudget_dev = 1;

*** EOF ./core/datainput.gms
