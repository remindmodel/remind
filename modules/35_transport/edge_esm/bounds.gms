*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/bounds.gms

* Specify amount of syn- and biofuels to be used in transport
vm_shBioFe.lo(t,regi)$(t.val > 2020) = 0.1;
vm_shBioFe.lo(t,regi)$(t.val > 2025) = 0.2;
vm_shBioFe.lo(t,regi)$(t.val > 2030) = 0.3;

vm_shSynSe.lo(t,regi)$(t.val > 2020) = 0.1;
vm_shSynSe.lo(t,regi)$(t.val > 2025) = 0.2;
vm_shSynSe.lo(t,regi)$(t.val > 2030) = 0.4;

* do not allow hydrogen to come from fossil sources in the future
loop(regi,
    loop(pe2se(entyPe, "seh2", te),
	vm_prodSe.up(t,regi,entyPe,"seh2",te)$(t.val > 2020) = vm_prodSe.l("2020",regi,entyPe,"seh2",te);
	);
);

* vm_cesIO.up(t,regi,ppfen_dyn35)$(t.val > 2020) = p35_demLimit(t,regi,"gdp_SSP2","Smart_lifestyles_Electricity_push",ppfen_dyn35);
*** EOF ./modules/35_transport/edge_esm/bounds.gms
