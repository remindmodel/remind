
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/KWTCint/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KWTCint/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KWTCint/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KWTCint/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KWTCint/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
