*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_4/bounds.gms
*** -------------------------------------------------------------
*** Bounds on pedem
*** -------------------------------------------------------------

*** -------------------------------------------------------------
*** Bounds on 1st generation biomass annual production
*** -------------------------------------------------------------

*** Prescribe upper and lower limit for first generation biomass from 2030/45 on, so REMIND has freedom before.
*** To avoid infeasibilities it was necessary to modify the initial vintage structure for bioeths.
vm_fuExtr.up(t,regi,"pebios","5")$(t.val ge 2045)  = p30_datapebio(regi,"pebios","5","maxprod",t);
vm_fuExtr.up(t,regi,"pebioil","5")$(t.val ge 2030) = p30_datapebio(regi,"pebioil","5","maxprod",t);

if(cm_1stgen_phaseout=0,
    vm_fuExtr.lo(t,regi,"pebios","5")$(t.val ge 2030)  = p30_datapebio(regi,"pebios","5","maxprod",t)*0.9;
    vm_fuExtr.lo(t,regi,"pebioil","5")$(t.val ge 2030) = p30_datapebio(regi,"pebioil","5","maxprod",t)*0.9;
else
    vm_fuExtr.lo(t,regi,"pebios","5")$(t.val eq 2030)  = p30_datapebio(regi,"pebios","5","maxprod",t)*0.9;
    vm_fuExtr.lo(t,regi,"pebioil","5")$(t.val eq 2030) = p30_datapebio(regi,"pebioil","5","maxprod",t)*0.9;
);

*** -------------------------------------------------------------
*** Bounds on 2nd generation biomass annual production
*** -------------------------------------------------------------

*** bound on global annual pebiolc production in EJ/a
s30_max_pebiolc $(cm_bioenergymaxscen=1) = 100;
s30_max_pebiolc $(cm_bioenergymaxscen=2) = 200;
s30_max_pebiolc $(cm_bioenergymaxscen=3) = 300;
s30_max_pebiolc $(cm_bioenergymaxscen=4) = 152;

p30_max200_path(t) = s30_max_pebiolc;

*** bounds until 2025 taken from old 200 EJ maxprod in generisdata_biosupply_grades.prn (EJ/yr)
p30_max200_path("2005") = 68.25;
p30_max200_path("2010") = 100;
p30_max200_path("2015") = 130;
p30_max200_path("2020") = 160;
p30_max200_path("2025") = 190;

*** Use values if they are smaller than the maximal allowed value (s30_max_pebiolc)
*** otherwise limit to maximal allowed value (s30_max_pebiolc)
loop(t,
     if (p30_max200_path(t)<s30_max_pebiolc, 
       p30_max_pebiolc_path_glob(t) = p30_max200_path(t);
     ELSE
       p30_max_pebiolc_path_glob(t) = s30_max_pebiolc;
     );
);

*** Reduce the global upper bound on purpose grown bio-energy by residues, since the total bound applies to the sum of residues and purpose grown
p30_max_pebiolc_path_glob(t) = p30_max_pebiolc_path_glob(t) * sm_EJ_2_TWa -  sum(regi, p30_datapebio(regi,"pebiolc","2","maxprod",t)); 

display p30_max_pebiolc_path_glob;

***-------------------------------------------------------------
*** Calclate regional bounds with equal marginal costs 
*** from global bound (inverting the supply curve)
***-------------------------------------------------------------
loop(ttot$(ttot.val ge cm_startyear),
*** initialization
     p30_max_pebiolc_dummy = 0;
     p30_pebiolc_price_dummy = 0.01;
     while(p30_max_pebiolc_dummy < p30_max_pebiolc_path_glob(ttot),
           loop(regi$(NOT sameas(regi,'JPN')),
*** Avoid execution errors for x**y with x<0 by applying the if-clause
                if( p30_pebiolc_price_dummy > (i30_bioen_price_a(ttot,regi)) * 1.01,
                      p30_fuelex_dummy(regi) = (p30_pebiolc_price_dummy - i30_bioen_price_a(ttot,regi)) / i30_bioen_price_b(ttot,regi);
                 else
                      p30_fuelex_dummy(regi) = 0;
                );
           ); 
*** Exclude JPN to avoid UNDF in p30_max_pebiolc_dummy
           p30_max_pebiolc_dummy = sum(regi, p30_fuelex_dummy(regi));
           p30_pebiolc_price_dummy = p30_pebiolc_price_dummy + 0.001;
     );
     p30_max_pebiolc_path(regi,ttot) = p30_fuelex_dummy(regi);
);

display p30_max_pebiolc_path;
***-------------------------------------------------------------

*** In REMIND there are two grades for fuel extraxtion from pebiolc. The first grade
*** is purpose grown bioenergy, the second grade are residues. The residue grade of
*** pebiolc (pebiolc.2) in REMIND is roughly MAgPIE's residue potential (plus some 
*** extra demand for traditional biomass, see below).

*** Already in the initial years there are technologies in REMIND that demand biomass. 
*** pm_pedem_res contains the biomass demand as it would evolve if all these biomass 
*** technologies that are present in 2005 would phase out (phase-out-trajectory). When
*** calculating the maximal residue potential p30_maxprod_residue we make sure (by
*** applying the max operator) that the resulting residue potential is big enough to 
*** feed these technologies so they do not need to demand purpose-grown biomass.
*** This is necessary, because in the early years MAgPIE's residue potential is smaller 
*** than the initial demand from REMIND's technologies. Except for "biotr" all 
*** technologies present in 2005 are allowed to expand, but the resulting additional 
*** demand for biomass (exceeding the phase-out-trajectory) will then be supplied 
*** from purpose-grown biomass.  

p30_maxprod_residue(ttot,regi)     = max(p30_datapebio(regi,"pebiolc","2","maxprod",ttot), sum(teBioPebiolc, pm_pedem_res(ttot,regi,teBioPebiolc)));
vm_fuExtr.up(t,regi,"pebiolc","2") = p30_maxprod_residue(t,regi)*1.0001;

*** According to EMF guidelines, the upper bound on total (residues+purpose) global
*** biomass production does not include traditional biomass use. Since the demand 
*** for traditional biomass is already supplied by the residue grade we expand the
*** purpose-grown grade by the demand for traditional biomass.

if(cm_bioenergymaxscen>0,
vm_fuExtr.up(t,regi,"pebiolc","1") = p30_max_pebiolc_path(regi,t) + pm_pedem_res(t,regi,"biotr");
);

*** EOF ./modules/30_biomass/magpie_4/bounds.gms
