*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
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
		pm_taxCO2eqRegi(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
		pm_taxCO2eqHist(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
		pm_taxCO2eqSCC(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;

***		pm_taxCO2eq(t,regi)$((t.val ge cm_startyear) and ETS_regi(ETS_mkt,regi)) = 0;
***		pm_taxCO2eqHist(t,regi)$((t.val ge cm_startyear) and ETS_regi(ETS_mkt,regi)) = 0;

*** Initializing emi market historical and reference prices
		pm_taxemiMkt(ttot,regi,emiMkt)$(ETS_regi(ETS_mkt,regi) AND p47_taxemiMktBeforeStartYear(ttot,regi,emiMkt)) = p47_taxemiMktBeforeStartYear(ttot,regi,emiMkt);
		pm_taxemiMkt("2005",regi,"ETS")$(ETS_regi(ETS_mkt,regi) and (cm_startyear le 2005)) = 0;
		pm_taxemiMkt("2010",regi,"ETS")$(ETS_regi(ETS_mkt,regi) and (cm_startyear le 2010))  = 15*sm_DptCO2_2_TDpGtC;
		pm_taxemiMkt("2015",regi,"ETS")$(ETS_regi(ETS_mkt,regi) and (cm_startyear le 2015))  = 8*sm_DptCO2_2_TDpGtC;
		pm_taxemiMkt("2020",regi,"ETS")$(ETS_regi(ETS_mkt,regi) and (cm_startyear le 2020))  = 41.28*sm_DptCO2_2_TDpGtC; !! 2018 =~ 16.5€/tCO2, 2019 =~ 25€/tCO2, 2020 =~ 25€/tCO2, 2021 =~ 53.65€/tCO2, 2022 =~ 80€/tCO2 -> average 2020 = 40€/tCO2 -> 40*1.032 $/tCO2 = 41.28 $/t CO2

***  calculating ETS CO2 emission target
		loop((ttot,target_type,emi_type)$pm_regiCO2ETStarget(ttot,target_type,emi_type),
			if(sameas(target_type,"budget"), !! budget total CO2 target
				pm_emiCurrentETS(ETS_mkt) = 
					sum(regi$ETS_regi(ETS_mkt,regi),
						sum(ttot2$((ttot2.val ge 2020) AND (ttot2.val le ttot.val)),
							pm_ts(ttot2)
***						sum(t$((t.val ge 2020) AND (t.val le ttot.val)),
***							pm_ts(t) * (1 -0.5$(t.val eq 2020 OR t.val eq ttot.val))
							*(v47_emiTargetMkt.l(ttot2, regi,"ETS",emi_type)*sm_c_2_co2)
					));		
			elseif sameas(target_type,"year"), !! year total CO2 target
				pm_emiCurrentETS(ETS_mkt) = sum(regi$ETS_regi(ETS_mkt,regi), v47_emiTargetMkt.l(ttot, regi,"ETS", emi_type)*sm_c_2_co2);
			);
		);
	
***  calculating ETS CO2 tax rescale factor
		loop((ttot,target_type,emi_type)$pm_regiCO2ETStarget(ttot,target_type,emi_type),
           if(sameas(target_type,"budget"),
		   		pm_ETSTarget_dev(ETS_mkt) = (pm_emiCurrentETS(ETS_mkt) - pm_regiCO2ETStarget(ttot,target_type,emi_type))/pm_regiCO2ETStarget(ttot,target_type,emi_type);		 
			);
			if(sameas(target_type,"year"),
	            pm_ETSTarget_dev(ETS_mkt) = (pm_emiCurrentETS(ETS_mkt) - pm_regiCO2ETStarget(ttot,target_type,emi_type))/pm_emissionsRefYearETS(ETS_mkt);		 
			);	
			pm_ETSTarget_dev_iter(iteration, ETS_mkt) = pm_ETSTarget_dev(ETS_mkt);
			if(iteration.val lt 10,
				pm_emiRescaleCo2TaxETS(ETS_mkt) = max(0.1, 1+pm_ETSTarget_dev(ETS_mkt)) ** 2;
			else
				pm_emiRescaleCo2TaxETS(ETS_mkt) = max(0.1, 1+pm_ETSTarget_dev(ETS_mkt)) ** 1;
			);
			if(sameas(target_type,"year"),
			    pm_emiRescaleCo2TaxETS(ETS_mkt) = pm_emiRescaleCo2TaxETS(ETS_mkt) ** 2;
			);				

*** dampen rescale factor with increasing iterations to help convergence if the last two iteration deviations where not in the same direction 
            if((iteration.val gt 3) and (pm_ETSTarget_dev_iter(iteration, ETS_mkt)*pm_ETSTarget_dev_iter(iteration+1, ETS_mkt) < 0),
				pm_emiRescaleCo2TaxETS(ETS_mkt)$pm_emiRescaleCo2TaxETS(ETS_mkt) =
					max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,pm_emiRescaleCo2TaxETS(ETS_mkt)),
						1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
					);
			);
		);

***	updating the ETS co2 tax
		loop((ttot,target_type,emi_type)$pm_regiCO2ETStarget(ttot,target_type,emi_type),		

***			target year
			pm_taxemiMkt(ttot,regi,"ETS")$ETS_regi(ETS_mkt,regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,ttot,regi,"ETS") * pm_emiRescaleCo2TaxETS(ETS_mkt));

***         2025 to target year
***			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt 2020) AND (t.val ge cm_startyear) AND (t.val lt ttot.val)) =  pm_taxemiMkt("2020",regi,"ETS") + ((pm_taxemiMkt(ttot,regi,"ETS") - pm_taxemiMkt("2020",regi,"ETS"))/(ttot.val-2020))*(t.val-2020); !!linear price between 2020 and ttot (ex. 2030)

