*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/sets.gms
Sets
  regi_dyn36(all_regi)   "dynamic region set for compatibility with testOneRegi"
  teEs_dyn36(all_teEs)  "technologies - buildings module additions"
  /
    te_ueshheb  "buildings space heating district heat"
    te_ueshhob  "buildings space heating liquids"
    te_ueshsob  "buildings space heating solids"
    te_ueshstb  "buildings space heating traditional solids (trad biomass + coal)"
    te_ueshgab  "buildings space heating district heat"
    te_ueshh2b  "buildings space heating hydrogen"
    te_ueshelb  "buildings space heating electricity resistance"
    te_ueshhpb  "buildings space heating electricity heat pump"
    
    te_uecwhob  "buildings cooking and water heating liquids"
    te_uecwsob  "buildings cooking and water heating solids"
    te_uecwstb  "buildings cooking and water heating traditional solids"
    te_uecwgab  "buildings cooking and water heating gas"
    te_uecwheb  "buildings cooking and water heating district heat"
    te_uecwh2b  "buildings cooking and water heating hydrogen"
    te_uecwelb  "buildings cooking and water heating electricity"
    te_uecwhpb  "buildings cooking and water heating heat pump"
    
  /    

  esty_dyn36(all_esty)            "Energy service types"
  /
    ueshheb  "buildings space heating district heat"
    ueshhob  "buildings space heating liquids"
    ueshsob  "buildings space heating solids"
    ueshstb  "buildings space heating traditional solids"
    ueshgab  "buildings space heating district heat"
    ueshh2b  "buildings space heating hydrogen"
    ueshelb  "buildings space heating electricity resistance"
    ueshhpb  "buildings space heating electricity heat pump"
    
    uecwhob  "buildings cooking and water heating liquids"
    uecwsob  "buildings cooking and water heating solids"
    uecwstb  "buildings cooking and water heating traditional solids"
    uecwgab  "buildings cooking and water heating gas"
    uecwheb  "buildings cooking and water heating district heat"
    uecwh2b  "buildings cooking and water heating hydrogen"
    uecwelb  "buildings cooking and water heating electricity"
    uecwhpb  "buildings cooking and water heating heat pump"
  /
  
  in_buildings_dyn36(all_in)   "all inputs and outputs of the CES function - buildings"
  /
    enb     "buildings energy use"
    
    esswb   "buildings weatherization energy service"
    
    uealb   "buildings appliances and light"
    uecwb   "buildings cooking and water heating"
    ueswb   "buildings weatherization"
    uescb   "buildings cooling"
    ueshb   "buildings heating"
    
    fescelb  "buildings space cooling electricity"
        
    fealelb  "buildings appliances and light electricity"
        
    kaphc     "buildings capital stock insulation"
    kapsc     "buildings capital stock space cooling"
    kapal     "buildings capital stock appliances and light"
    
  /
 

 
  es2ppfen_dyn36(all_esty,all_in)      "matching FE to ppfEn in MACRO"
/
    ueshheb.ueshb
    ueshhob.ueshb
    ueshsob.ueshb
    ueshstb.ueshb
    ueshgab.ueshb
    ueshh2b.ueshb
    ueshelb.ueshb
    ueshhpb.ueshb
           
    uecwhob.uecwb
    uecwsob.uecwb
    uecwstb.uecwb
    uecwgab.uecwb
    uecwheb.uecwb
    uecwh2b.uecwb
    uecwelb.uecwb
    uecwhpb.uecwb
/ 

fe2es_dyn36(all_enty,all_esty,all_teEs)    "map FE carriers to ES via appliances"
/
        fehes.ueshheb.te_ueshheb
        fehos.ueshhob.te_ueshhob
        fesos.ueshsob.te_ueshsob
        fesos.ueshstb.te_ueshstb
        fegas.ueshgab.te_ueshgab
        feh2s.ueshh2b.te_ueshh2b
        feels.ueshelb.te_ueshelb
        feels.ueshhpb.te_ueshhpb
               
        fehos.uecwhob.te_uecwhob
        fesos.uecwsob.te_uecwsob
        fesos.uecwstb.te_uecwstb
        fegas.uecwgab.te_uecwgab
        fehes.uecwheb.te_uecwheb
        feh2s.uecwh2b.te_uecwh2b
        feels.uecwelb.te_uecwelb
        feels.uecwhpb.te_uecwhpb
/
 
buildMoBio36 (all_esty)   "modern biomass in buildings"
/
ueshsob
uecwsob
/ 
 
fe2ces_dyn36(all_enty,all_esty,all_teEs,all_in) "map FE carriers to CES via appliances"
// 

feteces_dyn36(all_enty,all_teEs,all_in) "map FE carriers to CES without esty"
//

