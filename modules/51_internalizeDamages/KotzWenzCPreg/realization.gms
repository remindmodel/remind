*** SOF ./modules/51_internalizeDamages/KotzWenzCPreg/realization.gms

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/KotzWenzCPreg/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/KotzWenzCPreg/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/KotzWenzCPreg/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/51_internalizeDamages/KotzWenzCPreg/realization.gms
