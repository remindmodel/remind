*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/grades2poly/equations.gms
*NB/LB/BB/GL* 
*' Uranium extraction costs parameterized as 3rd order polynomial with short-term calibrated adjustment costs which capture inertias, e.g. from infrastructure
q31_costFuExPol(ttot,regi,peExPol(enty))$(ttot.val ge cm_startyear)..
  vm_costFuEx(ttot,regi,enty)
  =e=
*NB*111123 this is the long-term marginal extraction cost part
  ( p31_costExPoly(regi,"xi1",enty)
  + p31_costExPoly(regi,"xi2",enty) * v31_fuExtrCum(ttot,regi,enty,"1")
  + p31_costExPoly(regi,"xi3",enty) * v31_fuExtrCum(ttot,regi,enty,"1")**2
  + p31_costExPoly(regi,"xi4",enty) * v31_fuExtrCum(ttot,regi,enty,"1")**3
  )
  *
*NB*111123 this is the short-term adjustment cost part
  (1$(ttot.val eq 2005)
  + ((1-p31_fosadjco_xi5xi6(regi,"xi5",enty))
  + p31_fosadjco_xi5xi6(regi,"xi5",enty) * ((vm_fuExtr(ttot,regi,enty,"1")+1.e-5)/(vm_fuExtr(ttot-1,regi,enty,"1")$(ttot.val gt 2005)+1.e-5))**p31_fosadjco_xi5xi6(regi,"xi6",enty)
  )$(ttot.val gt 2005)
  )
  * vm_fuExtr(ttot,regi,enty,"1")
;

*JH*131202 New 3rd-order polynomial fitted to REMIND data (oil, gas and coal)
*' Oil, gas and coal extraction costs fitted to existing REMIND output as a 3rd-order polynomial with short-term calibrated adjustment costs which capture inertias, e.g. from infrastructure
q31_costfu_ex2(ttot,regi,peFos(enty))$(ttot.val ge cm_startyear)..
  vm_costFuEx(ttot,regi,enty)
  =e=
*NB*111123 this is the long-term marginal extraction cost part
  (
    ( p31_ffPolyCoeffs(regi,enty,"0")
    + p31_ffPolyCoeffs(regi,enty,"1") * v31_fuExtrCum(ttot,regi,enty,"1")
    + p31_ffPolyCoeffs(regi,enty,"2") * v31_fuExtrCum(ttot,regi,enty,"1")**2
    + p31_ffPolyCoeffs(regi,enty,"3") * v31_fuExtrCum(ttot,regi,enty,"1")**3
    )
    *
*NB*111123 this is the short-term adjustment cost part
    (1$(ttot.val eq 2005)
    +(((1-p31_fosadjco_xi5xi6(regi,"xi5",enty))
    + p31_fosadjco_xi5xi6(regi,"xi5",enty) * ((vm_fuExtr(ttot,regi,enty,"1")+1.e-5)/(vm_fuExtr(ttot-1,regi,enty,"1")$(ttot.val gt 2005)+1.e-5))**p31_fosadjco_xi5xi6(regi,"xi6",enty)
    )$(ttot.val gt 2005))
    )
  +
    ( 
      p31_rentdisctot(ttot,enty) *
      ( p31_ffPolyRent(regi,enty,"0")
      + p31_ffPolyRent(regi,enty,"1") * v31_fuExtrCum(ttot,regi,enty,"1")
      )$(v31_fuExtrCum.l(ttot,regi,enty,"1")$(ttot.val ge 2010 and ttot.val le 2150) gt pm_ffPolyCumEx(regi,enty,"min"))
    )
  )
  * vm_fuExtr(ttot,regi,enty,"1")
;

*' Cumulated fuel extraction (oil, gas and coal) is the sum of extraction in each time step multiplied by the time step length.
q31_fuExtrCum(ttot,regi,peEx(enty))$(ttot.val ge cm_startyear)..
  v31_fuExtrCum(ttot,regi,enty,"1")
  =e=
  v31_fuExtrCum(ttot-1,regi,enty,"1")$(ttot.val gt 2005) + pm_ts(ttot)*(vm_fuExtr(ttot,regi,enty,"1")
)
;

*NB* the 2 equations only for determining the regional uranium bounds
q31_mc_dummy(regi,peExPol(enty))..
  v31_fuExtrMC(enty,"1")
  =e=
  p31_costExPoly(regi,"xi1",enty)
    + p31_costExPoly(regi,"xi2",enty) * v31_fuExtrCumMax(regi,enty, "1")
    + p31_costExPoly(regi,"xi3",enty) * v31_fuExtrCumMax(regi,enty, "1")**2
    + p31_costExPoly(regi,"xi4",enty) * v31_fuExtrCumMax(regi,enty, "1")**3
;

q31_totfuex_dummy..
  v31_squaredDiff
  =e=
  (s31_max_disp_peur - sum(regi, v31_fuExtrCumMax(regi, "peur", "1"))) *
  (s31_max_disp_peur - sum(regi, v31_fuExtrCumMax(regi, "peur", "1")))
;

*** EOF ./modules/31_fossil/grades2poly/equations.gms
