*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS/postsolve.gms

*--------------------------------------------------------------------------
***                  save gdx
*--------------------------------------------------------------------------
*** write the fulldata.gdx file after each optimal iteration
***AJS* in Nash status 7 is considered optimal in that respect (see definition of o_modelstat in solve.gms)
if((o_modelstat le 2),
    Execute_Unload 'fulldata';
  );  
if((o_modelstat gt 2),
    Execute_Unload 'non_optimal';
  );

*** Calcualte AP emissions
Execute "Rscript exoGAINSAirpollutants.R";

*** Read input ref results for tall with following dimensions: pm_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP)
if((cm_startyear gt 2005),
Execute_Loadpoint 'input_ref' p11_emiAPexsolveGDX =  pm_emiAPexsolve;
pm_emiAPexsolve(tall,regi,all_sectorEmi,emiRCP) = p11_emiAPexsolveGDX(tall,regi,all_sectorEmi,emiRCP);
   );
   
*** Read result with following dimensions: pm_emiAPexsolve(t,all_regi,all_sectorEmi,emiRCP)
Execute_Loadpoint 'pm_emiAPexsolve' p11_emiAPexsolveGDX =  pm_emiAPexsolve;
pm_emiAPexsolve(t,regi,all_sectorEmi,emiRCP) = p11_emiAPexsolveGDX(t,regi,all_sectorEmi,emiRCP);

display pm_emiAPexsolve;

*** EOF ./modules/11_aerosols/exoGAINS/postsolve.gms
