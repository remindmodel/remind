*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/equations.gms

*' @equations

*' calculate emission cap in absolute terms (1e9 converts GtCeq to tonnes of CO2-equivalent and 1e-12 then converts the result to trillion USD)
q41_globalPermitTradeCap(t,regi)$(t.val gt 2025) ..

    sum(regi2,
        (vm_Xport(t,regi2,"perm") + vm_Mport(t,regi2,"perm"))
        * (pm_taxCO2eq(t,regi2))
    )

    =l=

    0.01 * p41_gdpGlob(t);


*' @stop
*** EOF ./modules/41_emicapregi/JUSTMip/equations.gms