***         2025 to target year (linear assuming projection from 2010)
			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt 2020) AND (t.val ge cm_startyear) AND (t.val lt ttot.val)) =  pm_taxemiMkt("2010",regi,"ETS") + ((pm_taxemiMkt(ttot,regi,"ETS") - pm_taxemiMkt("2010",regi,"ETS"))/(ttot.val-2010))*(t.val-2010); !!linear price between 2025 and target year assuming projection from 2010

***			target year to 2055			
$IFTHEN.ETS_postTargetIncrease "%cm_ETS_postTargetIncrease%" == "linear"
***			keep same slope as 2010 to target year variation
            pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt ttot.val) AND (t.val le 2055)) = pm_taxemiMkt("2010",regi,"ETS") + ((pm_taxemiMkt(ttot,regi,"ETS") - pm_taxemiMkt("2010",regi,"ETS"))/(ttot.val-2010))*(t.val-2010); !!linear price between ttot and 2055
$ELSEIF.ETS_postTargetIncrease not "%cm_ETS_postTargetIncrease%" == "off"
***			keep fixed per year increase
			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt ttot.val) AND (t.val le 2055)) = pm_taxemiMkt(ttot,regi,"ETS") + (%cm_ETS_postTargetIncrease% * sm_DptCO2_2_TDpGtC)*(t.val-ttot.val); !! post ttot (ex. in between 2030 and 2055): 2 €/tCO2 increase per year
$ENDIF.ETS_postTargetIncrease

***			2055 onward
			pm_taxemiMkt(t,regi,"ETS")$((ETS_regi(ETS_mkt,regi)) AND (t.val gt 2055)) = pm_taxemiMkt("2055",regi,"ETS") + (%cm_ETS_post2055Increase%*sm_DptCO2_2_TDpGtC)*(t.val-2055); !! post ttot (ex. 2055): 2 €/tCO2 increase per year
		);
	);		
*** forcing floor price for UKI (UK has a CO2 price floor of ~€20 €/tCO2e since 2013). The Carbon Price Floor was introduced in 2013 at a rate of £16 (€18.05) per tonne of carbon dioxide-equivalent (tCO2e), and was set to increase to £30 (€33.85) by 2020. However, the government more recently decided to cap the Carbon Price Floor at £18.08 (€20.40) till 2021.
***     	pm_taxemiMkt(t,regi,"ETS")$((t.val ge 2015) AND (sameas(regi,"UKI")) AND ETS_regi(ETS_mkt,regi)) = max(20*sm_DptCO2_2_TDpGtC, pm_taxemiMkt(t,regi,"ETS"));
		
***    display pm_regiCO2ETStarget, pm_emiCurrentETS, pm_ETSTarget_dev, pm_emissionsRefYearETS, pm_emiRescaleCo2TaxETS;
***    display pm_taxemiMkt;

$ENDIF.emiMktETS



