*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/equations.gms
$ontext

q36_logitProba(t,regi,entyFe,esty,teEs,in)$(t36_hist_last(t) AND regi_dyn36(regi) AND fe2ces_dyn36(entyFe,esty,teEs,in))..
v36_logitproba(t,regi,entyFe,esty,teEs,in)

=e=
exp ( v36_beta(regi,in) * p36_techCosts(t,regi,entyFe,esty,teEs))
/
sum (fe2ces_dyn36_2(entyFe2,esty2,teEs2,in),  exp ( v36_beta(regi,in) * p36_techCosts(t,regi,entyFe2,esty2,teEs2)))
;


q36_optimCondition(t,regi,in)$(t36_hist_last(t) AND regi_dyn36(regi) AND inViaEs_dyn36(in))..
sum (fe2ces_dyn36(entyFe,esty,teEs,in), 
       p36_techCosts(t,regi,entyFe,esty,teEs)
       * p36_shFeCes(t,regi,entyFe,in,teEs)
       )
=e=
sum (fe2ces_dyn36(entyFe,esty,teEs,in),
       p36_techCosts(t,regi,entyFe,esty,teEs)
       * v36_logitproba(t,regi,entyFe,esty,teEs,in)
       )
;

q36_dummy ..
v36_dummy =e= sum ((regi,in)$(regi_dyn36(regi) AND inViaEs_dyn36(in)),
                  v36_beta(regi,in)
                  )
;
                  
model m36_LogitParam / q36_logitProba, q36_optimCondition, q36_dummy/ ;

$offtext
*** EOF ./modules/36_buildings/services_with_capital/equations.gms
