*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/04_PE_FE_parameters/iea2014/datainput.gms

parameter f04_IO_input(tall,all_regi,all_enty,all_enty,all_te)        "Energy input based on IEA data"
/
$ondelim
$include "./modules/04_PE_FE_parameters/iea2014/input/f04_IO_input.cs4r"
$offdelim
/
;

if (smin((t,regi,pe2se(entyPe,entySe,te)), f04_IO_input(t,regi,entyPe,entySe,te)) lt 0,
  put_utility "msg" / "**""** input data problem: f04_IO_input has negative values that are overwritten";
  put_utility "msg" / "**""** to still allow model solving. Check input data." /;
  loop ((t,regi,pe2se(entyPe,entySe,te)),
    if (f04_IO_input(t,regi,entyPe,entySe,te) lt 0,
      put_utility "msg" /
	f04_IO_input.tn(t,regi,entyPE,entySE,te), " = ",
        f04_IO_input(t,regi,entyPe,entySe,te):10:8;
    );
  );
);
*' overwrite negative values with 0 to allow the model to solve. In the mid-term, the input data/mapping needs to be improved to prevent negative values
f04_IO_input(tall,regi,entyPe,entySe,te)$(f04_IO_input(tall,regi,entyPe,entySe,te) lt 0) = 0;

*CG* setting historical production from wind offshore to 0 (due to the scarcity of offshore wind before 2015)
$IFTHEN.WindOff %cm_wind_offshore% == "1"
f04_IO_input(tall,all_regi,"pewin","seel","windoff") = 0;
$ENDIF.WindOff

parameter f04_IO_output(tall,all_regi,all_enty,all_enty,all_te)        "Energy output based on IEA data"
/
$ondelim
$include "./modules/04_PE_FE_parameters/iea2014/input/f04_IO_output.cs4r"
$offdelim
/
;

if (smin((t,regi,pe2se(entyPe,entySe,te)), f04_IO_output(t,regi,entyPe,entySe,te)) lt 0,
  put_utility "msg" / "**""** input data problem: f04_IO_output has negative values that are overwritten" /
  put_utility "msg" / "**""** to still allow model solving. Check input data." /;
  loop ((t,regi,pe2se(entyPe,entySe,te)),
    if (f04_IO_output(t,regi,entyPe,entySe,te) lt 0,
     put_utility "msg" /
       f04_IO_output.tn(t,regi,entyPE,entySE, te), " = ",
       f04_IO_output(t,regi,entyPe,entySe,te):10:8;
    );
  );
);

*' overwrite negative values with 0 to allow the model to solve. In the mid-term, the input data/mapping needs to be improved to prevent negative values
f04_IO_output(tall,regi,entyPe,entySe,te)$(f04_IO_output(tall,regi,entyPe,entySe,te) lt 0) = 0;




*** making sure f04_IO_output is compatible with pm_fedemand values in 2005  
*** this will become irrelevant to the model once the input data routines can be fixed so that pm_fedemand is again the same as f04_IO_output
*** these lines should be removed once this is fixed at mrremind side.


*** save original input data
p04_IO_output_beforeFix(t,regi,all_enty,all_enty2,all_te) = f04_IO_output(t,regi,all_enty,all_enty2,all_te);

p04_IO_output_beforeFix_Total(t,regi,"fesob") = p04_IO_output_beforeFix(t,regi,"sesobio","fesob","tdbiosob")
                                                  + p04_IO_output_beforeFix(t,regi,"sesofos","fesob","tdfossob");

p04_IO_output_beforeFix_Total(t,regi,"fehob") = p04_IO_output_beforeFix(t,regi,"seliqbio","fehob","tdbiohob")
                                                  + p04_IO_output_beforeFix(t,regi,"seliqfos","fehob","tdfoshob");

*** adjust buildings solids
f04_IO_output("2005",regi,"sesobio","fesob","tdbiosob")$(p04_IO_output_beforeFix_Total("2005",regi,"fesob")) = p04_IO_output_beforeFix("2005",regi,"sesobio","fesob","tdbiosob") * pm_fedemand("2005",regi,"fesob")/p04_IO_output_beforeFix_Total("2005",regi,"fesob");
f04_IO_output("2005",regi,"sesofos","fesob","tdfossob")$(p04_IO_output_beforeFix_Total("2005",regi,"fesob")) = p04_IO_output_beforeFix("2005",regi,"sesofos","fesob","tdfossob") * pm_fedemand("2005",regi,"fesob")/p04_IO_output_beforeFix_Total("2005",regi,"fesob");

