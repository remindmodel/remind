
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/LabItr/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/LabItr/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/LabItr/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
