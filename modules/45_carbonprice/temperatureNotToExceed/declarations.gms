*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
parameters
p45_taxTempLimit(tall) "tax for Temperature limit [1000 $/tC]"
p45_taxTempLimitLastItr(tall) "tax for Temperature limit, last iteration [1000 $/tC]"

s45_taxTempLimitConvMaxDeviation  "limit for temperature deviation"
s45_eta              "inverse steepness of damage function at temperature limit (logistic function). Raise if no convergence" 
s45_itrAdjExp       "exponent for iterative adjustment of taxes. Lower if no convergence."
;
