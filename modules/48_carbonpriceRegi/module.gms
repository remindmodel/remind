
*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%carbonpriceRegi%" == "NDC" $include "./modules/48_carbonpriceRegi/NDC/realization.gms"
$Ifi "%carbonpriceRegi%" == "netZero" $include "./modules/48_carbonpriceRegi/netZero/realization.gms"
$Ifi "%carbonpriceRegi%" == "none" $include "./modules/48_carbonpriceRegi/none/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
