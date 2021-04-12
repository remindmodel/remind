*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
!! Beutler et al. 2019 (Climeworks)
!!fe demand electricity for ventilation
p33_dac_fedem_el("feels") = 5.28;
!!fe demand heat for material recovery
p33_dac_fedem_heat("fehes") = 21.12;
p33_dac_fedem_heat("fegas") = 21.12;
p33_dac_fedem_heat("feh2s") = 21.12;
p33_dac_fedem_heat("feels") = 21.12;
*** FS: INNOPATHS sensitivity on DAC efficiency
$if not "%cm_INNOPATHS_DAC_eff%" == "off" parameter p33_dac_fedem_fac(entyFeStat) / %cm_INNOPATHS_DAC_eff% /;
$if not "%cm_INNOPATHS_DAC_eff%" == "off" p33_dac_fedem(entyFeStat) = p33_dac_fedem(entyFeStat) * p33_dac_fedem_fac(entyFeStat);
