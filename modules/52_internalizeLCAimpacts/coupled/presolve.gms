*** SOF ./modules/52_internalizeLCAimpacts/coupled/presolve.gms

***---------------------------------------------------------------------------
*' TODO: adapt for LCA workflow
*' MAGICC is run and its output is read using different current R scripts in the external MAGICC folder
*' that are copied to each run's folder during the preparation phase. Different parametrizations of MAGICC can also be chosen with `cm_magicc_config`,
*' and are also handled during the preparation phase
*'
*' Below is the main code that handles the input prepration, running and output reading of MAGICC.
***---------------------------------------------------------------------------
*' @code

*** 

*** TODO: start Rscript here
pm_taxEI_SE(ttot,all_regi,all_te) = 0;
pm_taxEI_PE(ttot,all_regi,all_enty) = 0;
pm_taxEI_cap(ttot,all_regi,all_te) = 0;

*** EOF ./modules/52_internalizeLCAimpacts/coupled/presolve.gms
