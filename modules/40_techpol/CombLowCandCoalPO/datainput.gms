*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/CombLowCandCoalPO/datainput.gms
*cb see supplementary graphs of http://www.nature.com/doifinder/10.1038/nclimate2514 for context
*cb targets for renewable upscaling: CSP and SPV from plausible extrapolation of current trends, Wind taken from Optimal immediate policy run (slightly optimistic at beginning)
p40_NewRenBound("2015","csp")=2.267;
p40_NewRenBound("2015","spv")=180;
p40_NewRenBound("2015","wind")=506.022;
p40_NewRenBound("2020","csp")=4.5;
p40_NewRenBound("2020","spv")=400;
p40_NewRenBound("2020","wind")=826.341;
p40_NewRenBound("2025","csp")=8.5;
p40_NewRenBound("2025","spv")=610;
p40_NewRenBound("2025","wind")=1208.034;
p40_NewRenBound("2030","csp")=18.5;
p40_NewRenBound("2030","spv")=900;
p40_NewRenBound("2030","wind")=1646.939;

*cb plausible, quite conservative upscaling (much lower than in optimal immediate)
p40_NewRenBound("2020","bioftcrec")=2.4;
p40_NewRenBound("2025","bioftcrec")=18.4;
p40_NewRenBound("2030","bioftcrec")=84.5;
p40_NewRenBound("2020","ngccc")=2;
p40_NewRenBound("2025","ngccc")=10;
p40_NewRenBound("2030","ngccc")=50;

*cb targets from plausible extrapolation
p40_NewRenBound("2015","apCarElT")=0.000923077;
p40_NewRenBound("2020","apCarElT")=0.004615385;
p40_NewRenBound("2025","apCarElT")=0.015384615;
p40_NewRenBound("2030","apCarElT")=0.041538462;


*** EOF ./modules/40_techpol/CombLowCandCoalPO/datainput.gms
