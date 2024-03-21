
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Unreleased]

### added
- **config** regex tests for many parameters [[#1356](https://github.com/remindmodel/remind/pull/1356)]
- **scripts** add script to check fixing of runs to reference run
    [[#1410](https://github.com/remindmodel/remind/pull/1410)]
- **scripts** add script for cost decomposition of integrated damage runs
    [[#1445](https://github.com/remindmodel/remind/pull/1445)]
- **testthat** test and compile all config files [[#1356](https://github.com/remindmodel/remind/pull/1356)]
- **testthat** test existence of all required input data [[#1577](https://github.com/remindmodel/remind/pull/1577)]
- **37_industry** add feedstocks for chemicals subsector and plastics production
- **core** add process emissions from chemicals subsector and from plastics incineration
- **37_industry** add process-based steel model as alternative to CES-tree branch
- **47_regipol** add support for delaying quantity targets and improving regional emission tax convergence
- **core** change of preference parameters and associated computation of interest rates/mark ups 	
- **scripts** add script to automatically check project summations from piamInterfaces
    [[#1587](https://github.com/remindmodel/remind/pull/1587)]
- **32_power** extend and reparameterize flexibility tax implementation for electrolysis for hydrogen production
- **21_tax** add SE tax on electricity going into electrolysis for hydrogen production
- **scripts** add MAGICCv7.5.3 with AR6 settings as output script, add compareScenarios2 option
    [[#1475](https://github.com/remindmodel/remind/pull/1475), [[#1615](https://github.com/remindmodel/remind/pull/1615)]
- **scripts** add 'make test-fix' which runs codeCheck in interactive mode, adjusting not_used.txt files
    [[#1625](https://github.com/remindmodel/remind/pull/1625)

### fixed
- fixed weights of energy carriers in `pm_IndstCO2Captured`
    [[#1354](https://github.com/remindmodel/remind/pull/1354)]
- switch off MAgPIE emission abatement for 45/NPi realization
    [[#1401](https://github.com/remindmodel/remind/pull/1401)]
- let preempted and resumed runs start their subsequent runs
    [[#1414](https://github.com/remindmodel/remind/pull/1414)]
- correctly report `Tech|*|Capital Costs|w/ Adj Costs` for t < cm_startyear
    [[#1429](https://github.com/remindmodel/remind/pull/1429), [#1476](https://github.com/remindmodel/remind/pull/1476)]
- **scripts** '--test' mode for start.R and start_bundle_coupled.R does not write RData files anymore
    [[#1500](https://github.com/remindmodel/remind/pull/1500)]
- prevent traditional biomass spillover to other sectors than buildings
    [[#1519](https://github.com/remindmodel/remind/pull/1519)]
- fully fix landuse and MAGICC6 variables in delayed transition runs to reference run
    [[#1565](https://github.com/remindmodel/remind/pull/1565)]

### removed
- **45_carbonprice** remove outdated realizations:
    NDC2constant, NPi2018, diffPhaseIn2Constant, diffPhaseIn2Lin, diffPhaseInLin2LinFlex, diffPriceSameCost
    [[#1480](https://github.com/remindmodel/remind/pull/1480)]
- **36_buildings** remove outdated realizations: services_putty, services_with_capital 
    [[#1509](https://github.com/remindmodel/remind/pull/1509)]
- **35_transport** remove outdated realization: complex 
    [[#1543](https://github.com/remindmodel/remind/pull/1543)]

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
