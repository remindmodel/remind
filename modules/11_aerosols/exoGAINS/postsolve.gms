*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS/postsolve.gms

*--------------------------------------------------------------------------
***                  save gdx
*--------------------------------------------------------------------------

*** run exoGAINS from iteration 2 onwards to avoid incomplete GDX files when running it in the first iteration
if (iteration.val ge 2,

*** write data to file if an optimal solution was found
if((o_modelstat le 2),
    Execute_Unload 'fulldata_exoGAINS';
);

*** Calculate AP emissions
Execute "Rscript exoGAINSAirpollutants.R";

*** Read input ref results for tall with following dimensions: p11_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP)
if((cm_startyear gt 2005),
Execute_Loadpoint 'input_ref' p11_emiAPexsolveGDX =  p11_emiAPexsolve;
p11_emiAPexsolve(tall,regi,all_sectorEmi,emiRCP) = p11_emiAPexsolveGDX(tall,regi,all_sectorEmi,emiRCP);
   );
   
*** Read result with following dimensions: p11_emiAPexsolve(t,all_regi,all_sectorEmi,emiRCP)
Execute_Loadpoint 'p11_emiAPexsolve' p11_emiAPexsolveGDX =  p11_emiAPexsolve;
p11_emiAPexsolve(t,regi,all_sectorEmi,emiRCP) = p11_emiAPexsolveGDX(t,regi,all_sectorEmi,emiRCP);

display p11_emiAPexsolve;

);
*** EOF ./modules/11_aerosols/exoGAINS/postsolve.gms
