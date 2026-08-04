*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/sets.gms

SETS
target_type_47 "CO2 policy target type" / budget , year /

emi_type_47 "emission type used in regional target" 
/ 
  netCO2, netCO2_noBunkers, netCO2_noLULUCF_noBunkers, netCO2_LULUCFGrassi, netCO2_LULUCFGrassi_noBunkers, netCO2_LULUCFGrassi_intraRegBunker,
  netGHG, netGHG_noBunkers, netGHG_noLULUCF_noBunkers, netGHG_LULUCFGrassi, netGHG_LULUCFGrassi_noBunkers, netGHG_LULUCFGrassi_intraRegBunker, netGHG_noLULUCF,
  grossEnCO2_noBunkers 
/

*** Emission markets
$ifThen.emiMkt not "%cm_emiMktTarget%" == "off" 
  regiEmiMktTarget(ext_regi)                   "regions with emiMkt targets" / /
  regiANDperiodEmiMktTarget_47(ttot,ext_regi)  "regions and periods with emiMkt targets" / /
  regiEmiMktTarget2regi_47(ext_regi,all_regi)  "regions controlled by emiMkt market set to ext_regi" / / 
  rescaleType                                  "emi mkt carbon price scaling factor calculation methods" /
    squareDev_firstIteration, squareDev_lowPriceSpread, squareDev_unstableFit, squareDev_degenerateSlope, slope /
  regiEmiMktRescaleType(iteration,ttot,ttot,ext_regi,emiMktExt,rescaleType) "saving scaling type used in iteration" / /
  convergenceType                              "emiMkt target convergence reason" / 
    lowerThanTolerance, smallPrice, bestAchievable, unmetAtCap, unmetFrozen /
  regiEmiMktconvergenceType(iteration,ttot,ttot,ext_regi,emiMktExt,convergenceType) "saving convergence type in iteration" / /
  slopeTerm                                    "scratch accumulators and results of the convergence algorithm: least-squares slope terms plus the per-branch window counters" /
    n, sumP, sumE, sumP2, sumE2, sumPE, pMin, pMax, denom, num, varE, slope, r2, inBand, priceOk, devMax, devMin, settled, nWin, outBand, nSteer, skipSteer, cntSteer, atCap, emiMin, kneeIter, devAbsMax, devAbsMin, bestWinIter, nFlip,
    isFallback, recentStep, nStep, stepBound, rollIter, wantRoll, prevTgtYr, holdOk, divOut, divMax, divBest, divRoll /
  slopeParam                                   "configuration constants of the convergence algorithm, documented in tutorials/19_RegionalEmissionTargets.md section 10" /
*** slope fit and step size
    maxWindow             "rolling window length, counted in iterations this target actually STEERED [#]"
    minPriceSpread        "minimum price spread across the window (fraction of current price) to trust the slope [fraction]"
    minR2                 "minimum R-squared of the fit to use it for a Newton step [fraction]"
    maxSteep              "cap on the absolute slope magnitude [#]"
    degenerateThreshold   "minimum fitted emission change over window as fraction of BOTH 2005 emissions and remaining gap [fraction]"
    rescaleCapLo          "trust region, lower bound [#]"
    rescaleCapHi          "trust region, upper bound (2 = price may at most double per iteration) [#]"
*** convergence bands
    enterFrac             "AIM band: converge at |dev| <= enterFrac * tolerance (deliberately INSIDE tolerance) [fraction]"
    aimMaxTries           "attempts at AIM band before ACCEPTing anywhere inside tolerance [#]"
    exitFrac              "EXIT band: hold converged target until |dev| exceeds exitFrac * tolerance (hysteresis) [fraction]"
    persist               "consecutive iterations required for any state change (1 disables persistence) [#]"
    priceEps              "optional price-settled gate for entering: max |dprice|/price (0 = off) [fraction]"
*** deviation normalisation and price ceiling
    budgetDenomFloorFrac  "floors budget deviation denominator at this * CUMULATIVE 2005-rate reference budget [fraction]"
    maxPrice              "absolute carbon-price ceiling [US$2005/tCO2] (0 = off) [US$2005/tCO2]"
*** give-up stops
    noiseFloorMaxDev      "noise-floor stop only fires within this |dev| (0 disables tier-3 stops) [fraction]"
    noiseFloorBandWidth   "absolute floor for narrow-band width [fraction]"
    noiseFloorBandWidthRel "tolerance-relative band width; effective width is max(absolute, rel * tolerance) [#]"
    noiseFloorRollback    "freeze at WINDOW-LOCAL BEST rather than firing iteration (< 0.5 = off) [0 or 1]"
    parkedStop            "give up on target held converged by hysteresis outside tolerance but inside exit band (< 0.5 = off) [0 or 1]"
    infeasEmiTol          "knee tolerance for infeasible stop rollback: lowest price with equivalent emissions (0 = off) [fraction]"
    infeasStallFrac       "infeasible and divergence stops require |dev| now >= this * max |dev| over window (stalled) [fraction]"
    divergeFactor         "divergence threshold multiplier on max(best |dev| ever reached, tolerance) (< 1 disables) [#]"
    divergeMinBest        "ARMING band multiplier on tolerance: divergence test only live once reached while steering (< 1e-3 disables) [#]"
    divergeBrakeMax       "reversible brakes allowed before divergence stop freezes (< 1 = freeze on first detection) [#]"
