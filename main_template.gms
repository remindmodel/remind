*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./main.gms
*' @title REMIND - REgional Model of INvestments and Development
*'
*' @description REMIND is a global multi-regional model incorporating the economy, the climate system 
*' and a detailed representation of the energy sector. It solves for an intertemporal Pareto optimum 
*' in economic and energy investments in the model regions, fully accounting for interregional trade in 
*' goods, energy carriers and emissions allowances. REMIND enables analyses of technology options and 
*' policy proposals for climate change mitigation.
*'
*' The macro-economic core of REMIND is a Ramsey-type optimal growth model in which intertemporal global 
*' welfare is optimized subject to equilibrium constraints ([02_welfare]). Intertemporal optimization 
*' ([80_optimization]) with perfect foresight is subject to market clearing. The model explicitly represents 
*' trade in final goods, primary energy carriers, and when certain climate policies are enabled, emissions 
*' allowances ([24_trade]). The macro-economic production factors are capital, labor, and final energy. 
*' A nested production function with constant elasticity of substitution determines the final energy demand 
*' ([01_macro], [29_CES_parameters]). REMIND uses economic output for investments in the macro-economic 
*' capital stock as well as for consumption, trade, and energy system expenditures. 
*' 
*' The macro-economic core and the energy system part are hard-linked via the final energy demand and the 
*' costs incurred by the energy system. Economic activity results in demand for final energy in different 
*' sectors (transport ([35_transport]), industry ([37_industry]), buildings ([36_buildings])...) and of 
*' different type (electric ([32_power]) and non-electric). The primary energy carriers in REMIND include 
*' both exhaustible and renewable resources. Exhaustible resources comprise uranium as well as three fossil 
*' resources ([31_fossil]), namely coal, oil, and gas. Renewable resources include hydro, wind, solar, 
*' geothermal, and biomass ([30_biomass]). More than 50 technologies are available for the conversion of 
*' primary energy into secondary energy carriers as well as for the distribution of secondary energy carriers 
*' into final energy.
*'
*' The model accounts for the full range of anthropogenic greenhouse gas (GHG) emissions, most of which are 
*' represented by source. REMIND simulates emissions from long-lived GHGs (CO2, CH4, N2O), short-lived GHGs 
*' (CO, NOx, VOC) and aerosols (SO2, BC, OC). It accounts for these emissions with different levels of detail 
*' depending on the types and sources of emissions. It calculates CO2 emissions from fuel combustion, CH4 
*' emissions from fossil fuel extraction and residential energy use, and N2O emissions from energy supply 
*' based on sources. 
*'
*' The code is structured in a modular way, with code belonging either to the model's core, or to one of the 
*' modules. The folder structure is as follows: at the top level are the folders config, core, modules and 
*' scripts. The config folder contains the REMIND settings and configuration information. The core folder 
*' contains all the files that are part of the core. The modules folder holds all the files that belong to 
*' the modules, with numbered sub-folders for every module. The scripts folder contains helpful scripts for 
*' starting a model run and analysing results.
*' 
*' REMIND is run by executing the main.gms file, which loads the configuration information and builds the model, 
*' by concatenating all necessary files from the core and modules folders into a single file called full.gms. 
*' The concatenation process starts with files from the core and continues with files from activated modules, 
*' in increasing order of module-number. It observes the following structure:
*'
*' ![Technical Structure of REMIND](technical_structure.png){ width=100% }
*'
*'
*' The GAMS code follows a naming etiquette based on the following prefixes:
*'
*' * "q_" to designate equations,
*' * "v_" to designate variables,
*' * "s_" to designate scalars,
*' * "f_" to designate file parameters (parameters that contain unaltered data read in from input files),
*' * "o_" to designate output parameters (parameters that do not affect the optimization, but are affected by it),
*' * "p_" to designate other parameters (parameters that were derived from "f_" parameters or defined in code),
*' * "c_" to designate config switches (parameters that enable different configuration choices),
*' * "s_FIRSTUNIT_2_SECONDUNIT" to designate a scalar used to convert from the FIRSTUNIT to the SECONDUNIT 
*'                              through multiplication, e.g. s_GWh_2_EJ.
*'
*' These prefixes are extended in some cases by a second letter:
*'
*' * "?m_" to designate objects used in the core and in at least one module.
*' * "?00_" to designate objects used in a single module, exclusively, with the 2-digit number corresponding 
*'          to the module number.
*'
*' Sets are treated differently: instead of a prefix, sets exclusively used within a module get that module's 
*' number added as a suffix. If the set is used in more than one module no suffix is given. 
*' 
*' The units (e.g., TWa, EJ, GtC, GtCO2, ...) of variables and parameters are documented in the declaration files.



*##################### R SECTION START (VERSION INFO) ##########################
* 
* Regionscode: 62eff8f7
* 
* Input data revision: 6.284
* 
* Last modification (input data): Mon Feb 28 12:15:08 2022
* 
*###################### R SECTION END (VERSION INFO) ###########################

