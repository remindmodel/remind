*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms

***--------------------------------------------------
*** Emission markets (EU Emission trading system and Effort Sharing)
***--------------------------------------------------


$IFTHEN.emiMktETS not "%cm_emiMktETS%" == "off" 

	loop(ETS_mkt,
*** Removing the economy wide co2 tax parameters for regions within the ETS
		pm_taxCO2eq(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
		pm_taxCO2eqHist(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
		pm_taxCO2eqSCC(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
	
***		pm_taxCO2eq(t,regi)$((t.val ge cm_startyear) and ETS_regi(ETS_mkt,regi)) = 0;
***		pm_taxCO2eqHist(t,regi)$((t.val ge cm_startyear) and ETS_regi(ETS_mkt,regi)) = 0;

*** Initializing emi market historical and reference prices
		pm_taxemiMkt(ttot,regi,emiMkt)$(ETS_regi(ETS_mkt,regi) AND p47_taxemiMktBeforeStartYear(ttot,regi,emiMkt)) = p47_taxemiMktBeforeStartYear(ttot,regi,emiMkt);
		pm_taxemiMkt("2005",regi,"ETS")$ETS_regi(ETS_mkt,regi) = 0;
		pm_taxemiMkt("2010",regi,"ETS")$ETS_regi(ETS_mkt,regi) = 15*sm_DptCO2_2_TDpGtC;
		pm_taxemiMkt("2015",regi,"ETS")$ETS_regi(ETS_mkt,regi) = 8*sm_DptCO2_2_TDpGtC;

***  calculating ETS CO2 emission target
		loop((ttot,target_type,emi_type)$p47_regiCO2ETStarget(ttot,target_type,emi_type),
			if(sameas(target_type,"budget"), !! budget total CO2 target
				p47_emiCurrentETS(ETS_mkt) = 
					sum(regi$ETS_regi(ETS_mkt,regi),
						sum(t$((t.val ge 2020) AND (t.val le ttot.val)),
							pm_ts(t)
***						sum(t$((t.val ge 2020) AND (t.val le ttot.val)),
***							pm_ts(t) * (1 -0.5$(t.val eq 2020 OR t.val eq ttot.val))
							*(v47_emiTargetMkt.l(t, regi,"ETS",emi_type)*sm_c_2_co2)
					));		
			elseif sameas(target_type,"year"), !! year total CO2 target
				p47_emiCurrentETS(ETS_mkt) = sum(regi$ETS_regi(ETS_mkt,regi), v47_emiTargetMkt.l(ttot, regi,"ETS", emi_type)*sm_c_2_co2);
			);
		);
	
***  calculating ETS CO2 tax rescale factor
		loop((ttot,target_type,emi_type)$p47_regiCO2ETStarget(ttot,target_type,emi_type),		 
			if(iteration.val lt 10,
				p47_emiRescaleCo2TaxETS(ETS_mkt) = max(0.1, (p47_emiCurrentETS(ETS_mkt))/(p47_regiCO2ETStarget(ttot,target_type,emi_type)) ) ** 2;
			else
				p47_emiRescaleCo2TaxETS(ETS_mkt) = max(0.1, (p47_emiCurrentETS(ETS_mkt))/(p47_regiCO2ETStarget(ttot,target_type,emi_type)) ) ** 1;
			);
			p47_emiRescaleCo2TaxETS(ETS_mkt)$p47_emiRescaleCo2TaxETS(ETS_mkt) =
				max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_emiRescaleCo2TaxETS(ETS_mkt)),
					1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
				);
		);

***	updating the ETS co2 tax
		loop((ttot,target_type,emi_type)$p47_regiCO2ETStarget(ttot,target_type,emi_type),		
			pm_taxemiMkt(ttot,regi,"ETS")$ETS_regi(ETS_mkt,regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,ttot,regi,"ETS") * p47_emiRescaleCo2TaxETS(ETS_mkt));
***			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt 2015) AND (t.val ge cm_startyear) AND (t.val le ttot.val)) = pm_taxemiMkt(ttot,regi,"ETS")*1.05**(t.val-ttot.val); !! 2018 to 2055: increase at 5% p.a.
			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt 2015) AND (t.val ge cm_startyear) AND (t.val lt ttot.val)) = pm_taxemiMkt("2015",regi,"ETS") + ((pm_taxemiMkt(ttot,regi,"ETS") - pm_taxemiMkt("2015",regi,"ETS"))/(ttot.val-2015))*(t.val-2015); !!linear price between 2020 and ttot (ex. 2055)
