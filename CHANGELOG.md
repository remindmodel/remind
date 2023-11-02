
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Unreleased]

### added
- **config** regex tests for many parameters
- **scripts** add script to check fixing of runs to reference run
    [[#1410](https://github.com/remindmodel/remind/pull/1410)]
- **scripts** add script for cost decomposition of integrated damage runs
    [[#1445](https://github.com/remindmodel/remind/pull/1445)]
- **testthat** test and compile all config files

### fixed
- fixed weights of energy carriers in `pm_IndstCO2Captured`
    [[#1354](https://github.com/remindmodel/remind/pull/1354)]
- switch off MAgPIE emission abatement for 45/NPi realization
    [[#1401](https://github.com/remindmodel/remind/pull/1401)]
- let preempted and resumed runs start their subsequent runs
    [[#1414](https://github.com/remindmodel/remind/pull/1414)]
- correctly report `Tech|*|Capital Costs|w/ Adj Costs` for t < cm_startyear
    [[#1429](https://github.com/remindmodel/remind/pull/1429)]

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
