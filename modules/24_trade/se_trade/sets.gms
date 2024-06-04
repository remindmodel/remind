*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/sets.gms

sets
trade(all_enty)             "All traded commodities"
/
/

tradeMacro(all_enty)        "Traded macro-economic commodities"
/
    good, 
    perm
/

tradePe(all_enty)           "Traded primary energy commodities"
/
    peoil, 
    pecoal, 
    pegas, 
    peur, 
    pebiolc
/

tradeSe(all_enty)           "Traded secondary energy commodities"
/
    null
/

tradeCap(all_enty)          "Commodities traded via capacity mode."
/
    null
/
;

tradeSe("seh2") = YES;

$ifthen.import_nzero_EU "%cm_import_EU%" == "nzero"
*** Defining secondary energy commoditites that are tradeable in this scenario 
tradeSe(all_enty) = NO;
tradeSe("seh2") = YES;
tradeSe("seliqsyn") = YES;
$endif.import_nzero_EU

$ifthen.import_nzero_bio_EU "%cm_import_EU%" == "nzero_bio"
*** Defining secondary energy commoditites that are tradeable in this scenario 
tradeSe(all_enty) = NO;
tradeSe("seh2") = YES;
tradeSe("seliqsyn") = YES;
tradeSe("seliqbio") = YES;
$endif.import_nzero_bio_EU

$ifthen.high_bio "%cm_import_EU%" == "high_bio"
*** Defining secondary energy commoditites that are tradeable in this scenario 
tradeSe(all_enty) = NO;
tradeSe("seliqbio") = YES;
$endif.high_bio

*** EOF ./modules/24_trade/se_trade/sets.gms
