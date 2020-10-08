*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/exogenous/output.gms
***-------------------------------------------------------------------------------
*** *IM* 20140502 output
***-------------------------------------------------------------------------------

***SE per technology***
p_dummy(ttot,regi,"SE|Electricity|Gas|ngcc; EJ/yr;") = 			    vm_prodSe.l(ttot,regi,"pegas","seel","ngcc") * pm_conv_TWa_EJ;
p_dummy(ttot,regi,"SE|Electricity|Gas|ngccc; EJ/yr;") = 			  vm_prodSe.l(ttot,regi,"pegas","seel","ngccc") * pm_conv_TWa_EJ;
p_dummy(ttot,regi,"SE|Electricity|Gas|ngt; EJ/yr;") = 			    vm_prodSe.l(ttot,regi,"pegas","seel","ngt") * pm_conv_TWa_EJ;
p_dummy(ttot,regi,"SE|Electricity|Gas|gaschp; EJ/yr;") =			  vm_prodSe.l(ttot,regi,"pegas","seel","gaschp") * pm_conv_TWa_EJ;
p_dummy(ttot,regi,"SE|Electricity|Coal|igcc; EJ/yr;") = 			  vm_prodSe.l(ttot,regi,"pecoal","seel","igcc") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Coal|igccc; EJ/yr;") =			  vm_prodSe.l(ttot,regi,"pecoal","seel","igccc") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Coal|pc; EJ/yr;") = 			    vm_prodSe.l(ttot,regi,"pecoal","seel","pc") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Coal|pcc; EJ/yr;") = 			    vm_prodSe.l(ttot,regi,"pecoal","seel","pcc") * pm_conv_TWa_EJ;   
p_dummy(ttot,regi,"SE|Electricity|Coal|pco; EJ/yr;") = 			    vm_prodSe.l(ttot,regi,"pecoal","seel","pco") * pm_conv_TWa_EJ;   
p_dummy(ttot,regi,"SE|Electricity|Coal|coalchp; EJ/yr;") = 		  vm_prodSe.l(ttot,regi,"pecoal","seel","coalchp") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Oil|dot; EJ/yr;") = 			    vm_prodSe.l(ttot,regi,"peoil","seel","dot") * pm_conv_TWa_EJ; 
p_dummy(ttot,regi,"SE|Electricity|Nuclear|tnrs; EJ/yr;") = 		  vm_prodSe.l(ttot,regi,"peur","seel","tnrs") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Biomass|biochp; EJ/yr;") = 	  vm_prodSe.l(ttot,regi,"pebiolc","seel","biochp") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Biomass|bioigcc; EJ/yr;") = 	vm_prodSe.l(ttot,regi,"pebiolc","seel","bioigcc") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Biomass|bioigccc; EJ/yr;") = 	vm_prodSe.l(ttot,regi,"pebiolc","seel","bioigccc") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Geothermal|geohdr; EJ/yr;") = vm_prodSe.l(ttot,regi,"pegeo","seel","geohdr") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Hydro|hydro; EJ/yr;") = 		  vm_prodSe.l(ttot,regi,"pehyd","seel","hydro") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Wind|wind; EJ/yr;") = 			  vm_prodSe.l(ttot,regi,"pewin","seel","wind") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Solar|spv; EJ/yr;") = 			  vm_prodSe.l(ttot,regi,"pesol","seel","spv") * pm_conv_TWa_EJ;  
p_dummy(ttot,regi,"SE|Electricity|Solar|csp2; EJ/yr;") = 		    vm_prodSe.l(ttot,regi,"pesol","seel","csp") * pm_conv_TWa_EJ; 

