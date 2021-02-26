*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate.gms

*' @description 
*' The macro-calibration takes place in `modules/29_CES_parameters/calibration/`. The calibration itself is in the file `preloop.gms`.
*' 
*' The aim of the calibration is to provide the efficiency parameters of the CES tree for each time step and each region. 
*' Efficiency parameters have a strong influence on the level of energy demanded by the CES-tree to the energy system module. 
*' In order to avoid ad hoc assumptions on the level of these parameters, the new macro-calibration procedure loads exogenous 
*' energy demand pathways and ensures that a baseline REMIND run will meet these trajectories.
*' 
*' #### How to calibrate Remind
*'
*'1. the energy demand pathways will be selected automatically in input/pm_fe_demand.cs4r according to the modules selected and the SSP scenario chosen. If you wish to modify the pathways, refer to the mrremind library, which provides the pm_fe_demand.cs4r file.
*'2. Select/Add the scenarios of interest in `scenario_config_calibrateSSPs.csv` and copy it to `scenario_config.csv`.
*'3. Rscript start_bundle.R or similar command
*'4.	After the runs are finished, look at `CES calibration report_RunName.pdf` in the output folder
*'  * If there is nothing on the first two pages, it should be OK
*'  *	If there are a couple of rows in the table, look at the variables mentioned
*'  *	If you see more than 10 lines, there is a high chance that the calibration ran into problems
*'  *	There should be as many iterations as you asked for (default = 10). If that is not the case, it’s probably better to refrain from using the produced efficiencies
*'5. If everything went well, you will see in the output folder a couple of files:
*'  *	`stat_off-indu_fixed_shares-buil_services_putty-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_perfect-Reg_690d3718e1_ITERATION_1.inc`
*'6.	One of these files should be copied to `modules/29_CES_parameters/load/input`, by removing the _ITERATION_IterationNumber of the file chosen. Generally, you can take the 10th iteration (_ITERATION_10.inc)
*'So if you are in the output folder of your run:
*'`cp stat_off-indu_fixed_shares-buil_services_putty-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_perfect-Reg_690d3718e1_ITERATION_1.inc  ../../modules/29_CES_parameters/load/input/stat_off-indu_fixed_shares-buil_services_putty-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_perfect-Reg_690d3718e1.inc`
*'*KEEP THE SAME NAME WITH THE EXCEPTION OF THE _ITERATION_XX PART*
*'7.	Upload in GIT
*'
*'#### How the calibration works
*'
*'##### 1. Principle
*'
*'The calibration adapts the efficiency parameters of the CES function so that GDP and FE trajectories are met.
*'
*'Efficiency parameters are divided in three dimensions: the efficiency parameter, the efficiency growth parameter, and the income share parameter.
*'The efficiency growth parameter captures both the growth in efficiency and in the income share. So, this is the only time-variant parameter.
*'The income share parameter hence represents the 2005 income share.
*'
*'The calibration has to fulfill two constraints: an economical constraint and a technological constraint.
*'The technological constraint only means that the inputs of the CES function must yield the desired output. At this stage, there is no economical consideration at all. During a REMIND run however, the model will strive to find out the most efficient solution in terms of costs.
*'So, the second constraint is an economical constraint. The derivatives of the CES function, i.e. the marginal increase in income from increasing the considered input by one unit, must equal the price of that input, i.e. the marginal cost.
*'
*'##### 2. Inputs
*'In order to calibrate the CES tree of Remind, you will need
*'
*'    trajectories for labour, GDP and final energy carriers/energy services (ppfen) quantities, usually provided by EDGE. We also need the capital quantities pathways.
*'
*'If you are calibrating a new CES structure (added/removed branches to/from the CES tree), you will also need
*'
*'    explicit price trajectories for the primary production factors (`ppf`, capital and final energy carriers/energy services). They are included in `input/p29_cesdata_price.cs4r` which is derived from the mrremind library.
*'
*'Strictly speaking, the price only have to be larger than 0, but the closer the prices are to the "real" ones, the faster the calibration will converge.
*'It is therefore advisable to use the prices of some substitute energy carrier/service. The prices give the indication of the marginal cost of each input, and thus represent the economical constraint.
*'
*'The information on final energy quantities is stored in `./modules/29_CES_parameters/calibration/input/`, read in `./modules/29_CES_parameters/calibration/datainput.gms` in the parameter `pm_fedemand` and loaded in `./modules/29_CES_parameters/calibration/input/` and transfered to `pm_cesdata(,,,"quantity")` in `./modules/29_CES_parameters/calibration/datainput.gms`
*'The information on labour and GDP is stored and read somewhere else in the model in the parameters `p_lab` and `pm_gdp`, respectively.
*'The information on capital quantities is stored in `./modules/29_CES_parameters/calibrate/input/p29_capitalQuantity.cs4r` and loaded in `./modules/29_CES_parameters/calibration/datainput.gms` in the parameter `p29_capitalQuantity`.
*'
*'##### 3. A calibration in several iterations
*'
*'The calibration operates in several iterations. In each iteration, the nested CES function is adapted so that the exogenous final energy pathways and the exogenous GDP and labour trajectories correspond.
*'Each iteration only differs from the others in the prices that are provided to the calibration. They represent the feedback from the energy system module.
*'These prices are provided exogenously (or computed from `input.gdx`) for the first iteration, and are derived from a REMIND run for the next iteration.
*'The assumption is that by adjusting the efficiency parameters in each iteration, the efficiency parameters converge towards a stable value.
*'The steps to be followed between each iteration (start REMIND, store the `fulldata.gdx` under a different name, create the file to be used in the load mode) is contained in the function `submit.R`.
*'
*'The following paragraphs describe the calculations happening in each of the iteration i.e in `preloop.gms`.
*' 
*'##### 4. Computation of prices
*'
*'In the first iteration, for a new CES structure, there is no gdx file that could provide directly the equilibrium prices of the CES ppfen. Therefore, exogenous price trajectories must be provided. Switch `cfg$gms$c_CES_calibration_new_structure` to 1 in `config/default.cfg` in case you want to use exogenous prices for the first iteration.
*'For other iterations, or if the structure is the one from the `input.gdx`, the equilibrium prices will be computed. They are computed as the derivative of GDP in terms of each input.
*'By the chain rule, the derivatives of each level of the CES-tree must be multiplied to obtain the desired derivative.
*'
*'Primary production factor (`ppf`) prices are thus calculated as the derivatives of the production function.
*'
*'$V_o = \left( \sum_{(o,i)} \xi_i \left( \theta_i \delta_i V_i \right)^{\rho_o} \right)^{1/\rho_o}$
*'
*'where $\xi$ is the income share, $\theta$ the efficiency parameter,
*' $\delta$ the efficiency growth,
*' $\rho$ a parameter derived from the substitution elasticity,
*' $i,o$ the elements of the input and output sets, respectively.
*'
*'$\pi_i = \xi_i \theta_i \delta_i \ V_o^{1 - \rho_o} \ \left(\theta_i \delta_i V_i\right)^{\rho_o - 1}$
*'
*'
*'<pre><code class="GAMS">
*'*** Compute ppf prices from CES derivatives of previous run
*'p29_CESderivative(t,regi,ces(out,in))$( vm_cesIO.l(t,regi,in) gt 0 )
*'  =
*'    pm_cesdata(t,regi,in,"xi")
*'  * pm_cesdata(t,regi,in,"eff")
*'  * vm_effGr.l(t,regi,in)
*'  
*'  * vm_cesIO.l(t,regi,out)
*' ** (1 - pm_cesdata(t,regi,out,"rho"))
*'
*'  * ( pm_cesdata(t,regi,in,"eff")
*'    * vm_effGr.l(t,regi,in)
*'    * vm_cesIO.l(t,regi,in)
*'    )
*' ** (pm_cesdata(t,regi,out,"rho") - 1);
*';
*'
*'*** Propagate price down the CES tree
*'loop ((ceslev(counter,in),ces(in,in2),ces2(in2,in3)),
*'  p29_CESderivative(t,regi,"inco",in3)
*'  = p29_CESderivative(t,regi,"inco",in2)
*'  * p29_CESderivative(t,regi,in2,in3);
*');
*'
*'*** Prices of intermediate production factors are all 1
*'p29_CESderivative(t,regi,in,ipf(in2))$( p29_CESderivative(t,regi,in,in2) ) = 1;
*'</code></pre>
*'
*'
*'In the code, the "propagation" part corresponds to the chain rule. The prices of the intermediate production factors are set to one,
*' so that the prices of `ppfen` correspond to their price in terms of GDP. The efficiencies of the intermediate production factors will 
*'be changed accordingly, so that their derivative is equal to one. 
*'
*'Depending upon the setting, prices are then smoothed in the early years of the simulation.
*'
*'##### 5. Calculation of Intermediate Production Factors
*'
*'The economical constraint tells us that the prices are equal to the derivatives.
*'
*'$\pi_i = \frac{\partial V_o(V_1,..., V_i,...,V_n)}{\partial V_i}$
*'
*'The technological constraint tells us, following the Euler's rule, that, for homogenous functions of degree one (as it is the case here),
*'the output is equal to the sum of the derivatives times the quantity of inputs.
*'
*'$V_o = \sum_{(o,i)} \frac{\partial V_o}{\partial V_i}$ $V_i \qquad \forall o \in \text{ipf}$
*'
*'By combining both constraints, we deduce that the output is equal to the sum of inputs valued at their price.
*'
*'$V_o = \sum_{(o,i)} \pi_i V_i \qquad \forall o \in \text{ipf}$
*'
*'So, the prices and quantities given exogenously, combined with the two constraints,
*'are sufficient to determine all the quantities of the CES tree up to the last level with labour and capital.
*'
*'##### 6. Changing efficiencies to ensure that the economical constraint holds.
*'
*'We then have to ensure that the derivative is equal to the price. We set the efficiency growth to one to simplify the computation.
*'The total efficiency is now two-dimensional: the income share and the efficiency parameter.
*'
*'$\pi_i = \xi_i \theta_i \ V_o^{1 - \rho_o} \ \left(\theta_i V_i\right)^{\rho_o - 1}$
*'
*'The couple $(\xi_i,\theta_i) = (\frac{\pi V_i}{Vo}, \frac{V_o}{V_i})$ solves this equation.
*'
*'
*'###### Calculate Income Shares $\xi$
*'
*'$\xi_i = \frac{\pi_i V_i}{V_o} \qquad \forall (o,i) \in \text{CES}$
*'
*'###### Calculate Efficiencies $\theta$
*'
*'$\theta_i = \frac{V_o}{V_i} \qquad \forall (o,i) \in \text{CES}$
*'
*'
*'##### 7. Last level of the CES-tree: Ensure the GDP and Labour trajectories are met
*'
*'Thus far, we could compute the efficiencies for all levels below the energy component of the final aggregated production function.
*'At the top level (GDP, Labour, Aggregated Energy and Capital), the constraints are somewhat different. We must ensure that the total product of the CES tree will deliver the exogenous level of GDP.
*'The labour efficiency will be the adjustment variable. From the last steps, we know the income share of energy for all time steps.
*'Capital is treated as the other inputs seen above in the CES function. 
*'
*'Once we have both the price and quantities of energy and capital, we can easily determine the income share of labour, and thereby its price and efficiency.
*'
*'
*'##### 8. Calculate Efficiency growth parameter $\delta$
*'
*'For all inputs but capital, the changes over time of $\xi$ and $\theta$ are put into $\delta$. $\xi$ and $\theta$ are therefore constant at their 2005 levels.
*'
*'$\delta_i(t) = \frac{\theta_i(t)}{\theta_i(t_0)} \left(\frac{\xi_i(t)}{\xi_i(t_0)}\right)^{1 / \rho_o} \qquad \forall (o,i) \in \text{CES}$
*'
*'#### Calibrating at an intermediary level: What happens with efficiency in the lower part?
*'
*'The CES nest cannot be calibrated on two levels lying one upon the other. So, if one decides to calibrate at an intermediary level of the CES nest, i.e. not at the level linked to the energy system module, the levels below cannot be calibrated to. There is no golden rule for the growth of the efficiency parameters below the calibration level. They can be left to their 2005 level or the user can provide exogenous efficiency trajectories.
*'
*'#### Putty-Clay
*'
*'It is possible to introduce segments of the CES tree which are subject to putty-clay dynamics, _i.e._ the model at time `t` will substitute between _increments_ of the variables. The _aggregate_ level of the variable will be the sum of the _increment_ from the CES and the depreciated past _aggregate_ level. This mechanism limits the extent to which the energy demand can be reduced in response to higher energy prices.
*'
*'To treat some CES sections as putty-clay, the set items should be included to `in_putty` and `ppf_putty` for the lowest level of the putty-clay section. In addition, depreciation rates should be defined for the putty variables. For consistency, it is advisable to use identical depreciation rates for inputs and outputs in the same CES function.
*'
*'Currently, the calibration script has not been tested for a putty-clay structure that is in the `beyond_calib` part.
*'
*'The Powerpoint file attached gives some more explanations.
*'
*'#### Perfectly complementary factors
*'
*'To implement perfectly complementary factors, you should include the factors in the set `in_complements`. In addition, the elasticity of substitution between these factors should be set to `INF` (which is counter-intuitive). Prices of complementary inputs are set to 1, so that the output is equal to the sum of inputs (reason why the substitution elasticity should be INF), which makes sense for energetic entities. It would however be possible to change this (by choosing another elasticity of substitution) without harming the calibration.
*'
*'In the model, the complementary factors are subject to a constraint (`q01_prodCompl` or `q01_prodCompl_putty`), so that each variable is computed by multiplying a key variable of the CES function by a given factor. The calibration computes this factor for each period.
*'
*'#### Setup
*'
*'The relevant changes to the configuration are
*'* module *`29_CES_parameters`*: realization `calibrate`
*'* switch *`c_CES_calibration_iterations`* (default 10):
*'The calibration is an iterative process that runs for a fixed number of iterations and has no convergence criterium. The calibration can be continued (by using the `last_optim.gdx` as the `input.gdx` in a new run) if convergence was not good enough.
*'* switch *`c_CES_calibration_new_structure`* (default 0): 
*'Turn this on if you are calibrating a new CES structure (added/removed branches to/from the CES tree).
*'
*'
*'#### Calibration run
*'
*'Once set up, start Remind as you normally would. Ten calibration iterations will take about five hours.
*'
*'#### Calibration results
*'
*'The calibration will store the `full.lst`, `full.log` and `input.gdx` files for all calibration iterations (i.e., `input_00.gdx`, `input_01.gdx`, ...) for analysis and debugging.
*'The most important numbers (quantities, prices and efficiencies) are also written to the file `CES_calibration.csv` for easy analysis.
*'The file to be stored in `/load/datainput/` are produced after each iteration. Which iteration to take remains to be decided.
*'The calibration produces a PDF-file based on the data in `CES_calibration.csv` called `CES calibration report_RunName.pdf`. See at the "How to calibrate Remind" section to see how to interpret it.
*'The input files gathering all the efficiency parameters take the name `stat_off-indu_fixed_shares-buil_services_putty-tran_complex-POP_pop_SSP2-GDP_gdp_SSP2-Kap_perfect-Reg_690d3718e1_ITERATION_ITERATIONnumber.inc`. The file corresponding to the best iteration should be copied to `../../modules/29_CES_parameters/load/input/` removing the `_ITERATIONnumber` part


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/29_CES_parameters/calibrate/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/29_CES_parameters/calibrate/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/29_CES_parameters/calibrate/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/29_CES_parameters/calibrate/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/29_CES_parameters/calibrate/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/29_CES_parameters/calibrate/bounds.gms"
$Ifi "%phase%" == "output" $include "./modules/29_CES_parameters/calibrate/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/29_CES_parameters/calibrate.gms
