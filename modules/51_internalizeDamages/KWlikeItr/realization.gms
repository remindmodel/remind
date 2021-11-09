
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/KWlikeItr/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/KWlikeItr/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/KWlikeItr/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