***			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt ttot.val)) = pm_taxemiMkt(ttot,regi,"ETS")*1.0125**(t.val-ttot.val); !! post 2055: increase at 1.25% p.a.
			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt ttot.val)) = pm_taxemiMkt(ttot,regi,"ETS") + (2*sm_DptCO2_2_TDpGtC)*(t.val-ttot.val); !! post ttot (ex. 2055): 2 €/tCO2 increase per year
		);

	);		
*** forcing floor price for UKI (UK has a CO2 price floor of ~€20 €/tCO2e since 2013). The Carbon Price Floor was introduced in 2013 at a rate of £16 (€18.05) per tonne of carbon dioxide-equivalent (tCO2e), and was set to increase to £30 (€33.85) by 2020. However, the government more recently decided to cap the Carbon Price Floor at £18.08 (€20.40) till 2021.
***     	pm_taxemiMkt(t,regi,"ETS")$((t.val ge 2015) AND (sameas(regi,"UKI")) AND ETS_regi(ETS_mkt,regi)) = max(20*sm_DptCO2_2_TDpGtC, pm_taxemiMkt(t,regi,"ETS"));
		
	
$ontext	
***  calculating ETS CO2 tax rescale factor

		if(iteration.val lt 15,

$if "%cm_emiMktETS_type%" == "budget" p47_emiRescaleCo2TaxETS("2050",ETS_mkt) = max(0.1, sum(ttot$((ttot.val ge 2015) AND (ttot.val le 2050)), pm_ts(ttot) * (1-0.4$(ttot.val eq 2050))*(sum(regi$ETS_regi(ETS_mkt,regi),v47_emiTargetMkt.l(ttot,regi,"ETS","netCO2"))))/p47_emiTargetETS("2050",ETS_mkt) ) ** 2;
$if "%cm_emiMktETS_type%" == "year"   p47_emiRescaleCo2TaxETS("2050",ETS_mkt) = max(0.1, sum(regi$ETS_regi(ETS_mkt,regi),v47_emiTargetMkt.l("2050",regi,"ETS","netCO2"))/p47_emiTargetETS("2050",ETS_mkt) ) ** 2;
		else
$if "%cm_emiMktETS_type%" == "budget" p47_emiRescaleCo2TaxETS("2050",ETS_mkt) = max(0.1, sum(ttot$((ttot.val ge 2015) AND (ttot.val le 2050)), pm_ts(ttot) * (1-0.4$(ttot.val eq 2050))*(sum(regi$ETS_regi(ETS_mkt,regi),v47_emiTargetMkt.l(ttot,regi,"ETS","netCO2"))) )/p47_emiTargetETS("2050",ETS_mkt) );
$if "%cm_emiMktETS_type%" == "year"   p47_emiRescaleCo2TaxETS("2050",ETS_mkt) = max(0.1, sum(regi$ETS_regi(ETS_mkt,regi),v47_emiTargetMkt.l("2050",regi,"ETS","netCO2"))/p47_emiTargetETS("2050",ETS_mkt) );
		);

		p47_emiRescaleCo2TaxETS(t,ETS_mkt)$p47_emiRescaleCo2TaxETS(t,ETS_mkt) =
		max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_emiRescaleCo2TaxETS(t,ETS_mkt)),
			1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
		);

