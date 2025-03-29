*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/utilitarian/equations.gms

*' @equations
***---------------------------------------------------------------------------
*' The objective of the optimization is to maximize the total discounted intertemporal utility.
*' It is summed over all regions. 
***---------------------------------------------------------------------------
q02_welfareGlob..
    vm_welfareGlob
  =e=
    sum(regi, pm_w(regi)*v02_welfare(regi) )
;

***---------------------------------------------------------------------------
*' Total discounted intertemporal regional welfare calculated from per capita
*' consumption summing over all time steps taking into account the pure time
*' preference rate.  Assuming an intertemporal elasticity of substitution of 1,
*' it holds:
***---------------------------------------------------------------------------
q02_welfare(regi) ..
  v02_welfare(regi) 
  =e=
    sum(ttot$( ttot.val ge 2005 ),
      pm_welf(ttot)
    * pm_ts(ttot)
    / ((1 + pm_prtp(regi)) ** (pm_ttot_val(ttot) - 2005))
    * ( ( pm_pop(ttot,regi) 
        * ( ( ( ( vm_cons(ttot,regi)
            / pm_pop(ttot,regi)
        )
         ** (1 - 1 / pm_ies(regi))
          - 1
          )
        / (1 - 1 / pm_ies(regi))
        )$( pm_ies(regi) ne 1 )
      + log(vm_cons(ttot,regi) / pm_pop(ttot,regi))$( pm_ies(regi) eq 1 )
          )
        )
$ifthen %cm_INCONV_PENALTY% == "on"
      - v02_inconvPen(ttot,regi)
      - v02_inconvPenSolidsBuild(ttot,regi)
$endif
$ifthen.INCONV_bioSwitch not "%cm_INCONV_PENALTY_FESwitch%" == "off"
        !! inconvenience cost for fuel switching in FE between fossil,
        !! biogenic, synthetic solids, liquids and gases across sectors and
        !! emissions markets
      - sum((entySe,entyFe,te,sector,emiMkt)$(
                                    se2fe(entySe,entyFe,te)
                                AND entyFe2Sector(entyFe,sector) 
                                AND sector2emiMkt(sector,emiMkt) 
                                AND (entySeBio(entySe) OR  entySeFos(entySe)) ),
          v02_NegInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
          + v02_PosInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
          )
          / 1e3 !! heuristically determined rescaling factor so the dampening doesn't dominate the transformation
          * pm_demFeTotal0(ttot,regi) / pm_demFeTotal0(ttot,"%cm_INCONV_PENALTY_FESwitchRegi%") !! scale by relative total FE demand
$endif.INCONV_bioSwitch
$ifthen not "%cm_seFeSectorShareDevMethod%" == "off"
        !! penalizing secondary energy share deviation in sectors  
        - vm_penSeFeSectorShareDevCost(ttot,regi)
$endif
      )
    )
;

***---------------------------------------------------------------------------
*' Calculation of the inconvenience penalty:
***---------------------------------------------------------------------------
$IFTHEN.INCONV %cm_INCONV_PENALTY% == "on"
q02_inconvPen(t,regi)$(t.val > 2005)..
  v02_inconvPen(t,regi)
  =g=
*' local air pollution / inconvenience for all entySe production except for coaltr and biotrmod solids, wich are treated separately (see below)
  SUM(pe2se(enty,entySe,te)$( NOT (sameas(te,"coaltr") OR sameas(te,"biotrmod") ) ),
    p02_inconvpen_lap(t,regi,te) * vm_prodSe(t,regi,enty,entySe,te)
  )
;

q02_inconvPenSolidsBuild(t,regi)$(t.val > 2005)..
  v02_inconvPenSolidsBuild(t,regi)
  =g=
*' Local air pollution and inconvenience of using coal and (modern) biomass: inconvenience penalty applies only for use in residential/buildings
*' The inconvenience of using traditional biomass are accounted for in v02_inconvPen, and thus additional to the penalty on using solids in residential
  p02_inconvpen_lap(t,regi,"coaltr") * vm_demFeSector(t,regi,"sesofos","fesos","build","ES")
  + p02_inconvpen_lap(t,regi,"biotrmod") * vm_demFeSector(t,regi,"sesobio","fesos","build","ES")
;
$ENDIF.INCONV

*' @stop

*** small inconvenience penalty for increasing/decreasing biomass/synfuel use
*** between two time steps in buildings and industry and emissison markets
*** necessary to avoid switching behavior in sectors and emissions markets
*** between time steps as those sectors and markets do not have se2fe capcities
$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "constant"
q02_inconvPenFeBioSwitch(ttot,regi,entySe,entyFe,te,sector,emiMkt)$(
                                  ttot.val ge cm_startyear
                              AND se2fe(entySe,entyFe,te) 
                              AND entyFe2Sector(entyFe,sector) 
                              AND sector2emiMkt(sector,emiMkt) 
                              AND (entySeBio(entySe) OR  entySeFos(entySe)) ) ..
    vm_demFeSector(ttot,regi,entySe,entyFe,sector,emiMkt) 
  - vm_demFeSector(ttot-1,regi,entySe,entyFe,sector,emiMkt)
  + v02_NegInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
  - v02_PosInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
  =e=
  0
;
$ELSEIF.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "linear"
q02_inconvPenFeBioSwitch(ttot,regi,entySe,entyFe,te,sector,emiMkt)$(
                                  ttot.val ge cm_startyear
                              AND ttot.val < 2150
                              AND se2fe(entySe,entyFe,te) 
                              AND entyFe2Sector(entyFe,sector) 
                              AND sector2emiMkt(sector,emiMkt) 
                              AND (entySeBio(entySe) OR  entySeFos(entySe)) ) ..
  (vm_demFeSector(ttot+1,regi,entySe,entyFe,sector,emiMkt)
  - vm_demFeSector(ttot,regi,entySe,entyFe,sector,emiMkt))
  - (vm_demFeSector(ttot,regi,entySe,entyFe,sector,emiMkt) 
  - vm_demFeSector(ttot-1,regi,entySe,entyFe,sector,emiMkt))
  + v02_NegInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
  - v02_PosInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
  =e=
  0
;
$ENDIF.INCONV_bioSwitch

*** EOF ./modules/02_welfare/utilitarian/equations.gms