*** adjust buildings liquids
f04_IO_output("2005",regi,"seliqbio","fehob","tdbiohob")$(p04_IO_output_beforeFix_Total("2005",regi,"fehob")) = p04_IO_output_beforeFix("2005",regi,"seliqbio","fehob","tdbiohob") * pm_fedemand("2005",regi,"fehob")/p04_IO_output_beforeFix_Total("2005",regi,"fehob");
f04_IO_output("2005",regi,"seliqfos","fehob","tdfoshob")$(p04_IO_output_beforeFix_Total("2005",regi,"fehob")) = p04_IO_output_beforeFix("2005",regi,"seliqfos","fehob","tdfoshob") * pm_fedemand("2005",regi,"fehob")/p04_IO_output_beforeFix_Total("2005",regi,"fehob");



$ifthen.subsectors "%industry%" == "subsectors"   !! industry

*** industry solids
p04_IO_output_beforeFix_Total(t,regi,"fesoi") = p04_IO_output_beforeFix(t,regi,"sesobio","fesoi","tdbiosoi")
                                                  + p04_IO_output_beforeFix(t,regi,"sesofos","fesoi","tdfossoi");


f04_IO_output("2005",regi,"sesobio","fesoi","tdbiosoi")$(p04_IO_output_beforeFix_Total("2005",regi,"fesoi")) = p04_IO_output_beforeFix("2005",regi,"sesobio","fesoi","tdbiosoi")  
                                                            *  ( pm_fedemand("2005",regi,"feso_otherInd")
                                                               + pm_fedemand("2005",regi,"feso_cement")
                                                               + pm_fedemand("2005",regi,"feso_steel")
                                                               + pm_fedemand("2005",regi,"feso_chemicals"))
                                                            /  p04_IO_output_beforeFix_Total("2005",regi,"fesoi");


f04_IO_output("2005",regi,"sesofos","fesoi","tdfossoi")$(p04_IO_output_beforeFix_Total("2005",regi,"fesoi")) = p04_IO_output_beforeFix("2005",regi,"sesofos","fesoi","tdfossoi")  
                                                            *  ( pm_fedemand("2005",regi,"feso_otherInd")
                                                               + pm_fedemand("2005",regi,"feso_cement")
                                                               + pm_fedemand("2005",regi,"feso_steel")
                                                               + pm_fedemand("2005",regi,"feso_chemicals"))
                                                            /  p04_IO_output_beforeFix_Total("2005",regi,"fesoi");

*** industry liquids
p04_IO_output_beforeFix_Total(t,regi,"fehoi") = p04_IO_output_beforeFix(t,regi,"seliqbio","fehoi","tdbiohoi")
                                                  + p04_IO_output_beforeFix(t,regi,"seliqfos","fehoi","tdfoshoi");


f04_IO_output("2005",regi,"seliqbio","fehoi","tdbiohoi")$(p04_IO_output_beforeFix_Total("2005",regi,"fehoi")) = p04_IO_output_beforeFix("2005",regi,"seliqbio","fehoi","tdbiohoi")  
                                                            *  ( pm_fedemand("2005",regi,"feli_otherInd")
                                                               + pm_fedemand("2005",regi,"feli_cement")
                                                               + pm_fedemand("2005",regi,"feli_steel")
                                                               + pm_fedemand("2005",regi,"feli_chemicals"))
                                                            /  p04_IO_output_beforeFix_Total("2005",regi,"fehoi");


f04_IO_output("2005",regi,"seliqfos","fehoi","tdfoshoi")$(p04_IO_output_beforeFix_Total("2005",regi,"fehoi")) = p04_IO_output_beforeFix("2005",regi,"seliqfos","fehoi","tdfoshoi")  
                                                            *  ( pm_fedemand("2005",regi,"feli_otherInd")
                                                               + pm_fedemand("2005",regi,"feli_cement")
                                                               + pm_fedemand("2005",regi,"feli_steel")
                                                               + pm_fedemand("2005",regi,"feli_chemicals"))
                                                            /  p04_IO_output_beforeFix_Total("2005",regi,"fehoi");

*** industry gases
p04_IO_output_beforeFix_Total(t,regi,"fegai") = p04_IO_output_beforeFix(t,regi,"segabio","fegai","tdbiogai")
                                                  + p04_IO_output_beforeFix(t,regi,"segafos","fegai","tdfosgai");


