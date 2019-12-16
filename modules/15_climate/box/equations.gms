*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/equations.gms
ta2ttot10(ta10, ttot)$((ttot.val lt ta10.val) AND (pm_ttot_val(ttot+1) gt ta10.val)AND (ttot.val ge 2005)) = Yes;
display ttot2ta10, ta2ttot10;

***---------------------------------------------------------------------------
*'  Carbon Cycle. CO2 concentration is calculated using and Impulse-Response-Function Model with 3 time scales
***---------------------------------------------------------------------------
q15_cc(ta10)$(ord(ta10) ge 1)..
    v15_conc(ta10,'CO2')
	=e=
	s15_c0 + ((s15_c2000-s15_c0)/(s15_ca0*s15_cq0+s15_ca1*s15_cq1+s15_ca2*s15_cq2+s15_ca3*s15_cq3))
	         * (s15_ca0*s15_cq0 + s15_ca1*s15_cq1*exp(-(ord(ta10)-1)/s15_ctau1) + s15_ca2*s15_cq2*exp(-(ord(ta10)-1)/s15_ctau2) + s15_ca3*s15_cq3*exp(-(ord(ta10)-1)/s15_ctau3))
		   + s15_cconvi * sum((tx)$(ord(tx)lt ord(ta10)),v15_emi(tx,'CO2')*p15_epsilon(ta10-ord(tx)));

***---------------------------------------------------------------------------
*'  CH4 concentration
***---------------------------------------------------------------------------
q15_concCH4Q(ta10)$(Ord(ta10) GT 1)..
    (v15_conc(ta10,'CH4')-v15_conc(ta10-1,'CH4'))/s15_DELTAT
	=e=
	0.5 * (
	      (1/s15_CNVCH4 * (v15_emi(ta10,'CH4')+ s15_NATCH4) - (p15_conroh(ta10) / s15_TAUCH4OH + 1 / s15_TAUCH4SS) * v15_conc(ta10,'CH4'))
		  + (1/s15_CNVCH4*(v15_emi(ta10-1,'CH4') + s15_NATCH4) - (p15_conroh(ta10-1) / s15_TAUCH4OH + 1 / s15_TAUCH4SS) * v15_conc(ta10-1,'CH4'))
		  );

***---------------------------------------------------------------------------
*'  N20 concentration (from ACC2)
***---------------------------------------------------------------------------
q15_concN2OQ(ta10)$(Ord(ta10) GT 1)..
    (v15_conc(ta10,'N2O')-v15_conc(ta10-1,'N2O'))/s15_DELTAT
	=e=
	0.5 * (
	(1/s15_CNVN2O * (v15_emi(ta10,'N2O')+ s15_NATN2O) - (1/s15_TAUN2O*(v15_conc(ta10,'N2O')/s15_CONN2O2000R)**(-s15_SENTAUN2O)*v15_conc(ta10,'N2O')))
	+ (1/s15_CNVN2O * (v15_emi(ta10-1,'N2O') + s15_NATN2O) - (1/s15_TAUN2O*(v15_conc(ta10-1,'N2O')/s15_CONN2O2000R)**(-s15_SENTAUN2O)*v15_conc(ta10-1,'N2O')))
	);

***---------------------------------------------------------------------------
*'    CO2 radiative forcing
***---------------------------------------------------------------------------
q15_forcco2(ta10)..
    v15_forcComp(ta10,'CO2')
	=e=
	s15_fcodb * log(v15_conc(ta10,'CO2')/s15_c0) / log(2) ;

