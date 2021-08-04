SET all_enty             "all types of quantities"
/
        peoil        "PE oil"
        pegas        "PE gas"
        pecoal       "PE coal"
        peur         "PE uranium"
        pegeo        "PE geothermal"
        pehyd        "PE hydropower"
        pewin        "PE wind"
        pesol        "PE solar"
        pebiolc      "PE biomass lignocellulosic"
        pebios       "PE biomass sugar and starch"
        pebioil      "PE biomass sunflowers, palm oil, etc"
	all_seliq	 "all to SE liquids"
		seliqbio     "SE liquids from biomass (ex. ethanol)"
		seliqfos     "SE liquids from fossil pe (ex. petrol and diesel)"
                seliqsyn     "SE synthetic liquids from H2 (ex. petrol and diesel)"
        all_seso	 "all to SE solids"
		sesobio      "SE solids from biomass"
		sesofos      "SE solids from fossil pe"
        seel         "SE electricity"
        seh2         "SE hydrogen"
        all_sega	 "all to SE gas"
		segabio      "SE gas from biomass"
		segafos      "SE gas from fossil pe"
                segasyn      "SE synthetic gas from H2"
        sehe         "SE district heating and heat pumps"
        fegas        "FE gas stationary"
        fegab
        fegai
        fegat
        fega
        fehos        "FE heating oil stationary"
        fehob
        fehoi
        fesos        "FE solids stationary"
        feso
        fesoi
        fesob
        feels        "FE electricity stationary"
        feelb
        feelcb       "buildings use of conventional electricity (all but space heating)"
        feelhpb      "buildings use of electricity for space heating with heat pumps"
        feelrhb      "buildings use of electricity for space heating with resistive heating"
        feeli
        feel
        fehes        "FE district heating (including combined heat and power), and heat pumps stationary"
        feheg
        fehei
        feheb
        fehe
        feh2s        "FE hydrogen stationary"
        fepet        "FE petrol transport"
        fedie        "FE diesel transport"
        felit        "FE liquids for transport (includes diesel and petrol)"
        fetf         "FE transport fuels"
        feh2t        "FE hydrogen transport"
        feelt        "final energy electricity for transport"
        fehoi_cs     "final energy in industry diesel - carbon stored"
        fegai_cs     "final energy in industry natural gas - carbon stored "

        ueHDVt       "transport useful energy heavy duty vehicles"
        ueLDVt       "transport useful energy light duty vehicles"
        ueelTt       "transport useful energy for electric trains"

        co2          "carbon dioxide emissions"
        ch4          "methane emissions"
        n2o          "n2o emissions from the energy system"
        so2          "sulfur dioxide emissions"
        ch4coal    "fugitive emissions from coal mining"
        ch4gas     "fugitive emissions from gas production"
        ch4oil     "fugitive emissions from oil production"
        ch4wstl    "ch4 emissions from solid waste disposal on land"
        ch4wsts    "ch4 emissions from waste water"
        ch4rice    "ch4 emissions from rice cultivation (rice_ch4)"
        ch4animals "ch4 emissions from enteric fermentation of ruminants (ent_ferm_ch4)"
        ch4anmlwst "ch4 emissions from animal waste management(awms_ch4)"
        ch4agwaste "ch4 emissions from agricultural waste burning (no MAC available)"
        ch4forest  "ch4 emissions from forest burning"
        ch4savan   "ch4 emissions from savannah burnging"
        n2oforest  "n2o emissions from forest burning"
        n2osavan   "n2o emissions from savannah burnging"
        n2otrans   "n2o emissions from transport"
        n2oacid    "n2o emissions from acid production (only 2005 EDGAR data for calibration of n2oadac and n2onitac baselines)"
        n2oadac    "n2o emissions from adipic acid production"
        n2onitac   "n2o emissions from nitric acid production"
        n2ofert    "MAC for n2o emissions from fertilizer (starting with n2ofert)"
        n2ofertin  "n2o emissions from Inorganic fertilizers (inorg_fert_n2o)"
        n2ofertcr  "n2o emissions from decay of crop residues (resid_n2o)"
        n2ofertsom "n2o emissions from soil organic matter loss (som_n2o)"
        n2oanwst   "MAC for n2o emissions from animal waste (starting with n2oanwst)"
        n2oanwstc  "n2o emissions from manure applied to croplands (man_crop_n2o)"
        n2oanwstm  "n2o emissions from animal waste management (awms_n2o)"
        n2oanwstp  "n2o emissions from manure excreted on pasture (man_past_n2o)"
        n2oagwaste "n2o emissions from agricultural waste burning (no MAC available)"
        n2owaste   "n2o emissions from waste (domestic sewage)"
        co2luc     "co2 emissions from land use change"
        co2cement_process  "co2 from cement production (only process emissions)"
        n2obio       "N2O emissions from pebiolc "
        bc           "black carbon from fossil fuel combustion"
        oc           "organic carbon from fossil fuel combustion"
        NOx          "nitrogen oxide emissions"
        CO           "carbon monoxide emissions"
        VOC          "volatile organic compound emissions"
        NH3          "ammonia emissions"

        co2cement      "CO2 emissions from clinker and cement production"
        co2chemicals   "CO2 emissions from chemicals production"
        co2steel       "CO2 emissions from steel production"
        co2otherInd    "CO2 emissions from other industry (used only for reporting)"

        emiFgasTotal    "XXX"
        emiFgasPFC      "XXX"
        emiFgasCF4      "XXX"
        emiFgasC2F6     "XXX"
        emiFgasC6F14    "XXX"
        emiFgasHFC      "XXX"
        emiFgasHFC23    "XXX"
        emiFgasHFC32    "XXX"
        emiFgasHFC43-10 "XXX"
        emiFgasHFC125   "XXX"
        emiFgasHFC134a  "XXX"
        emiFgasHFC143a  "XXX"
        emiFgasHFC227ea "XXX"
        emiFgasHFC245fa "XXX"
        emiFgasSF6      "XXX"
        ccuco2short  "CCU related parameter for short term stored co2 in ccu products"
        CtoH         "co2 emissions ratio C to H for CCU-technologies"
        cco2         "captured CO2"
