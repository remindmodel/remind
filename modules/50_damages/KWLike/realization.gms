
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KWLike/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KWLike/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KWLike/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KWLike/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