f04_IO_output("2005",regi,"segabio","fegai","tdbiogai")$(p04_IO_output_beforeFix_Total("2005",regi,"fegai")) = p04_IO_output_beforeFix("2005",regi,"segabio","fegai","tdbiogai")  
                                                            *  ( pm_fedemand("2005",regi,"fega_otherInd")
                                                               + pm_fedemand("2005",regi,"fega_cement")
                                                               + pm_fedemand("2005",regi,"fega_steel")
                                                               + pm_fedemand("2005",regi,"fega_chemicals"))
                                                            /  p04_IO_output_beforeFix_Total("2005",regi,"fegai");


f04_IO_output("2005",regi,"segafos","fegai","tdfosgai")$(p04_IO_output_beforeFix_Total("2005",regi,"fegai")) = p04_IO_output_beforeFix("2005",regi,"segafos","fegai","tdfosgai")  
                                                            *  ( pm_fedemand("2005",regi,"fega_otherInd")
                                                               + pm_fedemand("2005",regi,"fega_cement")
                                                               + pm_fedemand("2005",regi,"fega_steel")
                                                               + pm_fedemand("2005",regi,"fega_chemicals"))
                                                            /  p04_IO_output_beforeFix_Total("2005",regi,"fegai");



*** industry heat
p04_IO_output_beforeFix_Total(t,regi,"fehei") = p04_IO_output_beforeFix(t,regi,"sehe","fehei","tdhei");


f04_IO_output("2005",regi,"sehe","fehei","tdhei")$(p04_IO_output_beforeFix_Total("2005",regi,"fehei")) = p04_IO_output_beforeFix("2005",regi,"sehe","fehei","tdhei")  
                                                            *  ( pm_fedemand("2005",regi,"fehe_otherInd")
                                                              )
                                                            /  p04_IO_output_beforeFix_Total("2005",regi,"fehei");

$endif.subsectors

*** end adjustment of f04_IO_output to pm_fedemand values

*** convert data from EJ to TWa
f04_IO_input(ttot,regi,all_enty,all_enty2,all_te) = f04_IO_input(ttot,regi,all_enty,all_enty2,all_te) * sm_EJ_2_TWa;
f04_IO_output(ttot,regi,all_enty,all_enty2,all_te) = f04_IO_output(ttot,regi,all_enty,all_enty2,all_te) * sm_EJ_2_TWa;

*** calculate bio share per carrier for buildings and industry (only for historically available years)
pm_secBioShare(ttot,regi,entyFe,sector)$((sameas(entyFE,"fegas") or sameas(entyFE,"fehos") or sameas(entyFE,"fesos")) and entyFe2Sector(entyFe,sector)  and (ttot.val ge 2005 and ttot.val le 2015) and (sum((entySe,all_enty,all_te)$entyFeSec2entyFeDetail(entyFe,sector,all_enty), f04_IO_output(ttot,regi,entySe,all_enty,all_te) ) gt 0)) = 
  sum((entySeBio,all_enty,all_te)$entyFeSec2entyFeDetail(entyFe,sector,all_enty), f04_IO_output(ttot,regi,entySeBio,all_enty,all_te) ) 
  /
  sum((entySe,all_enty,all_te)$entyFeSec2entyFeDetail(entyFe,sector,all_enty), f04_IO_output(ttot,regi,entySe,all_enty,all_te) )
;

display pm_secBioShare;

pm_IO_input(regi,all_enty,all_enty2,all_te)   = 0;
p04_IO_output(regi,all_enty,all_enty2,all_te)  = 0;
pm_IO_input(regi,all_enty,enty,all_te)  = f04_IO_input("2005",regi,all_enty,enty,all_te);    !! t0 did not work
p04_IO_output(regi,all_enty,enty,all_te) = f04_IO_output("2005",regi,all_enty,enty,all_te);  !! t0 did not work

***------------------ sum up info for buildings and industry to statinonary data --------------------------
loop(in2enty(all_enty,enty,all_te,te),
      pm_IO_input(regi,enty3,enty,te)  = sum(in2enty2(all_enty2,enty,all_te2,te),f04_IO_input("2005",regi,enty3,all_enty2,all_te2));
      p04_IO_output(regi,enty3,enty,te) = sum(in2enty2(all_enty2,enty,all_te2,te),f04_IO_output("2005",regi,enty3,all_enty2,all_te2));
);
display pm_IO_input, p04_IO_output;

