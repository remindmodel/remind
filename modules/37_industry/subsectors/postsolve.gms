*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/postsolve.gms

*** calculation of FE Industry Prices (useful for internal use and reporting 
*** purposes)
pm_FEPrice(ttot,regi,entyFE,"indst",emiMkt)$( abs(qm_budget.m(ttot,regi)) gt sm_eps )
  = q37_demFeIndst.m(ttot,regi,entyFE,emiMkt)
  / qm_budget.m(ttot,regi);

*** calculate reporting parameters for FE per subsector and SE origin to make R
*** reporting easier
*** total FE per energy carrier and emissions market in industry (sum over 
*** subsectors)
o37_demFeIndTotEn(ttot,regi,entyFE,emiMkt)
  = sum((fe2ppfEn37(entyFE,in),secInd37_2_pf(secInd37,in),
                         secInd37_emiMkt(secInd37,emiMkt)), 
      (vm_cesIO.l(ttot,regi,in)
      +pm_cesdata(ttot,regi,in,"offset_quantity"))
    );

*** share of subsector in FE industry energy carriers and emissions markets
o37_shIndFE(ttot,regi,entyFE,secInd37,emiMkt)$( 
                                    o37_demFeIndTotEn(ttot,regi,entyFE,emiMkt) )
  = sum(( fe2ppfEn37(entyFE,in),
          secInd37_2_pf(secInd37,in),
          secInd37_emiMkt(secInd37,emiMkt)), 
      (vm_cesIO.l(ttot,regi,in)
      +pm_cesdata(ttot,regi,in,"offset_quantity"))
    )
  / o37_demFeIndTotEn(ttot,regi,entyFE,emiMkt);


*** FE per subsector and energy carriers
o37_demFeIndSub(ttot,regi,entySE,entyFE,secInd37,emiMkt)
  = sum(secInd37_emiMkt(secInd37,emiMkt),
      o37_shIndFE(ttot,regi,entyFE,secInd37,emiMkt)
    * vm_demFeSector.l(ttot,regi,entySE,entyFE,"indst",emiMkt)
  );


*** FE per subsector whose emissions can be captured (helper parameter for 
*** calculation of industry captured CO2 below)
o37_demFeIndSub_SecCC(ttot,regi,secInd37) 
  = sum((se2fe(entySE,entyFE,te),macBaseInd37(entyFE,secInd37),
                                 sector2emiMkt("indst",emiMkt)), 
      o37_demFeIndSub(ttot,regi,entySE,entyFE,secInd37,emiMkt)
    );

*** industry captured CO2
pm_IndstCO2Captured(ttot,regi,entySE,entyFE,secInd37,emiMkt)$(
                        entyFECC37(entyFE) 
                        AND o37_demFeIndSub_SecCC(ttot,regi,secInd37)
                        AND macBaseInd37(entyFE,secInd37)) 
  = sum( secInd37_2_emiInd37(secInd37,emiInd37)$(emiInd37_fuel(emiInd37)), 
      vm_emiIndCCS.l(ttot,regi,emiInd37)
    )
  * o37_demFeIndSub(ttot,regi,entySE,entyFE,secInd37,emiMkt) 
  / o37_demFeIndSub_SecCC(ttot,regi,secInd37);



display vm_demFENonEnergySector.l;

*** to be deleted before merge of feedstocks implementation, just checking the values
*** check FE w/o non-energy use calculation
p37_FE_noNonEn(t,regi,enty,enty2,emiMkt) = 		  
          sum(sector$(entyFE2Sector(enty2,sector) AND sector2emiMkt(sector,emiMkt)), 
            vm_demFeSector.l(t,regi,enty,enty2,sector,emiMkt)
            - sum(entyFE2sector2emiMkt_NonEn(enty2,sector,emiMkt),
              vm_demFENonEnergySector.l(t,regi,enty,enty2,sector,emiMkt)));


*** check chemical process emissions calculation
p37_Emi_ChemProcess(t,regi,emi,emiMkt) =
    sum((entyFE2sector2emiMkt_NonEn(entyFE,sector,emiMkt), 
        se2fe(entySE,entyFE,te)), 
      vm_demFENonEnergySector.l(t,regi,entySE,entyFE,sector,emiMkt)
       * pm_emifacNonEnergy(t,regi,entySE,entyFE,sector,emi)
    );


*** check biogenic and synthetic carbon in feedstocks that generate negative emissions
p37_CarbonFeed_CDR(t,regi,emiMkt) = sum( entyFE2sector2emiMkt_NonEn(entyFE,"indst",emiMkt),
                                      sum( se2fe(entySE, entyFE, te)$(entySEBio(entySE) OR entySESyn(entySE)),
                                        vm_FeedstocksCarbon.l(t,regi,entySE,entyFE,emiMkt)
                                    ));


*** check feedstock correction term of left hand-side of Indst FE2CES equation 
p37_IndFeBal_FeedStock_LH(ttot,regi,entyFE,emiMkt) = sum(se2fe(entySE,entyFE,te),
                                                        vm_demFENonEnergySector.l(ttot,regi,entySE,entyFE,"indst",emiMkt)
                                                          );
*** check feedstock correction term of left right-side of Indst FE2CES equation 
p37_IndFeBal_FeedStock_RH(ttot,regi,entyFE,emiMkt) = sum((fe2ppfEN(entyFE,ppfen_industry_dyn37(in)),              
                                                          secInd37_emiMkt(secInd37,emiMkt),secInd37_2_pf(secInd37,in_chemicals_37(in))), 
       
      ( vm_cesIO.l(ttot,regi,in) 
      + pm_cesdata(ttot,regi,in,"offset_quantity")
      )
      * p37_chemicals_feedstock_share(ttot,regi)
      );

*** check FE combustion emissions with non-energy use correction
p37_EmiEnDemand_NonEnCorr(t,regi) = sum(emiMkt,
                                    sum(se2fe(enty,enty2,te),
                                      pm_emifac(t,regi,enty,enty2,te,"co2")
		                                  * sum(sector$(entyFE2Sector(enty2,sector) AND sector2emiMkt(sector,emiMkt)), 
                                          vm_demFeSector.l(t,regi,enty,enty2,sector,emiMkt)
*** substract FE used for non-energy, does not lead to energy-related emissions
                                      - sum(entyFE2sector2emiMkt_NonEn(enty2,sector,emiMkt),
                                          vm_demFENonEnergySector.l(t,regi,enty,enty2,sector,emiMkt))
                                        )
                                      )
                                    );

p37_EmiEnDemand(t,regi) = sum(emiMkt,
                            sum(se2fe(enty,enty2,te),
                                      pm_emifac(t,regi,enty,enty2,te,"co2")
		                                  * sum(sector$(entyFE2Sector(enty2,sector) AND sector2emiMkt(sector,emiMkt)), 
                                          vm_demFeSector.l(t,regi,enty,enty2,sector,emiMkt)
                                        )
                                      )
                                    );


*** EOF ./modules/37_industry/subsectors/postsolve.gms

