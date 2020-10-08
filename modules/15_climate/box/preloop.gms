*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/preloop.gms
*JeS* initialize forcing target parameters that are adapted after each negishi iteration with values of previous run
Execute_Loadpoint 'input' s15_gr_forc_kyo_nte_gdx = s15_gr_forc_kyo_nte;
Execute_Loadpoint 'input' s15_gr_forc_kyo_gdx = s15_gr_forc_kyo;

s15_gr_forc_kyo_nte  = s15_gr_forc_nte - 0.25;
s15_gr_forc_kyo      =  s15_gr_forc_os - 0.17;

if (cm_gdximport_target eq 1,
   if ( ((s15_gr_forc_kyo_nte_gdx < 1.5*s15_gr_forc_kyo_nte) AND (s15_gr_forc_kyo_nte_gdx > 0.5*s15_gr_forc_kyo_nte)),
      s15_gr_forc_kyo_nte=s15_gr_forc_kyo_nte_gdx;
   );
   if ( ((s15_gr_forc_kyo_gdx < 1.5*s15_gr_forc_kyo) AND (s15_gr_forc_kyo_gdx > 0.5*s15_gr_forc_kyo)),
      s15_gr_forc_kyo=s15_gr_forc_kyo_gdx;
   );
);

display s15_gr_forc_kyo_nte, s15_gr_forc_kyo;

s15_RPCTA2     = s15_tsens-s15_RPCTA1;
p15_epsilon(ta10) = s15_deltat_box*s15_ca0 + s15_ca1*s15_ctau1*(exp(-s15_deltat_box*(ord(ta10)-1)/s15_ctau1) - exp(-s15_deltat_box*(ord(ta10)/s15_ctau1))) + s15_ca2*s15_ctau2*(exp(-s15_deltat_box*(ord(ta10)-1)/s15_ctau2) - exp(-s15_deltat_box*(ord(ta10)/s15_ctau2))) + s15_ca3*s15_ctau3*(exp(-s15_deltat_box*(ord(ta10)-1)/s15_ctau3) - exp(-s15_deltat_box*(ord(ta10)/s15_ctau3)));
display p15_epsilon;

*** taken from box-model.inc ----------------------------------------
v15_forcComp.fx(ta10,'oghg_nokyo') = p15_oghgf_h2ostr(ta10)+p15_oghgf_o3trp(ta10)+p15_oghgf_minaer(ta10)+p15_oghgf_nitaer(ta10)+p15_oghgf_montreal(ta10)+p15_oghgf_o3str(ta10)+p15_oghgf_luc(ta10)+p15_oghgf_crbbb(ta10);
v15_forcComp.fx(ta10,'oghg_nokyo_rcp') = p15_oghgf_h2ostr(ta10)+p15_oghgf_o3trp(ta10)+p15_oghgf_montreal(ta10)+p15_oghgf_o3str(ta10)+p15_oghgf_crbbb(ta10); 
v15_forcComp.fx(ta10,'oghg_kyo')   = p15_oghgf_pfc(ta10)+p15_oghgf_hfc(ta10)+p15_oghgf_sf6(ta10);
*** end of stuff taken from box-model.inc ---------------------------

*** taken from couple.inc ----------------------------------------
*--- b) interpolation for linking (annual resolution of climate modules)
loop(ttot,
	loop(ta10$((ttot.val le ta10.val) AND (pm_ttot_val(ttot+1) ge ta10.val)),
		p15_interpol(ta10) = (p15_ta_val(ta10)-pm_ttot_val(ttot))/(pm_ttot_val(ttot+1)-pm_ttot_val(ttot));
	);
);
display p15_interpol;

*** end of stuff taken from couple.inc ----------------------------------------
*** EOF ./modules/15_climate/box/preloop.gms
