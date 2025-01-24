# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# This vector contains the module as name,
# and the realizations that require a 'path_gdx_bau' as elements
# This allows readCheckScenarioConfig and checkFixConfig to set it to NA
# if not needed, and complain if it is missing.
needBau <- list(carbonprice = "NDC",
                carbonpriceRegi = "NDC",
                emicapregi = "AbilityToPay")
