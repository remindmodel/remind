
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/Labor/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/Labor/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/Labor/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/Labor/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