inViaEs_dyn36(all_in)  "CES inputs which are provided throught the ES pathway"

  in_putty_dyn36(all_in) "putty in for buildings"
  /
   /
  ppf_putty_dyn36(all_in) "putty ppf for buildings"
  //
  
  in_complements_dyn36(all_in)  "Complementary factors"
  /
  uescb
  ueshb
  /
  

  ppfKap_dyn36(all_in)   "Capital primary production factors"
  /
    kaphc     
    kapsc   
    kapal 
        
    /
  
  ppfen_buildings_dyn36(all_in)   "primary production factors energy - buildings"
  / 
   ueshb
   uecwb   
   fescelb 
   fealelb
   /
  
  cal_ppf_buildings_dyn36(all_in)   "primary production factors - buildings - used for the calibration"
  / uescb, ueshb, uealb, uecwb, kaphc/
 
 ue_dyn36(all_in)  "useful energy items"
 /uescb, ueshb, uealb, uecwb/
 
  ces_buildings_dyn36(all_in,all_in)   "CES tree structure - buildings"
  /
    en    . enb
    enb   . (esswb, uealb, uecwb)
    esswb .  (ueswb,kaphc)
    ueswb . (uescb,ueshb)
    uescb . (fescelb,kapsc)
    
    uealb . (fealelb,kapal)
        
  /

  fe2ppfEn36(all_enty,all_in)   "match ESM entyFe to ppfEn"
  /
    feels . (fescelb,fealelb)
  /
  
    fe_tax_subEs36(all_in,all_esty)  "correspondence between tax and subsidy input data resolution and model sectoral resolution"
    /
    fesob . (ueshsob,ueshstb,uecwsob,uecwstb)
    fehob . (ueshhob,uecwhob)
    fegab . (ueshgab,uecwgab)
    feh2b . (ueshh2b,uecwh2b)
    feheb . (ueshheb,uecwheb)
    feelb . (ueshelb,ueshhpb, uecwelb,uecwhpb)  
    /
    
    fe_tax_sub36(all_in,all_in)  "correspondence between tax and subsidy input data resolution and model sectoral resolution"
    /
     feelb . (fealelb,fescelb)  
    /
    
    mapElHp(all_teEs,all_teEs) "correspondence between electric resistance technology and heat pump technology"
    /
    te_uecwelb. te_uecwhpb
    te_ueshelb. te_ueshhpb
    /
     
    richTechs(all_teEs) "technologies whose calibration decreases with income "
    /
    te_ueshgab
    te_uecwgab
    /
    
  t36_hist(ttot) "historic time steps"
  t36_hist_last(ttot) "last historic time step"
  t36_scen(ttot) "non historical scenario time step"
;   


loop ( fe2es_dyn36(all_enty,all_esty,all_teEs),
    loop ( es2ppfen_dyn36(all_esty,all_in),
    fe2ces_dyn36(all_enty,all_esty,all_teEs,all_in) = YES;
    inViaEs_dyn36(all_in) = YES;
    feteces_dyn36(all_enty,all_teEs,all_in) = YES;
    )
    );


 alias (fe2ces_dyn36,fe2ces_dyn36_2);
 alias (fe2es_dyn36, fe2es_dyn36_2);
 alias (feteces_dyn36, feteces_dyn36_2);
 
t36_hist(ttot) = NO;
t36_hist(ttot)$(sameAs(ttot,"2005") OR sameAs(ttot,"2010") OR sameAs(ttot,"2015")) = YES;

t36_scen(ttot) = NO;
t36_scen(ttot)$t(ttot) = YES;
t36_scen(ttot)$t36_hist(ttot) = NO;

$offOrder
 t36_hist_last(ttot) = NO;
 t36_hist_last(t36_hist)$(ord(t36_hist) eq card(t36_hist)) = YES;
$offOrder
***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------
ppfKap(ppfKap_dyn36) = YES;
in(in_buildings_dyn36)             = YES;
ppfEn(ppfen_buildings_dyn36)       = YES;
cesOut2cesIn(ces_buildings_dyn36)           = YES;
fe2ppfEn(fe2ppfEn36)                      = YES;
in_putty(in_putty_dyn36)                = YES;
ppf_putty(ppf_putty_dyn36)        = YES;
in_complements(in_complements_dyn36) = YES;
fe_tax_sub_sbi(fe_tax_sub36) = YES;
fe_tax_subEs(fe_tax_subEs36) = YES;

buildMoBio(buildMoBio36) = YES;
 
teEs(teEs_dyn36)         = YES;
esty(esty_dyn36)     = YES;
fe2es(fe2es_dyn36)       = YES;
es2ppfen(es2ppfen_dyn36) = YES;
*** EOF ./modules/36_buildings/services_with_capital/sets.gms
