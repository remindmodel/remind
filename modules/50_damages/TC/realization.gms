
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/TC/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/TC/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/TC/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/TC/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/TC/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