$IFTHEN.emiMktES not "%cm_emiMktES%" == "off" 

	loop((regi)$pm_emiTargetESR("2030",regi),

*** Removing the economy wide co2 tax parameters for regions within the ES
		pm_taxCO2eq(ttot,regi) = 0;
		pm_taxCO2eqRegi(ttot,regi) = 0;
		pm_taxCO2eqHist(ttot,regi) = 0;
		pm_taxCO2eqSCC(ttot,regi) = 0;

***  calculating the ES CO2 tax rescale factor
***		pm_ESRTarget_dev(t,regi)$pm_emiTargetESR(t,regi) = (v47_emiTargetMkt.l(t,regi,"ES","%cm_emiMktES_type%")-pm_emiTargetESR(t,regi))/pm_emiTargetESR(t,regi);
		pm_ESRTarget_dev(t,regi)$pm_emiTargetESR(t,regi) = (v47_emiTargetMkt.l(t,regi,"ES","%cm_emiMktES_type%")-pm_emiTargetESR(t,regi))/(pm_emissionsRefYearESR("2005",regi)/sm_c_2_co2);
		pm_ESRTarget_dev_iter(iteration, t,regi) = pm_ESRTarget_dev(t,regi);	
		if(iteration.val lt 15,
			pm_emiRescaleCo2TaxESR("2020",regi)$((cm_startyear le 2020) AND (pm_emiTargetESR("2020",regi))) = max(0.1, 1+pm_ESRTarget_dev("2020",regi) ) ** 4;
			pm_emiRescaleCo2TaxESR("2030",regi)$((cm_startyear le 2030) AND (pm_emiTargetESR("2030",regi))) = max(0.1, 1+pm_ESRTarget_dev("2030",regi) ) ** 4;
		else
			pm_emiRescaleCo2TaxESR("2020",regi)$((cm_startyear le 2020) AND (pm_emiTargetESR("2020",regi))) = max(0.1, 1+pm_ESRTarget_dev("2020",regi) ) ** 2;
			pm_emiRescaleCo2TaxESR("2030",regi)$((cm_startyear le 2030) AND (pm_emiTargetESR("2030",regi))) = max(0.1, 1+pm_ESRTarget_dev("2030",regi) ) ** 2;
		);

$IFTHEN.emiMktES2050 not "%cm_emiMktES2050%" == "off"
$IFTHEN.emiMktES2050_2 not "%cm_emiMktES2050%" == "linear"
$IFTHEN.emiMktES2050_3 not "%cm_emiMktES2050%" == "linear2010to2050"

		if(iteration.val lt 15,
			pm_emiRescaleCo2TaxESR("2050",regi)$(pm_emiTargetESR("2050",regi)) = max(0.1, 1+pm_ESRTarget_dev("2050",regi) ) ** 4;
		else
			pm_emiRescaleCo2TaxESR("2050",regi)$(pm_emiTargetESR("2050",regi)) = max(0.1, 1+pm_ESRTarget_dev("2050",regi) ) ** 2;
		);

$ENDIF.emiMktES2050_3
$ENDIF.emiMktES2050_2
$ENDIF.emiMktES2050

$IFTHEN.emiMktEScoop not "%cm_emiMktEScoop%" == "off"
*** alternative cooperative ES solution: calculating the ES CO2 tax rescale factor
		pm_ESRTarget_dev(t,regi)$pm_emiTargetESR(t,regi) = 
			( sum(regi2$regi_group("EU27_regi",regi2),
  				v47_emiTargetMkt.l(t,regi2,"ES","%cm_emiMktES_type%")
			  ) - 
			  sum(regi2$regi_group("EU27_regi",regi2),
  				pm_emiTargetESR(t,regi2)
			  ) 
			)/
***			sum(regi2$regi_group("EU27_regi",regi2),
***				pm_emiTargetESR(t,regi2)
***			)
			sum(regi2$regi_group("EU27_regi",regi2),
				(pm_emissionsRefYearESR("2005",regi2)/sm_c_2_co2)
			)
		; 
		pm_ESRTarget_dev_iter(iteration, t,regi) = pm_ESRTarget_dev(t,regi);	

		if(iteration.val lt 15,
			pm_emiRescaleCo2TaxESR("2020",regi)$((cm_startyear le 2020) AND (pm_emiTargetESR("2020",regi))) = max(0.1, 1+pm_ESRTarget_dev("2020",regi) ) ** 4;
			pm_emiRescaleCo2TaxESR("2030",regi)$((cm_startyear le 2030) AND (pm_emiTargetESR("2030",regi))) = max(0.1, 1+pm_ESRTarget_dev("2030",regi) ) ** 4;
		else
			pm_emiRescaleCo2TaxESR("2020",regi)$((cm_startyear le 2020) AND (pm_emiTargetESR("2020",regi))) = max(0.1, 1+pm_ESRTarget_dev("2020",regi) ) ** 2;
			pm_emiRescaleCo2TaxESR("2030",regi)$((cm_startyear le 2030) AND (pm_emiTargetESR("2030",regi))) = max(0.1, 1+pm_ESRTarget_dev("2030",regi) ) ** 2;
		);

$IFTHEN.emiMktES2050 not "%cm_emiMktES2050%" == "off"
$IFTHEN.emiMktES2050_2 NOT "%cm_emiMktES2050%" == "linear"
$IFTHEN.emiMktES2050_3 not "%cm_emiMktES2050%" == "linear2010to2050"

		if(iteration.val lt 15,
			pm_emiRescaleCo2TaxESR("2050",regi)$(pm_emiTargetESR("2050",regi)) = max(0.1, 1+pm_ESRTarget_dev("2050",regi) ) ** 2;
		else
			pm_emiRescaleCo2TaxESR("2050",regi)$(pm_emiTargetESR("2050",regi)) = max(0.1, 1+pm_ESRTarget_dev("2050",regi) ) ** 1;
		);

$ENDIF.emiMktES2050_3
$ENDIF.emiMktES2050_2
$ENDIF.emiMktES2050

$ENDIF.emiMktEScoop

*** dampen rescale factor with increasing iterations to help convergence if the last two iteration deviations where not in the same direction 
        loop(t$pm_emiRescaleCo2TaxESR(t,regi),
			if((iteration.val gt 3) and (pm_ESRTarget_dev_iter(iteration,t,regi)*pm_ESRTarget_dev_iter(iteration-1,t,regi) < 0),
				pm_emiRescaleCo2TaxESR(t,regi) =
					max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,pm_emiRescaleCo2TaxESR(t,regi)),
						1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
					);
			);
		);

***	updating the ES co2 tax
		pm_taxemiMkt("2005",regi,"ES") = 0;
		pm_taxemiMkt("2010",regi,"ES") = 0;
		pm_taxemiMkt("2015",regi,"ES") = 0;

