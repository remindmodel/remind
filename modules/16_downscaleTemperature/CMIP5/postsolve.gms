*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

***update regional temperature based on GMT
pm_regionalTemperature(tall,regi)$(tall.val ge 2005) =
  p16_tempRegionalCalibrate2005(regi)
  + pm_tempScaleGlob2Reg(tall,regi) * ( pm_globalMeanTemperature(tall) - pm_globalMeanTemperature("2005"));
