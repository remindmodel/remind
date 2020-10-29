



*** check naming convention for sets in modules (regi40_techpol?)
set regi_techpol(all_regi) "regions which techpol applies to";

*** c_regi_nucscen = switch
$IFTHEN.RegScenNuc "%c_techpol_EU%" == "1"
*** switch c_regi_nucscen all -> take all regions from
  regi_techpol(all_regi)=YES;
$ELSE.RegScenNuc
  regi_techpol(EUR_regi)=NO;
$ENDIF.RegScenNuc