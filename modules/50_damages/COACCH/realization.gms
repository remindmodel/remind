
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/COACCH/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/COACCH/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/COACCH/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/COACCH/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/COACCH/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
