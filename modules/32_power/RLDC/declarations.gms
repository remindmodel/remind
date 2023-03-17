*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/RLDC/declarations.gms

parameters
    p32_capFacDem(all_regi)						"Average demand factor of a power sector [0,1]"
    p32_capFacLoB(LoB)							"Capacity factor of a load band [0,1]"
    p32_RLDCcoeff(all_regi,PolyCoeff,RLDCbands)	"Coefficients for the non-separable wind/solar-cross-product polynomial RLDC fit"
    p32_avCapFac(ttot,all_regi,all_te)			"Average load factor (Nur) of the first 5 grades of a technology"
    p32_ResMarg(ttot,all_regi)					"Reserve margin as markup on actual peak capacity [0,1]"
    p32_curtOn(all_regi)						"Control variable for curtailment fitted from the DIMES-Results"
    p32_shCHP(ttot,all_regi)            		"Upper boundary of chp electricity generation"
    p32_grid_factor(all_regi)					"Multiplicative factor that scales total grid requirements down in comparatively small or homogeneous regions like Japan, Europe or India"
    p32_LoBheight0(all_regi,LoB)	            "Load band heights at 0% VRE share (declared here, on the data input file, because it is only used for the p32_capFacDem definition) [0,1]"
;

positive variables
    v32_scaleCap(ttot,all_regi)					"Scale Factor to scale the power capacitites from 'relative to Peak Demand' up to total system level [TW]"
    v32_shTh(ttot,all_regi,all_te)            	"Theoretical share of variable renewable energies [0,1]"
    v32_capLoB(ttot,all_regi,all_te,LoB)      	"Capacity of a technology within one load band relative to peak demand [0,1]"
    v32_capER(ttot,all_regi,all_te)           	"Early retired capacities [0,1]"
    v32_curt(ttot,all_regi)						"Curtailment of power in the RLDC formulation of the power sector [TWa]"
    v32_LoBheight(ttot,all_regi,LoB)          	"Height of each load band relative to Peak Demand [0,1]"
    v32_overProdCF(ttot,all_regi,all_te)      	"Overproduction CF from dispatchable renewable energies (csp and hydro) [0,1]"
    v32_CurtModelminusFit(ttot,all_regi)     	"Difference between model curtailment and fitted curtailment"
    v32_LoBheightCum(ttot,all_regi,LoB)       	"Cumulative height of each load band relative to Peak Demand [0,1]"
    v32_peakCap(ttot,all_regi)                	"Peak capacity after RLDC [0,1]"
    v32_H2cof_PVsh(ttot,all_regi)				"Amount of cofiring of gas/H2 to CSP needed due to correlation with PV"
    v32_H2cof_Lob4(ttot,all_regi)				"Amount of cofiring of gas/H2 to CSP needed due to use of CSP in LoB 4, which has a high CF" 
    v32_H2cof_Lob3(ttot,all_regi)				"Amount of cofiring of gas/H2 to CSP needed due to use of CSP in LoB 3, which has a high CF" 
    v32_H2cof_CSPsh(ttot,all_regi)				"Amount of cofiring of gas/H2 to CSP needed due to self-correlation of CSP"
    v32_sqrtCurt(ttot,all_regi)					"Helper variable: share of the year for which curtailment is higher than 1/3 of maximum curtailment - this is the amount that we assume we can use for producing H2. Because we assume a 1-to-3 ratio of time to capacity for curtailment, it is also used to calculate the curtailed capacity" 
    vm_shSeEl(ttot,all_regi,all_te)				"new share of electricity production in % [%]"
;

variables	
    v32_curtFit(ttot,all_regi)					"Curtailment as fitted from the DIMES-Results" 
    v32_FullIntegrationSlack(ttot,all_regi)		"Slack variable that allows implementation of the 'Full Integration' ADVANCE scenario variation, where we assume no integration challenges for wind and solar, thus no curtailment"
    v32_LoBheightCumExact(ttot,all_regi,LoB)	 "Cumulative height of load bands, calculated from theoretical wind and solar share based on the DIMES fits "   