*----------------------------------------------------------------------
*** main.gms: main file. welcome to remind!
*----------------------------------------------------------------------

file logfile /""/;

logfile.lw = 0;
logfile.nr = 2;
logfile.nd = 3;
logfile.nw = 0;
logfile.nz = 0;

*--------------------------------------------------------------------------
*** preliminaries:
*--------------------------------------------------------------------------
*** allow empty data sets:
$onempty
*** create dummy identifier to fill empty sets:
$phantom null
*** include unique element list:
$onuellist
*** include $-statements in listing
$ondollar
*** include end-of-line comments
$ONeolcom
*** remove the warnings for very small exponents (x**-60) when post-processing
$offdigit
*** turn profiling off (0) or on (1-3, different levels of detail)
option profile = 0;

*--------------------------------------------------------------------------
***           basic scenario choices
*--------------------------------------------------------------------------

***------------------------------------------------------------------------------------------------
***------------------------------------------------------------------------------------------------
*** WARNING *** WARNING *** WARNING *** WARNING *** WARNING *** WARNING ***
***------------------------------------------------------------------------------------------------
***                        START OF WARNING ZONE
***------------------------------------------------------------------------------------------------
***
*** PLEASE DO NOT PERFORM ANY CHANGES IN THE WARNING ZONE! ALL SETTINGS WILL BE AUTOMATICALLY
*** SET BY submit.R BASED ON THE SETTINGS OF THE CORRESPONDING CFG FILE
*** PLEASE DO ALL SETTINGS IN THE CORRESPONDING CFG FILE (e.g. config/default.cfg)
***
***------------------------------------------------------------------------------------------------
*** WARNING *** WARNING *** WARNING *** WARNING *** WARNING *** WARNING ***
***------------------------------------------------------------------------------------------------


***---------------------    Run name and description    -------------------------
[:TITLE:]


***------------------------------------------------------------------------------
***                           MODULES
***------------------------------------------------------------------------------

[:MODULES:]


***-----------------------------------------------------------------------------
***                     SWITCHES and FLAGS
***-----------------------------------------------------------------------------
***--------------- declaration of parameters for switches ----------------------

[:DECLARATION:]


*** ----------------------------------------------------------------------------
***        YOU ARE IN THE WARNING ZONE (DON'T DO CHANGES HERE)
*** ----------------------------------------------------------------------------
*--------------------switches---------------------------------------------------

[:SWITCHES:]


*** ----------------------------------------------------------------------------
***        YOU ARE IN THE WARNING ZONE (DON'T DO CHANGES HERE)
*** ----------------------------------------------------------------------------
*--------------------flags------------------------------------------------------

[:FLAGS:]


*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
***                                  END OF WARNING ZONE
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** --------------------------------------------------------------------------------------------------------------------------------------------------------------------

*--------------------more flags-------------------------------------------------------
*-------------------------------------------------------------------------------------
*AG* the remaining flags outside the warning zone are usually not changed
*LB* default: 5 years time steps from 2005 to 2150
*LB* test_TS: 2005,2010, 2020,2030,2040,2050,2070,2090,2110,2130,2150
*LB* END2110: 2005:5:2105,2120
***$setGlobal test_TS             !! def = off
*GL* Flag for short time horizon
***$setGlobal END2110             !! def = off

*-------------------------------------------------------------------------------------
*** automated checks and settings

*ag* set conopt version
option nlp = %cm_conoptv%;
option cns = %cm_conoptv%;

*--------------------------------------------------------------------------
***           SETS
*--------------------------------------------------------------------------
$include    "./core/sets.gms";
$batinclude "./modules/include.gms"    sets
$include    "./core/sets_calculations.gms";

*--------------------------------------------------------------------------
***        DECLARATION     of equations, variables, parameters and scalars
*--------------------------------------------------------------------------
$include    "./core/declarations.gms";
$batinclude "./modules/include.gms"    declarations

*--------------------------------------------------------------------------
***          DATAINPUT
*--------------------------------------------------------------------------
$include    "./core/datainput.gms";
$batinclude "./modules/include.gms"    datainput

*--------------------------------------------------------------------------
***          EQUATIONS
*--------------------------------------------------------------------------
$include    "./core/equations.gms";
$batinclude "./modules/include.gms"    equations

*--------------------------------------------------------------------------
***           PRELOOP   Calculations before the Negishi-loop starts
***                     (e.g. initial calibration of macroeconomic module)
*--------------------------------------------------------------------------
$include    "./core/preloop.gms";
$batinclude "./modules/include.gms"    preloop

*--------------------------------------------------------------------------
***         LOOP   solve statement, including BOUNDS
*--------------------------------------------------------------------------
$include    "./core/loop.gms";

*--------------------------------------------------------------------------
***         OUTPUT
*--------------------------------------------------------------------------
$ifthen.c_skip_output %c_skip_output% == "off"
$include    "./core/output.gms";
$batinclude "./modules/include.gms"    output
$include "./core/magicc.gms";    !!connection to MAGICC, needed for post-processing
$endif.c_skip_output

*** EOF ./main.gms