*** re-open parameters
    reopenMaxDev          "charge re-open only while |dev| <= this; further out is uncharged release (0 disables re-opening) [fraction]"
    reopenMax             "charged re-opens per target over whole run [count]"
    reopenStepCap         "cap on FIRST step after re-open (0 = off) [fraction]"
    reopenRefresh         "consecutive iterations FROZEN AND MET AND not given up that earn budget back (< 1 = off) [#]"
*** step bound for squareDev fallbacks
    fallbackStepFactor    "fallback step bound as multiple of MEAN |rescale-1| over window (0 = off) [#]"
    fallbackStepFloor     "minimum fallback step bound (+-this) [#]"
*** price rollback on freeze
    rollbackBestFrac      "prefer best-so-far price over stop candidate when at least this factor better (0 = off) [fraction]"
    rollbackMaxAge        "best-so-far candidate must lie within this many iterations (0 = no age limit) [#]"
    rollbackVerify        "undo rollback if next iteration is worse, then lock out future rollbacks (0 = off) [0 or 1]"
*** progressive oscillation dampening
    dampFlipMin           "reversals within window before dampening starts [#]"
    dampProgFactor        "step multiplier per extra reversal: dampProgFactor^(nFlip - dampFlipMin + 1) [fraction]"
    dampFloor             "lower bound on dampening multiplier [fraction]"
  /
  slopeTrace                                   "per-iteration diagnostics of the convergence algorithm, saved for debugging" /
    rawSlope, fitR2, preDamp, rollIter, rollUndo, divBrake, parked /
  targetState                                  "persistent per-target state of the convergence state machine, documented in tutorials/19_RegionalEmissionTargets.md section 11" /
*** budgets and counters
    reopenCount    "charged re-opens of this market target; run-wide budget (reopenMax), cleared only by reopenRefresh consecutive settled iterations [count]"
    settledCount   "consecutive iterations frozen AND met AND not given up; at reopenRefresh the re-open budget is earned back, any other state resets it [count]"
    refreshCount   "times this market target actually got a SPENT re-open budget back; a refresh with the budget already at 0 is not counted. Diagnostic only [count]"
    releaseCount   "times this market target was UN-FROZEN without a re-open being charged (|dev| beyond reopenMaxDev). Diagnostic only [count]"
    divBrakeCount  "divergence brakes taken on this market target; run-wide budget (divergeBrakeMax), after which the stop freezes instead [count]"
    aimTries       "attempts spent trying to close the gap between the raw tolerance and the tighter AIM band (enterFrac) [count]"
*** flags
    giveUp         "1 once a GIVE-UP branch (noise floor, infeasible target, divergence stop, parked stop, re-open budget spent) deliberately froze this market target [0 or 1]"
    divArmed       "1 once this market target reached |dev| <= divergeMinBest * tolerance while steering its own price; the divergence stop fires only on an armed target [0 or 1]"
    rolledBack     "rollback state of this market target: 0 = none yet, 1 = rolled back once, 2 = rolled back and UNDONE (never roll again) [0, 1 or 2]"
*** iteration marks
    reopenIter     "iteration in which this market target was last re-opened or braked; that iteration's step is capped at reopenStepCap [#]"
    bestDevIter    "iteration that produced bestDevAbs; candidate for the freeze rollback, subject to rollbackMaxAge (0 = none yet) [#]"
    rollFromIter   "iteration at which the price was rolled back; its stored price path is the pre-rollback state the undo restores (0 = none) [#]"
*** remembered values
    bestDevAbs     "smallest |target deviation| this market target has reached so far in the run [fraction]"
    rollFromDev    "|target deviation| at the iteration the rollback fired; the rollback is undone if the next iteration is worse than this [fraction]"
  /
$ENDIF.emiMkt

*** Implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS and/or OAE
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"

taxType "PE, SE or FE tax type"
/
  tax
  sub
/

targetType "PE, SE or FE target type"
/
  t  "absolute target (t=total)"
  s  "relative target (s=share)"
/

qttyTarget "quantity target for energy carrier level (primary, secondary, final energy) or CCS or OAE"
/
  PE              "Primary Energy"
  SE              "Secondary Energy"
  FE              "Final Energy"
  FE_indst        "Final Energy industry"
  FE_build        "Final Energy buildings"
  FE_trans        "Final Energy transport"
  FE_wo_b         "Final Energy without bunkers"
  FE_wo_n_e       "Final Energy without non-energy"
  FE_wo_b_wo_n_e  "Final Energy without bunkers and non-energy"
  CCS             "carbon capture and storage"
  oae             "ocean alkalinity enhancement"
/

