*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/sets_calculations.gms

*** This declaration is here and not in core/declarations because this scalar
*** is needed for calculating certain sets.
Scalar
  sm_tmp           "temporary scalar that can be used locally"
  sm_tmp2          "temporary scalar that can be used locally" 
;

***------------------- region set    ------------------------------------------
regi(all_regi)= YES;

display regi;

***-----------------------------------------------------------------------------
*** Generate complementary subsets of 'te':
***-----------------------------------------------------------------------------

***ESM-related sets
teNoRe(te)      = not teReNoBio(te);
teNoLearn(te)   = not teLearn(te);
teEtaConst(te)  = not teEtaIncr(te);
teNoCCS(te)     = not teCCS(te);

entyFe(enty)         = entyFeStat(enty) + entyFeTrans(enty);
trade(enty)          = tradePe(enty) + tradeSe(enty) + tradeMacro(enty);
emi(enty)            = emiTe(enty) + emiMac(enty) + emiExog(enty); 
emiMacMagpie(enty)   = emiMacMagpieCH4(enty) + emiMacMagpieN2O(enty) + emiMacMagpieCO2(enty);
emiMacExo(enty)      = emiMacExoCH4(enty) + emiMacExoN2O(enty);
peExGrade(enty)      = peEx(enty)  - peExPol(enty);
peRicardian(enty)    = peBio(enty) + peEx(enty);
en2se(enty,enty2,te) = pe2se(enty,enty2,te) + se2se(enty,enty2,te);

en2en(enty,enty2,te) = pe2se(enty,enty2,te) + se2se(enty,enty2,te) + se2fe(enty,enty2,te) + fe2ue(enty,enty2,te) + ccs2te(enty,enty2,te);
te2rlf(te,rlf)       = teFe2rlf(te,rlf) + teSe2rlf(te,rlf) + teue2rlf(te,rlf) + teCCS2rlf(te,rlf) + teCCU2rlf2(te,rlf) +teNoTransform2rlf(te,rlf);

***----------------------------------------------------------------------------
*** Fill sets that were created empty and should be filled from the mappings above
***----------------------------------------------------------------------------

loop(pe2se(enty,'seel',te),
                loop(pc2te(enty,enty2,te,'sehe'),
                                        teChp(te) = yes;
                                        );
        );
display teChp;


loop(fe2ue(entyFe,entyUe,te), 
    feForUe(entyFe) = yes;
);
display feForUe;


period4(ttot) = ttot(ttot) - tsu(ttot) - period1(ttot) - period2(ttot) - period3(ttot);
period12(ttot) = period1(ttot) + period2(ttot);
period123(ttot) = period1(ttot) + period2(ttot) + period3(ttot);
period1234(ttot) = period1(ttot) + period2(ttot) + period3(ttot) + period4(ttot);

*** calculate primary production factors (ppf)
ppf(all_in) = ppfEn(all_in) + ppfKap(all_in);
*** add labour to the primary production factors (ppf)
ppf("lab")  = YES;

*** calculate intermediate production factors
ipf(all_in) = in(all_in) - ppf(all_in);
ipf_putty(all_in) = in_putty(all_in) - ppf_putty(all_in);
loop ( out,
ppfIO_putty(in)$(cesOut2cesIn(out,in)
                  AND ipf_putty(in)
                  AND NOT in_putty(out))          = YES;
);
*** Initialise cesLevel2cesIO and cesRev2cesIO
loop (counter$( ord(counter) eq 1 ),
  cesLevel2cesIO(counter,"inco") = YES;   !! the root is at the lowest level
  sm_tmp = counter.val;              !! used here to track total depth in the tree
); 

loop ((counter,cesOut2cesIn(out,in)),    !! loop over all out/in combinations
  if (cesLevel2cesIO(counter-1,out),    !! if out was an input on the last level
    cesLevel2cesIO(counter,in) = YES;   !! in is an input on this level

    if (counter.val gt sm_tmp,   !! store deepest level reached
      sm_tmp = counter.val;
    )
  )
);

loop (counter$( counter.val eq sm_tmp ),
  cesRev2cesIO(counter,"inco") = YES;
);

for (sm_tmp = sm_tmp downto 0,
  loop ((counter,cesOut2cesIn(out,in))$( counter.val eq sm_tmp ),
    if (cesRev2cesIO(counter + 1,out),
      cesRev2cesIO(counter,in) = YES;
    )
  )
);

*** Compute all the elements of the CES below out, iteratively
loop( cesOut2cesIn(out,ppf(in)),
  cesOut2cesIn_below(out,in) = YES;
);

loop ((cesRev2cesIO(counter,in),cesOut2cesIn(in,in2)),
  loop(in3,
     cesOut2cesIn_below(in,in3)$ (cesOut2cesIn_below(in2,in3) ) = YES;
  );
  cesOut2cesIn_below(in,in2) = YES;
);

in_below_putty(in) = NO;
loop (ppf_putty,
in_below_putty(in)$cesOut2cesIn_below(ppf_putty,in) = YES;
);


*** Aliasing of mappings is not available in all GAMS versions
cesOut2cesIn2(out,in) = cesOut2cesIn(out,in);


*** Computing the reference complentary factors

$offOrder
sm_tmp = 0;
loop (cesOut2cesIn(out,in) $ in_complements(in),
  if ( NOT ord(out) eq sm_tmp,
  sm_tmp = ord(out);
  loop (cesOut2cesIn2(out,in2),
        complements_ref(in,in2) = YES;
        );
     );
     );

$onOrder
*** TODO this should be reworked with Robert when revising the transport module
loop(ue2ppfen(enty,ppfEn),
    ppfenFromUe(ppfEn) = yes;
);

loop (fe2ppfEn(entyFe,ppfEn),
  feForCes(entyFe) = YES;
);

display "production function sets", cesOut2cesIn, cesOut2cesIn2, cesLevel2cesIO, cesRev2cesIO, ppf, ppfEn, ipf;

*** Energy service layer sets
loop(es2ppfen(esty,ppfen),
    ppfenFromEs(ppfen) = yes;
);

loop (fe2es(entyFe,esty,teEs),
  feForEs(entyFe) = YES;
);

loop (fe2es(entyFe,esty,teEs),
    loop(es2ppfen(esty,ppfen),
	feViaEs2ppfen(entyFe,ppfen,teEs) = YES;
	);
);

display "ES layer sets:", ppfenFromEs, feForEs, feViaEs2ppfen;


loop ( se2fe(entySe,entyFe,te),
fete(entyFe,te) = YES;
);

*** MAGICC related sets
t_magiccttot(tall) = ttot(tall) + t_extra(tall);
t_magicc(t_magiccttot)$(t_magiccttot.val ge 2005) = Yes;

display "MAGICC related sets", t_magicc, t_extra, t;

Execute_Loadpoint 'input'   t_input_gdx = t;

t_interpolate(ttot) = t(ttot) - t_input_gdx(ttot);

*** Alias of mapping
en2en2(enty,enty2,te) = en2en(enty,enty2,te);

*** EOF ./core/sets_calculations.gms