***------------------ allocate all electricity produced from gas to ngt for initial calculation of average eta ----------------------------------------
pm_IO_input(regi,enty,enty2,"ngcc")  = pm_IO_input(regi,enty,enty2,"x_gas2elec");
p04_IO_output(regi,enty,enty2,"ngcc") = p04_IO_output(regi,enty,enty2,"x_gas2elec");

***------------------ allocate distribution loss to electricity to technologies -----------------------------
loop(regi,
   if(sum(pe2se("pecoal","seel",te2), pm_IO_input(regi,"pecoal","seel",te2)) gt 0,
        pm_IO_input(regi,"pecoal","seel",te) = pm_IO_input(regi,"pecoal","seel",te)
                                        + ( pm_IO_input(regi,"pecoal","seel",te) / sum(pe2se("pecoal","seel",te2), pm_IO_input(regi,"pecoal","seel",te2)) ) 
                                          * f04_IO_input("2005",regi,"pecoal","seel","d_coal2elec");
    );
    if(sum(pe2se("pegas","seel",te2), pm_IO_input(regi,"pegas","seel",te2)) gt 0,
        pm_IO_input(regi,"pegas","seel",te) = pm_IO_input(regi,"pegas","seel",te)
                                                + ( pm_IO_input(regi,"pegas","seel",te) / sum(pe2se("pegas","seel",te2), pm_IO_input(regi,"pegas","seel",te2)) ) 
                                                 * f04_IO_input("2005",regi,"pegas","seel","d_gas2elec");
    );
    if(sum(pe2se("pebiolc","seel",te2), pm_IO_input(regi,"pebiolc","seel",te2)) gt 0,
        pm_IO_input(regi,"pebiolc","seel",te) = pm_IO_input(regi,"pebiolc","seel",te)
                                                + ( pm_IO_input(regi,"pebiolc","seel",te) / sum(pe2se("pebiolc","seel",te2), pm_IO_input(regi,"pebiolc","seel",te2)) ) 
                                                  * f04_IO_input("2005",regi,"pebiolc","seel","d_bio2elec");
    );
);
***------------------ allocate transmission and distribution (T&D) loss to tdhe* and tdel* technologies -----------------------------
loop(regi,
     if(sum(se2fe("seel",enty3,te2), pm_IO_input(regi,"seel",enty3,te2)) gt 0,
        pm_IO_input(regi,enty,enty2,te)$(sameas(enty,"seel"))  = pm_IO_input(regi,enty,enty2,te)
                                                + ( pm_IO_input(regi,enty,enty2,te) / sum(se2fe(enty,enty3,te2), pm_IO_input(regi,enty,enty3,te2)) ) 
                                                  * ( f04_IO_input("2005",regi,enty,"feel","d_feel")
												     + f04_IO_output("2005",regi,"seel","feel","o_feel") );  !! this is actually autoconsumption of power plants, but for simplicity we account it at t&d losses
     );
     if(sum(se2fe("sehe",enty3,te2), pm_IO_input(regi,"sehe",enty3,te2)) gt 0,
        pm_IO_input(regi,enty,enty2,te)$(sameas(enty,"sehe"))  = pm_IO_input(regi,enty,enty2,te)
                                                + ( pm_IO_input(regi,enty,enty2,te) / sum(se2fe(enty,enty3,te2), pm_IO_input(regi,enty,enty3,te2)) ) 
                                                  * f04_IO_input("2005",regi,enty,"fehe","d_fehe");
     );
	 
	 
	 
	 if(sum(se2fe("segafos",enty3,te2), pm_IO_input(regi,"segafos",enty3,te2)) gt 0,
        pm_IO_input(regi,enty,enty2,te)$(sameas(enty,"segafos"))  = pm_IO_input(regi,enty,enty2,te)
                                                + ( pm_IO_input(regi,enty,enty2,te) / sum(se2fe(enty,enty3,te2), pm_IO_input(regi,enty,enty3,te2)) ) 
                                                  * f04_IO_input("2005",regi,enty,"fega","d_fegafos");
     );
	 if(sum(se2fe("segabio",enty3,te2), pm_IO_input(regi,"segabio",enty3,te2)) gt 0,
        pm_IO_input(regi,enty,enty2,te)$(sameas(enty,"segabio"))  = pm_IO_input(regi,enty,enty2,te)
                                                + ( pm_IO_input(regi,enty,enty2,te) / sum(se2fe(enty,enty3,te2), pm_IO_input(regi,enty,enty3,te2)) ) 
                                                  * f04_IO_input("2005",regi,enty,"fega","d_fegabio");
     );
	 if(sum(se2fe("sesofos",enty3,te2), pm_IO_input(regi,"sesofos",enty3,te2)) gt 0,
        pm_IO_input(regi,enty,enty2,te)$(sameas(enty,"sesofos"))  = pm_IO_input(regi,enty,enty2,te)
                                                + ( pm_IO_input(regi,enty,enty2,te) / sum(se2fe(enty,enty3,te2), pm_IO_input(regi,enty,enty3,te2)) ) 
                                                  * f04_IO_input("2005",regi,enty,"feso","d_fesofos");
     );
	 if(sum(se2fe("sesobio",enty3,te2), pm_IO_input(regi,"sesobio",enty3,te2)) gt 0,
        pm_IO_input(regi,enty,enty2,te)$(sameas(enty,"sesobio"))  = pm_IO_input(regi,enty,enty2,te)
                                                + ( pm_IO_input(regi,enty,enty2,te) / sum(se2fe(enty,enty3,te2), pm_IO_input(regi,enty,enty3,te2)) ) 
                                                  * f04_IO_input("2005",regi,enty,"feso","d_fesobio");
     );
);

