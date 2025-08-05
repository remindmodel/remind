*** SOF ./modules/52_internalizeLCAimpacts/coupled/postsolve.gms

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
Execute_unload 'fulldata_postsolve';

if( (ord(iteration) ge max(cm_startIter_EDGET, cm_startIter_LCA) and (mod(ord(iteration), 5) eq 0)),
  Execute "Rscript run_LCA_internalization_workflow.R fulldata_postsolve.gdx update_plca";
else
  Execute "Rscript run_LCA_internalization_workflow.R fulldata_postsolve.gdx recalculate_taxes"
);

!! Read in results
Execute_Loadpoint 'LCA_SE'  p52_LCAcosts_SE=pm_LCAcosts_SE;

!! convert units
pm_taxEI_SE(ttot,all_regi,all_te) = p52_LCAcosts_SE(ttot,all_regi,all_te) * sm_DpGJ_2_TDpTWa;

*** EOF ./modules/52_internalizeLCAimpacts/coupled/postsolve.gms
