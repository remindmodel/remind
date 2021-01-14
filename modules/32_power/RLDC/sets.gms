*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
***-----------------------------------------------------------
***                  module specific sets
***------------------------------------------------------------
SETS
	PolyCoeff   "Which coefficients exist for the RLDC formulation"
	/
		p00  
		p10   "wind ^1, solar ^0"
		p01   "wind ^0, solar ^1"
		p20
		p11
		p02
		p30
		p21
		p12
		p03
	/
	
	RLDCbands   "???"
	/
		1*4,
		curt
		peak
		curtShVRE
		shtStor
		STScost
		STSRes2Cap
	/
	
	LoB(RLDCbands) "Electricity load band"
	/1 * 4/
;

teVRE(all_te) = no;

*dynamically define teVRE
if ( (cm_solwindenergyscen eq 9) AND (cm_solwindenergyscen <> 8),
	teVRE("csp") = yes;
);
if (cm_solwindenergyscen <> 8,
	teVRE("spv") = yes;
	teVRE("wind") = yes;
);	

*RLDC dispatchable technologies
teRLDCDisp("ngcc") = yes;
teRLDCDisp("ngccc") = yes;
teRLDCDisp("ngt") = yes;
teRLDCDisp("gaschp") = yes;
teRLDCDisp("dot") = yes;
teRLDCDisp("igcc") = yes;
teRLDCDisp("igccc") = yes;
teRLDCDisp("pc") = yes;
teRLDCDisp("pcc") = yes;
teRLDCDisp("pco") = yes;
teRLDCDisp("coalchp") = yes;
teRLDCDisp("tnrs") = yes;
teRLDCDisp("fnrs") = yes;
teRLDCDisp("biochp") = yes;
teRLDCDisp("bioigcc") = yes;
teRLDCDisp("bioigccc") = yes;
teRLDCDisp("geohdr") = yes;
teRLDCDisp("hydro") = yes;
teRLDCDisp("h2turb") = yes;
teRLDCDisp("csp") = yes;

if (cm_solwindenergyscen eq 8,
	teRLDCDisp("spv") = yes;
	teRLDCDisp("wind") = yes;
);

*Sets used on data input assignments
SETS
	PeakDep(RLDCbands) "RLDC elements that scale with peak (not curtailment, storage)"
	/
		1 * 4
		peak
	/	

$ontext
	UsedGrades2070(all_regi,all_te,rlf)
	/
		ROW.csp.(1*2)
		EUR.csp.(1*4)
		CHN.csp.(1*3)
		IND.csp.(1*6)
		JPN.csp.(1*6)
		RUS.csp.(1*2)
		USA.csp.(1*4)
		OAS.csp.(1*5)
		MEA.csp.(1*2)
		LAM.csp.(1*2)
		AFR.csp.(1*3)
		ROW.hydro.(1*4)
		EUR.hydro.(1*4)
		CHN.hydro.(1*4)
		IND.hydro.(1*4)
		JPN.hydro.(1*4)
		RUS.hydro.(1*4)
		USA.hydro.(1*4)
		OAS.hydro.(1*4)
		MEA.hydro.(1*4)
		LAM.hydro.(1*4)
		AFR.hydro.(1*4)
	/	
$offtext

	teNotLoB1(all_te)   "Technologies that can't go into the first LoB as they are difficult to cycle continuously & quickly"
	/
		tnrs
		pc
		pcc
		ngcc
		ngccc
		pco
		igccc
		igcc
		bioigcc
		bioigccc
		coalchp
		gaschp
		biochp
	/
	
	teNotBase(all_te)   "Technologies that can't go into the last LoB (baseload) as they can't run for 7500 FLh"
	/
***		hydro
***		csp
***		coalchp
***		gaschp
***		biochp
	/	
;