;

equations
    q32_balSe(ttot,all_regi,all_enty)			"Balance equation for electricity secondary energy"
    q32_usableSe(ttot,all_regi,all_enty)		"Calculate usable se before se2se and MP/XP (without storage)"
    q32_usableSeTe(ttot,all_regi,entySe,all_te) "Calculate usable se produced by one technology (vm_usableSeTe)"
    q32_shTheo(ttot,all_regi,all_te)        	"Calculate theoretical share of wind and solar in power production"
    q32_scaleCapTe(ttot,all_regi,all_te)    	"Calculate upscaled power capacitites from 'relative to peak demand' up to total system level"
    q32_curt(ttot,all_regi)                 	"Calculate total curtailment"
    q32_curtFit(ttot,all_regi)              	"Calculate curtailment from DIMES-fit"
    q32_curtFitwCSP(ttot,all_regi)          	"Calculate curtailment from DIMES-fit, including 0.3 CSP"
    q32_LoBheightCumExact(ttot,all_regi,LoB)	"Calculate height of load bands from theoretical wind and solar share"
    q32_LoBheightCumExactNEW(ttot,all_regi,LoB)	"Calculate the model-used height of load bands, which need to have some slack (=g=) compared to the exact calulcation of v32_LoBheightCumExact to keep v32_LoBheightCum > 0"
    q32_LoBheightExact(ttot,all_regi,LoB)		"Calculate height of load bands from theoretical wind and solar share"
    q32_fillLoB(ttot,all_regi,LoB)          	"Fill Load Bands with power production"
    q32_capFac(ttot,all_regi,all_te)        	"Calculate resulting capacity factor for all power technologies"
    q32_capFacTER(ttot,all_regi,all_te)     	"Make sure that the non-bio renewables observe the limited capacity Factor"
    q32_stor_pv(ttot,all_regi)					"Calculate the short term storage requirements due to renewables"
    q32_peakCap(ttot,all_regi)              	"Calculate peak capacity after RLDC"
    q32_capAdeq(ttot,all_regi)              	"Make sure dispatchable capacities > peak capacity"
    q32_H2cofiring(ttot,all_regi)           	"Calculate co-firing needs"
    q32_H2cof_PVsh(ttot,all_regi)				"Cofiring CSP due to correlation with PV"
    q32_H2cof_LoB4(ttot,all_regi)				"Cofiring CSP due to use in LoB 4" 
    q32_H2cof_LoB3(ttot,all_regi)				"Cofiring CSP due to use in LoB 3"
    q32_H2cof_CSPsh(ttot,all_regi)				"Cofiring CSP due to self-correlation with CSP" 
    q32_curtCapH2(ttot,all_regi)				"Calculate the H2 capacity from curtailed electricity"
    q32_curtProdH2(ttot,all_regi)				"Calculate the H2 production from curtailed electricity"
    q32_sqrtCurt(ttot,all_regi)					"Calculate helper variable: share of the year for which curtailment is higher than 1/3 of maximum curtailment" 
    q32_hydroROR(ttot,all_regi)					"Represent Run-Of-River Hydro by requiring that 20% of produced hydro electricity comes from baseload"
    q32_limitCapTeChp(ttot,all_regi)  			"Capacitiy constraint for chp electricity generation"
    q32_limitCapTeGrid(ttot,all_regi)   		"Calculate the additional grid capacity required by VRE"
    q32_limitSolarWind(tall,all_regi)    		"Limits on fluctuating renewables, only turned on for special EMF27 scenarios"
    q32_shSeEl(ttot,all_regi,all_te)         		"calculate share of electricity production of a technology (vm_shSeEl)"
;

*** EOF ./modules/32_power/RLDC/declarations.gms
