*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/EVmandates/datainput.gms 
* values chosen with view on fig. 10 of www.iea.org/publications/freepublications/publication/Global_EV_Outlook_2016.pdf
p40_EV_share("2020",regi)$(sameas(regi,"EUR") OR sameas(regi,"JPN")  OR sameas(regi,"CHN"))  = 0.08; !! upper tier 
p40_EV_share("2020",regi)$(sameas(regi,"OAS") OR sameas(regi,"USA")  OR sameas(regi,"ROW")) = 0.05; 		!!middle tier
p40_EV_share("2020",regi)$(sameas(regi,"RUS") OR sameas(regi,"LAM") OR sameas(regi,"MEA") OR sameas(regi,"AFR") OR sameas(regi,"IND"))  = 0.02; !! lower tier
* parallel linear evolution of shares: + 2 % per year, 80% as maximum mandate
p40_EV_share(t,regi)$(t.val gt 2020) = min( p40_EV_share("2020",regi) + (t.val -2020) * 0.02,0.8);!!rising to 80% around 2060;
		
*** EOF ./modules/40_techpol/EVmandates/datainput.gms