qttyTargetGroup "quantity target aggregated categories"
/
  all
  biomass
  fossil
  VRE
  wind
  solar
  renewables
  renewablesNoBio
  synthetic
  hydrogen
  electricity
  heat
/

energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,all_enty) "set combining possible energy level (PE, SE or FE), energy types and energy carriers"
/
*** Primary energy type categories
***  PE.all.(entyPe) !! defined below as calculated set
  PE.biomass.(pebiolc,pebios,pebioil)
  PE.fossil.(peoil,pegas,pecoal)
  PE.VRE.(pewin,pesol)
  PE.wind.pewin
  PE.solar.pesol
  PE.renewables.(pegeo,pehyd,pewin,pesol,pebiolc,pebios,pebioil)
  PE.renewablesNoBio.(pegeo,pehyd,pewin,pesol)  
*** Secondary energy type categories
***  SE.all.(entySe) !! defined below as calculated set
  SE.biomass.(seliqbio,sesobio,segabio)
  SE.fossil.(seliqfos,sesofos,segafos)
  SE.synthetic.(seliqsyn,segasyn)
  SE.hydrogen.(seh2)
  SE.electricity.(seel)
  SE.heat.(sehe)
*** Final energy type categories
***  FE.all.(entySe) !! defined below as calculated set
  FE.biomass.(seliqbio,sesobio,segabio)
  FE.fossil.(seliqfos,sesofos,segafos)
  FE.synthetic.(seliqsyn,segasyn)
  FE.hydrogen.(seh2)
  FE.electricity.(seel)
  FE.heat.(sehe)
*** Total final energy per sector and final energy type
  FE_indst.all.(fegas,fehos,fesos,feels,fehes,feh2s)
  FE_build.all.(fegas,fehos,fesos,feels,fehes,feh2s)
  FE_trans.all.(fepet,fedie,feh2t,feelt,fegat)
/

qttyDelayType_47 "options to define different delay rules for starting the quantity targets algorithm"
/
  iteration    "quantity targets are only active after certain iteration"
  emiConv      "quantity targets are only active after emission targets defined at the carbon price modules and at the regipol modules converged"
  emiRegiConv  "quantity targets are only active after regional emission targets achieved given deviation levels"
/

$ifThen.cm_implicitQttyTargetType "%cm_implicitQttyTargetType%" == "scenario"
qttyTargetScenario  "hard-coded quantity scenarios"
/
  EU27_eedEff  "2018 energy efficiency directive    (846 Mtoe final energy by 2030)"
  EU27_ff55Eff "Fit for 55 energy efficiency target (787 Mtoe final energy by 2030)"
  EU27_RpEUEff "RePowerEU energy efficiency target  (750 Mtoe final energy by 2030)"

  EU27_bio4    "EU-27 primary energy biomass limited to 6 EJ by 2035 and 4 EJ by 2050"
  EU27_bio7    "EU-27 primary energy biomass limited to 7 EJ by 2035 and 2050"
  EU27_bio7p5  "EU-27 primary energy biomass limited to 7.5 EJ by 2035 and 2050"
  EU27_bio12   "EU-27 primary energy biomass limited to 12 EJ by 2035 and 2050"
  GLO_bio100   "Global primary energy biomass limited to 100EJ by 2035 and 2050"

  EU27_limVRE  "wind and solar limited to linear extrapolation of 2021-2022 growth of generation capacity by 2025 and 2050"

  EU28_CCS250Mt "EU27 and UK max CCS (including DACCS and BECCS) limited to 250 Mt CO2/yr."
  GLO_CCS2Gt   "Global max CCS (including DACCS and BECCS) limited to 2 Gt CO2/yr."
/
qttyTargetActiveScenario(qttyTargetScenario) "current run active quantity scenarios" / %cm_implicitQttyTarget% / 
$endif.cm_implicitQttyTargetType

$endIf.cm_implicitQttyTarget

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
fePriceScenario "scenarios for exogenous FE price targets"
/
  elecPrice
  H2Price
  initial
  highPrice
  lowPrice
  highElec
  lowElec
  highGasandLiq
/
$endIf.cm_implicitPriceTarget

$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
pePriceScenario "scenarios for exogenous PE price targets"
/
  highFossilPrice
/
$endIf.cm_implicitPePriceTarget

$ifthen.exogDemScen NOT "%cm_exogDem_scen%" == "off"
exogDemScen       "exogenuous FE and ES demand scenarios that can be activated by cm_exogDem_scen"
/
        ariadne_bal
        ariadne_ensec
        ariadne_highDem
        ariadne_lowDem
/
$endif.exogDemScen

;

*** Defining extra energyQttyTargetANDGroup2enty set elements
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
  loop(entyPe,
    energyQttyTargetANDGroup2enty("PE","all",entyPe) = YES;
  );
  loop(entySe,
    energyQttyTargetANDGroup2enty("SE","all",entySe) = YES;
  );
  loop(entyFe,
    energyQttyTargetANDGroup2enty("FE","all",entySe) = YES;
  );
$endIf.cm_implicitQttyTarget

*** EOF ./modules/47_regipol/regiCarbonPrice/sets.gms

