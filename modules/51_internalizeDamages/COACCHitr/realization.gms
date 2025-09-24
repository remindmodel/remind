
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/COACCHitr/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/COACCHitr/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/COACCHitr/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