***Water consumption per technology***
p_dummy(ttot,regi,"Water Consumption|Electricity|Gas|ngcc; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pegas","seel","ngcc") * sum(coolte70, i70_cool_share(regi,"ngcc",coolte70) * i70_water_con("ngcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;
p_dummy(ttot,regi,"Water Consumption|Electricity|Gas|ngccc; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pegas","seel","ngccc") * sum(coolte70, i70_cool_share(regi,"ngccc",coolte70) * i70_water_con("ngccc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;
p_dummy(ttot,regi,"Water Consumption|Electricity|Gas|ngt; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pegas","seel","ngt") * sum(coolte70, i70_cool_share(regi,"ngt",coolte70) * i70_water_con("ngt",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;
p_dummy(ttot,regi,"Water Consumption|Electricity|Gas|gaschp; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pegas","seel","gaschp") * sum(coolte70, i70_cool_share(regi,"gaschp",coolte70) * i70_water_con("gaschp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;
p_dummy(ttot,regi,"Water Consumption|Electricity|Coal|igcc; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pecoal","seel","igcc") * sum(coolte70, i70_cool_share(regi,"igcc",coolte70) * i70_water_con("igcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Coal|igccc; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pecoal","seel","igccc") * sum(coolte70, i70_cool_share(regi,"igccc",coolte70) * i70_water_con("igccc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Coal|pc; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pecoal","seel","pc") * sum(coolte70, i70_cool_share(regi,"pc",coolte70) * i70_water_con("pc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Coal|pcc; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pecoal","seel","pcc") * sum(coolte70, i70_cool_share(regi,"pcc",coolte70) * i70_water_con("pcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;   
p_dummy(ttot,regi,"Water Consumption|Electricity|Coal|pco; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pecoal","seel","pco") * sum(coolte70, i70_cool_share(regi,"pco",coolte70) * i70_water_con("pco",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;   
p_dummy(ttot,regi,"Water Consumption|Electricity|Coal|coalchp; km3/yr;") = 	  vm_prodSe.l(ttot,regi,"pecoal","seel","coalchp") * sum(coolte70, i70_cool_share(regi,"coalchp",coolte70) * i70_water_con("coalchp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Oil|dot; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"peoil","seel","dot") * sum(coolte70, i70_cool_share(regi,"dot",coolte70) * i70_water_con("dot",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non; 
p_dummy(ttot,regi,"Water Consumption|Electricity|Nuclear|tnrs; km3/yr;") = 	  vm_prodSe.l(ttot,regi,"peur","seel","tnrs") * sum(coolte70, i70_cool_share(regi,"tnrs",coolte70) * i70_water_con("tnrs",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Biomass|biochp; km3/yr;") = 	vm_prodSe.l(ttot,regi,"pebiolc","seel","biochp") * sum(coolte70, i70_cool_share(regi,"biochp",coolte70) * i70_water_con("biochp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Biomass|bioigcc; km3/yr;") = vm_prodSe.l(ttot,regi,"pebiolc","seel","bioigcc") * sum(coolte70, i70_cool_share(regi,"bioigcc",coolte70) * i70_water_con("bioigcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Biomass|bioigccc; km3/yr;") =vm_prodSe.l(ttot,regi,"pebiolc","seel","bioigccc") * sum(coolte70, i70_cool_share(regi,"bioigccc",coolte70) * i70_water_con("bioigccc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Geothermal|geohdr; km3/yr;")=vm_prodSe.l(ttot,regi,"pegeo","seel","geohdr") * sum(coolte70, i70_cool_share(regi,"geohdr",coolte70) * i70_water_con("geohdr",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Hydro|hydro; km3/yr;") = 	  vm_prodSe.l(ttot,regi,"pehyd","seel","hydro") * sum(coolte70, i70_cool_share(regi,"hydro",coolte70) * i70_water_con("hydro",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Wind|wind; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pewin","seel","wind") * sum(coolte70, i70_cool_share(regi,"wind",coolte70) * i70_water_con("wind",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Solar|spv; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pesol","seel","spv") * sum(coolte70, i70_cool_share(regi,"spv",coolte70) * i70_water_con("spv",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|Solar|csp; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pesol","seel","csp") * sum(coolte70, i70_cool_share(regi,"csp",coolte70) * i70_water_con("csp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  

***Water withdrawal per technology***
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Gas|ngcc; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pegas","seel","ngcc") * sum(coolte70, i70_cool_share(regi,"ngcc",coolte70) * i70_water_wtd("ngcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non ;
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Gas|ngccc; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pegas","seel","ngccc") * sum(coolte70, i70_cool_share(regi,"ngccc",coolte70) * i70_water_wtd("ngccc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Gas|ngt; km3/yr;") = 			    vm_prodSe.l(ttot,regi,"pegas","seel","ngt") * sum(coolte70, i70_cool_share(regi,"ngt",coolte70) * i70_water_wtd("ngt",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Gas|gaschp; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pegas","seel","gaschp") * sum(coolte70, i70_cool_share(regi,"gaschp",coolte70) * i70_water_wtd("gaschp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Coal|igcc; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pecoal","seel","igcc") * sum(coolte70, i70_cool_share(regi,"igcc",coolte70) * i70_water_wtd("igcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Coal|igccc; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pecoal","seel","igccc") * sum(coolte70, i70_cool_share(regi,"igccc",coolte70) * i70_water_wtd("igccc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Coal|pc; km3/yr;") = 			    vm_prodSe.l(ttot,regi,"pecoal","seel","pc") * sum(coolte70, i70_cool_share(regi,"pc",coolte70) * i70_water_wtd("pc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Coal|pcc; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pecoal","seel","pcc") * sum(coolte70, i70_cool_share(regi,"pcc",coolte70) * i70_water_wtd("pcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;   
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Coal|pco; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pecoal","seel","pco") * sum(coolte70, i70_cool_share(regi,"pco",coolte70) * i70_water_wtd("pco",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;   
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Coal|coalchp; km3/yr;") = 	  vm_prodSe.l(ttot,regi,"pecoal","seel","coalchp") * sum(coolte70, i70_cool_share(regi,"coalchp",coolte70) * i70_water_wtd("coalchp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Oil|dot; km3/yr;") = 			    vm_prodSe.l(ttot,regi,"peoil","seel","dot") * sum(coolte70, i70_cool_share(regi,"dot",coolte70) * i70_water_wtd("dot",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non; 
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Nuclear|tnrs; km3/yr;") = 	  vm_prodSe.l(ttot,regi,"peur","seel","tnrs") * sum(coolte70, i70_cool_share(regi,"tnrs",coolte70) * i70_water_wtd("tnrs",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Biomass|biochp; km3/yr;") = 	vm_prodSe.l(ttot,regi,"pebiolc","seel","biochp") * sum(coolte70, i70_cool_share(regi,"biochp",coolte70) * i70_water_wtd("biochp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Biomass|bioigcc; km3/yr;") = 	vm_prodSe.l(ttot,regi,"pebiolc","seel","bioigcc") * sum(coolte70, i70_cool_share(regi,"bioigcc",coolte70) * i70_water_wtd("bioigcc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Biomass|bioigccc; km3/yr;") = vm_prodSe.l(ttot,regi,"pebiolc","seel","bioigccc") * sum(coolte70, i70_cool_share(regi,"bioigccc",coolte70) * i70_water_wtd("bioigccc",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Geothermal|geohdr; km3/yr;") =vm_prodSe.l(ttot,regi,"pegeo","seel","geohdr") * sum(coolte70, i70_cool_share(regi,"geohdr",coolte70) * i70_water_wtd("geohdr",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Hydro|hydro; km3/yr;") = 		  vm_prodSe.l(ttot,regi,"pehyd","seel","hydro") * sum(coolte70, i70_cool_share(regi,"hydro",coolte70) * i70_water_wtd("hydro",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Wind|wind; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pewin","seel","wind") * sum(coolte70, i70_cool_share(regi,"wind",coolte70) * i70_water_wtd("wind",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Solar|spv; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pesol","seel","spv") * sum(coolte70, i70_cool_share(regi,"spv",coolte70) * i70_water_wtd("spv",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity|Solar|csp; km3/yr;") = 		    vm_prodSe.l(ttot,regi,"pesol","seel","csp") * sum(coolte70, i70_cool_share(regi,"csp",coolte70) * i70_water_wtd("csp",coolte70) / 100) * sm_TWa_2_MWh / sm_giga_2_non;  

***SE Totals***
p_dummy(ttot,regi,"SE|Electricity|Part; EJ/yr;") = 			sum(pe2se(enty,"seel",te), vm_prodSe.l(ttot,regi,enty,"seel",te)) * pm_conv_TWa_EJ; 
p_dummy(ttot,regi,"SE|Electricity|Full; EJ/yr;") = 			(sum(pe2se(enty,"seel",te), vm_prodSe.l(ttot,regi,enty,"seel",te))
															+ sum(se2se(enty,"seel",te), vm_prodSe.l(ttot,regi,enty,"seel",te))
															+ sum(pc2te(enty,entySe(enty3),te,"seel"), max(0, pm_prodCouple(regi,enty,enty3,te,"seel")) * vm_prodSe.l(ttot,regi,enty,enty3,te))
															) * pm_conv_TWa_EJ;
p_dummy(ttot,regi,"SE|Electricity2; MWh/yr;") = p_dummy(ttot,regi,"SE|Electricity|Part; EJ/yr;") * sm_EJ_2_TWa * sm_TWa_2_MWh; 
p_dummy(ttot,regi,"SE|Electricity2|wo/h; MWh/yr;") = (p_dummy(ttot,regi,"SE|Electricity|Part; EJ/yr;") - p_dummy(ttot,regi,"SE|Electricity|Hydro; EJ/yr;")) * sm_EJ_2_TWa * sm_TWa_2_MWh; 

***Water consumption totals and intensities***
p_dummy(ttot,regi,"Water Consumption|Electricity; km3/yr;") = sum(pe2se(entyPe,"seel",te),vm_prodSe.l(ttot,regi,entyPe,"seel",te) * sum(coolte70, i70_cool_share(regi,te,coolte70) * i70_water_con(te,coolte70) / 100)) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Consumption|Electricity|wo/h; km3/yr;") = p_dummy(ttot,regi,"Water Consumption|Electricity; km3/yr;") - p_dummy(ttot,regi,"Water Consumption|Electricity|Hydro|hydro; km3/yr;");  
p_dummy(ttot,regi,"Water Consumption|Electricity2; m3/yr;") = p_dummy(ttot,regi,"Water Consumption|Electricity; km3/yr;") * sm_giga_2_non;
p_dummy(ttot,regi,"Water Consumption|Electricity2|wo/h; m3/yr;") = p_dummy(ttot,regi,"Water Consumption|Electricity|wo/h; km3/yr;") * sm_giga_2_non;
p_dummy(ttot,regi,"Water Consumption Intensity|Electricity2; m3/MWh;") = p_dummy(ttot,regi,"Water Consumption|Electricity2; m3/yr;") / p_dummy(ttot,regi,"SE|Electricity2; MWh/yr;");
p_dummy(ttot,regi,"Water Consumption Intensity|Electricity2|wo/h; m3/MWh;") =	p_dummy(ttot,regi,"Water Consumption|Electricity2|wo/h; m3/yr;") / p_dummy(ttot,regi,"SE|Electricity2|wo/h; MWh/yr;");

***Water withdrawal totals and intensities***
p_dummy(ttot,regi,"Water Withdrawal|Electricity; km3/yr;") = sum(pe2se(entyPe,"seel",te),vm_prodSe.l(ttot,regi,entyPe,"seel",te) * sum(coolte70, i70_cool_share(regi,te,coolte70) * i70_water_wtd(te,coolte70) / 100)) * sm_TWa_2_MWh / sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal|Electricity2; m3/yr;") = p_dummy(ttot,regi,"Water Withdrawal|Electricity; km3/yr;") * sm_giga_2_non;  
p_dummy(ttot,regi,"Water Withdrawal Intensity|Electricity2; m3/MWh;") = p_dummy(ttot,regi,"Water Withdrawal|Electricity2; m3/yr;") / p_dummy(ttot,regi,"SE|Electricity2; MWh/yr;");
*** EOF ./modules/70_water/exogenous/output.gms