*RP 2019-02-19: This is now changed starting from rev 8352. Power plant output is from now on gross production instead of net, and power plant autoconsumption is shifted to t&d losses
*RP This was done to facilitate comparison with other sources which usually report gross electricity generation as well as gross capacity factors
***------------------ allocate own power consumption to electricity technologies -----------------------------
***p04_IO_output(regi,enty,enty2,te)$(sameas(enty2,"seel") AND (NOT sameas(te,"wind")) AND (NOT sameas(te,"spv")) )  = p04_IO_output(regi,enty,enty2,te)
***                                                           - ( p04_IO_output(regi,enty,enty2,te) / sum(pe2se(enty3,enty2,te2)$((NOT sameas(te2,"wind")) AND (NOT sameas(te2,"spv"))), p04_IO_output(regi,enty3,enty2,te2)) ) 
***                                                             * f04_IO_output("2005",regi,"seel","feel","o_feel");
display pm_IO_input, p04_IO_output;

*** ----------------------------------------------------------------------------------------------------------
***--------------------------------------- calculate coupled products ----------------------------------------
*** ----------------------------------------------------------------------------------------------------------
loop(pc2te(enty,enty2,te,enty3),
    loop(regi,
       if(p04_IO_output(regi,enty,enty2,te) ne 0,
          pm_prodCouple(regi,enty,enty2,te,enty3)  =  p04_IO_output(regi,enty,enty3,te) / p04_IO_output(regi,enty,enty2,te);
       );
    );
);
display pm_prodCouple;