$IFTHEN.emiMktES2020price "%cm_emiMktES2020price%" == "target"
		pm_taxemiMkt("2020",regi,"ES")$(pm_emiRescaleCo2TaxESR("2020",regi) AND pm_emiTargetESR("2020",regi)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2020",regi,"ES") * pm_emiRescaleCo2TaxESR("2020",regi));
$ELSEIF.emiMktES2020price not "%cm_emiMktES2020price%" == "off"
		pm_taxemiMkt("2020",regi,"ES")$(pm_emiRescaleCo2TaxESR("2020",regi) AND pm_emiTargetESR("2020",regi)) = %cm_emiMktES2020price%*sm_DptCO2_2_TDpGtC;
		pm_ESRTarget_dev("2020",regi) = 0;
$ENDIF.emiMktES2020price

***		pm_taxemiMkt(t,regi,"ES")$((t.val lt 2020) AND (t.val ge cm_startyear) AND (pm_emiTargetESR("2020",regi))) = pm_taxemiMkt("2020",regi,"ES")*1.05**(t.val-2020); !! pre 2020: decrease at 5% p.a.
***		!! ES only until 2020 (for bau purposes)
***		pm_taxemiMkt(t,regi,"ES")$((t.val gt 2020) AND (NOT (pm_emiTargetESR("2030",regi))))  = pm_taxemiMkt("2020",regi,"ES")*1.0125**(t.val-2020); !! post 2020 in case of 2020 only ES: increase at 1.25% p.a.
		!! ES up to 2030
		pm_taxemiMkt("2030",regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND pm_emiTargetESR("2030",regi)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2030",regi,"ES") * pm_emiRescaleCo2TaxESR("2030",regi));
***		pm_taxemiMkt(t,regi,"ES")$((t.val gt 2020) AND (t.val lt 2030) AND (t.val ge cm_startyear) AND (pm_emiTargetESR("2030",regi)) ) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt("2030",regi,"ES")*(1.05**(t.val-2030))); !! pre 2030: decrease at 5% p.a.
		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (t.val gt 2020) AND (t.val lt 2030) AND (t.val ge cm_startyear)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt("2020",regi,"ES") + (pm_taxemiMkt("2030",regi,"ES")-pm_taxemiMkt("2020",regi,"ES"))/2) ;
***		pm_taxemiMkt(t,regi,"ES")$((t.val gt 2030) AND (pm_emiTargetESR("2030",regi)) )  = pm_taxemiMkt("2030",regi,"ES")*1.0125**(t.val-2030); !! post 2030: increase at 1.25% p.a.

$IFTHEN.emiMktES2050 "%cm_emiMktES2050%" == "linear"

		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (t.val gt 2030) AND  (t.val le 2055))  = pm_taxemiMkt("2030",regi,"ES") + (%cm_ESD_postTargetIncrease%*sm_DptCO2_2_TDpGtC)*(t.val-2030) ; !! post 2030 and before 2055: 8 €/tCO2 increase per year after 2030
		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (t.val gt 2055) )  = pm_taxemiMkt("2055",regi,"ES") + (%cm_ESD_post2055Increase%*sm_DptCO2_2_TDpGtC)*(t.val-2055) ; !! post 2055: 2 €/tCO2 increase per year after 2030

$ELSEIF.emiMktES2050 "%cm_emiMktES2050%" == "linear2010to2050"

		pm_taxemiMkt("2030",regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND pm_emiTargetESR("2030",regi)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2030",regi,"ES") * pm_emiRescaleCo2TaxESR("2030",regi));
		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (t.val gt 2020) AND  (t.val le 2055)) = pm_taxemiMkt("2010",regi,"ES") + ((t.val - 2010)* (pm_taxemiMkt("2030",regi,"ES") - pm_taxemiMkt("2010",regi,"ES"))/(2030-2010));
		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (t.val gt 2055) )  = pm_taxemiMkt("2055",regi,"ES") + (%cm_ESD_post2055Increase%*sm_DptCO2_2_TDpGtC)*(t.val-2055) ; !! post 2055: 2 €/tCO2 increase per year after 2030

$ELSEIF.emiMktES2050 not "%cm_emiMktES2050%" == "off"
		
		pm_taxemiMkt("2050",regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND pm_emiTargetESR("2050",regi)) = max(1* sm_DptCO2_2_TDpGtC, pm_taxemiMkt_iteration(iteration,"2050",regi,"ES") * pm_emiRescaleCo2TaxESR("2050",regi));
		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (pm_emiTargetESR("2050",regi)) AND (t.val gt 2030) AND (t.val lt 2050)) = pm_taxemiMkt("2030",regi,"ES") + ((t.val-2030)/(2050-2030))*(pm_taxemiMkt("2050",regi,"ES")-pm_taxemiMkt("2030",regi,"ES"));
***		pm_taxemiMkt(t,regi,"ES")$((pm_emiTargetESR("2050",regi)) AND (t.val gt 2030) AND (t.val le 2050)) = pm_taxemiMkt("2050",regi,"ES")*1.05**(t.val-2050); !! 2035 to 2050: increase at 5% p.a.
		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (pm_emiTargetESR("2050",regi)) AND (t.val gt 2050)) = pm_taxemiMkt("2050",regi,"ES")*1.0125**(t.val-2050); !! post 2050: increase at 1.25% p.a.

