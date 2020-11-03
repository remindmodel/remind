*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
* satisfy dependencies
$ifi not %climate% == 'magicc' abort "module carbonprice=temperatureNotToExceed requires climate=magicc";
$ifi not %cm_magicc_temperatureImpulseResponse% == 'on' abort "module carbonprice=temperatureNotToExceed requires cm_magicc_temperatureImpulseResponse=on";
if(cm_emiscen ne 9,
    abort "module 45=temperatureNotToExceed requires cm_emiscen=9";
);
 

s45_eta = 0.025;       !! Raise if no convergence
s45_itrAdjExp =  0.04; !! Lower if no convergence


* initialize
p45_taxTempLimitLastItr(tall) = 0;
