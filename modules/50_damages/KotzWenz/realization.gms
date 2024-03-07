
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/KotzWenz/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KotzWenz/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KotzWenz/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KotzWenz/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KotzWenz/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
