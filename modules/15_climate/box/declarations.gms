*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/declarations.gms

*** ---------- PARAMETERS -----------
parameters
p15_conroh(tall)	"concentration of OH, derived from ACC2",
p15_epsilon(tall)         "discounting parameter of emissions according to the IRF function",
p15_oghgf_pfc(tall)    	"exogenous forcings from RCP all in W/m^2: PFCs",
p15_oghgf_hfc(tall)	 	"exogenous forcings from RCP: HFCs",
p15_oghgf_sf6(tall)		"exogenous forcings from RCP: SF6",
p15_oghgf_montreal(tall)	"exogenous forcings from RCP: montreal gases",
p15_oghgf_o3str(tall)		"exogenous forcings from RCP: stratospheric ozone",
p15_oghgf_luc(tall)		"exogenous forcings from RCP: albedo change due to land-use change",
p15_oghgf_crbbb(tall)		"exogenous forcings from RCP: carbonaceous aerosols from biomass burning",
p15_oghgf_ffbc(tall)		"exogenous forcings from RCP: black carbon from fossil fuels",
p15_oghgf_ffoc(tall)		"exogenous forcings from RCP: organic carbon from fossil fuels",
p15_oghgf_o3trp(tall)		"exogenous forcings from RCP: tropospheric ozone",
p15_oghgf_h2ostr(tall)	"exogenous forcings from RCP: stratospheric water vapor",
p15_oghgf_minaer(tall)	"exogenous forcings from RCP: mineral dust",
p15_oghgf_nitaer(tall)	"exogenous forcings from RCP: nitrates",
p15_so2emi(tall,all_enty)  "parameter to update so2 emissions between iterations",

p15_ta_val(tall)	 "auxiliary parameter",
p15_conroh_interpol(tall)   "auxiliary parameter"
;

*** --------- POSITIVE VARIABLES ---------------
positive variables
v15_conc(tall,FOB10)       "Atmospheric concentrations of direct and indirect forcing agents within the box model"
v15_temp(tall)                "global mean temperature"
v15_tempFast(tall)               "temperature in fast box"
v15_tempSlow(tall)               "temperature in slow box"
v15_slackForc(tall)         "slack variable to calculate forcing overshoot"
;
 
*** ------------- VARIABLES -------------------
variables
v15_forcComp(tall,FOBBOX10) "radiative forcing of box multi forcing agents"
v15_forcKyo(tall)    "radiative forcing of box Kyoto gases"
v15_forcRcp(tall)	 "radiative forcing from agents considered in the RCPs (total forcing excluding LUC, MINAER, NITAER)"

v15_emi(tall,FOB10)       "Anthropogenic emissions (both energy and non-energy related emissions)"
***                        Natural emissions are fixed and treated as parameters.
***                        Units are gas dependent. Units used in the model follows those in IPCC (2001) Appendix A.
***                        CO2             [GtC/yr]
***                        CH4             [TgCH4/yr]
***                        N2O             [TgN/yr]
***                        SO2             [TgS/yr]
***                        (rOH)
***                        (O3TRP)
***                        CF4             [Gg/yr]
***                        C2F6            [Gg/yr]
***                        C4F10           [Gg/yr]
***                        HFC23           [Gg/yr]
***                        HFC32           [Gg/yr]
***                        HFC4310mee      [Gg/yr]
***                        HFC125          [Gg/yr]
***                        HFC134a         [Gg/yr]
***                        HFC143a         [Gg/yr]
***                        HFC152a         [Gg/yr]
***                        HFC227ea        [Gg/yr]
***                        HFC236fa        [Gg/yr]
***                        HFC245ca        [Gg/yr]
***                        SF6             [Gg/yr]
***                        CFC11           [Gg/yr]
***                        CFC12           [Gg/yr]
***                        CFC113          [Gg/yr]
***                        CFC114          [Gg/yr]
***                        CFC115          [Gg/yr]
***                        CCl4            [Gg/yr]
***                        CH3CCl3         [Gg/yr]
***                        Halon1211       [Gg/yr]
***                        Halon1301       [Gg/yr]
***                        Halon2402       [Gg/yr]
***                        HCFC22          [Gg/yr]
***                        HCFC141b        [Gg/yr]
***                        HCFC142b        [Gg/yr]
***                        HCFC123         [Gg/yr]
***                        (CH3Cl)
***                        (CH3Br)
***                        NOx             [TgN/yr]
***                        CO              [TgCO/yr]
***                        VOC             [TgVOC/yr]
***                        (EESC)
;
 