$else.emiMktES2050

		pm_taxemiMkt(t,regi,"ES")$(pm_emiRescaleCo2TaxESR("2030",regi) AND (t.val gt 2030) AND (pm_emiTargetESR("2030",regi)) )  = pm_taxemiMkt("2030",regi,"ES")*1.0125**(t.val-2030); !! post 2030: increase at 1.25% p.a.

$ENDIF.emiMktES2050

***		assuming other emissions outside the ESD and ETS see prices equal to the ES prices
		pm_taxemiMkt(ttot,regi,"other")$pm_taxemiMkt(ttot,regi,"ES") = pm_taxemiMkt(ttot,regi,"ES");
		
	);
		
***    display pm_emiTargetESR,vm_emiTeMkt.l, pm_emiTargetESR, pm_ESRTarget_dev, pm_emissionsRefYearESR, pm_emiRescaleCo2TaxESR;
***    display pm_taxemiMkt;

$ENDIF.emiMktES

***--------------------------------------------------
*** Regional carbon princing
***--------------------------------------------------

$IFTHEN.regicarbonprice not "%cm_regiCO2target%" == "off" 

*** display pm_taxCO2eq;

*** Initializing co2eq historical and reference prices
loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))), !!for region groups
	pm_taxCO2eq(t,regi)$(regi_group(ext_regi,regi) AND p47_taxCO2eqBeforeStartYear(t,regi)) = p47_taxCO2eqBeforeStartYear(t,regi);
    pm_taxCO2eqRegi(t,regi)$(regi_group(ext_regi,regi)) = 0;
	);
loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))), !!for single regions
	pm_taxCO2eq(t,regi)$(sameas(ext_regi,regi) AND p47_taxCO2eqBeforeStartYear(t,regi)) = p47_taxCO2eqBeforeStartYear(t,regi);
    pm_taxCO2eqRegi(t,regi)$(sameas(ext_regi,regi)) = 0;
	);

** Fixing European 2020 carbon price to 20€/t CO2
pm_taxCO2eq("2020",regi)$(regi_group("EUR_regi",regi) and (cm_startyear le 2020)) =  20*sm_DptCO2_2_TDpGtC;

***  Calculating the current emission levels
***		for region groups
loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))),
	if(sameas(target_type,"budget"), !! budget total CO2 target
		pm_emissionsCurrent(ext_regi,ttot,ttot2) =
			sum(all_regi$regi_group(ext_regi,all_regi),
				sum(ttot3$((ttot3.val ge ttot.val) AND (ttot3.val le ttot2.val)),
					pm_ts(ttot3) * (1 -0.5$(ttot3.val eq ttot.val OR ttot3.val eq ttot2.val))
					*(v47_emiTarget.l(ttot3, all_regi,emi_type)*sm_c_2_co2)
			));		
	elseif sameas(target_type,"year"), !! year total CO2 target
* calculate emissions in target year
		pm_emissionsCurrent(ext_regi,ttot,ttot2) = sum(all_regi$regi_group(ext_regi,all_regi), v47_emiTarget.l(ttot2, all_regi,emi_type)*sm_c_2_co2);
* calculate emissions in 2015 (or cm_startyear), used to determine target compliance for year targets
        pm_emissionsRefYear(ext_regi,ttot,ttot2) = sum(all_regi$regi_group(ext_regi,all_regi), 
			sum(ttot3$(ttot3.val eq max(2015,cm_startyear)), !! v47_emiTarget is not defined for years before cm_startyear
				v47_emiTarget.l(ttot3, all_regi,emi_type)
			)*sm_c_2_co2)
		;	
	);
);

***		for single regions (overwrites region groups)  
loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))),
	if(sameas(target_type,"budget"), !! budget target
		pm_emissionsCurrent(ext_regi,ttot,ttot2) =
			sum(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
				sum(ttot3$((ttot3.val ge ttot.val) AND (ttot3.val le ttot2.val)),
					pm_ts(ttot3) * (1 -0.5$(ttot3.val eq ttot.val OR ttot3.val eq ttot2.val))
					*(v47_emiTarget.l(ttot3, all_regi,emi_type)*sm_c_2_co2)
			));
	elseif sameas(target_type,"year"),
* calculate emissions in target year
		pm_emissionsCurrent(ext_regi,ttot,ttot2) = sum(all_regi$sameas(ext_regi,all_regi), v47_emiTarget.l(ttot2, all_regi,emi_type)*sm_c_2_co2);
* calculate emissions in 2015, used to determine target compliance for year targets
		pm_emissionsRefYear(ext_regi,ttot,ttot2) = sum(all_regi$sameas(ext_regi,all_regi), 
			sum(ttot3$(ttot3.val eq max(2015,cm_startyear)), !! v47_emiTarget is not defined for years before cm_startyear
				v47_emiTarget.l(ttot3, all_regi,emi_type)
			)*sm_c_2_co2)
		;
	);
);

*** calculate target deviation
loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type)),
* for budget targets, target deviation is difference of current budget to target budget normalized by target budget
	if(sameas(target_type,"budget"),
		pm_regiTarget_dev(ext_regi, ttot, ttot2) = (pm_emissionsCurrent(ext_regi,ttot,ttot2)-pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) ) / pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type);
	);
