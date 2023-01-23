*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/realization.gms

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
*' This documentation is focused on the implementation. For instructions on how to calibrate, refer to the tutorial 'Calibrating CES Parameters' in the `tutorials` folder.
*'
*'#### How the calibration works (Overview)
*'
*'##### 1. Prerequisites
*'
*'The CES tree in Remind consists of a tree of nested CES functions of the form 
*'
*'$V_o = \left( \sum_{(o,i)} \xi_i \left( \theta_i \delta_i V_i \right)^{\rho_o} \right)^{1/\rho_o}$
*'
*' where $V$ are the quantities (`quantity` in the code),
*' $\xi$ is the income share (`xi`), $\theta$ the efficiency parameter (`eff`),
*' $\delta$ is the efficiency growth (`effGr`),
*' $\rho$ (`rho`) is a parameter derived from the substitution elasticity,
*' and $i,o$ are the elements of the input and output sets, respectively.
*' 
*' 'Nested' means that each output of one CES node serves as one of the inputs to the node above, up to the last level. The uppermost level of the tree is GDP (`inco`), the lowest ones (the 'leaves' of the tree) are called primary production factors (`ppf`). They include final energies (`ppfen`), different capitals, and labour (`lab`), which is a direct input to `inco`. 
*'
*' In the following, the term 'efficiency parameters' will be used collectively for the parameters $\xi$, $\theta$ and $\delta$ (income share, efficiency and efficiency growth). A distinction will follow later.  
*'
*'The CES tree has to fulfill two constraints: An economical constraint and a technological constraint.
*'The economical constraint defines the price of an input factor: During a REMIND run, the model will strive to find out the optimal solution in terms of costs. This means that the derivatives of the CES function, i.e. the marginal increase in income from increasing the considered input by one unit, must equal the price of that input. So the price $\pi_i$ of input $i$ can be calculated as 
*'
*'$\pi_i = \frac{\partial V_o(V_1,..., V_i,...,V_n)}{\partial V_i} = \xi_i \theta_i \delta_i \ V_o^{1 - \rho_o} \ \left(\theta_i \delta_i V_i\right)^{\rho_o - 1}.$
*'
*'The technological constraint states that the inputs of the CES function must yield the desired output.
*'For homogenous functions of degree one (as the CES function), this entails (following the Euler's homogeneous function theorem)
*'that the output is equal to the sum of derivative times quantity of inputs
*'
*'$V_o = \sum_{i} \frac{\partial V_o}{\partial V_i} V_i$
*'
*'By combining both constraints, we deduce that the output is equal to the sum of inputs valued at their price.
*'
*'$V_o = \sum_{i} \pi_i V_i$
*'
*'##### 2. Principle
*'
*' In Remind, the elasticities of substitution and thus $\rho$ are prescribed ad-hoc. The quantities $V$ are variables which are optimized in a run. The efficiency parameters are determined in the calibration. More precisely, 
*'
*' **The calibration adapts the efficiency parameters of the CES function so that precribed target trajectories for all inputs to the CES tree (FE and capital) and output (GDP, named `inco`) are met.**
*'
*' The target trajectories are usually provided by EDGE.
*'
*'The calibration works in several iterations, each consisting of one Remind run. In each iteration, the efficiency parameters are adjusted such that the target trajectories are met *with the prices of the primary production factors (ppf) from the previous iteration*. So the two steps of an iteration loop are: 
*'
*' 1. The calibration routine determines efficiencies
*' 2. The rest of remind determines the ppf prices
*'
*'Each iteration only differs from the others in the prices that are provided to the calibration. They represent the feedback from the energy system module.
*'The assumption is that by adjusting the efficiency parameters in each iteration, the efficiency parameters and prices converge towards a stable coherent value.
*' 
*'#### Steps of the calibration routine
*' 
*'The following paragraphs describe the calculations happening in each of the iteration i.e in `preloop.gms`.
*' 
*'##### 1. Computation of prices
*'
*'In the first iteration, for a new CES structure, there is no gdx file that could provide directly the equilibrium prices of the CES ppf. Therefore, exogenous price trajectories must be provided. Switch `cfg$gms$c_CES_calibration_new_structure` to 1 in `config/default.cfg` in case you want to use exogenous prices for the first iteration.
*'
*'For other iterations, or if the structure is the one from the `input.gdx`, the equilibrium prices will be computed. 
*'They are computed as the derivative **of GDP** in terms of each ppf input: 
*'The prices $\pi_i$ are calculated as in the formula obove. They are derivatives of a node **to the input directly below**.
*'So we apply the chain rule: The derivatives of each level of the CES-tree must be multiplied to obtain the desired derivative of GDP w.r.t. ppf.
*'We do this as a propagation from the top node (`inco`) down the tree, where we iteratively overwrite each `price` (which was previously w.r.t. the node above) with the product of all prices above the node.
*'
*'Afterwards, the prices of the intermediate production factors (`ipf`) are set to one, since they are now already factored in at the ppf level. Setting ipf prices to one means that the prices `pi_i` of `ppf` in terms of their direct output correspond to their price in terms of GDP. (In later steps, efficiencies will be adapted to fit these newly prescribed `ipf` prices.)
*'
*'Prices are then smoothed in the early years of the simulation.
*'
*'##### 2. Calculation of Intermediate Production Factors
*'
*'Ppf quantity target trajectories are given as input to the calibration, but ipf trajectories are not given. 
*'We determine them from the two constraints outlines above, i.e. from the equation 
*'
*'$V_o = \sum_{(o,i)} \pi_i V_i \qquad \forall o \in \text{ipf}$
*'
*'We have prescribed all prices and the quantities at ppf level, so we can move up the CES tree level by level from the ppf to compute quantities for ipf. 
*'We don't do this for the last level `inco`, as it would yield a trajectory for `income` which differs from the one we prescribed. We will deal with that later.
*'
*'##### 3. Changing efficiencies to ensure that the economical constraint holds.
*'
*'We have defined new prices which we precribe. Now we have to ensure that the derivatives of our CES functions are equal to these new prices. 
*'We set the efficiency growth to one to simplify the computation. We will later split this efficiency into a time-constant 2005 efficiency and a time-dependent efficiency growth.
*'The total efficiency is now two-dimensional: The income share $\theta$ and the efficiency parameter $\xi$. The simplified economical constraint now reads
*'
*'$\pi_i = \xi_i \theta_i \ V_o^{1 - \rho_o} \ \left(\theta_i V_i\right)^{\rho_o - 1}$
*'
*'The couple $(\xi_i,\theta_i) = (\frac{\pi V_i}{Vo}, \frac{V_o}{V_i})$, i.e. setting
*'
*'the income share $\xi_i = \frac{\pi_i V_i}{V_o} \qquad \forall (o,i) \in \text{CES}$
*'
*' and
*'
*'the efficiency $\theta_i = \frac{V_o}{V_i} \qquad \forall (o,i) \in \text{CES}$
*'
*'fulfills this constraint. We use it to update the efficiencies of all nodes except for `lab`.
*'
*'##### 4. Last level of the CES-tree: Ensure the GDP and Labour trajectories are met
*'
*'The top level (out: GDP; in: Labour, Aggregated Energy and Capital) is a special case: The quantity trajectory of the output `inco` is prescribed exogenously.
*'The quantity trajectories of capital and labour are also prescribed, as they are ppf.
*'From the last steps, we know the quantity and price of energy, as well as the (equilibrium) price of capital.
*'
*'The labour price will be the adjustment variable. So we don't use the equilibrium price from the last iteration for labour, instead we solve the equation 
*'
*'$V_o = \sum_{i} \pi_i V_i$
*'
*'for the new price of labour. From this, we can compute the efficiencies for labour as in the step above. 
*'(From the information given in this tutorial, switching this step with the previous one would make sense. However, some consistency checks are performed in between, which makes this order necessary)
*'
*'##### 5. Calculate Efficiency growth parameter $\delta$
*'
*'The efficiency growth, which was set to one for simplicity, is now re-introduced:
*'For all inputs but capital, the changes over time of $\xi$ and $\theta$ are put into $\delta$. $\xi$ and $\theta$ are thus made constant at their 2005 levels.
*'The efficiency growth parameter captures both the growth in efficiency and in the income share. So, this is the only time-variant parameter.
*'
*'$\delta_i(t) = \frac{\theta_i(t)}{\theta_i(t_0)} \left(\frac{\xi_i(t)}{\xi_i(t_0)}\right)^{1 / \rho_o} \qquad \forall (o,i) \in \text{CES}$
*'
*'##### Steps: Summary
*'
*' Five steps: 
*'
*' 1. Load prices $\pi_i=\partial V_o / \partial V_i$  and propagate via chain rule to get PPF price in terms of GDP $\partial V_{inco} / \partial V_{ppf}$. Overwrite loaded PPF prices $\pi_{ppf}$ with this chain rule product and set all ipf prices to one. 
*' 2. Using these prices and the prescribed target quantities $V_{ppf}$, move up CES tree level by level and determine IPF target trajectories using $V_o = \sum_{i} \pi_i V_i$. 
*' 3. Determine efficiencies such that CES derivatives using target quantities from step 2 yield prices from step 1: $\xi_i = \frac{\pi_i V_i}{V_o}$ and $\theta_i = \frac{V_o}{V_i}$
*' 4. Since GDP is a prescribed CES output quantity, adjust labour price such that all other (target) quantities and prices in that last CES node match; Now that labour price is known, do Step 3 also for labour. 
*' 5. Move time-dependent part of $\xi$ and $\theta$ to $\delta$.
*'
*'
*'#### Extensions and Special cases
*'
*'##### "Beyond Calib": Calibrating at an intermediary level
*'
*'The CES nest cannot be calibrated on two levels lying one upon the other, as prescribing an additional quantity trajectory would make the equation system over-determined. Recall that we already calibrate to two levels above each other (ppf and inco), but we resolved the over-determined system by introducing the additional degree of freedom of labour price. 
*'
*'Currently, in the industry part of the tree, both the useful energies (UE) and the ppf are calibrated to. This works in the following way:
*'
*'The 'main' calibration described above is only carried out down to the UE level. Everything below is left out at first. The part of the tree below UE is then treated in a separate calibration, which follows after the main one in `preloop.gms` under the label `Beyond Calibration`. The same steps as the one above are carried out for this. For this lower part of the tree, the UE are the topmost nodes and the ppfen and ppfkap are the inputs. Since the labour price is missing as an additional degree of freedom to match the trajectroy of the topmost node, a different approach is taken: All ppf input prices are mutliplied with the same factor (the ratio of prescribed to computed UE quantity), such that the quantity trajectories are met for UE. 
*'
*'##### Putty-Clay
*'
*'Putty-Clay is currently mainly used in the buildings module. 
*'
*'It is possible to introduce segments of the CES tree which are subject to putty-clay dynamics, _i.e._ the model at time `t` will substitute between _increments_ of the variables. The _aggregate_ level of the variable will be the sum of the _increment_ from the CES and the depreciated past _aggregate_ level. This mechanism limits the extent to which the energy demand can be reduced in response to higher energy prices.
*'
*'To treat some CES sections as putty-clay, the set items should be included to `in_putty` and `ppf_putty` for the lowest level of the putty-clay section. In addition, depreciation rates should be defined for the putty variables. For consistency, it is advisable to use identical depreciation rates for inputs and outputs in the same CES function.
*'
*'Currently, the calibration script has not been tested for a putty-clay structure that is in the `beyond_calib` part.
*'
*'The Powerpoint file attached gives some more explanations.
*'
*'##### Perfectly complementary factors
*'
*'To implement perfectly complementary factors, you should include the factors in the set `in_complements`. In addition, the elasticity of substitution between these factors should be set to `INF` (which is counter-intuitive). Prices of complementary inputs are set to 1, so that the output is equal to the sum of inputs (reason why the substitution elasticity should be INF), which makes sense for energetic entities. It would however be possible to change this (by choosing another elasticity of substitution) without harming the calibration.
*'
*'In the model, the complementary factors are subject to a constraint (`q01_prodCompl` or `q01_prodCompl_putty`), so that each variable is computed by multiplying a key variable of the CES function by a given factor. The calibration computes this factor for each period.
*'
*'##### Compute elasticities of substitution
*' 
*' Normally, the elasticities of substitution are prescribed as an ad-hoc guess in the according modules.
*' 
*' However, for some CES nodes (currently only in the `services_with_capital` realization of the buildings module), it is estimated with technological data instead.
*' 
*' To this end, equations are defined in the file `equations.gms`, and a corresponding model minimizing an error is solved in `preloop.gms` to best fit the data. The according section is labeled "compute elasticities of substitution" in the source code.
*' 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/29_CES_parameters/calibrate/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/29_CES_parameters/calibrate/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/29_CES_parameters/calibrate/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/29_CES_parameters/calibrate/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/29_CES_parameters/calibrate/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/29_CES_parameters/calibrate/bounds.gms"
$Ifi "%phase%" == "output" $include "./modules/29_CES_parameters/calibrate/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/29_CES_parameters/calibrate/realization.gms
