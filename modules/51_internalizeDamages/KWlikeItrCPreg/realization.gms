
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/KWlikeItrCPreg/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/KWlikeItrCPreg/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/KWlikeItrCPreg/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