* for year targets, target deviation is difference of current emissions in target year to target emissions normalized by 2015 emissions
	if(sameas(target_type,"year"),
		pm_regiTarget_dev(ext_regi, ttot, ttot2) = (pm_emissionsCurrent(ext_regi,ttot,ttot2)-pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) ) / pm_emissionsRefYear(ext_regi,ttot,ttot2);
***		pm_regiTarget_dev(ext_regi, ttot, ttot2) = (pm_emissionsCurrent(ext_regi,ttot,ttot2)-pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) ) / pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type);
	);
* save regional target deviation across iterations for debugging of target convergence issues
	pm_regiTarget_dev_iter(iteration, ext_regi, ttot, ttot2) = pm_regiTarget_dev(ext_regi, ttot, ttot2);
);


***  calculating the CO2 tax rescale factor
loop((ttot,ttot2,ext_regi,target_type,emi_type)$pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type),
*** co2 price updating rule for budget targets
	if(sameas(target_type,"budget"), !! budget target
		if(iteration.val lt 10,
			pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2) = (1+pm_regiTarget_dev(ext_regi, ttot, ttot2)) ** 2;
		else
			pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2) = (1+pm_regiTarget_dev(ext_regi, ttot, ttot2)) ** 1;
		);
	);
*** co2 price updating rule for year targets
	if(sameas(target_type,"year"), !! year target
		if(iteration.val lt 10,
*** rescale factor for year targets a bit higher given a certain target deviation because pm_regiTarget_dev is normalized to reference year emissions such that it will usually not be higher than 1 at maximum
			pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2) = (1+pm_regiTarget_dev(ext_regi, ttot, ttot2)) ** 4;
		else
			pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2) = (1+pm_regiTarget_dev(ext_regi, ttot, ttot2)) ** 2;
		);
	);
*** dampen rescale factor with increasing iterations to help convergence if the last two iteration deviations where not in the same direction 
	if((iteration.val gt 3) and (pm_regiTarget_dev_iter(iteration,ext_regi,ttot,ttot2)*pm_regiTarget_dev_iter(iteration-1,ext_regi,ttot,ttot2) < 0),
	  pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2) =
	    max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2)),1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01));
	);
);

***display pm_taxCO2eq_iteration;
  
***	updating the co2 tax
***		for region groups
loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))),
	loop(all_regi$regi_group(ext_regi,all_regi),
*** terminal year price
		pm_taxCO2eq(ttot2,all_regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,ttot2,all_regi) * pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2));
***	linear price between first free year and terminal year
		loop(ttot3,
			break$((ttot3.val ge ttot.val) and (ttot3.val ge cm_startyear)); !!initial free price year
			s47_prefreeYear = ttot3.val;
		);
        loop(ttot3$(ttot3.val eq s47_prefreeYear),
			pm_taxCO2eq(t,all_regi)$((t.val gt ttot3.val) AND (t.val lt ttot2.val))  = (pm_taxCO2eq(ttot3,all_regi) + pm_taxCO2eqHist(ttot3,all_regi)) + ((pm_taxCO2eq(ttot2,all_regi) - ( pm_taxCO2eq(ttot3,all_regi) + pm_taxCO2eqHist(ttot3,all_regi)))/(ttot2.val-ttot3.val))*(t.val-ttot3.val); 
		);	
*** fixed year increase after terminal year price (cm_postTargetIncrease €/tCO2 increase per year)
		pm_taxCO2eq(t,all_regi)$(t.val gt ttot2.val) = pm_taxCO2eq(ttot2,all_regi) + (cm_postTargetIncrease*sm_DptCO2_2_TDpGtC)*(t.val-ttot2.val);
	);
);
***		for single regions (overwrites region groups)
loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))),
	loop(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
*** terminal year price
		pm_taxCO2eq(ttot2,all_regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq_iteration(iteration,ttot2,all_regi) * pm_factorRescaleCO2Tax(ext_regi,ttot,ttot2));
***	linear price between first free year and terminal year
		loop(ttot3,
			break$((ttot3.val ge ttot.val) and (ttot3.val ge cm_startyear)); !!initial free price year
			s47_prefreeYear = ttot3.val;
		);
		loop(ttot3$(ttot3.val eq s47_prefreeYear),
			pm_taxCO2eq(t,all_regi)$((t.val gt ttot3.val) AND (t.val lt ttot2.val))  = (pm_taxCO2eq(ttot3,all_regi) + pm_taxCO2eqHist(ttot3,all_regi)) + ((pm_taxCO2eq(ttot2,all_regi) - ( pm_taxCO2eq(ttot3,all_regi) + pm_taxCO2eqHist(ttot3,all_regi)))/(ttot2.val-ttot3.val))*(t.val-ttot3.val); 
		);
*** fixed year increase after terminal year price (cm_postTargetIncrease €/tCO2 increase per year)
		pm_taxCO2eq(t,all_regi)$(t.val gt ttot2.val) = pm_taxCO2eq(ttot2,all_regi) + (cm_postTargetIncrease*sm_DptCO2_2_TDpGtC)*(t.val-ttot2.val);
	);
);


*** display pm_regiCO2target,pm_emissionsCurrent,pm_emissionsRefYear,pm_regiTarget_dev,pm_factorRescaleCO2Tax;
*** display pm_taxCO2eq;

$ENDIF.regicarbonprice



***---------------------------------------------------------------------------
*** Non-market based Efficiency Targets:
***---------------------------------------------------------------------------


