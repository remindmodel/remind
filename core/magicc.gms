*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/magicc.gms
*** FILE magicc.gms ***
$ontext
This connects REMIND with the MAGICC model.

TODO
- more documentation
- document MAGICC_scen_*.inc files
- document excel files and upload to tutorials
$offtext

$ifthen %cm_rcp_scen% == "rcp20"   p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_450(RCP_regions_world,tall,emiRCP);
$elseif %cm_rcp_scen% == "rcp26"   p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_450(RCP_regions_world,tall,emiRCP);
$elseif %cm_rcp_scen% == "rcp37"   p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_550(RCP_regions_world,tall,emiRCP);
$elseif %cm_rcp_scen% == "rcp45"   p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_550(RCP_regions_world,tall,emiRCP);
$elseif %cm_rcp_scen% == "rcp60"   p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_bau(RCP_regions_world,tall,emiRCP);
$elseif %cm_rcp_scen% == "rcp85"   p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_bau(RCP_regions_world,tall,emiRCP);
$elseif %cm_rcp_scen% == "none"    p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_bau(RCP_regions_world,tall,emiRCP);
$else                              p_MAGICC_emi(tall,RCP_regions_world,emiRCP) = magicc_default_data_bau(RCP_regions_world,tall,emiRCP);
$endif

*** populate data
p_MAGICC_emi(ttot,RCP_regions_world,"FossilCO2")$(ttot.val ge 2005)
=
sum(regi,
    (vm_emiTe.l(ttot,regi,"co2"))
  * p_regi_2_MAGICC_regions(regi,RCP_regions_world)
);

p_MAGICC_emi(ttot,RCP_regions_world,"OtherCO2")$(ttot.val ge 2005)
=
sum(regi,
    (vm_emiMac.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2"))
  * p_regi_2_MAGICC_regions(regi,RCP_regions_world)
);

p_MAGICC_emi(ttot,RCP_regions_world,"CH4")$(ttot.val ge 2005)
=
sum(regi,
    vm_emiAll.l(ttot,regi,"ch4")
  * p_regi_2_MAGICC_regions(regi,RCP_regions_world)
);

p_MAGICC_emi(ttot,RCP_regions_world,"N2O")$(ttot.val ge 2005)
=
sum(regi,
    vm_emiAll.l(ttot,regi,"n2o")
  * p_regi_2_MAGICC_regions(regi,RCP_regions_world)
);

***--------------------------- F-gases -------------------------------
loop(emiFgas2emiRCP(enty,emiRCP),
     p_MAGICC_emi(ttot,RCP_regions_world,emiRCP)$(ttot.val ge 2005)
     =
     sum(regi,
         vm_emiFgas.L(ttot,regi,enty)
       * p_regi_2_MAGICC_regions(regi,RCP_regions_world)
     );
);

***--------------------------- emiRCP2emiREMIND ----------------------
loop(emiRCP2emiREMIND(emiRCP,enty3),
    p_MAGICC_emi(ttot,RCP_regions_world_bunkers,emiRCP)$( ttot.val ge 2005 )
      =
        (sum(regi,
           p_regi_2_MAGICC_regions(regi,RCP_regions_world_bunkers)
         * ( sum(all_sectorEmi, pm_emiAPexsolve(ttot,regi,all_sectorEmi,emiRCP)
                )
             + pm_emiAPexo(ttot,regi,enty3,"AgWasteBurning")
             + pm_emiAPexo(ttot,regi,enty3,"Agriculture")
             + pm_emiAPexo(ttot,regi,enty3,"ForestBurning")
             + pm_emiAPexo(ttot,regi,enty3,"GrasslandBurning")
             + pm_emiAPexo(ttot,regi,enty3,"Waste")
          )
        )
     + (  pm_emiAPexoGlob(ttot,enty3,"Aviation")
        + pm_emiAPexoGlob(ttot,enty3,"InternationalShipping")
        )$(   sameas(RCP_regions_world_bunkers,"WORLD") 
           OR sameas(RCP_regions_world_bunkers,"BUNKERS") )
		)
		* (1 - (1 - s_NO2_2_N)$( sameas(enty3,"NOx")))
    ;
);

*** interpolate first periods
loop(emiRCP,
  loop(RCP_regions_world,
    p_MAGICC_emi("2001",RCP_regions_world,emiRCP)
    =
      0.8 * p_MAGICC_emi("2000",RCP_regions_world,emiRCP)
    + 0.2 * p_MAGICC_emi("2005",RCP_regions_world,emiRCP)
    ;

    p_MAGICC_emi("2002",RCP_regions_world,emiRCP)
    =
      0.6 * p_MAGICC_emi("2000",RCP_regions_world,emiRCP)
    + 0.4 * p_MAGICC_emi("2005",RCP_regions_world,emiRCP)
    ;
   
    p_MAGICC_emi("2003",RCP_regions_world,emiRCP)
    =
      0.4 * p_MAGICC_emi("2000",RCP_regions_world,emiRCP)
    + 0.6 * p_MAGICC_emi("2005",RCP_regions_world,emiRCP)
    ;
    
    p_MAGICC_emi("2004",RCP_regions_world,emiRCP)
    =
      0.2 * p_MAGICC_emi("2000",RCP_regions_world,emiRCP)
    + 0.8 * p_MAGICC_emi("2005",RCP_regions_world,emiRCP)
    ;
  )
);

*** generate MAGICC scenario file
put  magicc_scenario

*** MAGICC scenario files are based on the following template
$ontext
line     description
1        N_SCEN_DATALINES  - number of data lines, correspondes to periods
2        SCEN_SPECIALCODES - number describing the data present
                             1x seems to do nothing
                             2x  4 SRES regions
                             3x  5 RCP regions
                             4x  5 RCP regions plus bunkers
                             x1  8 gases and aerosols ) unsure how this relates
                             x2 11 gases and aerosols ) to the actual data files
