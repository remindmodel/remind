
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Unreleased]

### added
- Possibility of using updated sources for baseline non-CO2 emissions calculation, controlled by `cm_emifacs_baseyear`
- Add `readcoupledgdx` script that allows to print scalars from gdx files for all coupled runs
    [[#1977](https://github.com/remindmodel/remind/pull/1977)]

### input data/calibration
- new input data rev7.21 including new MAgPIE data [[#1956](https://github.com/remindmodel/remind/pull/1956)]

### changed
- **scripts** for MAgPIE coupled runs, if the coupled config contains a `path_gdx_ref` column, it needs a `path_gdx_refpolicycost` column as well.
    [[#1940](https://github.com/remindmodel/remind/pull/1940)]
  **core** merge cm_GDPscen and cm_POPscen into cm_GDPpopScen [[#1973](https://github.com/remindmodel/remind/pull/1973)]

### added
-

### removed
- **37_industry** removed superseded realization fixed_shares [[#1941](https://github.com/remindmodel/remind/pull/1941)]

### fixed
- **37_industry** fix and restructure chemical feedstock balancing to account for all negative emissions from stored non-fossil carbon [[#1829](https://github.com/remindmodel/remind/pull/1829)]


## [3.4.0] - 2024-12-11

### input data/calibration
- new input data rev6.84 [[#1757](https://github.com/remindmodel/remind/pull/1757)]
- new input data rev6.95 in US$2017 [[#1812](https://github.com/remindmodel/remind/pull/1812)]
- new input data rev7.13 including new MAgPIE emulators [[#1886](https://github.com/remindmodel/remind/pull/1886)]
- CES parameter and gdx files calibrated with new default diffLin2Lin for NPi 
    [[#1747](https://github.com/remindmodel/remind/pull/1747)] and
    [[#1757](https://github.com/remindmodel/remind/pull/1757)]
- Update of NDC goals with cutoff data August 31, 2024
    [[#1816](https://github.com/remindmodel/remind/pull/1816)]
- Prepare to make input data available for externals. Do not stop on missing validation data.
    [[1828](https://github.com/remindmodel/remind/pull/1828)]

### changed
- shift base unit from US$2005 to US$2017 [[#1812](https://github.com/remindmodel/remind/pull/1812)]
- plastic waste by default does not lag plastics production by ten years
    anymore; can be re-activated using `cm_wastelag`
- moved to edgeTransport 2.0 version [[#1749](https://github.com/remindmodel/remind/pull/1749)]
- **scripts** in readCheckScenarioConfig(), do not automatically remove path_gdx_bau if allegedly 'not needed'
    [[#1809](https://github.com/remindmodel/remind/pull/1809)]
- **scripts** adjust MAgPIE coupling to US$2005 -> 2017 shift
    [[#1851](https://github.com/remindmodel/remind/pull/1851)]
- **core** changed adjustment cost of geohe (central heat pumps), elh2 (electrolysis), MeOH (FT-Synthesis: H2-to-Liquids)
    and h22ch4 (methanation: H2-to-Gas) to better reflect upscaling dynamics
    [[#1823](https://github.com/remindmodel/remind/pull/1823)]
- **core** increase electrolysis CAPEX and slightly adjust default setting for electrolysis taxation and flexibility benefit,
    add near-term bounds for electrolysis and synthetic fuel deployment
    [[#1882](https://github.com/remindmodel/remind/pull/1882)]
- **core** update co2 capture rates and cost of biomass liquids and gas and some other X-to-Liq/Gas technologies to be internally consistent
    [[#1881](https://github.com/remindmodel/remind/pull/1881)]

### added
- **config** add ScenarioMIP config
    [[#1894](https://github.com/remindmodel/remind/pull/1894)] and [[#1920](https://github.com/remindmodel/remind/pull/1920)]
- **32_power** increase minimum required dispatchable back-up capacity for VRE integration
    [[#1789](https://github.com/remindmodel/remind/pull/1789)]
- **33_CDR** added ocean alkalinity enhancement to the CDR portfolio (OAE is turned off by default)
    [[#1777](https://github.com/remindmodel/remind/pull/1777)]
- **45_carbonprice** added realization functionalForm
    [[#1874](https://github.com/remindmodel/remind/pull/1874)] and [[#1723](https://github.com/remindmodel/remind/pull/1723)]
- **45_carbonprice** added realizations NPi2025, NPi2025expo and NPiexpo
    [[#1851](https://github.com/remindmodel/remind/pull/1851)] and
    [[#1888](https://github.com/remindmodel/remind/pull/1888)]
- **50_damages**, **51_internalizeDamages** add KotzWenz realization based on Kotz & Wenz (2024)
    [[#1601](https://github.com/remindmodel/remind/pull/1601)]
- **config** add ELEVATE2p3 config
    [[#1851](https://github.com/remindmodel/remind/pull/1851)]
- **scripts** define defaults for script selections in output.R
    [[#1739](https://github.com/remindmodel/remind/pull/1739)]
- **scripts** fail transparently on duplicated column names in `scenario_config*.csv` files
    [[#1742](https://github.com/remindmodel/remind/pull/1742)]
- **scripts** checkProjectSummations now also checks whether global intensive variables (prices)
    lie between regional min/max
    [[#1773](https://github.com/remindmodel/remind/pull/1773)]
- **scripts** add support for EDGE-Transport standalone results to cs2 
    [[#1780](https://github.com/remindmodel/remind/pull/1780)]
- **scripts** add option to use raw land-use change emissions variable in coupled runs
    [[#1796](https://github.com/remindmodel/remind/pull/1796)]
- **testthat** fail if manipulating main.gms with default cfg drops/changes switches and comments
    [[#1764](https://github.com/remindmodel/remind/pull/1764)] and
    [[#1767](https://github.com/remindmodel/remind/pull/1767)]
- **scripts** integrate automated scenario validation via piamValidation as output script
    [[#1790](https://github.com/remindmodel/remind/pull/1790)]
- **scripts** add interactive plotting script 'selectPlots'
    [[#1815](https://github.com/remindmodel/remind/pull/1815)]
- **scripts** in readCheckScenarioConfig() while running tests, check if all scenarios stated in path_gdx* columns exist
    [[#1818](https://github.com/remindmodel/remind/pull/1818)]
- **scripts** fail transparently if cm_startyear is earlier than that of path_gdx_ref
    [[#1851](https://github.com/remindmodel/remind/pull/1851)]
- **testthat** ignore missing historical.mif in tests because it is an optional input file
    [[#1857](https://github.com/remindmodel/remind/pull/1857)]
- **scripts** Add scripts for preparing a release
    [[#1871](https://github.com/remindmodel/remind/pull/1871)]
    
### fixed
- **30_biomass** reset 1st gen. biofuel bound from 2045 to 2030
    [[#1890](https://github.com/remindmodel/remind/pull/1890)]
- **37_industry** included CCS from plastic waste incineration in CCS mass flows so it is
    subject to injection constraints (but did not add CCS costs, see
    https://github.com/remindmodel/development_issues/issues/274
- **MAGICC7** fix climate data for time before cm_startyear on reference run
    [[#1744](https://github.com/remindmodel/remind/pull/1744)]
- **scripts** fix tax convergence reporting in modelSummary
    [[#1728](https://github.com/remindmodel/remind/pull/1728)]
- **scripts** cleanup non-existing realizations from settings_config.csv
    [[#1718](https://github.com/remindmodel/remind/pull/1718)]
- **scripts** REMIND-MAgPIE start scripts now correctly use all non-gms cfg switches
    [[#1768](https://github.com/remindmodel/remind/pull/1768)]
- **scripts** limit slurm runtime of output.R scripts to 2 hours
    [[#1783](https://github.com/remindmodel/remind/pull/1783)]

### removed
- **45_carbonprice** removed superseded realizations linear, exponential and diffCurvPhaseIn2Lin
    [[#1858](https://github.com/remindmodel/remind/pull/1858)]

## [3.3.2] - 2024-07-04

### changed
- fix output generation [[#1715](https://github.com/remindmodel/remind/pull/1715)]

## [3.3.1] - 2024-06-18

### changed
- new input data (6.77) including new GDP and population data
    [[#83](https://github.com/pik-piam/mrdrivers/pull/83)] [[#1684](https://github.com/remindmodel/remind/pull/1684)]
- **37_industry** remove subsector-specific shares of SE
  origins in FE carriers for performance reasons [[#1659](https://github.com/remindmodel/remind/pull/1659)]
- **37_industry** make process-based steel production model the default over the ces-based model [[#1663](https://github.com/remindmodel/remind/pull/1663)]
- **37_industry** fixed incineration of plastic and non-plastic waste causing
  non-zero emissions for biomass and synfuels
  [[#1682](https://github.com/remindmodel/remind/pull/1682)]
- **core** another change of preference parameters and associated computation of interest rates/mark ups [[#1663](https://github.com/remindmodel/remind/pull/1663)]
- **scripts** do not check anymore that MAgPIE uses renv
  [[1646](https://github.com/remindmodel/remind/pull/1646)]
- **scripts** adjust function calls after moving functionality from `remind2`
  [[#578](https://github.com/pik-piam/remind2/pull/578)] to `piamPlotComparison` and `piamutils` [[#1661](https://github.com/remindmodel/remind/pull/1661)]
- **scripts** enhance output script `reportCEScalib` to include additional plot formats [[#1671](https://github.com/remindmodel/remind/pull/1671)]

### added
- **24_trade** add optinal trade scenario for EUR hydrogen and e-liquids imports [[#1666](https://github.com/remindmodel/remind/pull/1666)] 

## [3.3.0] - 2024-03-28

### changed
- **37_industry** changed industry to have subsector-specific shares of SE
  origins in FE carriers [[#1620](https://github.com/remindmodel/remind/pull/1620)]

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
    [[#1475](https://github.com/remindmodel/remind/pull/1475)], [[#1615](https://github.com/remindmodel/remind/pull/1615)]
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