*** define global values for couple production that can be used if the regional IEA data are 0
p04_prodCoupleGlob("pecoal","seel","coalchp","sehe")        = 0.61;
p04_prodCoupleGlob("pegas","seel","gaschp","sehe")          = 0.42;
p04_prodCoupleGlob("pecoal","seh2","coalh2","seel")         = 0.081;
p04_prodCoupleGlob("pecoal","seh2","coalh2c","seel")        = 0.054;
p04_prodCoupleGlob("pebiolc","seel","biochp","sehe")        = 0.72;
p04_prodCoupleGlob("pebiolc","seliqbio","bioftrec","seel")  = 0.147; !! from Liu et al. 2011 (Making Fischer-Tropsch Fuels and Electricity from Coal and Biomass: Performance and Cost Analysis)
p04_prodCoupleGlob("pebiolc","seliqbio","bioftcrec","seel") = 0.108; !! from Liu et al. 2011 (Making Fischer-Tropsch Fuels and Electricity from Coal and Biomass: Performance and Cost Analysis)
p04_prodCoupleGlob("pebiolc","segabio","biogasc","seel")    = -0.07;
p04_prodCoupleGlob("pebiolc","seliqbio","bioethl","seel")   = 0.153;
p04_prodCoupleGlob("segabio","fegas","tdbiogas","seel")     = -0.05;
p04_prodCoupleGlob("segafos","fegas","tdfosgas","seel")     = -0.05;
p04_prodCoupleGlob("pegeo","sehe","geohe","seel")           = -0.3;
p04_prodCoupleGlob("cco2","ico2","ccsinje","seel")          = -0.005;
p04_prodCoupleGlob("fedie","uedit","apcardiEffT","feelt")   = -0.1;
p04_prodCoupleGlob("fedie","uedit","apcardiEffH2T","feelt") = -0.2;
p04_prodCoupleGlob("fedie","uedit","apcardiEffH2T","feh2t") = -0.1;
*** use global data for coule products if regional data form IEA are 0
loop(pc2te(enty,enty2,te,enty3),
    loop(regi,
       if(pm_prodCouple(regi,enty,enty2,te,enty3) eq 0,
          pm_prodCouple(regi,enty,enty2,te,enty3)  =  p04_prodCoupleGlob(enty,enty2,te,enty3);
       );
    );
);
display pm_prodCouple;
*** ----------------------------------------------------------------------------------------------------------
***--------------------------------------- calculate eta and mix0 --------------------------------------------
*** ----------------------------------------------------------------------------------------------------------
*** calculate eta
loop(en2en(enty,enty2,te),
    loop(regi,
       if(pm_IO_input(regi,enty,enty2,te) ne 0,
          pm_data(regi,"eta",te) = p04_IO_output(regi,enty,enty2,te)/pm_IO_input(regi,enty,enty2,te);
       );
    );
);


*** recalculating the eta for seliq (fehos, fedie and fepet), seso and sega T&D to final energy, assuming that biomass or fossil based fuels use the same network and, consequently, share the same eta  
loop(entyFe$(SAMEAS(entyFe,"fehos") OR SAMEAS(entyFe,"fedie") OR SAMEAS(entyFe,"fepet") OR SAMEAS(entyFe,"fegas") OR SAMEAS(entyFe,"fesos")), 
	loop(regi,
		if(sum(se2fe(entySe,entyFe,te), pm_IO_input(regi,entySe,entyFe,te)) ne 0,
			loop((entySe,te)$se2fe(entySe,entyFe,te),
				pm_data(regi,"eta",te) = sum(se2fe(enty,entyFe,te2), p04_IO_output(regi,enty,entyFe,te2))/sum(se2fe(enty,entyFe,te2), pm_IO_input(regi,enty,entyFe,te2));
			);
		);
	);
);



