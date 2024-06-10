# Taxation mechanism

_Laurin Köhler-Schindler (<laurin.koehler-schindler@pik-potsdam.de>),
25 May 2024_

_Purpose:_ Motivate and explain REMIND's iterative taxation mechanism in a toy model. 

## 1. Toy model: brown and green energy

We consider a simple economy producing output ($Y$) from energy ($E$), i.e.

$$	Y = f(E). $$

There are two energy options available, brown (b) and green (g): 

$$ E = E_b + E_g. $$

The marginal energy costs are given by $\gamma_b(E_b)$ and $\gamma_g(E_g)$, both $\gamma_b$ and $\gamma_g$ being continuous, non-decreasing functions. The total costs are thus given by

$$
	\Gamma_b(E_b) = \int_0^{E_b} \gamma_b(E') dE',
$$

and analogously for $\Gamma_g(E_g)$. For simplicity, we assume that $E$ is fixed, thus also $Y$ is fixed and $E_b$ determines $E_g = E - E_b$. In our simple economy, consumption ($C$) of the representative household is determined as the difference of output and energy costs, i.e.

$$ \tag{1}
 	C = Y - \big(\Gamma_b(E_b) + \Gamma_g(E_g)\big).
$$

Therefore, the consumption maximization problem of the representative household is equivalent to the cost minimization problem

$$
	\min_{E_b, E_g} \Gamma_b(E_b) + \Gamma_g(E_g) \quad \text{subject to}\ E_b + E_g = E, 
$$

or equivalently

$$
 	\min_{E_b} \Gamma_b(E_b) + \Gamma_g(E-E_b).
$$

## 2. Solution without taxation

The first order condition reads

$$
	\gamma_b(E_b) = \gamma_g(E - E_b),
$$

i.e. any interior solution $E^\ast_b$ needs to satisfy that the marginal cost of brown energy $\gamma_b(E^\ast_b)$ equals 
the marginal cost of green energy $\gamma_g(E^\ast_g)$, where $E_g^\ast := E- E_b^\ast$. Assuming $\gamma_b(0) < \gamma_g(E)$ and 
$\gamma_b(E) > \gamma_g(0)$ guarantees that $E^\ast_b$ exists and is indeed optimal.

## 3. Solution with taxation

Brown energy emits CO2 and we are thus introducing a unit tax $\tau>0$ (often called excise) on brown energy. 
The marginal cost of brown energy thereby increases to $\gamma_b(E_b) + \tau$ and the total cost is given by $\Gamma_b(E_b) + \tau \cdot E_b$. 
Our cost minimization problem thus becomes

$$
	\min_{E_b} \Gamma_b(E_b) + \tau \cdot E_b + \Gamma_g(E-E_b),
$$

and the first order condition reads

$$
	\gamma_b(E_b) + \tau = \gamma_g(E - E_b),
$$

i.e. any interior solution $E^\tau_b$ needs to satisfy that the marginal cost of brown energy including taxation equals the marginal cost of green energy. 
Assuming $\gamma_b(0) + \tau < \gamma_g(E)$ and $\gamma_b(E) + \tau > \gamma_g(0)$ guarantees that $E_b^\tau$ exists and is indeed optimal.

Resulting consumption is given by 

$$
C = Y - \big(\Gamma_b(E^\tau_b) + \tau \cdot E_b^\tau + \Gamma_g(E-E^\tau_b)\big),
$$

meaning that the taxation is _not_ budget-neutral as it enters the budget equation of the representative household 
and thereby reduces the remaining output available for consumption.

## 4. Tax revenue recycling

The tax implementation in the previous section assumes that the tax revenue $T = \tau \cdot E_b$ is _not_ recycled, i.e. not fed back into the economy. 
A first approach to recycle the tax revenue  would be to transfer it to the representative household, so that the budget equation would then read

$$
	C = Y   - \big(\Gamma_b(E_b) + \tau \cdot E_b +  \Gamma_g(E_g)\big) + T = Y   - \big(\Gamma_b(E_b) +  \Gamma_g(E_g)\big).
$$

Note that we have recovered Equation (1) and thus the solution to the consumption maximization problem is given by $E^\ast_b$, 
which is the optimal solution _without_ taxation derived in Section 2. Why? The representative household anticipates the recycling of the tax revenue 
and thus incorporates it when solving the consumption maximization problem.

This is a problem as the tax on brown energy looses its steering effect. We thus need to find another way of recycling the tax revenue 
that preserves the desired steering effect. To this end, we will disable the representative household's ability to anticipate the recycling of the tax revenue.

## 5. Solution with budget-neutral taxation

_Idea:_ We let the representative household solve an iterative consumption maximization problem, in which she receives the tax revenue 
from the previous iteration as a transfer and pays taxes according to her choice in the current iteration.

Consumption in iteation $i\ge 1$ is thus given by

$$
	C(i) = Y - \big(\Gamma_b(E_b(i)) + \tau \cdot E_b(i) +  \Gamma_g(E-E_b(i))\big) + T(i-1),
$$

where $T(i):= \tau \cdot E_b(i)$ for $i\ge 1$ and $T(0):=0$ by convention. Setting $\Delta T(i) := T(i) - T(i-1)$, this can be rewritten as 

$$
	 Y = C(i) +  \Delta T(i) +  \big(\Gamma_b(E_b(i)) + \Gamma_g(E-E_b(i))\big).
$$

In each iteration, the representative household maximizes $C(i)$ by choosing $E_b(i)$.

**Claim:** In each iteration, the solution to the consumption maximization problem is given by $E_b^\tau$, 
which is the solution with taxation derived in Section 3, and so the _taxation has the intended steering effect_. Therefore, the iteration converges 
after one step, meaning that for all $i\ge 2$,

$$
	\Delta T(i) = 0, \quad \text{and} \quad C(i) = Y - \big(\Gamma_b(E_b^\tau) + \Gamma_g(E-E_b^\tau)\big),
$$

and so the _taxation is indeed budget-neutral_.

_Intuition:_ Thanks to the iterative problem formulation, the representative household does not anticipate the recycling of the 
tax revenue and therefore the tax has the desired steering effect.

_Proof:_ We now fix any $i\ge 1$ and solve the consumption maximization problem in iteration $i$. We need to choose $E_b(i)$ in order to maximize 

$$
	C(i) = Y - \big(\Gamma_b(E_b(i)) + \tau \cdot E_b(i) + \Gamma_g(E-E_b(i))\big) + T(i-1).
$$

However, $T(i-1)$ does _not_ depend on $E_b(i)$ and the problem reduces to choosing $E_b(i)$ in order to maximize 

$$
	C(i) = Y - \big(\Gamma_b(E_b(i)) + \tau \cdot E_b(i) + \Gamma_g(E-E_b(i))\big),
$$

which is equivalent to the cost minimization problem from Section 3. Thus, the solution is given by $E_b^\tau$. 
The convergence after one step readily follows.