***       pco2         "CCS related parameter during compression of CO2"
***       tco2         "CCS related parameter during transportation of CO2"
        ico2         "CCS related parameter during injection of CO2"
***       sco2         "CCS related parameter during storage of CO2 - monitoring ???"
        uedit        "Useful Energy: DIesel for Transport. Unit: TWa (not yet a real ES, only copied 1:1 from FE)"
        uepet        "Useful Energy: PEtrol for Transport. Unit: TWa (not yet a real ES, only copied 1:1 from FE)"
        ueelt        "Useful Energy: ELectricity for Transport. Unit: TWa (not yet a real ES, only copied 1:1 from FE)"
*** uegat   "Useful Energy: GAs for Transport. Unit: TWa (not yet a real ES, only copied 1:1 from FE)"
*** ueh2t   "Useful Energy: H2 for Transport. Unit: TWa (not yet a real ES, only copied 1:1 from FE)"

	good         "Generic good"
         perm         "Carbon permit"
         peog         "aggregated oil and gas, only relevant for calibration because IEA only provides aggregated data"
/


enty(all_enty)       "all types of quantities"
/
        peoil        "primary energy oil"
        pegas        "primary energy gas"
        pecoal       "primary energy coal"
        peur         "primary energy uranium"
        pegeo        "primary energy geothermal"
        pehyd        "primary energy hydropower"
        pewin        "primary energy wind"
        pesol        "primary energy solar"
        pebiolc      "primary energy biomass lignocellulosic"
        pebios       "primary energy biomass sugar nd starch"
        pebioil      "primary energy biomass sunflowers, palm oil, etc"
        seliqbio     "secondary energy liquids from biomass (ex. ethanol)"
	seliqfos     "secondary energy liquids from fossil primary energy (ex. petrol and diesel)"
        seliqsyn     "secondary energy synthetic liquids from H2"
        sesobio      "secondary energy solids from biomass"
	sesofos      "secondary energy solids from fossil primary energy"
        seel         "secondary energy electricity"
        seh2         "secondary energy hydrogen"
        segabio      "secondary energy gas from biomass"
	segafos      "secondary energy gas from fossil primary energy"
        segasyn      "secondary energy synthetic gas from H2"
        sehe         "secondary energy district heating and heat pumps"
        fegas        "final energy gas stationary"
        fehos        "final energy heating oil stationary"
        fesos        "final energy solids stationary"
        feels        "final energy electricity stationary"
        fehes        "final energy district heating (including combined heat nd power), nd heat pumps stationary"
        feh2s         "final energy hydrogen stationary"
        fepet         "final energy petrol transport"
        fedie         "final energy diesel transport"
        feelt         "final energy electricity for transport"
        fetf          "final energy transport fuels"
        feh2t         "final energy hydrogen transport"
        fegat         "final energy nat. gas for transport"

        co2          "carbon dioxide emissions"
        ch4          "methane emissions"
        n2o          "n2o emissions from the energy system"
        so2          "sulfur dioxide emissions"
        ch4coal    "fugitive emissions from coal mining"
        ch4gas     "fugitive emissions from gas production"
        ch4oil     "fugitive emissions from oil production"
        ch4wstl    "ch4 emissions from solid waste disposal on land"
        ch4wsts    "ch4 emissions from waste water"
        ch4rice    "ch4 emissions from rice cultivation (rice_ch4)"
        ch4animals "ch4 emissions from enteric fermentation of ruminants (ent_ferm_ch4)"
        ch4anmlwst "ch4 emissions from animal waste management(awms_ch4)"
        ch4agwaste "ch4 emissions from agricultural waste burning (no MAC available)"
        ch4forest  "ch4 emissions from forest burning"
        ch4savan   "ch4 emissions from savannah burnging"
        n2oforest  "n2o emissions from forest burning"
        n2osavan   "n2o emissions from savannah burnging"
        n2otrans   "n2o emissions from transport"
        n2oacid    "n2o emissions from acid production (only 2005 EDGAR data for calibration of n2oadac and n2onitac baselines)"
        n2oadac    "n2o emissions from adipic acid production"
        n2onitac   "n2o emissions from nitric acid production"
        n2ofert    "MAC for n2o emissions from fertilizer (starting with n2ofert)"
        n2ofertin  "n2o emissions from Inorganic fertilizers (inorg_fert_n2o)"
        n2ofertcr  "n2o emissions from decay of crop residues (resid_n2o)"
        n2ofertsom "n2o emissions from soil organic matter loss (som_n2o)"
        n2oanwst   "MAC for n2o emissions from animal waste (starting with n2oanwst)"
        n2oanwstc  "n2o emissions from manure applied to croplands (man_crop_n2o)"
        n2oanwstm  "n2o emissions from animal waste management (awms_n2o)"
        n2oanwstp  "n2o emissions from manure excreted on pasture (man_past_n2o)"
        n2oagwaste "n2o emissions from agricultural waste burning (no MAC available)"
        n2owaste   "n2o emissions from waste (domestic sewage)"
        co2luc     "co2 emissions from land use change"
        co2cement_process  "co2 from cement production (only process emissions)"
        n2obio       "N2O emissions from pebiolc"
        bc           "black carbon from fossil fuel combustion"
        oc           "organic carbon from fossil fuel combustion"
        NOx
        CO
        VOC
        NH3
        cco2         "captured CO2"
