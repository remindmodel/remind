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

*** TODO: pass an argument that this should use the current gdx
Execute "Rscript run_LCA_internalization_workflow.R";
* Read in results
Execute_Loadpoint 'LCA_SE'  p52_LCAcosts_SE=pm_LCAcosts_SE;

* convert units
pm_taxEI_SE(ttot,all_regi,all_te) = p52_LCAcosts_SE(ttot,all_regi,all_te) * sm_DpGJ_2_TDpTWa;

*** EOF ./modules/52_internalizeLCAimpacts/coupled/presolve.gms
