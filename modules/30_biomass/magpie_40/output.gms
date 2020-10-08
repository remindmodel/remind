*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_4/output.gms
*LB* save data for exogenous biomass module
file p30_fix_costfu_bio;
put p30_fix_costfu_bio;
   loop(ttot$(ttot.val ge 2005),
      loop(regi,
        if( vm_costFuBio.l(ttot,regi) > 0, 
          put 'p30_fix_costfu_bio("' ttot.val:0:0 '","' regi.tl:0:0 '") = ', @70,  vm_costFuBio.l(ttot,regi):15:12, ';' /;
        );
      )
    );
putclose p30_fix_costfu_bio;

*LB* save data for exogenous biomass module
file p30_fix_fuelex;
put p30_fix_fuelex;
   loop(ttot$(ttot.val ge 2005),
     loop(regi,
      loop(peBio(enty),
        loop(rlf,
          if( vm_fuExtr.l(ttot,regi,enty,rlf) > 0, 
            put 'p30_fix_fuelex("' ttot.val:0:0 '","' regi.tl:0:0 '","' enty.tl:0:0 '","' rlf.tl:0:0 '") = ', @70,  vm_fuExtr.l(ttot,regi,enty,rlf):15:12, ';' /;
          );
         )
       )
     )
   );
putclose p30_fix_fuelex;

***----------------------------------------------
*DK: export modelstatus for php-script DK 091211
***----------------------------------------------
file remind_modelstat;
put remind_modelstat;
put o_modelstat /;
putclose;

*** EOF ./modules/30_biomass/magpie_4/output.gms
