***-----------------------------------------------------------------------------
*** Preparation before reading GAMS code from 24_trade module
***-----------------------------------------------------------------------------
$ONEMPTY
$include "./modules/24_trade/network_trade/toymodel/prep.gms"



***-----------------------------------------------------------------------------
*** Load sets and declarations from 24_trade module
***-----------------------------------------------------------------------------

*** sets
$include "./modules/24_trade/network_trade/sets.gms"

*** declarations
$include "./modules/24_trade/network_trade/declarations.gms"



***-----------------------------------------------------------------------------
*** Load REMIND variables from input GDX file
***-----------------------------------------------------------------------------
execute_loadpoint './modules/24_trade/network_trade/toymodel/input.gdx' vm_Mport;
execute_loadpoint './modules/24_trade/network_trade/toymodel/input.gdx' vm_Xport;
execute_loadpoint './modules/24_trade/network_trade/toymodel/input.gdx' p_PEPrice;

display vm_Xport.l;



***-----------------------------------------------------------------------------
*** Load datainput and presolve from 24_trade module
***-----------------------------------------------------------------------------

*** datainput
$include "./modules/24_trade/network_trade/datainput.gms"

*** run trade model in presolve
$include "./modules/24_trade/network_trade/presolve.gms"



***-----------------------------------------------------------------------------
*** Dump results to a GDX file
***-----------------------------------------------------------------------------
execute_unload './modules/24_trade/network_trade/toymodel/toymodel_output/results.gdx', v24_shipment_quan, v24_cap_tradeTransp, v24_deltaCap_tradeTransp;
