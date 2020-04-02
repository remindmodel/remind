*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/postsolve.gms
***  ---------------------------------------------------------
***  Track of changes between iterations
***  ---------------------------------------------------------

*GL* calculate mean square deviation from previous tax revenue as metric for convergence of revenue iteration
p21_deltarev(iteration+1,regi)=sqrt(sum(ttot$(ttot.val ge max(2010,cm_startyear)),sqr(vm_taxrev.l(ttot,regi)*pm_ts(ttot)))/(sum(ttot$(ttot.val ge max(2010,cm_startyear)),1)));
OPTION decimals =5;
display p21_deltarev;
OPTION decimals =3;

*GL* save reference level value of taxes for revenue recycling
*JH* !!Warning!! The same allocation block exists in presolve.gms.
***                Do not forget to update the other file.
p21_taxrevGHG0(ttot,regi) = ( pm_taxCO2eq(ttot,regi) + pm_taxCO2eqSCC(ttot,regi) + pm_taxCO2eqHist(ttot,regi)) * (vm_co2eq.l(ttot,regi) - vm_emiMacSector.l(ttot,regi,"co2luc")$(cm_multigasscen ne 3));
p21_taxrevCO2luc0(ttot,regi) = ( pm_taxCO2eq(ttot,regi) + pm_taxCO2eqSCC(ttot,regi) + pm_taxCO2eqHist(ttot,regi)) * cm_cprice_red_factor * vm_emiMacSector.l(ttot,regi,"co2luc")$(cm_multigasscen ne 3);
p21_taxrevCCS0(ttot,regi) = cm_frac_CCS * pm_data(regi,"omf","ccsinje") * pm_inco0_t(ttot,regi,"ccsinje") 
                            * ( sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf) ) ) )
                            * (1/sm_ccsinjecrate) * sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf) ) ) / pm_dataccs(regi,"quan","1");
p21_taxrevNetNegEmi0(ttot,regi) = cm_frac_NetNegEmi * pm_taxCO2eq(ttot,regi) * v21_emiALLco2neg.l(ttot,regi);
p21_taxrevFEtrans0(ttot,regi) = SUM(feForUe(enty),
                                      (p21_tau_fe_tax_transport(ttot,regi,feForUe) + p21_tau_fe_sub_transport(ttot,regi,feForUe) ) * SUM(se2fe(enty2,enty,te), vm_prodFe.l(ttot,regi,enty2,enty,te))
                                    );
p21_taxrevFEBuildInd0(ttot,regi) = SUM(ppfen(in)$( NOT ppfenFromUe(in)),
                                         (p21_tau_fe_tax_bit_st(ttot,regi,ppfen) + p21_tau_fe_sub_bit_st(ttot,regi,ppfen) ) * vm_cesIO.l(ttot,regi,ppfen)
                                       );
p21_taxrevFE_Es0(ttot,regi) = SUM(fe2es(entyFe,esty,teEs),
                                          (pm_tau_fe_tax_ES_st(ttot,regi,esty) + pm_tau_fe_sub_ES_st(ttot,regi,esty) ) * vm_demFeForEs.L(ttot,regi,entyFe,esty,teEs)
                                       );
p21_taxrevResEx0(ttot,regi) = sum(pe2rlf(peEx(enty),rlf), p21_tau_fuEx_sub(ttot,regi,enty) * vm_fuExtr.l(ttot,regi,enty,rlf));
p21_taxrevPE2SE0(ttot,regi) = SUM(pe2se(enty,enty2,te),
                                    (p21_tau_pe2se_tax(ttot,regi,te) + p21_tau_pe2se_sub(ttot,regi,te) + p21_tau_pe2se_inconv(ttot,regi,te)) * vm_prodSe.l(ttot,regi,enty,enty2,te)
                                  ); 
p21_taxrevXport0(ttot,regi) = SUM(tradePe(enty), p21_tau_XpRes_tax(ttot,regi,enty) * vm_Xport.l(ttot,regi,enty));
p21_taxrevSO20(ttot,regi) = p21_tau_so2_tax(ttot,regi) * vm_emiTe.l(ttot,regi,"so2");
p21_taxrevBio0(ttot,regi) = v21_tau_bio.l(ttot) * vm_fuExtr.l(ttot,regi,"pebiolc","1") * vm_pebiolc_price.l(ttot,regi);
p21_implicitDiscRate0(ttot,regi) = sum(ppfKap(in),  p21_implicitDiscRateMarg(ttot,regi,in)  * vm_cesIO.l(ttot,regi,in) );
***DK: for reporting only
p21_tau_bioenergy_tax(t) = v21_tau_bio.l(t);

*** Save reference level of tax revenues for each iteration
p21_taxrevGHG_iter(iteration+1,ttot,regi) = v21_taxrevGHG.l(ttot,regi);
p21_taxrevCCS_iter(iteration+1,ttot,regi) = v21_taxrevCCS.l(ttot,regi); 
p21_taxrevNetNegEmi_iter(iteration+1,ttot,regi) = v21_taxrevNetNegEmi.l(ttot,regi);
p21_emiALLco2neg0(ttot,regi)          = v21_emiALLco2neg.l(ttot,regi);
p21_taxrevFEtrans_iter(iteration+1,ttot,regi) = v21_taxrevFEtrans.l(ttot,regi); 
p21_taxrevFEBuildInd_iter(iteration+1,ttot,regi) = v21_taxrevFEBuildInd.l(ttot,regi);
p21_taxrevFE_Es_iter(iteration+1,ttot,regi) = v21_taxrevFE_Es.l(ttot,regi) ;
p21_taxrevResEx_iter(iteration+1,ttot,regi) = v21_taxrevResEx.l(ttot,regi);
p21_taxrevPE2SE_iter(iteration+1,ttot,regi) = v21_taxrevPE2SE.l(ttot,regi);
p21_taxrevXport_iter(iteration+1,ttot,regi) = v21_taxrevXport.l(ttot,regi);
p21_taxrevSO2_iter(iteration+1,ttot,regi) = v21_taxrevSO2.l(ttot,regi);
p21_taxrevBio_iter(iteration+1,ttot,regi) = v21_taxrevBio.l(ttot,regi);
p21_implicitDiscRate_iter(iteration+1,ttot,regi) = v21_implicitDiscRate.l(ttot,regi);
*** EOF ./modules/21_tax/on/postsolve.gms
