*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/timeDepGrades/equations.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: timeDepGrades
* FILE.......: equations.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables the model to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: JH, NB, TAC
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2015-12-03 : Cleaning up
*   - 2013-10-01 : Cleaning up
*   - 2012-05-04 : Creation
*===========================================

*' @equations
*' Uranium extraction is represented as a 3rd order polynomial parametrized by long-term marginal extraction costs.
*---------------------------------------
*** Uranium extraction (3rd order poly)
*---------------------------------------
*NB/LB/BB/GL* fossil extraction costs parameterized as 3rd order polynomial
***This is used for uranium
q31_costFuExPol(ttot,regi,peExPol(enty))$(ttot.val ge cm_startyear)..
	vm_costFuEx(ttot,regi,enty)
	=e=
*NB*111123 this is the long-term marginal extraction cost part
	( p31_costExPoly(regi,"xi1",enty)
	  + p31_costExPoly(regi,"xi2",enty) * v31_fuExtrCum(ttot,regi,enty, "1")
	  + p31_costExPoly(regi,"xi3",enty) * v31_fuExtrCum(ttot,regi,enty, "1")**2
	  + p31_costExPoly(regi,"xi4",enty) * v31_fuExtrCum(ttot,regi,enty, "1")**3
	)
	*
*' Short term decline and increase rates are determined by adjustment costs.
*NB*111123 this is the short-term adjustment cost part
	(1$(ttot.val eq 2005)
	+(
		(1-p31_fosadjco_xi5xi6(regi,"xi5",enty))
		+ p31_fosadjco_xi5xi6(regi,"xi5",enty) * ((vm_fuExtr(ttot,regi,enty,"1")+1.e-5)/(vm_fuExtr(ttot-1,regi,enty,"1")$(ttot.val gt 2005)+1.e-5))**p31_fosadjco_xi5xi6(regi,"xi6",enty)
	)$(ttot.val gt 2005)
	)
	* vm_fuExtr(ttot,regi,enty,"1")
;

*' Two dummy equations further determine regional uranium extraction bounds. 
*NB* the 2 dummy equations only for determining the regional uranium bounds
q31_mc_dummy(regi,peExPol(enty))..
   v31_fuExtrMC(enty,"1") 
   =e=
   p31_costExPoly(regi,"xi1",enty)
   + p31_costExPoly(regi,"xi2",enty) * v31_fuExtrCumMax(regi,enty, "1")
   + p31_costExPoly(regi,"xi3",enty) * v31_fuExtrCumMax(regi,enty, "1")**2
   + p31_costExPoly(regi,"xi4",enty) * v31_fuExtrCumMax(regi,enty, "1")**3 
;

q31_totfuex_dummy(peExPol(enty))..
    s31_max_disp_peur
    =e=
    sum(regi, v31_fuExtrCumMax(regi,enty, "1"))
;

***-----------------------------------------
*** MOFEX
***-----------------------------------------
*** LB, JH

*' MOFEX (Model of Fossil Extraction) minimizes the discounted extraction and trade costs of fossils while balancing trade for each time step.
*' The model takes fossil demand, imports and exports from a prior REMIND run as inputs, and it calculates fossil extraction and trade as outputs. 
*' In this realization, the output variables are returned to the current REMIND run as starting points for the hybrid optimization.

$IFTHEN.mofex %cm_MOFEX% == "on"
*** Trade of resources (oil, gas and coal)
q31_MOFEX_tradebal(t,trade(peExGrade))..
	sum(regi,  vm_Xport(t,regi,trade) - vm_Mport(t,regi,trade)) =e= 0;