*        pco2         "CCS related parameter during compression of CO2"
*        tco2         "CCS related parameter during transportation of CO2"
        ico2         "CCS related parameter during injection of CO2"
*        sco2         "CCS related parameter during storage of CO2 - monitoring ???"
	good         "Generic good"
	perm         "Carbon permit"

        co2cement      "CO2 emissions from clinker and cement production"
        co2chemicals   "CO2 emissions from chemicals production"
        co2steel       "CO2 emissions from steel production"
/


entySe(all_enty)       "secondary energy types"
/
        seliqbio     "secondary energy liquids from biomass"
        seliqfos     "secondary energy liquids from fossil primary energy"
        seliqsyn     "secondary energy synthetic liquids from H2"
        sesobio      "secondary energy solids from biomass"
        sesofos      "secondary energy solids from fossil primary energy"
        seel         "SE electricity"
        seh2         "SE hydrogen"
        segabio      "secondary energy gas from biomass"
        segafos      "secondary energy gas from fossil primary energy"
        segasyn      "secondary energy synthetic gas from H2"
        sehe         "SE district heating nd heat pumps"
/


peFos(all_enty)      "primary energy fossil fuels"
/
        peoil        "PE oil"
        pegas        "PE gas"
        pecoal       "PE coal"
/
;