$ifthen.cm_implicitFE "%cm_implicitFE%" == "exoTax"
*** Exogenous FE implicit tax

*** saving previous iteration value for implicit tax revenue recycling
	p47_implFETax0(t,regi) = sum(enty2$entyFE(enty2), p47_implFETax(t,regi,enty2) * sum(se2fe(enty,enty2,te), vm_prodFe.l(t,regi,enty,enty2,te)));

*** setting exogenous tax level
***		for region groups
	loop((ttot,ext_regi,FEtarget_sector)$(p47_implFEExoTax(ttot,ext_regi,FEtarget_sector) AND (NOT(all_regi(ext_regi)))),
		loop(all_regi$regi_group(ext_regi,all_regi),
			p47_implFETax(ttot2,all_regi,entyFe)$((ttot2.val ge ttot.val) AND FEtarget_sector2entyFe(FEtarget_sector,entyFe)) = p47_implFEExoTax(ttot,ext_regi,FEtarget_sector) * sm_DpGJ_2_TDpTWa;
		);
	);

***		for single regions
	loop((ttot,ext_regi,FEtarget_sector)$(p47_implFEExoTax(ttot,ext_regi,FEtarget_sector) AND (all_regi(ext_regi))),
		loop(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
			p47_implFETax(ttot2,all_regi,entyFe)$((ttot2.val ge ttot.val) AND FEtarget_sector2entyFe(FEtarget_sector,entyFe)) = p47_implFEExoTax(ttot,ext_regi,FEtarget_sector) * sm_DpGJ_2_TDpTWa;
		);
	);
	
***	display p47_implFETax,p47_implFETax0;

$elseif.cm_implicitFE "%cm_implicitFE%" == "FEtarget"
*** Endogenous FE implicit tax calculate to reach total FE target

*** Updating original target to include bunkers and non-energy use
p47_implFETarget_extended(ttot,ext_regi)$p47_implFETarget(ttot,ext_regi) = p47_implFETarget(ttot,ext_regi) 
*** bunkers
  + sum(regi$regi_group(ext_regi,regi), sum(se2fe(entySe,entyFe,te), vm_demFeSector.l(ttot,regi,entySe,entyFe,"trans","other")) )
*** non-energy use
  + p47_nonEnergyUse(ttot,ext_regi)
  ;

*** initialize tax value for first iteration
if(iteration.val eq 1,
***		for region groups
	loop((ttot,ext_regi)$(p47_implFETarget(ttot,ext_regi) AND (NOT(all_regi(ext_regi)))),
		loop(all_regi$regi_group(ext_regi,all_regi),
			p47_implFETax(t,all_regi,entyFe)$((t.val ge ttot.val)) = 0.1;
			p47_implFETax(t,all_regi,entyFe)$((t.val eq ttot.val-5)) = 0.05;
		);
	);
***		for single regions (overwrites region groups)  
	loop((ttot,ext_regi,target_type,emi_type)$(p47_implFETarget(ttot,ext_regi) AND (all_regi(ext_regi))),
		loop(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
			p47_implFETax(t,all_regi,entyFe)$((t.val ge ttot.val)) = 0.1;
			p47_implFETax(t,all_regi,entyFe)$((t.val eq ttot.val-5)) = 0.05;
		);
	);	
);

*** saving previous iteration value for implicit tax revenue recycling
p47_implFETax_prevIter(t,all_regi,entyFe) = p47_implFETax(t,all_regi,entyFe);
p47_implFETax0(t,regi) = sum(enty2$entyFE(enty2), p47_implFETax(t,regi,enty2) * sum(se2fe(enty,enty2,te), vm_prodFe.l(t,regi,enty,enty2,te)));

***  Calculating current FE level
***		for region groups
loop((ttot,ext_regi)$(p47_implFETarget(ttot,ext_regi) AND (NOT(all_regi(ext_regi)))),
  p47_implFETargetCurrent(ext_regi) = sum(all_regi$regi_group(ext_regi,all_regi), sum(ttot2$sameas(ttot2,ttot), sum(se2fe(enty,entyFe,te), vm_prodFe.l(ttot2,all_regi,enty,entyFe,te))));
);
***		for single regions (overwrites region groups)  
loop((ttot,ext_regi)$(p47_implFETarget(ttot,ext_regi) AND (all_regi(ext_regi))),
  p47_implFETargetCurrent(ext_regi) = sum(all_regi$sameas(ext_regi,all_regi), sum(ttot2$sameas(ttot2,ttot), sum(se2fe(enty,entyFe,te), vm_prodFe.l(ttot2,all_regi,enty,entyFe,te))));
);

***  calculating efficiency directive targets implicit tax rescale
loop((ttot,ext_regi)$p47_implFETarget(ttot,ext_regi),	
  if(iteration.val lt 10,
  		p47_implFETax_Rescale(ext_regi) = max(0.1, ( p47_implFETargetCurrent(ext_regi) / p47_implFETarget_extended(ttot,ext_regi) )) ** 3; !! current final energy levels minus target 
  elseif(iteration.val lt 15),
  		p47_implFETax_Rescale(ext_regi) = max(0.1, ( p47_implFETargetCurrent(ext_regi) / p47_implFETarget_extended(ttot,ext_regi) )) ** 2; !! current final energy levels minus target 
  else 
        p47_implFETax_Rescale(ext_regi) = max(0.1, p47_implFETargetCurrent(ext_regi) / p47_implFETarget_extended(ttot,ext_regi));
  );  
  p47_implFETax_Rescale(ext_regi) =
	max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p47_implFETax_Rescale(ext_regi)),
		1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
	);
);

