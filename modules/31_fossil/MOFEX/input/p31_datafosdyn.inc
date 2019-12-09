*** SOF ./modules/31_fossil/timeDepGrades/input/p31_datafosdyn.inc
*NB* this file is hardcoded
*NB, IM* The parameter values are based on World Energy Outlook (2008, 2009) and further assumptions/approximations.
*NB* However, is has been agreed at the RoSE meeting aon July 19 that this needs to done

* Maximum decline rate for oil, gas and coal
p31_datafosdyn(regi, "pegas",  rlf, "dec")$(p31_datafosdyn(regi, "pegas",  rlf, "dec") eq 0) = 0.15;
p31_datafosdyn(regi, "peoil",  rlf, "dec")$(p31_datafosdyn(regi, "peoil",  rlf, "dec") eq 0) = 0.15;
p31_datafosdyn(regi, "pecoal", rlf, "dec")$(p31_datafosdyn(regi, "pecoal", rlf, "dec") eq 0) = 0.15;

* Maximum extraction rate increase of oil, gas and coal
p31_datafosdyn(regi, "pegas",  rlf, "inc") = 0.1;
p31_datafosdyn(regi, "peoil",  rlf, "inc") = 0.1;
p31_datafosdyn(regi, "pecoal", rlf, "inc") = 0.1;

* Additional factor entering the decline rate equation 
p31_datafosdyn(regi,  "peoil",  rlf, "decoffset") = -2.E-4;
p31_datafosdyn(regi,  "pegas",  rlf, "decoffset") = -2.E-4;
p31_datafosdyn(regi,  "pecoal", rlf, "decoffset") = -2.E-4;
p31_datafosdyn("MEA", "peoil",  rlf, "decoffset") = -2.E-5;
p31_datafosdyn("RUS", "peoil",  rlf, "decoffset") = -2.E-5;
p31_datafosdyn("MEA", "pegas",  rlf, "decoffset") = -2.E-5;
p31_datafosdyn("RUS", "pegas",  rlf, "decoffset") = -2.E-5;

* Additional factor entering the increase rate equation
p31_datafosdyn(regi, "pegas",  rlf, "incoffset") = 0.002 * p31_grades("2005", regi, "xi3", "pegas",  rlf);
p31_datafosdyn(regi, "peoil",  rlf, "incoffset") = 0.002 * p31_grades("2005", regi, "xi3", "peoil",  rlf);
p31_datafosdyn(regi, "pecoal", rlf, "incoffset") = 0.002 * p31_grades("2005", regi, "xi3", "pecoal", rlf);

* Factor for quadratic adjustment cost function
p31_datafosdyn(regi, enty, rlf, "alph") = 20;
*** EOF ./modules/31_fossil/timeDepGrades/input/p31_datafosdyn.inc