***	updating the ETS co2 tax
*		pm_taxemiMkt("2005",regi,"ETS")$ETS_regi(ETS_mkt,regi) = 0;
*		pm_taxemiMkt("2010",regi,"ETS")$ETS_regi(ETS_mkt,regi) = 15*sm_DptCO2_2_TDpGtC;
*		pm_taxemiMkt("2015",regi,"ETS")$ETS_regi(ETS_mkt,regi) = 8*sm_DptCO2_2_TDpGtC;
		pm_taxemiMkt("2050",regi,"ETS")$ETS_regi(ETS_mkt,regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2050",regi,"ETS") * p47_emiRescaleCo2TaxETS("2050",ETS_mkt));
		pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt 2015) AND (t.val ge cm_startyear) AND (t.val le 2050)) = pm_taxemiMkt("2050",regi,"ETS")*1.05**(t.val-2050); !! 2013 to 2050: increase at 5% p.a.
		pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt 2050)) = pm_taxemiMkt("2050",regi,"ETS")*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.

*** forcing floor price for UKI (UK has a CO2 price floor of ~€20 €/tCO2e since 2013). The Carbon Price Floor was introduced in 2013 at a rate of £16 (€18.05) per tonne of carbon dioxide-equivalent (tCO2e), and was set to increase to £30 (€33.85) by 2020. However, the government more recently decided to cap the Carbon Price Floor at £18.08 (€20.40) till 2021.
***     	pm_taxemiMkt(t,regi,"ETS")$((t.val ge 2015) AND (sameas(regi,"UKI")) AND ETS_regi(ETS_mkt,regi)) = max(20*sm_DptCO2_2_TDpGtC, pm_taxemiMkt(t,regi,"ETS"));

	);
$offtext
    display p47_emiRescaleCo2TaxETS;
    display pm_taxemiMkt;
$ENDIF.emiMktETS



