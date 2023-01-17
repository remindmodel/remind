*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/RLDC/datainput.gms

*------------------------------------------------------------------------------------
***                        RLDC specific data input
*------------------------------------------------------------------------------------

parameter f32_shCHP(ttot,all_regi)    "upper boundary of chp electricity generation"     
/
$ondelim
$include "./modules/32_power/RLDC/input/f32_shCHP.cs4r"
$offdelim
/
;
p32_shCHP(ttot,all_regi) = f32_shCHP(ttot,all_regi) + 0.05;
p32_shCHP(ttot,all_regi)$(ttot.val ge 2050) = min(p32_shCHP("2020",all_regi) + 0.15, 0.75);
p32_shCHP(ttot,all_regi)$((ttot.val gt 2020) and (ttot.val lt 2050)) = p32_shCHP("2020",all_regi) + ((p32_shCHP("2050",all_regi) - p32_shCHP("2020",all_regi)) / 30 * (ttot.val - 2020));


***parameter p32_grid_factor(all_regi) - multiplicative factor that scales total grid requirements down in comparatively small or homogeneous regions like Japan, Europe or India
parameter p32_grid_factor(all_regi)                "multiplicative factor that scales total grid requirements down in comparatively small or homogeneous regions like Japan, Europe or India"
/
$ondelim
$include "./modules/32_power/RLDC/input/p32_grid_factor.cs4r"
$offdelim
/
;

***parameter p32_capFacLoB(LoB) - Capacity factor of a load band (Unit 0..1)		
p32_capFacLoB("1") = 0.08;
p32_capFacLoB("2") = 0.25;
p32_capFacLoB("3") = 0.50;
p32_capFacLoB("4") = 0.86; !! no plant runs longer than 7500 hours - accordingly the height of the base load band is rescaled in q32_LoBheight

***parameter p32_ResMarg(ttot,all_regi) - reserve margin as markup on actual peak capacity. Unit [0..1]
p32_ResMarg(ttot,regi) = 0.30;	

***parameter p32_RLDCcoeff(all_regi,PolyCoeff,RLDCbands) - Coefficients for the non-separable wind/solar-cross-product polynomial RLDC fit
table f32_RLDC_Coeff_LoB(all_regi,RLDCbands,PolyCoeff)    "RLDC coefficients for combined Wind-Solar Polynomial"
$ondelim
$include "./modules/32_power/RLDC/input/f32_RLDC_Coeff_LoB.cs3r"
$offdelim
;
table f32_RLDC_Coeff_Peak(all_regi,RLDCbands,PolyCoeff) "RLDC coefficients for combined Wind-Solar Polynomial"
$ondelim
$include "./modules/32_power/RLDC/input/f32_RLDC_Coeff_Peak.cs3r"
$offdelim
;

loop(regi,
  loop(RLDCbands,
    if( PeakDep(RLDCbands),
      p32_RLDCcoeff(regi,PolyCoeff,RLDCbands) = (f32_RLDC_Coeff_LoB(regi,RLDCbands,PolyCoeff)+f32_RLDC_Coeff_Peak(regi,RLDCbands,PolyCoeff)) / f32_RLDC_Coeff_Peak(regi,"peak","p00");
    else
      p32_RLDCcoeff(regi,PolyCoeff,RLDCbands) = (f32_RLDC_Coeff_LoB(regi,RLDCbands,PolyCoeff)+f32_RLDC_Coeff_Peak(regi,RLDCbands,PolyCoeff)) ;
    )
  );
);

***parameter p32_LoBheight0(all_regi,LoB) - Load band heights at 0% VRE share (Unit 0..1)
loop(LoB,
  p32_LoBheight0(regi,LoB) = p32_RLDCcoeff(regi,"p00",LoB) - p32_RLDCcoeff(regi,"p00",LoB+1)$( LoB.val < card(LoB) );
  if ( ( LoB.val eq card(LoB) ),
    p32_LoBheight0(regi,LoB) = p32_LoBheight0(regi,LoB) * ( 1 / p32_capFacLoB(LoB) );  !! upscale the height of the base-load band to represent the fact that the fit was done with 8760 hours ( = 1), while no plant runs longer than 7500 hours (CF = 0.86)
  )
);          

***parameter p32_capFacDem(all_regi) - Average demand factor of a power sector (Unit 0..1)
p32_capFacDem(regi) = sum(LoB, p32_LoBheight0(regi,LoB) * p32_capFacLoB(LoB) );

loop(regi,
  loop(te$(teReNoBio(te)),
    p32_avCapFac(t,regi,te) = 
       sum(rlf, pm_dataren(regi,"nur",rlf,te) * pm_dataren(regi,"maxprod",rlf,te) ) 
       / ( sum(rlf, pm_dataren(regi,"maxprod",rlf,te) ) + 1e-8) 
	; 
  );
);	

$ontext
loop(regi,
  loop(te$(teReNoBio(te)),
    p32_avCapFac(t,regi,te) = 
*      sum(rlf$(UsedGrades2070(regi,te,rlf)),
       sum(rlf,
         pm_dataren(regi,"nur",rlf,te) * pm_dataren(regi,"maxprod",rlf,te)
        ) 
*        / ( sum(rlf$UsedGrades2070(regi,te,rlf), pm_dataren(regi,"maxprod",rlf,te) )
        / ( sum(rlf, pm_dataren(regi,"maxprod",rlf,te) )
            + 1e-8) ; 
  );
);	
$offtext

***parameter p32_curtOn(all_regi) - control variable for curtailment fitted from the DIMES-Results
p32_curtOn(regi) = 1;
if (cm_solwindenergyscen = 8,  !! RI No Integration scenario 
	p32_curtOn(regi) = 0;
);

***display p32_capFacDem, p32_capFacLoB, p32_RLDCcoeff, p32_avCapFac, p32_ResMarg, p32_curtOn, p32_shCHP, p32_grid_factor;

*** EOF ./modules/32_power/RLDC/datainput.gms
