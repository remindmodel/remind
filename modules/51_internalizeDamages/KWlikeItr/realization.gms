
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/51_internalizeDamages/KWlikeItr/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/KWlikeItr/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/KWlikeItr/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/51_internalizeDamages/KWlikeItr/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/51_internalizeDamages/KWlikeItr/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/51_internalizeDamages/KWlikeItr/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/51_internalizeDamages/KWlikeItr/presolve.gms"
$Ifi "%phase%" == "solve" $include "./modules/51_internalizeDamages/KWlikeItr/solve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/KWlikeItr/postsolve.gms"
$Ifi "%phase%" == "output" $include "./modules/51_internalizeDamages/KWlikeItr/output.gms"
*######################## R SECTION END (PHASES) ###############################
