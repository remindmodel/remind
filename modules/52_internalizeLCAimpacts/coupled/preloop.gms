*** SOF ./modules/52_internalizeLCAimpacts/coupled/preloop.gms

*** Set taxes to zero to begin with.
pm_taxEI_SE(ttot,all_regi,all_te) = 0;
pm_taxEI_PE(ttot,all_regi,all_enty) = 0;
pm_taxEI_cap(ttot,all_regi,all_te) = 0;
pm_taxEI_FE(ttot,all_regi,emi_sectors,all_enty) = 0;

*** TODO: pass an argument that this should use the input_ref.gdx
Execute "Rscript run_LCA_internalization_workflow.R";
* Read in results
Execute_Loadpoint 'LCA_SE'  p52_LCAcosts_SE=pm_LCAcosts_SE;

* convert units
pm_taxEI_SE(ttot,all_regi,all_te) = p52_LCAcosts_SE(ttot,all_regi,all_te) * sm_DpGJ_2_TDpTWa;

*** EOF ./modules/52_internalizeLCAimpacts/coupled/preloop.gms