$IFTHEN.emiMktES not "%cm_emiMktES%" == "off" 

	loop((regi)$p47_emiTargetES("2030",regi),

*** Removing the economy wide co2 tax parameters for regions within the ES
		pm_taxCO2eq(ttot,regi) = 0;
		pm_taxCO2eqHist(ttot,regi) = 0;
		pm_taxCO2eqSCC(ttot,regi) = 0;
		
***  calculating the ES CO2 tax rescale factor
		if(iteration.val lt 15,
			p47_emiRescaleCo2TaxES("2020",regi)$((cm_startyear le 2020) AND (p47_emiTargetES("2020",regi))) = max(0.1, ( v47_emiTargetMkt.l("2020",regi,"ES","%cm_emiMktES_type%")/p47_emiTargetES("2020",regi) ) )** 2;
			p47_emiRescaleCo2TaxES("2030",regi)$((cm_startyear le 2030) AND (p47_emiTargetES("2030",regi))) = max(0.1, ( v47_emiTargetMkt.l("2030",regi,"ES","%cm_emiMktES_type%")/p47_emiTargetES("2030",regi) ) )** 2;
		else
			p47_emiRescaleCo2TaxES("2020",regi)$((cm_startyear le 2020) AND (p47_emiTargetES("2020",regi))) = max(0.1, ( v47_emiTargetMkt.l("2020",regi,"ES","%cm_emiMktES_type%")/p47_emiTargetES("2020",regi) ) );
			p47_emiRescaleCo2TaxES("2030",regi)$((cm_startyear le 2030) AND (p47_emiTargetES("2030",regi))) = max(0.1, ( v47_emiTargetMkt.l("2030",regi,"ES","%cm_emiMktES_type%")/p47_emiTargetES("2030",regi) ) );
		);

$IFTHEN.emiMktES2050 not "%cm_emiMktES2050%" == "off"
$IFTHEN.emiMktES2050_2 not "%cm_emiMktES2050%" == "linear"

		if(iteration.val lt 15,
			p47_emiRescaleCo2TaxES("2050",regi)$(p47_emiTargetES("2050",regi)) = max(0.1, ( v47_emiTargetMkt.l("2050",regi,"ES","%cm_emiMktES_type%")/p47_emiTargetES("2050",regi) ) )** 2;
		else
			p47_emiRescaleCo2TaxES("2050",regi)$(p47_emiTargetES("2050",regi)) = max(0.1, ( v47_emiTargetMkt.l("2050",regi,"ES","%cm_emiMktES_type%")/p47_emiTargetES("2050",regi) ) );
		);

$ENDIF.emiMktES2050_2
$ENDIF.emiMktES2050

$IFTHEN.emiMktEScoop not "%cm_emiMktEScoop%" == "off"
*** alternative cooperative ES solution: calculating the ES CO2 tax rescale factor
		if(iteration.val lt 15,
			p47_emiRescaleCo2TaxES("2020",regi)$((cm_startyear le 2020) AND (p47_emiTargetES("2020",regi))) = max(0.1, ( sum(regi2$regi_group("EUR_regi",regi2),v47_emiTargetMkt.l("2020",regi2,"ES","%cm_emiMktES_type%"))/sum(regi2$regi_group("EUR_regi",regi2),p47_emiTargetES("2020",regi2)) ) )** 2;
			p47_emiRescaleCo2TaxES("2030",regi)$((cm_startyear le 2030) AND (p47_emiTargetES("2030",regi))) = max(0.1, ( sum(regi2$regi_group("EUR_regi",regi2),v47_emiTargetMkt.l("2030",regi2,"ES","%cm_emiMktES_type%"))/sum(regi2$regi_group("EUR_regi",regi2),p47_emiTargetES("2030",regi2)) ) )** 2;
		else
			p47_emiRescaleCo2TaxES("2020",regi)$((cm_startyear le 2020) AND (p47_emiTargetES("2020",regi))) = max(0.1, ( sum(regi2$regi_group("EUR_regi",regi2),v47_emiTargetMkt.l("2020",regi2,"ES","%cm_emiMktES_type%"))/sum(regi2$regi_group("EUR_regi",regi2),p47_emiTargetES("2020",regi2)) ) );
			p47_emiRescaleCo2TaxES("2030",regi)$((cm_startyear le 2030) AND (p47_emiTargetES("2030",regi))) = max(0.1, ( sum(regi2$regi_group("EUR_regi",regi2),v47_emiTargetMkt.l("2030",regi2,"ES","%cm_emiMktES_type%"))/sum(regi2$regi_group("EUR_regi",regi2),p47_emiTargetES("2030",regi2)) ) );
		);

$IFTHEN.emiMktES2050 not "%cm_emiMktES2050%" == "off"
$IFTHEN.emiMktES2050_2 NOT "%cm_emiMktES2050%" == "linear"

		if(iteration.val lt 15,
			p47_emiRescaleCo2TaxES("2050",regi)$(p47_emiTargetES("2050",regi)) = max(0.1, ( sum(regi2$regi_group("EUR_regi",regi2),v47_emiTargetMkt.l("2050",regi2,"ES","%cm_emiMktES_type%"))/sum(regi2$regi_group("EUR_regi",regi2),p47_emiTargetES("2050",regi)) ) )** 2;
		else
			p47_emiRescaleCo2TaxES("2050",regi)$(p47_emiTargetES("2050",regi)) = max(0.1, ( sum(regi2$regi_group("EUR_regi",regi2),v47_emiTargetMkt.l("2050",regi2,"ES","%cm_emiMktES_type%"))/sum(regi2$regi_group("EUR_regi",regi2),p47_emiTargetES("2050",regi)) ) );
		);

$ENDIF.emiMktES2050_2
$ENDIF.emiMktES2050

$ENDIF.emiMktEScoop


		p47_emiRescaleCo2TaxES(t,regi)$p47_emiRescaleCo2TaxES(t,regi) =
		max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_emiRescaleCo2TaxES(t,regi)),
			1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
		);


