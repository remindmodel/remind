
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### changed
- **scripts** do not check anymore that MAgPIE uses renv
  [[1646](https://github.com/remindmodel/remind/pull/1646)]
- **37_industry** remove subsector-specific shares of SE
  origins in FE carriers for performance reasons [[#1659]](https://github.com/remindmodel/remind/pull/1659)
- **37_industry** make process-based steel production model the default over the ces-based model [[#1663]](https://github.com/remindmodel/remind/pull/1663)
- **37_industry** fixed incineration of plastic and non-plastic waste causing
  non-zero emissions for biomass and synfuels
  [[#1682]](https://github.com/remindmodel/remind/pull/1682)
- **core** another change of preference parameters and associated computation of interest rates/mark ups [[#1663]](https://github.com/remindmodel/remind/pull/1663)	
- **scripts** adjust function calls after moving functionality from `remind2` [[#578]]](https://github.com/pik-piam/remind2/pull/578) to `piamPlotComparison` and `piamutils` [[#1661](https://github.com/remindmodel/remind/pull/1661)
- **scripts** enhance output script `reportCEScalib` to include additional plot formats [[#1671](https://github.com/remindmodel/remind/pull/1671)

### added
- **24_trade** add optinal trade scenario for EUR hydrogen and e-liquids imports [[#1666](https://github.com/remindmodel/remind/pull/1666)] 

## [3.3.0] - 2024-03-28

### changed
- **37_industry** changed industry to have subsector-specific shares of SE
  origins in FE carriers [[#1620]](https://github.com/remindmodel/remind/pull/1620)

### added
- **config** regex tests for many parameters [[#1356](https://github.com/remindmodel/remind/pull/1356)]
- **21_tax** add SE tax on electricity going into electrolysis for hydrogen production
- **32_power** extend and reparameterize flexibility tax implementation for electrolysis for hydrogen production
- **37_industry** add feedstocks for chemicals subsector and plastics production
- **37_industry** add process-based steel model as alternative to CES-tree branch
- **47_regipol** add support for delaying quantity targets and improving regional emission tax convergence
- **core** add process emissions from chemicals subsector and from plastics incineration
- **core** change of preference parameters and associated computation of interest rates/mark ups 	
- **scripts** add script to check fixing of runs to reference run
    [[#1410](https://github.com/remindmodel/remind/pull/1410)]
- **scripts** add script for cost decomposition of integrated damage runs
    [[#1445](https://github.com/remindmodel/remind/pull/1445)]
- **scripts** add script to automatically check project summations from piamInterfaces
    [[#1587](https://github.com/remindmodel/remind/pull/1587)]
- **scripts** add MAGICCv7.5.3 with AR6 settings as output script, add compareScenarios2 option
    [[#1475](https://github.com/remindmodel/remind/pull/1475), [[#1615](https://github.com/remindmodel/remind/pull/1615)]
- **scripts** add 'make test-fix' which runs codeCheck in interactive mode, adjusting not_used.txt files
    [[#1625](https://github.com/remindmodel/remind/pull/1625)]
- **testthat** test and compile all config files [[#1356](https://github.com/remindmodel/remind/pull/1356)]
- **testthat** test existence of all required input data [[#1577](https://github.com/remindmodel/remind/pull/1577)]
- **80_optimization** For Nash mode: after infeasibilities continue in debug mode before aborting
    [[#1636](https://github.com/remindmodel/remind/pull/1636)]

### fixed
- **26_agCosts** **30_biomass** fully fix landuse and MAGICC6 variables in delayed transition runs to reference run
    [[#1565](https://github.com/remindmodel/remind/pull/1565)]
- **36_buildings** prevent traditional biomass spillover to other sectors than buildings
    [[#1519](https://github.com/remindmodel/remind/pull/1519)]
- **37_industry** fixed weights of energy carriers in `pm_IndstCO2Captured`
    [[#1354](https://github.com/remindmodel/remind/pull/1354)]
- **core** switch off MAgPIE emission abatement for 45/NPi realization
    [[#1401](https://github.com/remindmodel/remind/pull/1401)]
- **scripts** let preempted and resumed runs start their subsequent runs
    [[#1414](https://github.com/remindmodel/remind/pull/1414)]
- **scripts** '--test' mode for start.R and start_bundle_coupled.R does not write RData files anymore
    [[#1500](https://github.com/remindmodel/remind/pull/1500)]
- **reporting** correctly report `Tech|*|Capital Costs|w/ Adj Costs` for t < cm_startyear
    [[#1429](https://github.com/remindmodel/remind/pull/1429), [#1476](https://github.com/remindmodel/remind/pull/1476)]

### removed
- **35_transport** remove outdated realization: complex 
    [[#1543](https://github.com/remindmodel/remind/pull/1543)]
- **36_buildings** remove outdated realizations: services_putty, services_with_capital 
    [[#1509](https://github.com/remindmodel/remind/pull/1509)]
- **45_carbonprice** remove outdated realizations:
    NDC2constant, NPi2018, diffPhaseIn2Constant, diffPhaseIn2Lin, diffPhaseInLin2LinFlex, diffPriceSameCost
    [[#1480](https://github.com/remindmodel/remind/pull/1480)]

## [3.2.1] - 2023-07-13 (incomplete)

### changed
- **documentation** MAgPIE coupling, DIETER coupling, input changes
- **config** NGFS_v4, SHAPE
- **scripts** re-enable summation checks for IIASA submission
- **inputs** update of landuse emissions and costs using MAgPIE 4.6.8, mrcommons 1.32.0, input data rev6.543
- **scripts** MAgPIE coupling interface: replace old MAgPIE cost variable
- **scripts** MAgPIE coupling interface: remove filtering of negative LU emissions
- **scripts** `./start.R --gamscompile` now adjust sets and gets input data
- **core** MAgPIE coupling: tolerate negative values for `n2ofertsom` and deactivate its MAC
- **05_initialCap** fix overwriting of investment cost changes from cm_inco0Factor switch
- **core** fix bug that emissions from gas use in transport were not accounted

### added
- **45_carbonprice** added realization `NPi` (National Policies Implemented)
- **47_carbonpriceRegi** now supports BECCS quantity targets
- **MAgPIE coupling** added `qos=auto` mode
- **MAgPIE coupling** added renv support mode

### removed
- **scripts** removed .snapshot.Rprofile and snapshot support, renv now fully supersedes snapshots

[Unreleased]: https://github.com/remindmodel/remind/compare/v3.2.1...HEAD
[3.2.1]: https://github.com/remindmodel/remind/compare/v3.2.0...v3.2.1