3        NAME              - scenario name
4        DESCRIPTION       - scenario description
5        NOTES             - usually creation date
6                        empty
7        REGION HEADER     - region name (RCP_regions_world)
8        COLUMN HEADINGS   - YEARS and quantity names (emiRCP)
9        UNITS             - quantity units (emiRCP2unitsMagicc)
...                        data

lines 7 - 9 repeat for each region
$offtext

put " 24" /;
put " 41" /;
put " %c_expname%" /;
put " MAGICC sceanrio file generated by REMIND core/magicc.gms" /;
put " Date created:", system.date, " ", system.time /;
put /;

loop(RCP_regions_world_bunkers,
  put " ", RCP_regions_world_bunkers.tl /;

  put "      Years"
  loop((numberEmiRCP,emiRCP2order(emiRCP,numberEmiRCP)),
    put emiRCP.tl:>11;
  );
  put /;

  put "        Yrs"
  loop((numberEmiRCP,emiRCP2order(emiRCP,numberEmiRCP),
        emiRCP2unitsMagicc(emiRCP,unitsMagicc)),
    put unitsMagicc.tl:>11;
  );
  put /;

  loop(t_magiccttot$( t_magiccttot.val ge 2000 ),
    put t_magiccttot.tl:>11;
    loop((numberEmiRCP,emiRCP2order(emiRCP,numberEmiRCP)),
      put p_MAGICC_emi(t_magiccttot,RCP_regions_world_bunkers,emiRCP):>11:4;
    )
    put /;
  );

  put /;
  put /;
);

putclose magicc_scenario

*** write sed scripts to edit MAGICC configuration files
put  magicc_sed_script

put 's|  FILE_EMISSIONSCENARIO.*|  FILE_EMISSIONSCENARIO =  "REMIND_%c_expname%",|g' /;
put 's|  RUNNAME.*|  RUNNAME =  "%c_expname%",|g' /;
put 's|  RUNDATE.*|  RUNDATE =  "%system.date%",|g' /;
put 's|  RF_SOLAR_SCALE =.*|  RF_SOLAR_SCALE =  0,|g' /;

putclose magicc_sed_script;

*** EOF ./core/magicc.gms