***---------------------------------------------------------------------------
*'    CH4 radiative forcing (from ACC2)
***---------------------------------------------------------------------------
q15_forcCH4Q(ta10)..
    v15_forcComp(ta10,'CH4')
	=e=
	s15_RHOCH4 * (SQRT(v15_conc(ta10,'CH4')) - SQRT(s15_CONCH4PRE))
    - s15_OVERLFAC1 * LOG(1 + s15_OVERLFAC2 *(v15_conc(ta10,'CH4') * s15_CONN2OPRE)**s15_OVERLEXP1
	                        + s15_OVERLFAC3 * v15_conc(ta10,'CH4') * (v15_conc(ta10,'CH4')*s15_CONN2OPRE)**s15_OVERLEXP2
							)
    + s15_OVERLFAC1 * LOG(1 + s15_OVERLFAC2 * (s15_CONCH4PRE*s15_CONN2OPRE)**s15_OVERLEXP1
	                        + s15_OVERLFAC3 * s15_CONCH4PRE * (s15_CONCH4PRE*s15_CONN2OPRE)**s15_OVERLEXP2
							);
							
***---------------------------------------------------------------------------
*'    N2O radiative forcing (from ACC2)
***---------------------------------------------------------------------------
q15_forcN2OQ(ta10)..
    v15_forcComp(ta10,'N2O')
	=e=
	s15_RHON2O * (SQRT(v15_conc(ta10,'N2O'))-SQRT(s15_CONN2OPRE))
    - s15_OVERLFAC1 * LOG(1 + s15_OVERLFAC2 * (s15_CONCH4PRE*v15_conc(ta10,'N2O'))**s15_OVERLEXP1
	                      + s15_OVERLFAC3 * s15_CONCH4PRE * (s15_CONCH4PRE*v15_conc(ta10,'N2O'))**s15_OVERLEXP2
						  )
    + s15_OVERLFAC1 * LOG(1 + s15_OVERLFAC2 * (s15_CONCH4PRE*s15_CONN2OPRE)**s15_OVERLEXP1
	                      + s15_OVERLFAC3 * s15_CONCH4PRE * (s15_CONCH4PRE*s15_CONN2OPRE)**s15_OVERLEXP2
						  );

***---------------------------------------------------------------------------
*'    SO2 radiative forcing
***---------------------------------------------------------------------------
q15_forcso2(ta10)..
    v15_forcComp(ta10,'SO2')
	=e=
	s15_dso1990 * v15_emi(ta10,'SO2') / s15_so1990 
	+ s15_iso1990 * log(1 + v15_emi(ta10,'SO2')/s15_enatso2) / log(1 + s15_so1990/s15_enatso2) ;
									   
***---------------------------------------------------------------------------
*'    BC and OC from fossil fuels radiative forcing; scales linear with emissions.
***---------------------------------------------------------------------------
q15_forcbc(ta10)..
	v15_forcComp(ta10,'BC')
	=e=
	(v15_emi(ta10,'BC') / s15_bc2005) * p15_oghgf_ffbc('2005');
					
q15_forcoc(ta10)..
	v15_forcComp(ta10,'OC')
	=e=
	(v15_emi(ta10,'OC') / s15_oc2005) * p15_oghgf_ffoc('2005');					

***---------------------------------------------------------------------------
*'    Total radiative forcing (foghg given exogenously)
***---------------------------------------------------------------------------
q15_forctotal(ta10)..
    v15_forcComp(ta10,'TTL')
	=e=
	hv15_forcComp(ta10,'CO2') 
	+ v15_forcComp(ta10,'SO2') 
	+ v15_forcComp(ta10,'CH4') 
	+ v15_forcComp(ta10,'N2O') 
	+ v15_forcComp(ta10,'BC') 
	+ v15_forcComp(ta10,'OC') 
	+ v15_forcComp(ta10,'oghg_nokyo') 
	+ v15_forcComp(ta10,'oghg_kyo');
								
***---------------------------------------------------------------------------
*'    Total radiative forcing of Kyoto gases
***---------------------------------------------------------------------------
q15_forc_kyo(ta10)..
    v15_forcKyo(ta10) 
	=e=
	v15_forcComp(ta10,'CO2') 
	+ v15_forcComp(ta10,'CH4') 
	+ v15_forcComp(ta10,'N2O') 
	+ v15_forcComp(ta10,'oghg_kyo');

