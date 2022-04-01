
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/TCitr/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/TCitr/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/TCitr/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
