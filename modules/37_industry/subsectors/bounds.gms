*** SOF ./modules/37_industry/subsectors/bounds.gms

*** FIXME
!! $include "./modules/37_industry/subsectors/input/vm_cesIO_scales.inc";
vm_cesIO.scale(ttot(t2),regi,in_industry_dyn37(in))$(
                                        NOT tsu(t2) AND vm_cesIO.l(t2,regi,in) )
  = sum(tttot(t)$( NOT tsu(t) ), vm_cesIO.l(t,regi,in))
  / (card(ttot) - card(tsu));

*** Include upper bounds on secondary steel production, due to scarcity of
*** steel scrap.
$ifthen.secondary_steel_bound "%c37_secondary_steel_bound%" == "yearly"
vm_cesIO.up(ttot,regi,"ue_steel_secondary")
  = min(
      vm_cesIO.up(ttot,regi,"ue_steel_secondary"),
      p37_cesIO_up_steel_secondary(ttot,regi,"%cm_GDPscen%")
    );
$endif.secondary_steel_bound

vm_cesIO.lo(t,regi,in_industry_dyn37(in))$( 
                             t.val gt 2005 AND NOT vm_cesIO.lo(t,regi,in) ne 0 )
  = 1e-12$( NOT pm_cesdata(t,regi,in,"offset_quantity") )
  - pm_cesdata(t,regi,in,"offset_quantity")$(
                                      pm_cesdata(t,regi,in,"offset_quantity") );

*** EOF ./modules/37_industry/subsectors/bounds.gms
