*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
*' Efficiency parameters have a strong influence on the level of energy that the CES-tree demands from the energy system module.
*' In order to avoid ad hoc assumptions on the level of these parameters, the new macro-calibration procedure loads exogenous
*' energy demand pathways and ensures that a baseline REMIND run will meet these trajectories.
*'
*' #### How to calibrate Remind
*'
*' This documentation is focused on the implementation. For a practical guide on how to calibrate, refer to the tutorial
*' 'Calibrating CES Parameters' in the `tutorials` folder.
*'
*' #### How the calibration works (Overview)
*'
*' ##### 1. Prerequisites
*'
*' The CES tree in Remind consists of a tree of nested CES production functions of the form
*'
*' $V_o = \left( \sum_{i} \xi_i \left( \theta_i \delta_i V_i \right)^{\rho_o} \right)^{1/\rho_o}$
*'
*' where $V_o$ is the output quantity (`quantity` in the code) with the output node index $o$,
*' $V_i$ are the input quantities with the input node index $i$,
*' $\xi_i$ is the income share (`xi`), $\theta_i$ the efficiency parameter (`eff`),
*' $\delta_i$ is the efficiency growth (`effGr`),
*' and $\rho_o$ (`rho`) is a parameter derived from the substitution elasticity.
*'
*' 'Nested' means that each output of one CES node serves as one of the inputs to the node above, up to the last level.
*' The uppermost level of the tree is GDP (`inco`), the lowest ones (the 'leaves' of the tree) are called primary production
*' factors (`ppf`). They include final energies (`ppfen`), different capital stocks, and labour (`lab`), which is a direct
*' input to `inco`. Consequently, ppf only serve as input to a CES function and there are no CES functions in the tree with
*' ppf as their output. Nodes which are neither ppf nor the top node are called intermdiate production factors (`ipf`).
*'
*' In the following, the term 'efficiency parameters' will be used collectively for the parameters $\xi_i$, $\theta_i$
*' and $\delta_i$ (income share, efficiency and efficiency growth). By combining all three into
*' $\alpha_i = \xi_i \left( \theta_i \delta_i )^{\rho_o}$, the CES function could be simplified to
*'
*' $V_o = \left( \sum_{i} \alpha_i V_{i}^{\rho_o} \right)^{1/\rho_o}.$
*'
*' However, we keep the split into the three components for the following reasons:
*'
*' - We split the efficiency parameter in a time-constant $\xi_i, \thata_i$ and a time-variant $\delta_i(t)$ component to
*'   allow the latter to be controlled endogenously by the model (in module 20_growth/spillover).
*' - The split of the time-constant part into the two components $\xi_i$ and $\theta_i$ is (1) for historic reasons
*'   and (2) allows for easier testing the resulting parameter trajectories in an economic context by checking $\xi_i$
*'   against certain bounds.
*'
*' The derivative of the CES function with respect to one of its input quanities $V_i$  can be calculated as
*'
*' $\frac{\partial V_o(V_1,..., V_i,...,V_n)}{\partial V_i}$
*' $= \xi_i \theta_i \delta_i \ V_o^{1 - \rho_o} \ \left(\theta_i \delta_i V_i\right)^{\rho_o - 1}.$
*'
*' The CES function is a homogenous function of degree one. This entails (following Euler's homogeneous function theorem)
*' that the output is equal to the sum of derivative times quantity of each input
*'
*' $V_o = \sum_{i} \frac{\partial V_o}{\partial V_i} V_i$
*'
*' This motivates to interpret the derivative of $\frac{\partial V_o}{\partial V_i} =: \pi_i$ as the price of $V_i$ in terms
*' of $V_o$. We denote it by $\pi_i$. The output is then equal to the sum of inputs valued at their price, i.e.
*'
*' $V_o = \sum_{i} \pi_i V_i.$
*'
*' ##### 2. Principle
*'
*' In Remind, the elasticities of substitution and thus $\rho$ are prescribed ad-hoc. The quantities $V$ are variables
*' which are optimized in a run (except for labour). The efficiency parameters are determined in the calibration. More
*' precisely,
*'
*' **The calibration adapts the efficiency parameters of the CES function so that precribed target trajectories for all
*'   inputs to the CES tree (FE and capital) and output (GDP, named `inco`) are met.**
*'
*' The target trajectories are usually provided by EDGE models for the different sectors.
*'
*' The calibration works in several iterations, each consisting of one Remind run. In each iteration, the efficiency
*' parameters are adjusted such that the target trajectories are met *with the prices of the primary production factors
*' (ppf) from the previous iteration*. So the two steps of an iteration loop are:
*'
*' 1. The calibration routine determines efficiencies (based on prices of previous iteration)
*' 2. The rest of the remind model run determines optimal ppf prices (given the efficiencies from 1.)
*'
*' Each iteration only differs from the others in the prices that are provided to the calibration. They represent the
*' feedback from the energy system module.
*' The assumption is that by adjusting the efficiency parameters in each iteration, the efficiency parameters and
*' prices converge towards a stable coherent value.
*'
*' #### Steps of the calibration routine
*'
*' The following paragraphs describe the calculations happening in each of the iteration i.e in `preloop.gms`.
*' They can be summarized in five steps:
*'
*' 1. Load CES quantities, calculate prices $\pi_i=\partial V_o / \partial V_i$ from them and propagate via chain rule
*' to get ppf price in terms of GDP $\partial V_{inco} / \partial V_{ppf}$. Set ppf prices $\pi_{ppf}$ to this chain rule
*' product and set all ipf prices to one.
*' 2. Using these prices and the prescribed target quantities $V_{ppf}$, move up CES tree level by level and determine
*' ipf trajectories using $V_o = \sum_{i} \pi_i V_i$.
*' 3. Determine efficiencies such that CES derivatives using target quantities from step 2 yield prices from step 1:
*' $\xi_i = \frac{\pi_i V_i}{V_o}$ and $\theta_i = \frac{V_o}{V_i}$
*' 4. Since GDP is a prescribed CES output quantity, adjust labour price such that all other (target) quantities and
*' prices in that last CES node match; Now that labour price is known, do Step 3 also for labour.
*' 5. Move time-dependent part of $\xi$ and $\theta$ to $\delta$.
*'
*' These steps are now described in more detail.
*'
*' ##### 1. Computation of prices
*'
*' Ppf prices are computed from CES node quantities which are read in from the previous iteration from an `input.gdx` file. In
*' the first iteration, there is no previous iteration, but a file from a previous different run can be used instead, provided
*' that the structure of the CES tree is the same, such that all needed quantities were computed in that previous run.
*'
*' In the first iteration, for a **new** CES tree structure, there is no gdx file from a previous run that could provide
*' directly the CES node quantities needed for calculation of prices. Therefore, exogenous prices must be provided.
*' Switch `cfg$gms$c_CES_calibration_new_structure` to 1 in `config/default.cfg` in case you want to use exogenous prices
*' for the first iteration (If you have a new structure and do not set this switch to 1, you will get an error, as not all
*' necessary prices are found).
*'
*' For other iterations, or if the structure is the one from the `input.gdx`, the equilibrium prices will be computed.
*' They are computed as the derivative *of GDP* in terms of each ppf input:
*' The prices $\pi_i$ are calculated as in the formula obove. They are derivatives of a node with respect to *its direct
*' input nodes* in the level below $\partial V_o / \partial V_i$.
*' What we want, however, is the derivative of GDP (the topmost node) with respect to the ppf (the nodes at the very bottom).
*' So we apply the chain rule: The derivatives of each level of the CES-tree must be multiplied to obtain the desired
*' derivative of GDP w.r.t. ppf.
*' As an example, if one branch of the CES tree is `inco` - `en` - `industry` - `cement` - `eekcement`, then the price
*' of `eekcement` is calculated as
*'
*' $\frac{\partial V_{inco}}{\partial V_{eekcement}}
*'  = \frac{\partial V_{inco}}{\partial V_{en}} \frac{\partial V_{en}}{\partial V_{industry}}
*'    \frac{\partial V_{industry}}{\partial V_{cement}} \frac{\partial V_{cement}}{\partial V_{eekcement}}
*'  = \pi_{en} \pi_{industry} \pi_{cement} \pi_{eekcement}$
*'
*' We do this as a propagation from the top node (`inco`) down the whole tree, where we iteratively calculate each
*' derivative of `inco` as the product of all derivatives above the node, so e.g. we first compute
*' $\frac{\partial V_{inco}}{\partial V_{industry}} = \frac{\partial V_{inco}}{\partial V_{en}}
*'  \frac{\partial V_{en}}{\partial V_{industry}}$
*' and then, using that value, we calculate
*' $\frac{\partial V_{inco}}{\partial V_{cement}} = \frac{\partial V_{inco}}{\partial V_{industry}}
*'  \frac{\partial V_{industry}}{\partial V_{cement}}$,
*' and so on, until we obtain ppf prices on the last level in terms of GDP.
*'
*' Afterwards, the prices of the intermediate production factors (`ipf`) are set to one, since they are now already
*' factored in at the ppf level. Setting ipf prices to one means that the prices $pi_i$ of `ppf` in terms of their
*' direct output correspond to their price in terms of GDP. (In later steps, efficiencies will be adapted to fit
*' these newly prescribed prices.)
*'
*' In a subsequent step, prices are then smoothed in the early years of the model.
*'
*' ##### 2. Calculation of Intermediate Production Factors
*'
*' Ppf quantity target trajectories are given as input to the calibration, but ipf trajectories are not given.
*' We determine them from the equation
*'
*' $V_o = \sum_{i} \pi_i V_i \qquad \forall o \in \text{ipf}$
*'
*' which was derived above. We have calculated all prices and the quantities at ppf level, so we can move up the CES
*' tree level by level from the ppf to compute quantities for ipf.
*' We don't do this for the last level `inco`, as it would yield a trajectory for `income` which differs from the one
*' we prescribed. We will deal with that later.
*'
*' ##### 3. Changing efficiencies to ensure prices are met
*'
*' We have computed prices in step 1 which we precribe. Now we have to ensure that the derivatives of our CES functions
*' are equal to these new prices.
*' We do this by adjusting the efficiencies.
*' We set the efficiency growth to one to simplify the computation. (We will later split this efficiency into a
*' time-constant 2005 efficiency and a time-dependent efficiency growth.)
*' The total efficiency now consists of the two parameters income share $\xi_i$ and efficiency parameter $\theta_i$.
*' Inserting this simplification $\detla_i=1$ into the CES derivative yields
*'
*' $\pi_i = \xi_i \theta_i \ V_o^{1 - \rho_o} \ \left(\theta_i V_i\right)^{\rho_o - 1}$
*'
*' which we can transform to
*'
*' $\xi_i \theta_i^{\rho_o} = \pi_i \frac{V_i}{V_o} \left(\frac{V_o}{V_i}\right)^{\rho_o}$
*'
*' As stated above, the split of the total efficiency into $\xi_i$ and $\theta_i$ is not needed for mathematical
*' reasons. Here, this means that we have to degrees of freedom to fulfill one equation, the system is underdetermined
*' and we have different combinations of $\xi_i$ and $\theta_i$ that fulfill it.
*' We choose
*'
*' - $\xi_i = \frac{\pi_i V_i}{V_o}$
*'   (income share, i.e. share of the value (quantity $\times$ price) of input $i$ ind output $o$) and
*' - $\theta_i = \frac{V_o}{V_i}$ (efficiency, i.e. output $o$ per unit $i$).
*'
*' We use these values to update the efficiencies $\xi_i$ and $\theta_i$ of all nodes except for `lab`.
*'
*' ##### 4. Last level of the CES-tree: Ensure the GDP and Labour trajectories are met
*'
*' The top level (out: GDP; in: Labour, Aggregated Energy and Capital) is a special case: The quantity trajectory of the
*' output `inco` is prescribed exogenously.
*' The quantity trajectories of capital and labour are also prescribed, as they are ppf.
*' From the last steps, we know the quantity and price of energy, as well as the (equilibrium) price of capital.
*'
*' The labour price will be the adjustment variable. So we don't use the equilibrium price from the last iteration for
*' labour, instead we solve the equation
*'
*' $V_o = \sum_{i} \pi_i V_i$
*'
*' for the new price of labour. From this, we can compute the efficiencies for labour as in the step above.
*' (From the information given in this tutorial, switching this step with the previous one would make sense. However, some
*' consistency checks are performed in between, which makes this order necessary.)
*'
*' ##### 5. Calculate Efficiency growth parameter $\delta$
*'
*' The efficiency growth, which was set to one for simplicity, is now re-introduced:
*' For all inputs but capital, the changes over time of $\xi$ and $\theta$ are put into $\delta$. $\xi$ and $\theta$ are
*' thus made constant at their 2005 levels.
*' The efficiency growth parameter captures both the growth in efficiency and in the income share. So, this is the only
*' time-variant parameter.
*'
*' $\delta_i(t) = \frac{\theta_i(t)}{\theta_i(t_0)} \left(\frac{\xi_i(t)}{\xi_i(t_0)}\right)^{1 / \rho_o}$
*'
*' on all CES nodes.
*'
*' #### Extensions and Special cases
*'
*' ##### "Beyond Calib": Calibrating at an intermediary level
*'
*' The CES nest cannot be calibrated on two levels lying one upon the other, as prescribing an additional quantity
*' trajectory would make the equation system over-determined. Recall that we already calibrate to two levels above
*' each other (ppf and inco), but we resolved the over-determined system by introducing the additional degree of
*' freedom of labour price.
*'
*' Currently, in the industry part of the tree, both the subsector outputs (members of
*' `industry_ue_calibration_target_dyn37`)
*' and the ppf are calibrated to. This works in the following way (this documentation is
*' only for the case `c_CES_calibration_industry_FE_target == 1`):
*'
*' The 'main' calibration described above is only carried out down to the UE level. Everything below is left out at
*' first. The part of the tree below UE is then treated in a separate calibration, which follows after the main one
*' in `preloop.gms` under the label `Beyond Calibration`. The same steps as the one above are carried out for this.
*' For this lower part of the tree, the UE are the topmost nodes and the ppfen and ppfkap are the inputs. Since the
*' labour price is missing as an additional degree of freedom to match the trajectroy of the topmost node, a different
*' approach is taken: All ppfen (not ppfkap) input prices are mutliplied with the same factor (the ratio of prescribed
*' to computed UE quantity, minus the ppfkap share), such that the quantity trajectories are met for UE.
*'
*' ##### Putty-Clay
*'
*' Putty-Clay is currently mainly used in the buildings module.
*'
*' It is possible to introduce segments of the CES tree which are subject to putty-clay dynamics, _i.e._ the model at
*' time `t` will substitute between _increments_ of the variables. The _aggregate_ level of the variable will be the
*' sum of the _increment_ from the CES and the depreciated past _aggregate_ level. This mechanism limits the extent
*' to which the energy demand can be reduced in response to higher energy prices.
*'
*' To treat some CES sections as putty-clay, the set items should be included to `in_putty` and `ppf_putty` for the lowest
*' level of the putty-clay section. In addition, depreciation rates should be defined for the putty variables. For
*' consistency, it is advisable to use identical depreciation rates for inputs and outputs in the same CES function.
*'
*' Currently, the calibration script has not been tested for a putty-clay structure that is in the `beyond_calib` part.
*'
*' The Powerpoint file attached gives some more explanations.
*'
*' ##### Perfectly complementary factors
*'
*' To implement perfectly complementary factors, you should include the factors in the set `in_complements`. In addition,
*' the elasticity of substitution between these factors should be set to `INF` (which is counter-intuitive). Prices of
*' complementary inputs are set to 1, so that the output is equal to the sum of inputs (reason why the substitution
*' elasticity should be INF), which makes sense for energetic entities. It would however be possible to change this
*' (by choosing another elasticity of substitution) without harming the calibration.
*'
*' In the model, the complementary factors are subject to a constraint (`q01_prodCompl` or `q01_prodCompl_putty`), so that
*' each variable is computed by multiplying a key variable of the CES function by a given factor. The calibration computes
*' this factor for each period.
*'
*' ##### Compute elasticities of substitution
*'
*' Normally, the elasticities of substitution are prescribed as an ad-hoc guess in the according modules.
*'
*' However, for some CES nodes (currently only in the `services_with_capital` realization of the buildings module), it is
*' estimated with technological data instead.
*'
*' To this end, equations are defined in the file `equations.gms`, and a corresponding model minimizing an error is solved
*' in `preloop.gms` to best fit the data. The according section is labeled "compute elasticities of substitution" in the
*' source code.
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