*** Discounted extraction and trade costs of fossil fuels 
	q31_MOFEX_costMinFuelEx..
	v31_MOFEX_costMinFuelEx
	=e=
	sum(ttot$(ttot.val ge cm_startyear), 
		sum(regi,
			pm_ts(ttot) / ((1 + pm_prtp(regi))**(pm_ttot_val(ttot)-cm_startyear))
			* (sum(peFos(enty), vm_costFuEx(ttot,regi,enty))
				+ sum(peFos(enty), pm_costsTradePeFinancial(regi,"Mport",enty) * vm_Mport(ttot,regi,enty))
				+ sum(peFos(enty),
					(pm_costsTradePeFinancial(regi,"Xport",enty) * vm_Xport(ttot,regi,enty))
					* (1
						+ pm_costsTradePeFinancial(regi,"XportElasticity",enty) / sqr(pm_ttot_val(ttot)-pm_ttot_val(ttot-1))
						* ( vm_Xport(ttot,regi,enty)  / (vm_Xport(ttot-1,regi,enty) + pm_costsTradePeFinancial(regi, "tradeFloor",enty)) - 1)
					  )
				     )
			  )
		   )
   );
$ENDIF.mofex

***-----------------------------------------
*** Fossil fuel extraction (grade structure)
***-----------------------------------------
*NB/LB/BB/GL/IM* fossil extraction costs as grade structure with linearly increasing marginal extraction costs
***This is used for oil, gas and coal. Notice that coal supply cost curves remain constant over time

*' Fossil fuels are represented by discrete grades based on ranges of marginal extraction costs. The total extraction cost for each time step 
*' is calculated based on long-term marginal extraction costs and short-term calibrated adjustment costs which capture inertias, e.g. from infrastructure

q31_costFuExGrade(ttot,regi,peExGrade(enty))$(ttot.val ge cm_startyear)..
	vm_costFuEx(ttot,regi,enty)
	=e=
*NB*111123 this is the long-term marginal extraction cost part
	sum(pe2rlf(enty,rlf),
		((p31_grades(ttot,regi,"xi1",enty, rlf) + pm_costsTradePeFinancial(regi,"use",enty)
			+ (p31_grades(ttot,regi,"xi2",enty,rlf)-p31_grades(ttot,regi,"xi1",enty, rlf)) * v31_fuExtrCum(ttot-1,regi,enty, rlf)$(ttot.val gt 2005) / p31_grades(ttot,regi,"xi3",enty, rlf)
			+ (p31_grades(ttot,regi,"xi2",enty,rlf)-p31_grades(ttot,regi,"xi1",enty, rlf)) * (v31_fuExtrCum(ttot,regi,enty,rlf)-v31_fuExtrCum(ttot-1,regi,enty,rlf)$(ttot.val gt 2005)) / (2 * p31_grades(ttot,regi,"xi3",enty, rlf))
			)
***this is the short-term adjustment cost part
			* (
				(1 +
				(p31_datafosdyn(regi,enty,rlf,"alph") * 1/(sqr(pm_ttot_val(ttot)-pm_ttot_val(ttot-1)))
				* sqr(((vm_fuExtr(ttot,regi,enty,rlf)-vm_fuExtr(ttot-1,regi,enty,rlf))/(vm_fuExtr(ttot-1,regi,enty,rlf)+
							0.001*p31_grades(ttot,regi,"xi3",enty,rlf) + 
							p31_extraseed(ttot,regi,enty,rlf) +
							1.e-9)))
				)$(ttot.val gt 2005) 
				)
			)
			* vm_fuExtr(ttot,regi,enty,rlf)
		)$(p31_grades(ttot,regi,"xi3",enty,rlf) gt 0)
	)
;

*--------------------------------------
*** Calculate cumulated fuel extraction
*--------------------------------------
*' Cumulated fuel extraction (oil, gas and coal) is the sum of extraction in each time step multiplied by the time step length.
*' If early retirement of oil wells is switched on, any slack capacity from those fields is also added.

q31_fuExtrCum(ttot,regi,pe2rlf(peEx(enty),rlf))$(ttot.val ge cm_startyear)..
    v31_fuExtrCum(ttot,regi,enty,rlf) 
    =e= 
    v31_fuExtrCum(ttot-1,regi,enty,rlf)$(ttot.val gt 2005) + pm_ts(ttot)*(vm_fuExtr(ttot,regi,enty,rlf)
  + v31_fuSlack(ttot,regi,enty,rlf)
    );