***	updating efficiency directive targets implicit tax
***		for region groups
loop((ttot,ext_regi)$(p47_implFETarget(ttot,ext_regi) AND (NOT(all_regi(ext_regi)))),
	loop(all_regi$regi_group(ext_regi,all_regi),
    	p47_implFETax(t,all_regi,entyFe)$((t.val ge ttot.val)) = max(1e-10, p47_implFETax_prevIter(t,all_regi,entyFe) * p47_implFETax_Rescale(ext_regi)); !! assuring that the updated tax is positive, otherwise other policies like the carbon tax are already enough to achieve the efficiency target
		p47_implFETax(t,all_regi,entyFe)$((t.val eq ttot.val-5)) = p47_implFETax(ttot,all_regi,entyFe)/2;
  );
);
***		for single regions (overwrites region groups)
loop((ttot,ext_regi,target_type,emi_type)$(p47_implFETarget(ttot,ext_regi) AND (all_regi(ext_regi))),
	loop(all_regi$sameas(ext_regi,all_regi), !! trick to translate the ext_regi value to the all_regi set
    	p47_implFETax(t,all_regi,entyFe)$((t.val ge ttot.val)) = max(1e-10, p47_implFETax_prevIter(t,all_regi,entyFe) * p47_implFETax_Rescale(ext_regi));
		p47_implFETax(t,all_regi,entyFe)$((t.val eq ttot.val-5)) = p47_implFETax(ttot,all_regi,entyFe)/2;
  );
);

*** saving iteration level for efficiency directive targets implicit tax (for debugging purposes only)
p47_implFETax_iter(iteration,ttot,all_regi,entyFe) = p47_implFETax(ttot,all_regi,entyFe);
p47_implFETax_Rescale_iter(iteration,ext_regi) = p47_implFETax_Rescale(ext_regi);
p47_implFETargetCurrent_iter(iteration,ext_regi) = p47_implFETargetCurrent(ext_regi);

*** display p47_implFETargetCurrent, p47_implFETarget, p47_implFETarget_extended, p47_implFETax_prevIter, p47_implFETax, p47_implFETax_Rescale, p47_implFETax_Rescale_iter, p47_implFETax_iter, p47_implFETargetCurrent_iter, p47_implFETax0;

$endIf.cm_implicitFE


*** parameter to track value of emissions in regipol module over iterations
*** track "grossEnCO2_noBunkers" emissions as this calculation (see regiCarbonPrice/equations.gms) involves parameters from the last iteration
*** such that v47_emiTarget level value may deviate from the value after the last iteration
p47_emiTarget_grossEnCO2_noBunkers_iter(iteration,t,regi) = 
*** total net CO2 energy CO2 (w/o DAC accounting of synfuels) 
	vm_emiTe.l(t,regi,"co2")
*** DAC accounting of synfuels: remove CO2 of vm_emiCDR (which is negative) from vm_emiTe which is not stored in vm_co2CCS
	+  vm_emiCdr.l(t,regi,"co2") * (1-pm_share_CCS_CCO2(t,regi))
*** add pe2se BECCS
	+  sum(emi2te(enty,enty2,te,enty3)$(teBio(te) AND teCCS(te) AND sameAs(enty3,"cco2")), vm_emiTeDetail.l(t,regi,enty,enty2,te,enty3)) * pm_share_CCS_CCO2(t,regi)
*** add industry CCS with hydrocarbon fuels from biomass (industry BECCS) or synthetic origin 
	+  sum( (entySe,entyFe,secInd37,emiMkt)$(NOT (entySeFos(entySe))),
		pm_IndstCO2Captured(t,regi,entySe,entyFe,secInd37,emiMkt)) * pm_share_CCS_CCO2(t,regi)
*** remove bunker emissions
	-  sum(se2fe(enty,enty2,te), pm_emifac(t,regi,enty,enty2,te,"co2") * vm_demFeSector.l(t,regi,enty,enty2,"trans","other"))
;


***---------------------------------------------------------------------------
*** Exogenous CO2 tax level:
***---------------------------------------------------------------------------

$ifThen.regiExoPrice not "%cm_regiExoPrice%" == "off"
loop((ttot,ext_regi)$p47_exoCo2tax(ext_regi,ttot),
  pm_taxCO2eqHist(ttot,regi)$(regi_group(ext_regi,regi) and ttot.val ge cm_startyear) = 0;
  pm_taxCO2eq(ttot,regi)$(regi_group(ext_regi,regi) and ttot.val ge cm_startyear) = p47_exoCo2tax(ext_regi,ttot)*sm_DptCO2_2_TDpGtC;
);
display 'update of CO2 prices due to exogenously given CO2 prices in p47_exoCo2tax', pm_taxCO2eq;
$endIf.regiExoPrice

*** EOF ./modules/47_regipol/regiCarbonPrice/postsolve.gms

