*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/none/datainput.gms


* initialize regipol target deviation parameter
pm_regiTarget_dev(ext_regi,ttot,ttot2) = 0;


*** Region-specific datainput (with hard-coded regions)

*** FS: scale down capacity factor for coal power in Germany in the near-term based on observed values in 2020 (~0.35 CF)
*** https://static.agora-energiewende.de/fileadmin/Projekte/2021/2020_01_Jahresauswertung_2020/200_A-EW_Jahresauswertung_2020_WEB.pdf

*** do this only in non-baseline runs for now to not mess with the calibration, the if clause can be removed (or changes moved to mrremind) once covid-corrected calibration input data is there

if( cm_emiscen ne 1,
pm_cf("2020",regi,"pc")$(sameAs(regi,"DEU")) = 0.35;
pm_cf("2025",regi,"pc")$(sameAs(regi,"DEU")) = 0.35;
pm_cf("2030",regi,"pc")$(sameAs(regi,"DEU")) = 0.4;
);


$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off" 
*** Changing Germany and France refineries emission factors to avoid negative emissions on pe2se (changing from 18.4 to 20 zeta joule = 20/31.7098 = 0.630719841 Twa = 0.630719841 * 3.66666666666666 * 1000 * 0.03171  GtC/TWa = 73.33 GtC/TWa)
  pm_emifac(ttot,regi,"peoil","seliqfos","refliq","co2")$(sameas(regi,"DEU") OR sameas(regi,"FRA")) = 0.630719841;
*** Changing Germany and UKI solids emissions factors to be in line with CRF numbers (changing from 26.1 to 29.27 zeta joule = 0.922937989 TWa = 107.31 GtC/TWa)
  pm_emifac(ttot,regi,"pecoal","sesofos","coaltr","co2")$(sameas(regi,"DEU") OR sameas(regi,"UKI")) = 0.922937989;
$endif.altFeEmiFac

*** EOF ./modules/47_regipol/none/datainput.gms
