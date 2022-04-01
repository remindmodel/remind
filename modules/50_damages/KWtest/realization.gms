
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KWtest/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KWtest/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KWtest/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KWtest/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