***---------------------------------------------------------------------------
*'    RCP forcing
***---------------------------------------------------------------------------
q15_forc_rcp(ta10)..
	v15_forcRcp(ta10)
	=e=
	v15_forcComp(ta10,'CO2') 
	+ v15_forcComp(ta10,'CH4') 
	+ v15_forcComp(ta10,'N2O') 
	+ v15_forcComp(ta10,'oghg_kyo') 
	+ v15_forcComp(ta10,'SO2') 
	+ v15_forcComp(ta10,'BC') 
	+ v15_forcComp(ta10,'OC') 
	+ v15_forcComp(ta10,'oghg_nokyo_rcp');
																
***---------------------------------------------------------------------------
*'    Temperature equations, consisting of a fast and a slow response function
***---------------------------------------------------------------------------
q15_clisys01(ta10)$(ord(ta10)=1)..
    v15_tempFast(ta10)
	=e=
	s15_RPCTA1 * s15_temp2000 / s15_tsens;

q15_clisys02(ta10)$(ord(ta10)=1)..
    v15_tempSlow(ta10)
	=e=
	s15_RPCTA2 * s15_temp2000 / s15_tsens;

q15_clisys1(ta10)$(Ord(ta10) > 1)..
    (v15_tempFast(ta10) - v15_tempFast(ta10-1)) / s15_deltat_box
    =e=
    0.5 / s15_RPCTT1 * ( (s15_RPCTA1 * v15_forcComp(ta10,'TTL') / 3.7 - v15_tempFast(ta10))
	                   + (s15_RPCTA1 * v15_forcComp(ta10-1,'TTL') / 3.7 - v15_tempFast(ta10-1))
					   );

q15_clisys2(ta10)$(Ord(ta10) > 1)..
    (v15_tempSlow(ta10) - v15_tempSlow(ta10-1)) / s15_deltat_box
	=e=
	0.5 / s15_RPCTT2 * ( (s15_RPCTA2 * v15_forcComp(ta10,'TTL') / 3.7 - v15_tempSlow(ta10))
	                   + (s15_RPCTA2 * v15_forcComp(ta10-1,'TTL') / 3.7 - v15_tempSlow(ta10-1))
					   );

q15_clisys(ta10)..
    v15_temp(ta10)
	=e=
	v15_tempFast(ta10) + v15_tempSlow(ta10);

***---------------------------------------------------------------------------
*'    Forcing overshoot for damage function
***---------------------------------------------------------------------------
q15_forc_os(t)..
    vm_forcOs(t)
	=e=
	v15_forcKyo(t) - s15_gr_forc_kyo + v15_slackForc(t);

***-----------------------------------------------------------------------------------------
*'     link to core
***-----------------------------------------------------------------------------------------
q15_linkEMI(ttot2ta10(ttot, ta10),emis2climate10(enty,FOB10))..
    vm_emiAllGlob(ttot,enty)
	=e=
	v15_emi(ta10,FOB10);
$IF %cm_so2_out_of_opt% == "on" q15_linkEMI_aer(ttot2ta10(ttot, ta10),emiaer2climate10(emiaer,FOB10)).. p15_so2emi(ttot,emiaer) =e= v15_emi(ta10,FOB10);

***-----------------------------------------------------------------------------------------
*'     interpolation for linking (annual resolution of climate modules)
***-----------------------------------------------------------------------------------------
q15_interEMI(ta2ttot10(ta10, ttot),FOBEMI(FOB10))..
    v15_emi(ta10,FOB10)
	=e=
	(1-p15_interpol(ta10)) * v15_emi(ttot,FOB10) + p15_interpol(ta10) *  v15_emi(ttot+1,FOB10);

*** EOF ./modules/15_climate/box/equations.gms
