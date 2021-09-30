
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/KWLike/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KWLike/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KWLike/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/50_damages/KWLike/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/50_damages/KWLike/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KWLike/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/50_damages/KWLike/presolve.gms"
$Ifi "%phase%" == "solve" $include "./modules/50_damages/KWLike/solve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KWLike/postsolve.gms"
$Ifi "%phase%" == "output" $include "./modules/50_damages/KWLike/output.gms"
*######################## R SECTION END (PHASES) ###############################