*** calculate mix0 - the share in the production of v*_INIdemEn0, which is the energy demand in t0 minus the energy produced by couple production
***old calculation: mix0(enty, enty2, te) = output(enty, enty2, te) / sum( (enty3,te2), output(enty3, enty2, te2) $(enty2 is not joint product of a te2 that is technology with joint products, like CHP )
loop(en2en(enty,enty2,te),  !! this sum does not include couple production, only direct transformation processes
  loop(regi,
    if(sum(en2en2(enty3,enty2,te2), p04_IO_output(regi,enty3,enty2,te2)) ne 0,
      pm_data(regi,"mix0",te)  =  p04_IO_output(regi,enty,enty2,te) / sum(en2en2(enty3,enty2,te2), p04_IO_output(regi,enty3,enty2,te2));
    );
  );
);

*RP* adjust pm_prodCouple values to default of 0.9 if technology is not used in the initial time step
loop(teCHP(te),
  loop(regi,
    if( pm_data(regi,"mix0",te) eq 0 , 
      loop(pc2te(enty,"seel",te,"sehe"),
        pm_prodCouple(regi,enty,"seel",te,"sehe") = 0.9; 
      );
    );
  );
);

display pm_prodCouple;


*** ----------------------------------------------------------------------------------------------------------
***--------------------------------------- Own consumption coefficients in extraction sector -----------------
*** ----------------------------------------------------------------------------------------------------------

*** compute fuel extraction per fuel and region from data
p04_fuExtr(regi, enty) = sum((enty2,te), pm_IO_input(regi,enty,enty2,te)) - pm_IO_trade("2005",regi,enty,"Mport") + pm_IO_trade("2005",regi,enty,"Xport");

*** compute share of oil and gas in total oil-gas extraction (due to aggregate data provided by IEA that has to be split)
p04_shOilGasEx(regi, "pegas") =  p04_fuExtr(regi, "pegas")/(p04_fuExtr(regi, "pegas") + p04_fuExtr(regi, "peoil"));
p04_shOilGasEx(regi, "peoil") =  p04_fuExtr(regi, "peoil")/(p04_fuExtr(regi, "pegas") + p04_fuExtr(regi, "peoil"));

*** compute energy input of (oil,gas,electricity) for oil and gas extraction given the shares of the previous step
f04_IO_input("2005", regi, "peoil", "peoil", "d_oil2oil")  = p04_shOilGasEx(regi, "peoil") * f04_IO_input("2005", regi, "peoil", "peog", "d_oil2og");
f04_IO_input("2005", regi, "peoil", "pegas", "d_oil2gas")  = p04_shOilGasEx(regi, "pegas") * f04_IO_input("2005", regi, "peoil", "peog", "d_oil2og");
f04_IO_input("2005", regi, "pegas", "peoil", "d_gas2oil")  = p04_shOilGasEx(regi, "peoil") * f04_IO_input("2005", regi, "pegas", "peog", "d_gas2og");
f04_IO_input("2005", regi, "pegas", "pegas", "d_gas2gas")  = p04_shOilGasEx(regi, "pegas") * f04_IO_input("2005", regi, "pegas", "peog", "d_gas2og");
f04_IO_input("2005", regi, "seel",  "peoil", "d_elec2oil") = p04_shOilGasEx(regi, "peoil") * f04_IO_input("2005", regi, "seel",  "peog", "d_elec2og");
f04_IO_input("2005", regi, "seel",  "pegas", "d_elec2gas") = p04_shOilGasEx(regi, "pegas") * f04_IO_input("2005", regi, "seel",  "peog", "d_elec2og");

*** compute energy own consumption coefficients for all relevant combinations
pm_fuExtrOwnCons(regi, enty, enty2) = 0;
pm_fuExtrOwnCons(regi, "peoil", "peoil") = f04_IO_input("2005", regi, "peoil", "peoil", "d_oil2oil")/ p04_fuExtr(regi, "peoil");
pm_fuExtrOwnCons(regi, "peoil", "pegas") = f04_IO_input("2005", regi, "peoil", "pegas", "d_oil2gas")/ p04_fuExtr(regi, "pegas");
pm_fuExtrOwnCons(regi, "peoil", "pecoal")= f04_IO_input("2005", regi, "peoil", "pecoal","d_oil2coal")/ p04_fuExtr(regi, "pecoal");
pm_fuExtrOwnCons(regi, "pegas", "peoil") = f04_IO_input("2005", regi, "pegas", "peoil", "d_gas2oil")/ p04_fuExtr(regi, "peoil");
pm_fuExtrOwnCons(regi, "pegas", "pegas") = f04_IO_input("2005", regi, "pegas", "pegas", "d_gas2gas")/ p04_fuExtr(regi, "pegas");
pm_fuExtrOwnCons(regi, "seel", "peoil")  = f04_IO_input("2005", regi, "seel",  "peoil", "d_elec2oil")/p04_fuExtr(regi, "peoil");
pm_fuExtrOwnCons(regi, "seel", "pegas")  = f04_IO_input("2005", regi, "seel",  "pegas", "d_elec2gas")/p04_fuExtr(regi, "pegas");
pm_fuExtrOwnCons(regi, "seel", "pecoal") = f04_IO_input("2005", regi, "seel",  "pecoal","d_elec2coal")/p04_fuExtr(regi, "pecoal");


*RP* Distribute the initial gas numbers to ngcc and ngt based on energy values:
loop(regi,
  if( pm_data(regi,"mix0","ngcc") < 0.1 ,  !! in regions where gas provides < 10% of electricity, distribute 80/20
    p04_shareNGTinGas(regi) = 0.15;
  elseif pm_data(regi,"mix0","ngcc") < 0.3 ,  !! in regions where gas provides > 10% and < 30% of electricity, distribute 90/10 (else the amount of peak-load ngt plants is unrealistically high)
    p04_shareNGTinGas(regi) = 0.1;
  else  !! in regions with mix0 > 0.3, use 95/5
    p04_shareNGTinGas(regi) = 0.05;
  );
  if( pm_data(regi,"eta","ngcc") < 0.22 ,   !! if the empiric efficiency of gas->electricity is very low, this implies a higher share of ngt 
    p04_shareNGTinGas(regi) = p04_shareNGTinGas(regi) * 2;
  elseif pm_data(regi,"eta","ngcc") < 0.33 ,
    p04_shareNGTinGas(regi) = p04_shareNGTinGas(regi) * 1.5;
  );
);  

*** apply the split
p04_aux_data(regi,"mix0","ngcc") = pm_data(regi,"mix0","ngcc");
p04_aux_data(regi,"eta","ngcc")  = pm_data(regi,"eta","ngcc");
pm_data(regi,"mix0","ngcc")    = (1 - p04_shareNGTinGas(regi) ) * p04_aux_data(regi,"mix0","ngcc");
pm_data(regi,"mix0","ngt")     = p04_shareNGTinGas(regi) * p04_aux_data(regi,"mix0","ngcc");
pm_data(regi,"eta","ngcc")     = p04_aux_data(regi,"eta","ngcc") * ( 1/0.6 * pm_data(regi,"mix0","ngt") + pm_data(regi,"mix0","ngcc") ) / ( p04_aux_data(regi,"mix0","ngcc") + 1e-8) ;   !! this assumes that the efficiency of an ngt is only 60% of the eff. of ngcc 
pm_data(regi,"eta","ngt")      = 0.6 * pm_data(regi,"eta","ngcc") ;

display pm_fuExtrOwnCons, p04_aux_data, pm_data;

*LB* check if sum mix0 = 1     !! mix0 only sums up to 1 if there is NO own consumption! otherwise the mix0 calculated from p04_IO_output and pm_IO_input is not consistent with v*_INIdemEn0 
***parameter mix0sum(all_regi,all_enty);
***mix0sum(regi,enty2) = sum(en2en(enty,enty2,te),pm_data(regi,"mix0",te));
***display mix0sum;

*LB* preliminary bug fix for all eta > 1 and all eta = 0
loop(regi,
   loop(te,
       if(pm_data(regi,"eta",te) gt 1,
             pm_data(regi,"eta",te) =  fm_dataglob("eta",te);
       );
       if(pm_data(regi,"eta",te) eq 0,
             pm_data(regi,"eta",te) =  fm_dataglob("eta",te);
       );   
   );
);

*NB* use defqult value (MtUR to TWa) for tnrs
pm_data(regi,"eta","tnrs") = fm_dataglob("eta","tnrs");


*** ----------------------------------------------------------------------------------------------------------
***------------------------------- calculate average growth rate of fe use from 1995 to 2010 -----------------
*** ----------------------------------------------------------------------------------------------------------
pm_histfegrowth(regi,enty) = 0.005;
*** FE stationary
loop(regi,
     loop(in2enty(all_enty,entyFe,all_te,te),
         if(sum(se2fe(entySe,entyFe,te), sum(in2enty2(all_enty2,entyFe,all_te2,te), f04_IO_output("1995",regi,entySe,all_enty2,all_te2) )) ne 0,
              pm_histfegrowth(regi,entyFe) = (  sum(se2fe(entySe,entyFe,te), sum(in2enty2(all_enty2,entyFe,all_te2,te), f04_IO_output("2010",regi,entySe,all_enty2,all_te2) ))
                                              / sum(se2fe(entySe,entyFe,te), sum(in2enty2(all_enty2,entyFe,all_te2,te), f04_IO_output("1995",regi,entySe,all_enty2,all_te2) ))
                                             ) **(1/15) - 1;
         );
     );
);
*** FE not stationary (currently transport)
loop(regi,
     loop(se2fe(entySe,entyFeTrans,te),
         if(f04_IO_output("1995",regi,entySe,entyFeTrans,te) ne 0,
              pm_histfegrowth(regi,entyFeTrans) = (  f04_IO_output("2010",regi,entySe,entyFeTrans,te) 
                                                   / f04_IO_output("1995",regi,entySe,entyFeTrans,te) 
                                                  ) **(1/15) - 1;
         );
     );
);
*** SE

loop(regi,
     loop(se2fe(entySe,entyFe,te),
         if(sum((entyPe,te2), f04_IO_output("1995",regi,entyPe,entySe,te2) ) ne 0,
              pm_histfegrowth(regi,entySe) = (  sum((entyPe,te2), f04_IO_output("2010",regi,entyPe,entySe,te2) )
                                              / sum((entyPe,te2), f04_IO_output("1995",regi,entyPe,entySe,te2) )
                                             ) **(1/15) - 1;
         );
     );
);

display pm_histfegrowth, pm_data;

*** EOF ./modules/04_PE_FE_parameters/iea2014/datainput.gms