*** ------------- EQUATIONS -------------------
equations
q15_cc(tall)             "carbon cycle with prescriptor-corrector method"
q15_forcso2(tall)        "calculation of direct so2 forcing"
q15_forcbc(tall)			"calculation of bc from fossil fuels forcing"
q15_forcoc(tall)			"calculation of oc from fossil fuels forcing"
q15_forcco2(tall)        "calculation of co2 forcing"
q15_forctotal(tall)      "calculation of total radiative forcing"
q15_forc_kyo(tall)       "calculation of total radiative forcing of Kyoto gases" 
q15_forc_rcp(tall)		"calculation of rcp forcing"
q15_clisys(tall)         "temperature equations"
q15_clisys1(tall)         "temperature equations time scale 1"
q15_clisys2(tall)         "temperature equations time scale 2"
q15_clisys01(tall)         "temperature equations initial condition time scale 1"
q15_clisys02(tall)         "temperature equations initial condition time scale 2"
q15_concN2OQ(tall)       "N2O concentration"
q15_concCH4Q(tall)       "CH4 concentration"
q15_forcCH4Q(tall)       "CH4 radiative forcing"
q15_forcN2OQ(tall)       "N2O radiative forcing"
q15_forc_os(tall)  "calculate forcing overshoot"
q15_linkEMI(ttot, ta10, all_enty, FOB10)         "links total global emissions to the climate system"
$IF %cm_so2_out_of_opt% == "on" q15_linkEMI_aer(ttot, ta10, all_enty, FOB10)         "links total global aerosol emissions to the climate system, if flag cm_so2_out_of_opt is on"
q15_interEMI(ta10, ttot, FOB10)		"interpolates timesteps of core model to one year timesteps"
;

*** ------------- SCALARS -------------------
scalars
*AG* 07102012 the value written here was 114 but was being overwritten later in ACC2_M301_init_future.inc by the new value below
s15_TAUN2O       	nitrous oxide lifetime [yr]                                   /114.3808538025/,
*AG* 07102012 the value written here was 10.2 but was being overwritten later in ACC2_M301_init_future.inc by the new value below
s15_NATN2O           Natural nitrous oxide emission                [TgN per yr]    /11.3395625973/,
*AG* 06132012 the value written here was 210 but was being overwritten later in ACC2_M301_init_future.inc by the new value below
s15_NATCH4       	Natural methane emission                      [TgCH4 per yr]  /319.8994621193/,
s15_c0               preindustrial co2 in ppmv	/277.00000/,
s15_c2000            concentration in 2000 in ppmv (multigas-boxmodel)	/369.5600/,
s15_cconvi           conversions factor gtc into ppmv	/0.47000/,
*** this is the value for remind-r (in remind-g, it is 77.1097)
*** todo: calculate this parameter in the initialcap routine 
s15_so1990           so2 emissions in 1990  (tgs per a)	/57.39272/,
s15_enatso2          natural so2 emissions  (tgs per a)	/42.00000/,
s15_dso1990          direct aerosol forcing in 1900 (w per m2)	/-0.40000/,
s15_iso1990          indirect aerosol forcing in 1900 (w per m2)	/-0.70000/,
s15_bc2005           black carbon emissions from fossil fuels in 2005 (Tg BC)	/5.228/,
s15_oc2005           organic carbon emissions from fossil fuels in 2005 (Tg OC)	/13.66/,
s15_fcodb            radiative forcing for a doubling of co2 (w per m2)	/3.70000/,
s15_tsens            climate sensitivity for a doubling of co2	/3.00000/,
s15_RPCTT1           time scale 1 (temperature response) (per year)	/13.574/,
s15_RPCTT2           time scale 2 (temperature response) (per year)	/328.782/,
s15_RPCTA1           amplitude 1 (temperature response)	/2.010/,
s15_deltat_box       box model time step lenght in yr	/1/,
s15_temp2000         temperature increase in 2000 in K	/0.8323/,
s15_ca0              amplitude 0 of CC IRF	/0.463/,
s15_ca1              amplitude 1 of CC IRF	/0.475/,
s15_ca2              amplitude 2 of CC IRF	/0.0/,
s15_ca3              amplitude 3 of CC IRF	/0.062/,
s15_ctau1            time scale 1 of CC IRF	/20.972/,
s15_ctau2            time scale 2 of CC IRF	/44.186/,
s15_ctau3            time scale 3 of CC IRF	/4.48/,
s15_cq0			  cumulated emissions 1750-1999	/488.347/,
s15_cq1			  cumulated emissions 1750-1999 decayed with s15_ctau1	/377.974/,
s15_cq2			  cumulated emissions 1750-1999 decayed with s15_ctau2	/127.796/,
s15_cq3			  cumulated emissions 1750-1999 decayed with s15_ctau3	/22.284/,
*cb* 20120411 updated to the GWP values of AR4 used in the reporting: 298 ttot CO2eq/ t CH4 and 25 t CO2eq / t N2O
s15_DELTAT          Time step of model run                          [yr]    /1/
*** The model is written only for the time step of 1 year.
*** Do not alter the time step assignment above,
*** which would require the change in the time control statements need adjustments.

