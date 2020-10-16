*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** satisfy dependencies
$ifi not %cm_rcp_scen% == 'rcp26' $ifi not %cm_rcp_scen% == 'rcp85' abort "module downscaleTemperature=CMIP5 requires cm_rcp_scen={rcp26,rcp85}. As the differences in downscaling are not large across RCPs, you may just want to comment out this abort.";

***$ifi not (%cm_rcp_scen% == 'rcp26') abort "module downscaleTemperature=CMIP5 requires cm_rcp_scen={rcp26,rcp85}. As the differences in downscaling are not large across RCPs, you may just want to comment out this abort.";

*** load temperature downscaling parameters 
*** 09172019: reads in H12 files based on BS's R downscaling routine using fixed 2010 populations - could also use the file with changing populations (...SSPpopgrid...) - currently only available for SSP2 - same applies below for 2005 temperatures
*** for other regional settings the downscaling has to be redone offline
parameter f16_tempRegionalCMIP5(all_rcp_scen,ttot,all_regi)   "XXX"
/ 
$ondelim
*$include "./modules/16_downscaleTemperature/CMIP5/input/p16_tempRegional_H12.inc"
$include "./modules/16_downscaleTemperature/CMIP5/input/p16_tempRegional_H12_BSinR_pop2010.inc"
*$include "./modules/16_downscaleTemperature/CMIP5/input/p16_tempRegional_H12_BSinR_SSPpopgrid_REMINDtimes.inc"
$offdelim
/
;

p16_tempRegionalCMIP5(ttot,regi) = f16_tempRegionalCMIP5("%cm_rcp_scen%",ttot,regi);

parameter f16_tempGlobalCMIP5(all_rcp_scen,ttot)  "XXX"
/
$ondelim
$include "./modules/16_downscaleTemperature/CMIP5/input/p16_tempGlobal.inc"
$offdelim
/
;
p16_tempGlobalCMIP5(ttot) = f16_tempGlobalCMIP5("%cm_rcp_scen%",ttot);

parameter p16_tempRegionalCalibrate2005(all_regi)  "XXX"
/
$ondelim
*$include "./modules/16_downscaleTemperature/CMIP5/input/p16_tempRegional2005_H12.inc"
$include "./modules/16_downscaleTemperature/CMIP5/input/p16_tempRegional2005_H12_BSinR_pop2010.inc"
*$include "./modules/16_downscaleTemperature/CMIP5/input/p16_tempRegional2005_H12_BSinR_SSPpopgrid_REMINDtimes.inc"
$offdelim
/
;

*** regional temperature scaling
*** scale factor (called kappa in Supplement to Schultes et al. (2017)): 
pm_tempScaleGlob2Reg(ttot, regi)$(ttot.val ge 2005) =   
	     ( p16_tempRegionalCMIP5(ttot,regi) - p16_tempRegionalCMIP5("2000",regi) )
	    /( p16_tempGlobalCMIP5(ttot) - p16_tempGlobalCMIP5("2000") )
;
display pm_tempScaleGlob2Reg;

*** interpolate (I use this many times, this should be a function. is there a better way to do this in GAMS?)
loop(ttot$(ttot.val ge 2005) ,
    loop(tall$(pm_tall_2_ttot(tall, ttot) and tall.val le 2100),
	    pm_tempScaleGlob2Reg(tall,regi) =
		(1 - pm_interpolWeight_ttot_tall(tall)) * pm_tempScaleGlob2Reg(ttot,regi)
		+ pm_interpolWeight_ttot_tall(tall) * pm_tempScaleGlob2Reg(ttot + 1,regi);
));
*** keep constant from 2090 on
pm_tempScaleGlob2Reg(tall,regi)$(tall.val gt 2090) = pm_tempScaleGlob2Reg("2090",regi);