***	updating the ES co2 tax
		pm_taxemiMkt("2005",regi,"ES") = 0;
		pm_taxemiMkt("2010",regi,"ES") = 0;
		pm_taxemiMkt("2015",regi,"ES") = 0;
		pm_taxemiMkt("2020",regi,"ES")$(p47_emiRescaleCo2TaxES("2020",regi) AND p47_emiTargetES("2020",regi)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2020",regi,"ES") * p47_emiRescaleCo2TaxES("2020",regi));
***		pm_taxemiMkt(t,regi,"ES")$((t.val lt 2020) AND (t.val ge cm_startyear) AND (p47_emiTargetES("2020",regi))) = pm_taxemiMkt("2020",regi,"ES")*1.05**(t.val-2020); !! pre 2020: decrease at 5% p.a.
***		!! ES only until 2020 (for bau purposes)
***		pm_taxemiMkt(t,regi,"ES")$((t.val gt 2020) AND (NOT (p47_emiTargetES("2030",regi))))  = pm_taxemiMkt("2020",regi,"ES")*1.0125**(t.val-2020); !! post 2020 in case of 2020 only ES: increase at 1.25% p.a.
		!! ES up to 2030
		pm_taxemiMkt("2030",regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND p47_emiTargetES("2030",regi)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2030",regi,"ES") * p47_emiRescaleCo2TaxES("2030",regi));
***		pm_taxemiMkt(t,regi,"ES")$((t.val gt 2020) AND (t.val lt 2030) AND (t.val ge cm_startyear) AND (p47_emiTargetES("2030",regi)) ) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt("2030",regi,"ES")*(1.05**(t.val-2030))); !! pre 2030: decrease at 5% p.a.
		pm_taxemiMkt(t,regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND (t.val gt 2020) AND (t.val lt 2030) AND (t.val ge cm_startyear)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt("2020",regi,"ES") + (pm_taxemiMkt("2030",regi,"ES")-pm_taxemiMkt("2020",regi,"ES"))/2) ;
***		pm_taxemiMkt(t,regi,"ES")$((t.val gt 2030) AND (p47_emiTargetES("2030",regi)) )  = pm_taxemiMkt("2030",regi,"ES")*1.0125**(t.val-2030); !! post 2030: increase at 1.25% p.a.

$IFTHEN.emiMktES2050 "%cm_emiMktES2050%" == "linear"

***		pm_taxemiMkt(t,regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND (t.val gt 2030) AND (p47_emiTargetES("2030",regi) AND (t.val le 2050)) )  = pm_taxemiMkt("2030",regi,"ES") + (4*sm_DptCO2_2_TDpGtC)*(t.val-2030) ; !! post 2030: 4 €/tCO2 increase per year after 2030
***		pm_taxemiMkt(t,regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND (t.val gt 2050) AND (p47_emiTargetES("2030",regi)) ) = pm_taxemiMkt("2050",regi,"ES")*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.
		pm_taxemiMkt(t,regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND (t.val gt 2030) )  = pm_taxemiMkt("2030",regi,"ES") + (4*sm_DptCO2_2_TDpGtC)*(t.val-2030) ; !! post 2030: 4 €/tCO2 increase per year after 2030

$ELSEIF.emiMktES2050 not "%cm_emiMktES2050%" == "off"
		
		pm_taxemiMkt("2050",regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND p47_emiTargetES("2050",regi)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2050",regi,"ES") * p47_emiRescaleCo2TaxES("2050",regi));
		pm_taxemiMkt(t,regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND (p47_emiTargetES("2050",regi)) AND (t.val gt 2030) AND (t.val lt 2050)) = pm_taxemiMkt("2030",regi,"ES") + ((t.val-2030)/(2050-2030))*(pm_taxemiMkt("2050",regi,"ES")-pm_taxemiMkt("2030",regi,"ES")) ;
***		pm_taxemiMkt(t,regi,"ES")$((p47_emiTargetES("2050",regi)) AND (t.val gt 2030) AND (t.val le 2050)) = pm_taxemiMkt("2050",regi,"ES")*1.05**(t.val-2050); !! 2035 to 2050: increase at 5% p.a.
		pm_taxemiMkt(t,regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND (p47_emiTargetES("2050",regi)) AND (t.val gt 2050)) = pm_taxemiMkt("2050",regi,"ES")*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.

$else.emiMktES2050

		pm_taxemiMkt(t,regi,"ES")$(p47_emiRescaleCo2TaxES("2030",regi) AND (t.val gt 2030) AND (p47_emiTargetES("2030",regi)) )  = pm_taxemiMkt("2030",regi,"ES")*1.0125**(t.val-2030); !! post 2030: increase at 1.25% p.a.

$ENDIF.emiMktES2050

***		assuming other emissions outside the ESD and ETS see prices equal to the ES prices
		pm_taxemiMkt(ttot,regi,"other")$pm_taxemiMkt(ttot,regi,"ES") = pm_taxemiMkt(ttot,regi,"ES");
		
	);
		
    display p47_emiRescaleCo2TaxES,vm_emiTeMkt.l;
    display pm_taxemiMkt;

$ENDIF.emiMktES

***--------------------------------------------------
*** Regional carbon princing
***--------------------------------------------------

$IFTHEN.regicarbonprice not "%cm_regiCO2target%" == "off" 

display pm_taxCO2eq;

*** Initializing co2eq historical and reference prices
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))), !!for region groups
	pm_taxCO2eq(ttot,regi)$(regi_group(ext_regi,regi) AND p47_taxCO2eqBeforeStartYear(ttot,regi)) = p47_taxCO2eqBeforeStartYear(ttot,regi);
	);
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))), !!for single regions
	pm_taxCO2eq(ttot,regi)$(sameas(ext_regi,regi) AND p47_taxCO2eqBeforeStartYear(ttot,regi)) = p47_taxCO2eqBeforeStartYear(ttot,regi);
	);	