*** N2O
s15_CNVN2O          Conversion factor from mass (TgN) to concentration (ppb)        [TgN per ppb]   /4.8/
s15_CONN2O2000R     Reference concentration of nitrous oxide in 2000                [ppb]           /330/
*** Note that the value here is different from the computed value from the past run.
*** The reference value is used only for the N2O concentration equation
*** as calibrated in the sensitivity experiment (see IPCC (2001) Table 4.5).
s15_SENTAUN2O       Sensitivity coefficient of N2O lifetime                         [ln(yr) per ln(ppb)] /-0.046/
*** Methane
s15_CNVCH4          Conversion factor from mass (TgCH4) to concentration (ppb)      [TgCH4 per ppb] /2.746/
*** Concentrations
s15_TAUCH4OH        Methane lifetime with respect to OH depletion       [yr]     /8.5348789101/
s15_TAUCH4SS        Methane lifetime with respect to stratospheric depletion and soil uptake [yr]   /68.2/
s15_RHOCH4          Coefficient for CH4 radiative forcing calculation               [W per (m^2*ppb^0.5)] /0.036/
*** Note to the unit (see the Joos et al. (2001) equation A8).
s15_CONCH4PRE       Preindustrial CH4 concentration                                 [ppb]           /700/
*** (IPCC (2001) Table 6.1)
s15_OVERLFAC1       CH4-N2O overlap modeling factor                                 [W per m^2]     /0.47/
s15_OVERLFAC2       CH4-N2O overlap modeling factor                                 [1]             /2.01e-5/
s15_CONN2OPRE       Preindustrial N2O concentration                                 [ppb]           /270/
*** (IPCC (2001) Table 6.1)
s15_OVERLEXP1       CH4-N2O overlap exponent                                        [1]             /0.75/
s15_OVERLFAC3       CH4-N2O overlap modeling factor                                 [1]             /5.31e-15/
s15_OVERLEXP2       CH4-N2O overlap exponent                                        [1]             /1.52/
s15_RHON2O          Coefficient for N2O radiative forcing calculation               [W per (m^2*ppb^0.5)] /0.12/
*** Note to the unit (see the Joos et al. (2001) equation A10).
s15_RPCTA2          "amplitude 2 (temperature response)",

s15_gr_conc          "CO2 concentration target [ppm]"
s15_gr_forc_os       "overshoot radiative forcing target from 2100 on [W/m^2]",
s15_gr_forc_nte      "not to exceed radiative forcing target [W/m^2]",
s15_gr_forc_kyo      "guardrail for 450 ppm Kyoto forcing, adapted between negishi iterations",
s15_gr_forc_kyo_gdx  "gdx value which may override the default" 
s15_gr_forc_kyo_nte  "guardrail for 550 ppm Kyoto forcing, adapted between negishi iterations"
s15_gr_forc_kyo_nte_gdx "gdx value which may override the default value"
s15_gr_temp          "guardrail for temperature anomaly relative to preindustrial [K]"
s15_diffrad			 "difference in 2100 radiative forcing to target"
;

*** EOF ./modules/15_climate/box/declarations.gms