***-----------------------------------------------------------------------------
*** Definition of the main characteristics set 'char':
***-----------------------------------------------------------------------------
SET char            "characteristics of technologies"
/
  mix0            "share in the production of v*_INIdemEn0, which is the energy demand in t0 minus the energy produced by couple production"
  ccap0           "cumulated installed capacity in t0. Unit: TW"
  inco0           "investment costs in t0. Unit: $/kW"
  incolearn       "Investment costs that can be reduced through learning. Unit: $/kW"
  floorcost       "Floor investment costs for learning technologies. Unit: $/kW"
  eta             "conversion efficiency"
  omf             "fixed o&m"
  omv             "variable o&m"
  tlt             "techical life time"
  delta           "depreciation rate"
  learn           "learning rate"
  learnMult_woFC  "multiplicative parameter in learning equation (without taking into account floor costs)"
  learnExp_woFC   "exponent in learning equation (without taking into account floor costs)"
  learnMult_wFC   "multiplicative parameter in learning equation, adjusted to take floor costs into account"
  learnExp_wFC    "exponent in learning equation, adjusted to take Floor Costs into account"
  bgrl            "lower bound on growth rate"
  bgru            "upper bound on growth rate"
  bcal            "lower bound on capacity"
  bcau            "upper bound on capacity"
  bmil            "lower bound on contribution to energy mix"
  bmiu            "upper bound on contribution to energy mix"
  bscu            "upper bound on combined heat power contribution to electricity production"
  nur             "multiplicator for nu"
  maxprod         "maximum annual production"
  cost            "marginal costs of extraction"
  quan            "quantity of fuel class"
  leak            "leakage rate of CCS sequestration"
  omeg            "NOT USED ANYMORE. New parameter: pm_omeg. Weight factor of still available capacities."
  seed            "initial value for control variable constraint"
  lingro          "linear growth of control variable additions p.a."
  linconstela     "elastaticity of investment costs for linear growth constraint"
  limitGeopot        "geographical annual solar potential"
  luse            "land use factor of solar technologies"
  capacity        "capacity of solar technologies"
  constrTme       "Construction time in years, needed to calculate turn-key cost premium compared to overnight costs"
  tkpremused      "turn-key cost premium used in the model (with a discount rate of 3+ pure rate of time preference); in comparison to overnight costs)"
  lifetime        "average lifetime of a technology (integral under the omeg-curve). Unit: years"
  flexibility                        "representing ramping constraints or additional costs for partial load of technologies in power sector"
  tech_stat       "technology status: how close a technology is to market readiness. Scale: 0-3, with 0 'I can go out and build a GW plant today' to 3 'Still some research necessary'"
  Xport           "imports"
  Mport           "exports"
  use             "financial trade costs for PE use [trl$US per TWa]"
  XportElasticity "PE trade adjustment cost parameter that influences the export supply elasticity"
  tradeFloor      "PE trade adjustment cost parameter that allows for smallest trade increase without adjustment cost"
  min             "minimum"
  max             "maximum"
  usehr            "number of hours in a year when the technology is used"
  elh2VREcapRatio    "ratio of elh2VRE capacity to storage technology capacity"
  h2turbVREcapRatio  "ratio of h2turbVRE capacity to storage technology capacity"
  batteryVREcapRatio  "ratio of battery capacity to storage technology capacity"
/
;

SET all_regi "all regions" /LAM,OAS,SSA,EUR,NEU,MEA,REF,CAZ,CHA,IND,JPN,USA,     ENC, NES, EWN, ECS, ESC, ECE, UKI, NEN, ESW,          DEU, FRA/;
SET regi(all_regi) / LAM,OAS,SSA,EUR,NEU,MEA,REF,CAZ,CHA,IND,JPN,USA /;

ALIAS(regi,regi2,regi3);


SETS
tall            "time index"
/
        1900*3000
/
ttot(tall)      "time index with spin up"
/
        2005,
        2010,
        2015,
        2020,
        2025,
        2030,
        2035,
        2040,
        2045,
        2050,
        2055,
        2060,
        2070,
        2080,
        2090,
        2100,
        2110,
        2130,
        2150
/
;

alias(ttot,t);

SCALAR cm_startyear "first optimized modelling time step [year]"
/ 2005 /;

PARAMETERS
    pm_ttot_val(ttot)                                    "value of ttot set element"
    p_tall_val(tall)                                     "value of tall set element"
    pm_ts(tall)                                          "(t_n+1 - t_n-1)/2 for a timestep t_n"
    pm_dt(tall)                                          "difference to last timestep"
;

*------------------------------------------------------------------------------------
***                        calculations based on sets
*------------------------------------------------------------------------------------
pm_ttot_val(ttot) = ttot.val;
p_tall_val(tall) = tall.val;

pm_ts(ttot) = (pm_ttot_val(ttot+1)-(pm_ttot_val(ttot-1)))/2;
pm_ts("2005") = 5;
$if setGlobal END2110 pm_ts(ttot)$(ord(ttot) eq card(ttot)-1) =  pm_ts(ttot-1) ;
pm_ts(ttot)$(ord(ttot) eq card(ttot)) = 27;
pm_dt("2005") = 5;
pm_dt(ttot)$(ttot.val > 1900) = ttot.val - pm_ttot_val(ttot-1);
display pm_ts, pm_dt;



SCALARS
cm_tradecost_bio / 1 /
cm_trdcst / 1 /
cm_trdadj / 1 /
cm_ariadne_trade_el / 0 /
cm_ariadne_trade_h2 / 0 /
cm_ariadne_trade_syn / 0 /
;


PARAMETERS
    p_PEPrice(ttot,all_regi,all_enty)                     "parameter to capture all PE prices (tr$2005/TWa)"
;