*** new energy CO? Would include energy Co2 emissions, cement emissions (check whether they are in vm_emiMac, take vm_emiIndCCS instead?), CDR emissions (maybe take only DAC later as CDR option that belongs to energy system)
*** (vm_emiTe.l(t,all_regi,"co2")+vm_emiMac.l(t,all_regi,"co2cement_process")+vm_emiCdr(t,regi,"co2"))*sm_c_2_co2

***  Calculating the current emission levels
***		for region groups
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))),
	if(sameas(target_type,"budget"), !! budget total CO2 target
		p47_emissionsCurrent(ext_regi) =
			sum(all_regi$regi_group(ext_regi,all_regi),
				sum(t$((t.val ge 2020) AND (t.val le ttot.val)),
					pm_ts(t) * (1 -0.5$(t.val eq 2020 OR t.val eq ttot.val))
					*(v47_emiTarget.l(t, all_regi,emi_type)*sm_c_2_co2)
			));		
	elseif sameas(target_type,"year"), !! year total CO2 target
		p47_emissionsCurrent(ext_regi) = sum(all_regi$regi_group(ext_regi,all_regi), v47_emiTarget.l(ttot, all_regi,emi_type)*sm_c_2_co2);
	);
);


***		for single regions (overwrites region groups)  
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))),
	if(sameas(target_type,"budget"), !! budget target
		p47_emissionsCurrent(ext_regi) =
			sum(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
				sum(t$((t.val ge 2020) AND (t.val le ttot.val)),
					pm_ts(t) * (1 -0.5$(t.val eq 2020 OR t.val eq ttot.val))
					*(v47_emiTarget.l(t, all_regi,emi_type)*sm_c_2_co2)
			));
	elseif sameas(target_type,"year"),
		p47_emissionsCurrent(ext_regi) = sum(all_regi$sameas(ext_regi,all_regi), v47_emiTarget.l(ttot, all_regi,emi_type)*sm_c_2_co2); 
	);
);

	
***  calculating the CO2 tax rescale factor
loop((ttot,ext_regi,target_type,emi_type)$p47_regiCO2target(ttot,ext_regi,target_type,emi_type),		 
	if(iteration.val lt 10,
		p47_factorRescaleCO2Tax(ext_regi) = max(0.1, (p47_emissionsCurrent(ext_regi))/(p47_regiCO2target(ttot,ext_regi,target_type,emi_type)) ) ** 2;
	else
		p47_factorRescaleCO2Tax(ext_regi) = max(0.1, (p47_emissionsCurrent(ext_regi))/(p47_regiCO2target(ttot,ext_regi,target_type,emi_type)) ) ** 1;
	);
	p47_factorRescaleCO2Tax(ext_regi) =
		max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_factorRescaleCO2Tax(ext_regi)),
			1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
		);
);