*NB*110720 dynamic constraints on resource extraction
*' These dynamic constraints on the decline and increase rates of production reflect physical and technical inertias of oil, gas and coal
*** --------------------------------------
*' Dynamic constraint on decline rate
*** --------------------------------------
q31_fuExtrDec(ttot+1,regi,enty2rlf_dec(enty,rlf))$(pm_ttot_val(ttot+1) ge max(2010,cm_startyear))..
      vm_fuExtr(ttot+1,regi,enty,rlf)
    + v31_fuSlack(ttot+1,regi,enty,rlf)
    =g=
    p31_datafosdyn(regi,enty,rlf,"decoffset") * p31_grades(ttot,regi,"xi3",enty,rlf) * 0.5 * ( pm_ts(ttot+1) + pm_ts(ttot) )     !! This is an (arbitrarily set) minimal amount that can simply be turned off from one time step to the next

    + (1-p31_datafosdyn(regi,enty,rlf,"dec"))**(pm_ttot_val(ttot+1)-pm_ttot_val(ttot)) * vm_fuExtr(ttot,regi,enty,rlf);

***CG:RETIRE% ==  replacing earlyreti_lim with regional early retirement rate pm_extRegiEarlyRetiRate(ext_regi)
q31_smoothoilphaseout(ttot,regi,enty2rlf_dec(enty,rlf))$( (ttot.val ge cm_startyear) AND (ttot.val lt 2120) AND (sameas(enty,"peoil")) )..
	v31_fuSlack(ttot+1,regi,enty,rlf)
	=l=
	v31_fuSlack(ttot,regi,enty,rlf) + (pm_ttot_val(ttot+1)-pm_ttot_val(ttot)) * sum(regi_group(ext_regi,regi), pm_extRegiEarlyRetiRate(ext_regi)) * 0.3 * p31_max_oil_extraction(regi,enty,rlf); !! 0.3 is an arbitrarily chosen number to make the retirement of oil comparable to retirement of other sectors- the "max_oil_extraction" is alsways higher than the real extraction, so some decrease of this limit makes the results smoother.
;


*** --------------------------------------
*' Dynamic constraint on increase rate
*** --------------------------------------
q31_fuExtrInc(ttot+1,regi,enty2rlf_inc(enty,rlf))$((p31_grades(ttot,regi,"xi3",enty,rlf) gt 0) AND (pm_ttot_val(ttot+1) ge max(2010,cm_startyear)))..
	vm_fuExtr(ttot+1,regi,enty,rlf)
	=l=
	(1 + p31_datafosdyn(regi,enty,rlf,"inc"))**(pm_ttot_val(ttot+1)-pm_ttot_val(ttot)) * (vm_fuExtr(ttot,regi,enty,rlf) + p31_datafosdyn(regi,enty,rlf,"incoffset"))
$ifthen.cm_oil_scen %cm_oil_scen% == "highOil"	  +(10)$(cm_startyear eq 2015 AND pm_ttot_val(ttot+1) eq 2015 AND ((sameas(enty,"peoil") AND sameas(rlf,"7")) OR (sameas(enty,"pegas") AND sameas(rlf,"6"))))
                                                  +(10)$(cm_startyear eq 2015 AND pm_ttot_val(ttot+1) eq 2015 AND (sameas(enty,"peoil") AND sameas(rlf,"1") AND sameas(regi,"REF")));
$elseif.cm_oil_scen %cm_oil_scen% == "4"          +(10)$(cm_startyear eq 2015 AND pm_ttot_val(ttot+1) eq 2015 AND ((sameas(enty,"peoil") AND sameas(rlf,"7")) OR (sameas(enty,"pegas") AND sameas(rlf,"6"))))
$endif.cm_oil_scen
;
*** EOF ./modules/31_fossil/timeDepGrades/equations.gms
