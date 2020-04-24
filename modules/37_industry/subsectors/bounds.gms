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
$elseif.secondary_steel_bound "%c37_secondary_steel_bound%" == "scenario"
if (1 eq cm_emiscen,
  !! In no-policy scenarios, tight bounds representing usual scrap recycling 
  !! rates apply.  Only 10% of the difference between projected secondary 
  !! steel production and the upper bound with increased recycling rates are 
  !! available for increased production. 
  vm_cesIO.up(t,regi,"ue_steel_secondary")
    = ( ( p37_cesIO_up_steel_secondary(t,regi,"%cm_GDPscen%")
        / p29_fedemand(t,regi,"%cm_GDPscen%","ue_steel_secondary")
        - 1
        )
      / 10
      + 1
      )
    * p29_fedemand(t,regi,"%cm_GDPscen%","ue_steel_secondary");
else
  !! In policy scenarios, secondary steel production can be increased up to the 
  !! limit of theoretical scrap availability.
  vm_cesIO.up(t,regi,"ue_steel_secondary")
    = p37_cesIO_up_steel_secondary(t,regi,"%cm_GDPscen%");
);
$endif.secondary_steel_bound

vm_cesIO.lo(t,regi,in_industry_dyn37(in))$( vm_cesIO.lo(t,regi,in) ne 0 )
  = 1e-12$( NOT pm_cesdata(t,regi,in,"offset_quantity") )
  - pm_cesdata(t,regi,in,"offset_quantity")$(
                                      pm_cesdata(t,regi,in,"offset_quantity") );

*** EOF ./modules/37_industry/subsectors/bounds.gms