***	updating the co2 tax
***		for region groups
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))),
	loop(all_regi$regi_group(ext_regi,all_regi),
		pm_taxCO2eq("2050",all_regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,"2050",all_regi) * p47_factorRescaleCO2Tax(ext_regi)); !! 2050 price
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2050)  = p_pvpRegiBeforeStartYear(ttot,regi,"perm") + ((pm_taxCO2eq("2050",all_regi) - pm_taxCO2eq("2015",all_regi))/(2050-2015))*(t.val-2015); !!linear price between 2020 and 2050
		loop(ttot2, 
			break$(ttot2.val gt 2016 AND ttot2.val ge cm_startyear); !!initial free price year
			pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2050)  = ( pm_taxCO2eq(ttot2,all_regi) + pm_taxCO2eqHist(ttot2,all_regi)) + ((pm_taxCO2eq("2050",all_regi) - ( pm_taxCO2eq(ttot2,all_regi) + pm_taxCO2eqHist(ttot2,all_regi)))/(2050-ttot2.val))*(t.val-ttot2.val); !!linear price between first free year and 2050
			);
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2050)  = p_pvpRegiBeforeStartYear("2015",all_regi,"perm") + ((pm_taxCO2eq("2050",all_regi) - p_pvpRegiBeforeStartYear("2015",all_regi,"perm"))/(2050-2015))*(t.val-2015); !!linear price between 2020 and 2050
		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi) + (2*sm_DptCO2_2_TDpGtC)*(t.val-2050); !! post 2050: 2 €/tCO2 increase per year

***		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2051)  = pm_taxCO2eq("2050",all_regi)*1.05**(t.val-2050); !! 2020 to 2050: increase at 5% p.a.
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.

***		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2031)  = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,t,all_regi) * p47_factorRescaleCO2Tax(ext_regi)); !! before 2030
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2030) = pm_taxCO2eq("2030",all_regi)*1.05**(t.val-2030); !! post 2030: increase at 5% p.a.
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.
	);
);
***		for single regions (overwrites region groups)
loop((ttot,ext_regi,target_type,emi_type)$(p47_regiCO2target(ttot,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))),
	loop(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set

		pm_taxCO2eq("2050",all_regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,"2050",all_regi) * p47_factorRescaleCO2Tax(ext_regi)); !! before 2050
		loop(ttot2, 
			break$(ttot2.val gt 2016 AND ttot2.val ge cm_startyear); !!initial free price year
			pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2050)  = ( pm_taxCO2eq(ttot2,all_regi) + pm_taxCO2eqHist(ttot2,all_regi)) + ((pm_taxCO2eq("2050",all_regi) - ( pm_taxCO2eq(ttot2,all_regi) + pm_taxCO2eqHist(ttot2,all_regi)))/(2050-ttot2.val))*(t.val-ttot2.val); !!linear price between first free year and 2050
			);
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2050)  = p_pvpRegiBeforeStartYear("2015",all_regi,"perm") + ((pm_taxCO2eq("2050",all_regi) - p_pvpRegiBeforeStartYear("2015",all_regi,"perm"))/(2050-2015))*(t.val-2015); !!linear price between 2020 and 2050
		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi) + (2*sm_DptCO2_2_TDpGtC)*(t.val-2050); !! post 2050: 2 €/tCO2 increase per year

***		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2051)  = pm_taxCO2eq("2050",all_regi)*1.05**(t.val-2050); !! 2020 to 2050: increase at 5% p.a.
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.

***		pm_taxCO2eq(t,all_regi)$(t.val gt 2016 AND t.val ge cm_startyear AND t.val lt 2031)  = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,t,all_regi) * p47_factorRescaleCO2Tax(ext_regi)); !! before 2030
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2030) = pm_taxCO2eq("2030",all_regi)*1.05**(t.val-2030); !! post 2030: increase at 5% p.a.
***		pm_taxCO2eq(t,all_regi)$(t.val gt 2050) = pm_taxCO2eq("2050",all_regi)*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.
	);
);

display p47_regiCO2target,p47_emissionsCurrent,p47_factorRescaleCO2Tax;
display pm_taxCO2eq;

$ENDIF.regicarbonprice


*** EOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms

