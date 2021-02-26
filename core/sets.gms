*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/sets.gms

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***            Definition of all super-sets "all_*"
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
SETS
* Save select compiler flags as sets, to make them accessible from the final gdx
c_expname       "c_expname as set for use in GDX"       /%c_expname%/
cm_GDPscen      "cm_GDPscen as set for use in GDX"      /%cm_GDPscen%/
*

all_POPscen     " all possible population scenarios"
/
pop_SDP         "SDP population scenario"
pop_SSP1        "SSP1 population scenario"
pop_SSP2        "SSP2 population scenario"
pop_SSP3        "SSP3 population scenario"
pop_SSP4        "SSP4 population scenario"
pop_SSP5        "SSP5 population scenario"
pop_a1
pop_a2
pop_b1
pop_b2
/

all_GDPscen    "all possible GDP scenarios"
/
gdp_SDP         "SDP fastGROWTH medCONV"
gdp_SSP1        "SSP1 fastGROWTH medCONV"
gdp_SSP2        "SSP2 medGROWTH medCONV"
gdp_SSP3        "SSP3 slowGROWTH slowCONV"
gdp_SSP4        "SSP4  medGROWTH mixedCONV"
gdp_SSP5        "SSP5 fastGROWTH fastCONV"
gdp_a1
gdp_a2
gdp_b1
gdp_b2
/

all_GDPpcScen    "all possible GDP per capita scenarios (GDP and Population from the same SSP-scenario"
/
SDP         "SDP scenario"
SSP1        "SSP1 fastGROWTH medCONV"
SSP2        "SSP2 medGROWTH medCONV"
SSP3        "SSP3 slowGROWTH slowCONV"
SSP4        "SSP4  medGROWTH mixedCONV"
SSP5        "SSP5 fastGROWTH fastCONV"
a1
a2
b1
b2
/

all_SSP_forcing_adjust  "all possible forcing targets and budgets according to SSP scenario such that magicc forcing meets the target"
/
forcing_SSP1
forcing_SSP2
forcing_SSP3
forcing_SSP4
forcing_SSP5
/

all_rcp_scen   "all possible RCP scenarios"
/none,rcp20,rcp26,rcp37,rcp45,rcp60,rcp85/

all_delayPolicy   "all possible SPA policy choices"
/
SPA0            "no baseline policy"
SPAx            "moderate baseline policy, depends on the SSP-scenario"
/

all_APscen     "all air pollutant scenarios"
/
SSP1
SSP2
SSP3
SSP4
SSP5
CLE
FLE
FLE_building_transport
MFR
MFR_Transports
GlobalEURO6
SLCF_building_transport
/

all_LU_emi_scen  "all emission baselines for CH4 and N2O land use emissions from MAgPIE"
/
    SDP         "very low emissions (from SDP scenario in MAgPIE)"
    SSP1        "low    emissions (from SSP1 scenario in MAgPIE)"
    SSP2        "medium emissions (from SSP2 scenario in MAgPIE)"
    SSP3        "currently not available"
    SSP4        "currently not available"
    SSP5        "high   emissions (from SSP5 scenario in MAgPIE)"
/

all_fossilScen    "all possible scenarios for fossils"
/
lowCoal,medCoal,highCoal,
lowGas,medGas,highGas,
lowOil,medOil,highOil
/
all_te          "all energy technologies, including from modules"
/
        ngcc            "natural gas combined cycle"
        ngccc           "natural gas combined cycle with capture"
        ngt             "natural gas turbine"
        gastr           "transformation of gases"
        gaschp          "combined heating power using gas"
        gashp           "heating plant using gas"
        gash2           "gas to hydrogen"
        gash2c          "gas to hydrogen with capture"
        gasftrec        "gas based fischer-tropsch recycle"
        gasftcrec       "gas based fischer-tropsch with capture recycle"
        refliq          "refinery oil to se liquids"
        dot             "diesel oil turbine"
        dhp             "diesel oil heating plant"
        igcc            "integrated coal gasification combined cycle"
        igccc           "integrated coal gasification combined cycle with capture"
        pc              "pulverised coal power plant"
$ifthen setGlobal cm_ccsfosall        
        pcc             "pulverised coal power plant with capture"
        pco             "pulverised coal power plant with oxyfuel capture"
$endif
        coalchp         "combined heat powercoal"
        coalhp          "heating plantcoal"
        coaltr          "tranformation of coal"
        coalgas         "coal gasification"
        coalftrec       "coal based fischer-tropsch recycle"
        coalftcrec      "coal based fischer-tropsch with capture recycle"
        coalh2          "coal to hydrogen"
        coalh2c         "coal to hydrogen with capture"
        biotr           "transformation of biomass"
        biotrmod        "modern solids from biomass"
        biotrtradIEA    "only needed for reporting"
        biotrmodIEA     "only needed for reporting"
        biochp          "biomass combined heat and power"
        biohp           "biomass heating plant"
        bioigcc         "integrated biomass gasification combined cycle"
        bioigccc        "integrated biomass gasification combined cycle with CCS"
        biogas          "gasification of biomass"
        bioftrec        "biomass based fischer-tropsch recycle"
        bioftcrec       "biomass based fischer-tropsch with capture recycle"
        bioh2           "biomass to hydrogen"
        bioh2c          "biomass to hydrogen with capture"
        bioethl         "biomass to ethanol"
        bioeths         "sugar and starch biomass to ethanol"
        biodiesel       "oil biomass to biodiesel"
        geohdr          "geothermal electric hot dry rock"
        geohe           "geothermal heat"
        hydro           "hydro electric"
        wind            "wind power converters"
        spv             "solar photovoltaic"
        csp             "concentrating solar power"
        solhe           "solar thermal heat generation"
        tnrs            "thermal nuclear reactor (simple structure)"
        fnrs            "fast nuclear reactor (simple structure)"
        elh2            "hydrogen elecrolysis"
        h2turb          "hydrogen turbine for electricity production"
		elh2VRE         "dummy technology: hydrogen electrolysis; to demonstrate the capacities and SE flows inside the storXXX technologies"
        h2turbVRE       "dummy technology: hydrogen turbine for electricity production; to demonstrate the capacities and SE flows inside the storXXX technologies"
        h2curt          "hydrogen production from curtailment"
        h22ch4          "Methanation, H2 + 4 CO2 --> CH4 + 2 H20"
        MeOH			"Methanol production /liquid fuel, CO2 hydrogenation, CO2 + 3 H2 --> CH3OH + H20"
		tdels           "transmission and distribution for electricity to stationary users"
        tdeli           "transmission and distribution for electricity to industry"
        tdelb           "transmission and distribution for electricity to buildings"
        tdelt           "transmission and distribution for electricity to transport"
        tdbiogas        "transmission and distribution for gas from biomass origin to stationary users"
		tdfosgas        "transmission and distribution for gas from fossil origin to stationary users"
        tdbiogai        "transmission and distribution for gas from biomass origin to industry"
		tdfosgai        "transmission and distribution for gas from fossil origin to industry"
        tdbiogab        "transmission and distribution for gas from biomass origin to buildings"
		tdfosgab        "transmission and distribution for gas from fossil origin to buildings"
        tdbiogat        "transmission and distribution for gas from biomass origin to transportation"
		tdfosgat        "transmission and distribution for gas from fossil origin to transportation"
        tdbiohos        "transmission and distribution for heating oil from biomass origin to transportation"
        tdfoshos        "transmission and distribution for heating oil from fossil origin to stationary users"
        tdbiohoi        "transmission and distribution for heating oil from biomass origin to industry"
		tdfoshoi        "transmission and distribution for heating oil from fossil origin to industry"
        tdbiohob        "transmission and distribution for heating oil from biomass origin to buildings"
        tdfoshob        "transmission and distribution for heating oil from fossil origin to buildings"
        tdh2s           "transmission and distribution for hydrogen to stationary users"
        tdh2t           "transmission and distribution for hydrogen to transportation"
        tdbiodie        "transmission and distribution for diesel from biomass origin to stationary users"
        tdfosdie        "transmission and distribution for diesel from fossil origin to stationary users"
		tdbiopet        "transmission and distribution for petrol from biomass origin to stationary users"
        tdfospet        "transmission and distribution for petrol from fossil origin to stationary users"
        tdbiosos        "transmission and distribution for solids from biomass origin to stationary users"
        tdfossos        "transmission and distribution for solids from fossil origin to stationary users"
        tdbiosoi        "transmission and distribution for solids from biomass origin to industry"
        tdfossoi        "transmission and distribution for solids from fossil origin to industry"
        tdbiosob        "transmission and distribution for solids from biomass origin to buildings"
		tdfossob        "transmission and distribution for solids from fossil origin to buildings"
        tdhes           "transmission and distribution for heat to stationary users"
        tdhei           "transmission and distribution for heat to industry"
        tdheb           "transmission and distribution for heat to buildings"

*        ccscomp         "compression of co2"
*        ccspipe         "transportation of co2"
        ccsinje         "injection of co2"
*        ccsmoni         "monitoring of co2"
*RP* Storage technology:
        storspv         "storage technology for photo voltaic (PV)"
        storwind        "storage technology for wind"
        storcsp         "storage technology for concentrating solar power (CSP)"
*RP* grid technology
        gridspv         "grid between areas with high pv production and the rest"
        gridcsp         "grid between areas with high csp production and the rest"
        gridwind        "grid between areas with high wind production and the rest"
*AJS* transport technologies (ESH2T etc..) are defined in the transport module. 
 	apCarPeT        "Cars using final energy petrol (FEPET) to produce useful energy in form of petrol for transport (UEPET) "
    apCarDiT        "Vehicles using final energy diesel (FEDIE) to produce heavy-duty useful energy (uedit, e.g. freight, busses, planes, ships)."
    apcarDiEffT     "More efficient vehicles using final energy diesel (FEDIE) and electricity (FEELT) to produce heavy-duty useful energy (uedit, e.g. freight, busses, planes, ships)."
    apcarDiEffH2T   "Even more efficient vehicles using final energy diesel (FEDIE), electricity (FEELT) and Hydrogen (FEH2T) to produce heavy-duty useful energy (uedit, e.g. freight, busses, planes, ships)."
    apCarH2T        "Cars using final energy hydrogen for transport (FEH2T) to produce useful energy as hydrogen for transport (ESH2T)."
        apCarElT        "Cars using final energy electricity (FEELT) to produce useful energy as electricity for transport (UEELT)"
        apTrnElT        "Trains using final energy electricity (FEELT) to produce useful energy as electricity for transport (UEELT)"
***  appCarGaT  "Cars using FEGAT to produce ESGAT."  ???
        rockgrind       "grinding rock for enhanced weathering"
        dac             "direct air capture"
        x_gas2elec
        d_bio2elec      "d_* transmission and distribution losses"
        d_coal2elec
        d_gas2elec
        d_feel
        d_fehe
        d_fesobio
		d_fesofos
        d_fegabio
		d_fegafos
        d_coal2coal
        d_oil2coal
        d_gas2coal
        d_elec2coal
        d_oil2og
        d_gas2og
        d_elec2og
        d_oil2oil
        d_oil2gas
        d_gas2oil
        d_gas2gas
        d_elec2oil
        d_elec2gas
        tdgai_cs
        tdhoi_cs
        o_feel
/

all_enty             "all types of quantities"
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
        all_seso	 "all to SE solids" 
		sesobio      "SE solids from biomass"
		sesofos      "SE solids from fossil pe"
        seel         "SE electricity"
        seh2         "SE hydrogen"
        all_sega	 "all to SE gas" 
		segabio      "SE gas from biomass"
		segafos      "SE gas from fossil pe"
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

        !! emissions
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

        !! emissions from industry sub-sectors
        co2cement      "CO2 emissions from clinker and cement production"
        co2chemicals   "CO2 emissions from chemicals production"
        co2steel       "CO2 emissions from steel production"
        co2otherInd    "CO2 emissions from other industry (used only for reporting)"

        !! various emissions
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

all_esty "energy services"
/
*** Transport module: Energy services
	espet_pass_sm
	esdie_pass_sm
	esdie_pass_lo
	eselt_pass_sm
	esdie_frgt_lo
	esdie_frgt_sm
	eselt_frgt_sm
    esh2t_pass_sm
    esgat_pass_sm
    esh2t_frgt_sm
    esgat_frgt_sm

*** Buildings module: Energy services (useful energy)
    ueshheb  "buildings space heating district heat"
    ueshhob  "buildings space heating liquids"
    ueshsob  "buildings space heating solids"
    ueshstb  "buildings space heating traditional solids"
    ueshgab  "buildings space heating district heat"
    ueshh2b  "buildings space heating hydrogen"
    ueshelb  "buildings space heating electricity resistance"
    ueshhpb  "buildings space heating electricity heat pump"
    
    uecwhob  "buildings cooking and water heating liquids"
    uecwsob  "buildings cooking and water heating solids"
    uecwstb  "buildings cooking and water heating traditional solids"
    uecwgab  "buildings cooking and water heating gas"
    uecwheb  "buildings cooking and water heating district heat"
    uecwh2b  "buildings cooking and water heating hydrogen"
    uecwelb  "buildings cooking and water heating electricity"
    uecwhpb  "buildings cooking and water heating heat pump"
/

all_sectorEmi     "all sectors with emissions"
/       indst        "emissions from industry sector"
        res          "emissions from residential sector"
        trans        "emissions from transport sector"
        power        "emissions from power sector"
        solvents     "emissions from solvents"
        extraction   "emissions from fuel extraction"
        indprocess   "process emissions from industry"
/

all_exogEmi     " all exogenous emission types"
/       Aviation         "Exog emi from Aviation"
        InternationalShipping "Ecog emi from Int. Shipping" 
        Waste            "Exogenous emissions from Waste treatment"
        Agriculture      "Exogenous emissions from Agriculture" 
        AgWasteBurning   "Exogenous emissions from Ag Waste Burning"
        ForestBurning    "Exogenous emissions from Forest Burning"
        GrasslandBurning "Exogenous emissions from Grassland Burning"
/

all_in   "all inputs and outputs of the CES function"
/
  inco                    "macroeconomic output"  

  lab                     "labour input"
  kap                     "capital input"
  en                      "energy input"

  ens                     "stationary energy use"
  ensh                    "stationary heat energy use"
  fesos                   "stationary use of solid energy carriers"
  fehos                   "stationary use of liquid energy carriers"
  fegas                   "stationary use of gaseous energy carriers"
  feh2s                   "stationary use of hydrogen"
  fehes                   "stationary use of district heat"
  feels                   "stationary use of electricity"

  enb                     "buildings energy use"
  enhb                    "buildings heat energy use"
  enhgab                  "buildings heat gaseous energy use (fegab and feh2b)"  
  fesob                   "buildings use of solid energy carriers"
  fehob                   "buildings use of liquid energy carriers"
  fegab                   "buildings use of gaseous energy carriers"
  feh2b                   "buildings use of hydrogen"
  feheb                   "buildings use of district heat"
  feelb                   "buildings use of electricity"

  eni                     "industry energy use"
  enhi                    "industry heat energy use"
  enhgai                  "industry heat gaseous energy use (fegab and feh2b)" 
  fesoi                   "industry use of solid energy carriers"
  fehoi                   "industry use of liquid energy carriers"
  fegai                   "industry use of gaseous energy carriers"
  feh2i                   "industry use of hydrogen"
  fehei                   "industry use of district heat"
  feeli                   "industry use of electricity"

  fehcsob                 "buildings heating and cooking solids final energy"
  fehcelb                 "buildings heating and cooking electricity final energy" 
  fehcheb                 "buildings heating and cooking district heat final energy"
  fehcgab                 "buildings heating and cooking gas final energy"
  fehchob                 "buildings heating and cooking liquids final energy"
  fealelb                 "buildings appliances and light electricity final energy"
  fecwsob                 "buildings cooking and water heating solids final energy"
  fecwelb                 "buildings cooking and water heating electricity final energy" 
  fecwhpb                 "buildings cooking and water heating electricity heat pump final energy" 
  fecwheb                 "buildings cooking and water heating district heat final energy"
  fecwgab                 "buildings cooking and water heating gas final energy"
  fecwhob                 "buildings cooking and water heating liquids final energy"
  fescelb                 "buildings space cooling electricity final energy"
  feshsob                 "buildings space heating solids final energy"
  feshelb                 "buildings space heating electricity final energy" 
  feshheb                 "buildings space heating district heat final energy"
  feshgab                 "buildings space heating gas final energy"
  feshhob                 "buildings space heating liquids final energy"
  feshhpb                 "buildings space heating electricity heat pump final energy"
    
  esswb                   "buildings weatherization energy service"
  uehcb                   "buildings heating and cooking useful energy"
  uecwb                   "buildings cooking and water heating useful energy"
  uescb                   "buildings space cooling useful energy"
  ueshb                   "buildings space heating useful energy"
  uealb                   "buildings appliances and light, useful energy"
  ueswb                   "buildings weatherization"
  feshh2b                 "buildings space heating hydrogen"
  fecwb                   "buildings cooking and water heating FE"
  fecwh2b                 "buildings cooking and water heating hydrogen"
*** FIXME this should be reworked with Robert when revising the transport module
  entrp                   "transport energy use"
  fetf                    "transport fuel use"
  ueLDVt                  "transport useful energy light duty vehicles"
  ueHDVt                  "transport useful energy heavy duty vehicles"
  feh2t                   "transport hydrogen use"
  ueelTt                  "transport useful energy for electric trains"

  entrp_pass              "passenger transport"
  entrp_frgt              "freight transport"
  entrp_pass_sm           "short-to-medium distance passenger transport"
  entrp_pass_lo           "long distance passenger transport"
  entrp_frgt_sm           "short-to-medium distance freight transport"
  entrp_frgt_lo           "long distance freight transport"
  fepet_pass_sm           "short-to-medium distance passenger transport, petrol"
  fedie_pass_sm           "short-to-medium distance passenger transport, diesel"
  feelt_pass_sm           "short-to-medium distance passenger transport, electricity"
  fedie_pass_lo           "long distance passenger transport, diesel"
  fedie_frgt_sm           "short-to-medium distance freight transport, diesel"
  feelt_frgt_sm           "short-to-medium distance freight transport, electricity"
  fedie_frgt_lo           "long distance freight transport, diesel"

  kaphc                   "buildings capital stock insulation"
  kapsc                   "buildings capital stock space cooling"
  kapal                   "buildings capital stock appliances and light"
    
  !! production factors of industry with subsectors
  ue_industry             "useful energy of industry sector"

  ue_cement               "useful energy of cement production"
  en_cement               "energy use of cement production"
  kap_cement              "energy efficiency capital of cement production"
  en_cement_non_electric  "non-electric energy use of cement production"
  feso_cement             "solids energy use of cement production"
  feli_cement             "liquids energy use of cement production"
  fega_cement             "gases energy use of cement production"
  feh2_cement             "hydrogen energy use of cement production"
  feel_cement             "electricity energy use of cement production"
 

  ue_chemicals            "useful energy of chemicals production"
  en_chemicals            "energy use of chemicals production"
  kap_chemicals           "energy efficiency capital of chemicals production"
  en_chemicals_fhth       "feedstock and high temperature heat enery use of chemicals production"
  feso_chemicals          "solids energy use of cement production"
  feli_chemicals          "liquids energy use of chemicals production"
  fega_chemicals          "gases energy use of chemicals production"
  feh2_chemicals          "hydrogen energy use of chemicals production"
  feelhth_chemicals       "high temperature heat electricity energy use of chemicals production"
  feelwlth_chemicals      "work and low temperature heat electricity energy use of chemicals production"

  ue_steel                "useful energy of steel production"
  ue_steel_primary        "useful energy of primary steel production"
  ue_steel_secondary      "useful energy of secondary steel production"
  en_steel_primary        "energy use of primary steel production"
  kap_steel_primary       "energy efficiency capital of primary steel production"
  kap_steel_secondary     "energy efficiency capital of secondary steel production"
  en_steel_furnace        "non-electric energy use of primary steel production"
  feso_steel              "solids energy use of primary steel production"
  feli_steel              "liquids energy use of primary steel production"
  fega_steel              "gases energy use of primary steel production"
  feh2_steel              "hydrogen energy use of primary steel production"
  feel_steel_primary      "electricity energy use pf primary steel production"
  feel_steel_secondary    "electricity energy use of secondary steel production"

  ue_otherInd             "useful energy of other industry production"
  en_otherInd             "energy use of other industry production"
  kap_otherInd            "energy efficiency capital of other industry production"
  en_otherInd_hth         "non-electric energy use of other industry production"
  feso_otherInd           "solids energy use of other industry production"
  feli_otherInd           "liquids energy use of other industry production"
  fega_otherInd           "gases energy use of other industry production"
  feh2_otherInd           "hydrogen energy use of other industry production"
  fehe_otherInd           "heat energy use of other industry production"
  feelhth_otherInd        "high temperature heat electricity energy use of other industry production"
  feelwlth_otherInd       "work and low temperature heat electricity energy use of other industry production"
/

all_teEs                 "energy service technologies"
/
*** transport module
    te_espet_pass_sm "short-to-medium distance passenger transport CES node"
    te_esdie_pass_sm "short-to-medium distance passenger transport CES node"
    te_eselt_pass_sm "short-to-medium distance passenger transport CES node"
    te_esh2t_pass_sm "short-to-medium distance passenger transport CES node"
    te_esgat_pass_sm "short-to-medium distance passenger transport CES node"
    te_esdie_pass_lo "long distance passenger transport (aviation) CES node"
    te_esdie_frgt_sm "short-to-medium distance freight transport CES node"
    te_eselt_frgt_sm "short-to-medium distance freight transport CES node"
    te_esh2t_frgt_sm "short-to-medium distance freight transport CES node"
    te_esgat_frgt_sm "short-to-medium distance freight transport CES node"
    te_esdie_frgt_lo "long distance freight transport CES node" 

*** Buildings module
    te_ueshheb  "buildings space heating district heat"
    te_ueshhob  "buildings space heating liquids"
    te_ueshsob  "buildings space heating solids"
    te_ueshstb  "buildings space heating traditional solids"
    te_ueshgab  "buildings space heating district heat"
    te_ueshh2b  "buildings space heating hydrogen"
    te_ueshelb  "buildings space heating electricity resistance"
    te_ueshhpb  "buildings space heating electricity heat pump"
    
    te_uecwhob  "buildings cooking and water heating liquids"
    te_uecwsob  "buildings cooking and water heating solids"
    te_uecwstb  "buildings cooking and water heating traditional solids"
    te_uecwgab  "buildings cooking and water heating gas"
    te_uecwheb  "buildings cooking and water heating district heat"
    te_uecwh2b  "buildings cooking and water heating hydrogen"
    te_uecwelb  "buildings cooking and water heating electricity"
    te_uecwhpb  "buildings cooking and water heating heat pump" 
/

teEs(all_teEs)           "ES technologies which are actually used (to be filled by module realizations)."
//

;

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***                 Definition of region sets
***-----------------------------------------------------------------------------


***-----------------------------------------------------------------------------
***###############################################################################
***######################## R SECTION START (SETS) ###############################
*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY
*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT INPUT DOWNLOAD
*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start_functions.R

sets

   all_regi "all regions" /LAM,OAS,SSA,EUR,NEU,MEA,REF,CAZ,CHA,IND,JPN,USA/

   ext_regi "extended regions list (includes subsets of H12 regions)" / LAM_regi,OAS_regi,SSA_regi,EUR_regi,NEU_regi,MEA_regi,REF_regi,CAZ_regi,CHA_regi,IND_regi,JPN_regi,USA_regi,LAM,OAS,SSA,EUR,NEU,MEA,REF,CAZ,CHA,IND,JPN,USA /

   regi_group(ext_regi,all_regi) "region groups (regions that together corresponds to a H12 region)"
      /
        LAM_regi .(LAM)
        OAS_regi .(OAS)
        SSA_regi .(SSA)
        EUR_regi .(EUR)
        NEU_regi .(NEU)
        MEA_regi .(MEA)
        REF_regi .(REF)
        CAZ_regi .(CAZ)
        CHA_regi .(CHA)
        IND_regi .(IND)
        JPN_regi .(JPN)
        USA_regi .(USA)
      /
 
   iso "list of iso countries" /
       ABW,AFG,AGO,AIA,ALA,ALB,AND,ARE,ARG,ARM,
       ASM,ATA,ATF,ATG,AUS,AUT,AZE,BDI,BEL,BEN,
       BES,BFA,BGD,BGR,BHR,BHS,BIH,BLM,BLR,BLZ,
       BMU,BOL,BRA,BRB,BRN,BTN,BVT,BWA,CAF,CAN,
       CCK,CHN,CHE,CHL,CIV,CMR,COD,COG,COK,COL,
       COM,CPV,CRI,CUB,CUW,CXR,CYM,CYP,CZE,DEU,
       DJI,DMA,DNK,DOM,DZA,ECU,EGY,ERI,ESH,ESP,
       EST,ETH,FIN,FJI,FLK,FRA,FRO,FSM,GAB,GBR,
       GEO,GGY,GHA,GIB,GIN,GLP,GMB,GNB,GNQ,GRC,
       GRD,GRL,GTM,GUF,GUM,GUY,HKG,HMD,HND,HRV,
       HTI,HUN,IDN,IMN,IND,IOT,IRL,IRN,IRQ,ISL,
       ISR,ITA,JAM,JEY,JOR,JPN,KAZ,KEN,KGZ,KHM,
       KIR,KNA,KOR,KWT,LAO,LBN,LBR,LBY,LCA,LIE,
       LKA,LSO,LTU,LUX,LVA,MAC,MAF,MAR,MCO,MDA,
       MDG,MDV,MEX,MHL,MKD,MLI,MLT,MMR,MNE,MNG,
       MNP,MOZ,MRT,MSR,MTQ,MUS,MWI,MYS,MYT,NAM,
       NCL,NER,NFK,NGA,NIC,NIU,NLD,NOR,NPL,NRU,
       NZL,OMN,PAK,PAN,PCN,PER,PHL,PLW,PNG,POL,
       PRI,PRK,PRT,PRY,PSE,PYF,QAT,REU,ROU,RUS,
       RWA,SAU,SDN,SEN,SGP,SGS,SHN,SJM,SLB,SLE,
       SLV,SMR,SOM,SPM,SRB,SSD,STP,SUR,SVK,SVN,
       SWE,SWZ,SXM,SYC,SYR,TCA,TCD,TGO,THA,TJK,
       TKL,TKM,TLS,TON,TTO,TUN,TUR,TUV,TWN,TZA,
       UGA,UKR,UMI,URY,USA,UZB,VAT,VCT,VEN,VGB,
       VIR,VNM,VUT,WLF,WSM,YEM,ZAF,ZMB,ZWE /

   regi2iso(all_regi,iso) "mapping regions to iso countries"
      /
       LAM . (ABW,AIA,ARG,ATA,ATG,BES,BHS,BLM,BLZ,BMU)
       LAM . (BOL,BRA,BRB,BVT,CHL,COL,CRI,CUB,CUW,CYM)
       LAM . (DMA,DOM,ECU,FLK,GLP,GRD,GTM,GUF,GUY,HND)
       LAM . (HTI,JAM,KNA,LCA,MAF,MEX,MSR,MTQ,NIC,PAN)
       LAM . (PER,PRI,PRY,SGS,SLV,SUR,SXM,TCA,TTO,URY)
       LAM . (VCT,VEN,VGB,VIR)
       OAS . (AFG,ASM,ATF,BGD,BRN,BTN,CCK,COK,CXR,FJI)
       OAS . (FSM,GUM,IDN,IOT,KHM,KIR,KOR,LAO,LKA,MDV)
       OAS . (MHL,MMR,MNG,MNP,MYS,NCL,NFK,NIU,NPL,NRU)
       OAS . (PAK,PCN,PHL,PLW,PNG,PRK,PYF,SGP,SLB,THA)
       OAS . (TKL,TLS,TON,TUV,UMI,VNM,VUT,WLF,WSM)
       SSA . (AGO,BDI,BEN,BFA,BWA,CAF,CIV,CMR,COD,COG)
       SSA . (COM,CPV,DJI,ERI,ETH,GAB,GHA,GIN,GMB,GNB)
       SSA . (GNQ,KEN,LBR,LSO,MDG,MLI,MOZ,MRT,MUS,MWI)
       SSA . (MYT,NAM,NER,NGA,REU,RWA,SEN,SHN,SLE,SOM)
       SSA . (SSD,STP,SWZ,SYC,TCD,TGO,TZA,UGA,ZAF,ZMB)
       SSA . (ZWE)
       EUR . (ALA,AUT,BEL,BGR,CYP,CZE,DEU,DNK,ESP,EST)
       EUR . (FIN,FRA,FRO,GBR,GGY,GIB,GRC,HRV,HUN,IMN)
       EUR . (IRL,ITA,JEY,LTU,LUX,LVA,MLT,NLD,POL,PRT)
       EUR . (ROU,SVK,SVN,SWE)
       NEU . (ALB,AND,BIH,CHE,GRL,ISL,LIE,MCO,MKD,MNE)
       NEU . (NOR,SJM,SMR,SRB,TUR,VAT)
       MEA . (ARE,BHR,DZA,EGY,ESH,IRN,IRQ,ISR,JOR,KWT)
       MEA . (LBN,LBY,MAR,OMN,PSE,QAT,SAU,SDN,SYR,TUN)
       MEA . (YEM)
       REF . (ARM,AZE,BLR,GEO,KAZ,KGZ,MDA,RUS,TJK,TKM)
       REF . (UKR,UZB)
       CAZ . (AUS,CAN,HMD,NZL,SPM)
       CHA . (CHN,HKG,MAC,TWN)
       IND . (IND)
       JPN . (JPN)
       USA . (USA)
      /
iso_regi "all iso countries and EU and greater China region" /  EUR,CHA,
       ABW,AFG,AGO,AIA,ALA,ALB,AND,ARE,ARG,ARM,
       ASM,ATA,ATF,ATG,AUS,AUT,AZE,BDI,BEL,BEN,
       BES,BFA,BGD,BGR,BHR,BHS,BIH,BLM,BLR,BLZ,
       BMU,BOL,BRA,BRB,BRN,BTN,BVT,BWA,CAF,CAN,
       CCK,CHN,CHE,CHL,CIV,CMR,COD,COG,COK,COL,
       COM,CPV,CRI,CUB,CUW,CXR,CYM,CYP,CZE,DEU,
       DJI,DMA,DNK,DOM,DZA,ECU,EGY,ERI,ESH,ESP,
       EST,ETH,FIN,FJI,FLK,FRA,FRO,FSM,GAB,GBR,
       GEO,GGY,GHA,GIB,GIN,GLP,GMB,GNB,GNQ,GRC,
       GRD,GRL,GTM,GUF,GUM,GUY,HKG,HMD,HND,HRV,
       HTI,HUN,IDN,IMN,IND,IOT,IRL,IRN,IRQ,ISL,
       ISR,ITA,JAM,JEY,JOR,JPN,KAZ,KEN,KGZ,KHM,
       KIR,KNA,KOR,KWT,LAO,LBN,LBR,LBY,LCA,LIE,
       LKA,LSO,LTU,LUX,LVA,MAC,MAF,MAR,MCO,MDA,
       MDG,MDV,MEX,MHL,MKD,MLI,MLT,MMR,MNE,MNG,
       MNP,MOZ,MRT,MSR,MTQ,MUS,MWI,MYS,MYT,NAM,
       NCL,NER,NFK,NGA,NIC,NIU,NLD,NOR,NPL,NRU,
       NZL,OMN,PAK,PAN,PCN,PER,PHL,PLW,PNG,POL,
       PRI,PRK,PRT,PRY,PSE,PYF,QAT,REU,ROU,RUS,
       RWA,SAU,SDN,SEN,SGP,SGS,SHN,SJM,SLB,SLE,
       SLV,SMR,SOM,SPM,SRB,SSD,STP,SUR,SVK,SVN,
       SWE,SWZ,SXM,SYC,SYR,TCA,TCD,TGO,THA,TJK,
       TKL,TKM,TLS,TON,TTO,TUN,TUR,TUV,TWN,TZA,
       UGA,UKR,UMI,URY,USA,UZB,VAT,VCT,VEN,VGB,
       VIR,VNM,VUT,WLF,WSM,YEM,ZAF,ZMB,ZWE /

   map_iso_regi(iso_regi,all_regi) "mapping from iso countries to regions that represent country" 
         /
       EUR . EUR
       CHA . CHA
       IND . IND
       JPN . JPN
       USA . USA
      /
;
***######################### R SECTION END (SETS) ################################
***###############################################################################

*** FS: definition of regional sensitivity/scenario sets

$IFTHEN.RegScenNuc "%c_regi_nucscen%" == "all"
  set regi_nucscen(all_regi) "regions which nucscen applies to";
  regi_nucscen(all_regi)=YES;
$ELSE.RegScenNuc
  set regi_nucscen(all_regi) "regions which nucscen applies to" / %c_regi_nucscen% /;
$ENDIF.RegScenNuc

$IFTHEN.RegScenCapt "%c_regi_capturescen%" == "all"
  set regi_capturescen(all_regi) "regions which capturescen applies to";
  regi_capturescen(all_regi)=YES;
$ELSE.RegScenCapt
  set regi_capturescen(all_regi) "regions which capturescen applies to" / %c_regi_capturescen% /;
$ENDIF.RegScenCapt

$IFTHEN.RegScenSens "%c_regi_sensscen%" == "all"
  set regi_sensscen(all_regi) "regions which regional sensitivity parameters apply to";
  regi_sensscen(all_regi)=YES;
$ELSE.RegScenSens
  set regi_sensscen(all_regi) "regions which regional sensitivity parameters apply to" / %c_regi_sensscen% /;
$ENDIF.RegScenSens

*** definition of set of regions that use alternative FE emission factors from umweltbundesamt
$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off" 
set
  altFeEmiFac_regi(ext_regi)  "set of regions that use alternative FE emission factors from umweltbundesamt" 
  /
    %cm_altFeEmiFac%
  /
;
$endif.altFeEmiFac 

***###############################################################################
***######################## R SECTION START (MODULES) ###############################
*** THIS CODE IS CREATED AUTOMATICALLY, DO NOT MODIFY THESE LINES DIRECTLY
*** ANY DIRECT MODIFICATION WILL BE LOST AFTER NEXT MODEL START
*** CHANGES CAN BE DONE USING THE RESPECTIVE LINES IN scripts/start_functions.R

sets

       modules "all the available modules"
       /
       macro
       welfare
       PE_FE_parameters
       initialCap
       aerosols
       climate
       downscaleTemperature
       growth
       tax
       subsidizeLearning
       capitalMarket
       trade
       agCosts
       CES_parameters
       biomass
       fossil
       power
       CDR
       transport
       buildings
       industry
       stationary
       CCU
       techpol
       emicapregi
       banking
       carbonprice
       regipol
       damages
       internalizeDamages
       water
       optimization
       codePerformance
       /

module2realisation(modules,*) "mapping of modules and active realisations" /
       macro . %macro%
       welfare . %welfare%
       PE_FE_parameters . %PE_FE_parameters%
       initialCap . %initialCap%
       aerosols . %aerosols%
       climate . %climate%
       downscaleTemperature . %downscaleTemperature%
       growth . %growth%
       tax . %tax%
       subsidizeLearning . %subsidizeLearning%
       capitalMarket . %capitalMarket%
       trade . %trade%
       agCosts . %agCosts%
       CES_parameters . %CES_parameters%
       biomass . %biomass%
       fossil . %fossil%
       power . %power%
       CDR . %CDR%
       transport . %transport%
       buildings . %buildings%
       industry . %industry%
       stationary . %stationary%
       CCU . %CCU%
       techpol . %techpol%
       emicapregi . %emicapregi%
       banking . %banking%
       carbonprice . %carbonprice%
       regipol . %regipol%
       damages . %damages%
       internalizeDamages . %internalizeDamages%
       water . %water%
       optimization . %optimization%
       codePerformance . %codePerformance%
      /
;
***######################### R SECTION END (MODULES) ################################
***###############################################################################

sets

regi(all_regi)  "all regions used in the solution process"   

*** region sets used for MAGICC
RCP_regions_world_bunkers "five RCP regions plus total (world) and bunkers"
/
  WORLD
  R5OECD
  R5REF
  R5ASIA
  R5MAF
  R5LAM
  BUNKERS
/

RCP_regions_world(RCP_regions_world_bunkers) "five RCP regions plus total (world)"
/
  WORLD
  R5OECD
  R5REF
  R5ASIA
  R5MAF
  R5LAM
  BUNKERS
/
;

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***   Miscellaneous sets
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
Sets 
  counter   "helper set to facilitate looping in defined order"   / 1 * 20 /
;

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***   Definition of time-related sets
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------

SETS
tall            "time index"
        /
        1900*3000
        /

*LB* Different time-steps are used for the flags cm_less_TS (default), test_TS, 
*** and END2110. If none of these flags is set, five year steps are used.
*** test_TS: 2005,2010,2020,2030,2040,2050,2070,2090,2110,2130,2150
*** cm_less_TS: 2005,2010,2015,2020,2025,2030,2035,2040,2045,2050,2055,2060,
*** 2070,2080,2090,2100,2110,2130,2150
*** END2110: 2005:5:2105,2120
*AJS* Defining ttot as sum of t and tsu will give errors from compiler, so do 
*** it manually instead: 
ttot(tall)      "time index with spin up"
/
        1900, 1905, 1910, 1915, 1920, 1925,
        1930, 1935, 1940, 1945, 1950, 1955,
        1960, 1965, 1970, 1975, 1980, 1985,
        1990, 1995,
        2000, 2005, 2010,
$if not setGlobal test_TS   2015,
                            2020,
$if not setGlobal test_TS   2025,
                            2030,
$if not setGlobal test_TS   2035,
                            2040,
$if not setGlobal test_TS   2045,
                            2050,
$if not setGlobal test_TS   2055,
$if not setGlobal test_TS   2060,
$if not setGlobal test_TS $if %cm_less_TS% == "off"  2065,
                            2070,
$if not setGlobal test_TS $if %cm_less_TS% == "off"  2075,
$if not setGlobal test_TS   2080,
$if not setGlobal test_TS $if %cm_less_TS% == "off"  2085,
                            2090,
$if not setGlobal test_TS $if %cm_less_TS% == "off"  2095,
$if not setGlobal test_TS   2100,
$if not setGlobal test_TS $if %cm_less_TS% == "off"  2105,
$if setGlobal END2110       2120
$if not setGlobal END2110 $if setGlobal test_TS  2110, 2130, 2150
$if not setGlobal END2110 $if %cm_less_TS% == "on"  2110, 2130, 2150
$if not setGlobal END2110 $if not setGlobal test_TS $if %cm_less_TS% == "off"  2110, 2115, 2120, 2125, 2130, 2135, 2140, 2145, 2150
/

$if not setGlobal test_TS $if %cm_less_TS% == "off" t_interpol(ttot)/ 2065,2075,2085,2095,2105,2115,2125,2135,2145/

*cb the content of those subsets is defined 16 lines further down
t(ttot) "modeling time, usually starting in 2005, but later for fixed delay runs",
tsu(ttot) "spin up-time before 2005",

opTimeYr            "actual life time of ??? in years"
/
        1*100
/
opTime5(opTimeYr)            "actual life time of ??? in years - 5 years time steps for the past to calculate vintages (???)"

/
        1,6,11,16,21,26,31,36,41,46,51,56,61,66,71,76,81,86,91,96
/
t0(tall)   "start of modelling time, not optimization" /2005/    

t_input_gdx(ttot)     "t loaded from input.gdx, used for t interpolation"
t_interpolate(ttot)   "periods that need interpolation"
;

t(ttot)$(ttot.val ge cm_startyear)=Yes;
tsu(ttot)$(ttot.val lt 2005)=Yes;
display ttot;

*** time sets used for MAGICC
Sets
  t_magiccttot(tall) "time periods including spin-up"
  t_magicc(tall)     "time periods exported to magicc"
  t_extra(tall)      "averaging between REMIND and MAGICC" / 2000 * 2004 /
;





***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***                 Definition of SETS of ESM
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------

***-----------------------------------------------------------------------------
*** Definition of the main technology set 'te':
***-----------------------------------------------------------------------------
SETS
te(all_te)              "energy technologies"
/
        ngcc            "natural gas combined cycle"
        ngccc           "natural gas combined cycle with capture"
        ngt             "natural gas turbine"
        gastr           "transformation of gases"
        gaschp          "combined heat and power using gas"
        gashp           "heating plant using gas"
        gash2           "gas to hydrogen"
        gash2c          "gas to hydrogen with carbon capture"
        gasftrec        "gas based fischer-tropsch recycle"
        gasftcrec       "gas based fischer-tropsch with capture recycle"		
        refliq          "refinery oil to SE liquids"
        dot             "diesel oil turbine"
        igcc            "integrated coal gasification combined cycle"
        igccc           "integrated coal gasification combined cycle with carbon capture"
        pc              "pulverised coal power plant"
$ifthen setGlobal cm_ccsfosall
        pcc             "pulverised coal power plant with capture"
        pco             "pulverised coal power plant with oxyfuel capture"
$endif
        coalchp         "combined heat powercoal"
        coalhp          "heating plant coal"
        coaltr          "tranformation of coal"
        coalgas         "coal gasification"
        coalftrec       "coal based fischer-tropsch recycle"
        coalftcrec      "coal based fischer-tropsch with capture recycle"
        coalh2          "coal to hydrogen"
        coalh2c         "coal to hydrogen with capture"
        biotr           "transformation of biomass"
        biotrmod        "modern solids from biomass"
        biochp          "biomass combined heat and power"
        biohp           "biomass heating plant"
        bioigcc         "integrated biomass gasification combined cycle"
        bioigccc        "integrated biomass gasification combined cycle with CCS"
        biogas          "gasification of biomass"
        bioftrec        "biomass based fischer-tropsch recycle"
        bioftcrec       "biomass based fischer-tropsch with capture recycle"
        bioh2           "biomass to hydrogen"
        bioh2c          "biomass to hydrogen with capture"
        bioethl         "biomass to ethanol"
        bioeths         "sugar and starch biomass to ethanol"
        biodiesel       "oil biomass to biodiesel"
        geohdr          "geothermal electric hot dry rock"
        geohe           "geothermal heat"
        hydro           "hydro electric"
        wind            "wind power converters"
        spv             "solar photovoltaic"
        csp             "concentrating solar power"
        solhe           "solar thermal heat generation"
        tnrs            "thermal nuclear reactor (simple structure)"
        fnrs            "fast nuclear reactor (simple structure)"
        elh2            "hydrogen elecrolysis"
        h2turb          "hydrogen turbine for electricity production"
		elh2VRE         "dummy technology: hydrogen electrolysis; to demonstrate the capacities and SE flows inside the storXXX technologies"
        h2turbVRE       "dummy technology: hydrogen turbine for electricity production; to demonstrate the capacities and SE flows inside the storXXX technologies"
        h2curt      	"hydrogen production from curtailment"
        tdels           "transmission and distribution for electricity to stationary users"
        tdelt           "transmission and distribution for electricity to transport"
        tdbiogas        "transmission and distribution for gas from biomass origin to stationary users"
        tdfosgas        "transmission and distribution for gas from fossil origin to stationary users"
        tdbiogat        "transmission and distribution for gas from biomass origin to transportation"
        tdfosgat        "transmission and distribution for gas from biomass origin to transportation"
        tdbiohos        "transmission and distribution for heating oil from biomass origin to stationary users"
        tdfoshos        "transmission and distribution for heating oil from fossil origin to stationary users"
        tdh2s           "transmission and distribution for hydrogen to stationary users"
        tdh2t           "transmission and distribution for hydrogen to transportation"
        tdbiodie        "transmission and distribution for diesel from biomass origin to stationary users"
        tdfosdie        "transmission and distribution for diesel from fossil origin to stationary users"
        tdbiopet        "transmission and distribution for petrol from biomass origin to stationary users"
		tdfospet        "transmission and distribution for petrol from fossil origin to stationary users"
        tdbiosos        "transmission and distribution for solids from biomass origin to stationary users"
        tdfossos        "transmission and distribution for solids from fossil origin to stationary users"
        tdhes           "transmission and distribution for heat to stationary users"

*        ccscomp         "compression of co2, CCS related"
*        ccspipe         "transportation of co2, CCS related"
        ccsinje         "injection of co2, CCS related"
*        ccsmoni         "monitoring of co2, CCS related"

        storspv         "storage technology for photo voltaic"
        storwind        "storage technology for wind"
        storcsp         "storage technology for concentrating solar power"

        gridspv         "grid between areas with high pv production and the rest"
        gridcsp         "grid between areas with high csp production and the rest"
        gridwind        "grid between areas with high wind production and the rest"
/
teAdj(all_te)           "technologies with adjustment costs on capacity additions"
/
  ngcc            "natural gas combined cycle"
  ngccc           "natural gas combined cycle with capture"
  ngt             "natural gas turbine"
  gastr           "transformation of gases"
  gaschp          "combined heat and power plant using gas"
  gashp           "heating plant using gas"
  gash2           "gas to hydrogen"
  gash2c          "gas to hydrogen with capture"
  gasftrec        "gas based fischer-tropsch recycle"
  gasftcrec       "gas based fischer-tropsch with capture recycle"  
  dot             "diesel oil turbine"
  igcc            "integrated coal gasification combined cycle"
  igccc           "integrated coal gasification combined cycle with capture"
  pc              "pulverised coal power plant"
$ifthen setGlobal cm_ccsfosall
  pcc             "pulverised coal power plant with capture"
  pco             "pulverised coal power plant with oxyfuel capture"
$endif
  coalchp         "combined heat powercoal"
  coalhp          "heating plant coal"
  coaltr          "tranformation of coal"
  coalgas         "coal gasification"
  coalftrec       "coal based fischer-tropsch recycle"
  coalftcrec      "coal based fischer-tropsch with capture recycle"
  coalh2          "coal to hydrogen"
  coalh2c         "coal to hydrogen with capture"
  biotr           "transformation of biomass"
  biotrmod        "modern solids from biomass"
  biochp          "heating plant bio"
  biohp           "heating plant bio"
  bioigcc         "integrated biomass gasification combined cycle"
  bioigccc        "integrated biomass gasification combined cycle with CCS"
  biogas          "gasification of biomass"
  bioftrec        "biomass based fischer-tropsch recycle"
  bioftcrec       "biomass based fischer-tropsch with capture recycle"
  bioh2           "biomass to hydrogen"
  bioh2c          "biomass to hydrogen with capture"
  bioethl         "biomass to ethanol"
  bioeths         "sugar and starch biomass to ethanol"
  biodiesel       "oil biomass to biodiesel"
  geohdr          "geothermal electric hot dry rock"
  geohe           "geothermal heat"
  hydro           "hydro electric"
  wind            "wind power converters"
  spv             "solar photovoltaic"
  csp             "concentrating solar power"
  solhe           "solar thermal heat generation"
  tnrs            "thermal nuclear reactor (simple structure)"
  fnrs            "fast nuclear reactor (simple structure)"
  elh2            "hydrogen elecrolysis"
  h2turb          "hydrogen turbine for electricity production"
  h2curt      	  "hydrogen production from curtailment"
*** ccscomp         "compression of co2, CCS related"
*** ccspipe         "transportation of co2, CCS related"
  ccsinje         "injection of co2, CCS related"
*** ccsmoni         "monitoring of co2, CCS related"

  storspv         "storage technology for PV"
  storwind        "storage technology for wind"
  storcsp         "storage technology for CSP"
  
  refliq          "refinery oil to SE liquids"
  
  gridspv         "grid between areas with high pv production and the rest"
  gridcsp         "grid between areas with high csp production and the rest"
  gridwind        "grid between areas with high wind production and the rest"
/

***-----------------------------------------------------------------------------
*** Definition of subsets of 'te':
***-----------------------------------------------------------------------------

teRLDCDisp(all_te)     "RLDC Dispatchable technologies that produce seel"
/
/

teLearn(all_te)     "Learning technologies (investment costs can be reduced)"
/
        wind        "wind power converters"
        spv         "solar photovoltaic" 
        csp         "concentrating solar power"
        storspv     "storage technology for spv"
        storwind    "storage technology for wind"
        storcsp     "storage technology for csp"
        dac         "direct air capture"
        elh2        "hydrogen elecrolysis"
/

teNoLearn(all_te)   "Technologies without learning effect"

teEtaIncr(all_te)       "Technologies with time variable efficiency parameter eta"   
*RP* computationally the explicit build-time tracking for teEtaIncr is expensive. Therefore, I removed the heating plants, because there the efficiency is anyway high and doesn't have such a large influence
/
  pc    
  igcc  
  igccc 
  ngcc  
  ngccc 
  ngt   
  bioigcc
  bioigccc
/

teEtaConst(all_te)      "Technologies with constant eta"

teCCS(all_te)       "Technologies with CCS"
/
  ngccc       "natural gas combined cycle with carbon capture"
  gash2c      "gas to hydrogen with capture"     
  igccc       "integrated coal gasification combined cycle with carbon capture"
$ifthen setGlobal cm_ccsfosall
  pcc         "pulverized coal power plant with capture"
  pco         "pulverized coal power plant with oxyfuel capture"
$endif
  coalftcrec  "coal based fischer-tropsch with capture recycle"
  coalh2c     "coal to hydrogen with capture"
  bioftcrec   "biomass based fischer-tropsch with capture recycle"
  bioh2c      "biomass to hydrogen with capture"
  bioigccc    "integrated biomass gasification combined cycle with CCS"
/

teNoCCS(all_te)     "Technologies without CCS"

teChp(all_te)       "Technologies that produce seel as main output und sehe as secondary output - dynamically defined"

teBio(all_te)      "biomass energy systems technologies"
/
        biotr       "transformation of biomass"
        biotrmod    "modern solids from biomass"
        biochp      "biomass combined heat and power"
        biohp       "biomass heating plant"
        bioigcc     "integrated biomass gasification combined cycle"
        bioigccc    "integrated biomass gasification combined cycle with CCS"
        biogas      "gasification of biomass"
        bioftrec    "biomass based fischer-tropsch recycle"
        bioftcrec   "biomass based fischer-tropsch with capture recycle"
        bioh2       "biomass to hydrogen"
        bioh2c      "biomass to hydrogen with capture"
        bioethl     "biomass to ethanol"
        bioeths     "sugar and starch biomass to ethanol"
        biodiesel   "oil biomass to biodiesel"
/
teRe(all_te)     "renewable technologies including biomass"
/
        biotr       "transformation of biomass"
        biotrmod    "modern solids from biomass"
        biochp      "biomass combined heat and power"
        biohp       "biomass heating plant"
        bioigcc     "integrated biomass gasification combined cycle"
        bioigccc    "integrated biomass gasification combined cycle with CCS"
        biogas      "gasification of biomass"
        bioftrec    "biomass based fischer-tropsch recycle"
        bioftcrec   "biomass based fischer-tropsch with capture recycle"
        bioh2       "biomass to hydrogen"
        bioh2c      "biomass to hydrogen with capture"
        bioethl     "biomass to ethanol"
        bioeths     "sugar and starch biomass to ethanol"
        biodiesel   "oil biomass to biodiesel"
        geohdr      "geothermal electric hot dry rock"
        geohe       "geothermal heat"
        hydro       "hydro electric"
        wind        "wind power converters"
        spv         "solar photovoltaic"
        csp         "concentrating solar power"
        solhe       "solar thermal heat generation"
/
teReNoBio(all_te) "renewable technologies except for biomass"
/
        geohdr      "geothermal electric hot dry rock"
        geohe       "geothermal heat"
        hydro       "hydro electric"
        wind        "wind power converters"
        spv         "solar photovoltaic"
        csp         "concentrating solar power"
***        solhe       "solar thermal heat generation"
/
teNoRe(all_te)        "Non renewable energy technologies"

teVRE(all_te)      "technologies requiring storage"
/
        wind        "wind power converters"
        spv         "solar photovoltaic"
        csp         "concentrating solar power"
/

teStor(all_te)        "storage technologies"
/
        storspv     "storage technology for spv"
        storwind    "storage technology for wind"
        storcsp     "storage technology for csp"
/
teLoc(all_te)      "centralized technologies which require grid"
/
        wind        "wind power converters"
        spv         "solar photovoltaic"
        csp         "concentrating solar power"
/
teGrid(all_te)      "grid between areas"
/
    gridspv     "grid between areas with high pv production and the rest"
    gridcsp     "grid between areas with high csp production and the rest"
    gridwind    "grid between areas with high wind production and the rest"
/
teFosCCS(all_te)    "fossil technologies with CCS"
/
        ngccc       "natural gas combined cycle with carbon capture"
	gash2c      "gas to hydrogen with capture"     
        gasftcrec       "gas based fischer-tropsch with capture recycle"
        igccc       "integrated coal gasification combined cycle with carbon capture"
$ifthen setGlobal cm_ccsfosall
        pcc         "pulverized coal power plant with capture"
        pco         "pulverized coal power plant with oxyfuel capture"
$endif
        coalftcrec  "coal based fischer-tropsch with capture recycle"
        coalh2c     "coal to hydrogen with capture"
/
teFosNoCCS(all_te)  "fossil technologies without CCS"
/
        ngcc         "natural gas combined cycle"
        gash2        "gas to hydrogen"
        igcc         "integrated coal gasification combined cycle"
        pc           "pulverized coal power plant"
        coalftrec    "coal based Fisher-Tropsch recycle"
        coalh2       "coal to hydrogen"
        ngt          "natural gas turbine"
        gastr        "transformation of gases"
        gaschp       "gas combined heat and power"
        gashp        "gas heating plant"
        dot          "diesel oil turbine"
        coalchp      "coal combined heat and power"
        coalhp       "coal heating plant"
        coalgas      "coal gasification"
        coaltr       "transformation of coal"
$IF %cm_OILRETIRE% == "on"   refliq
/
teBioPebiolc(all_te)      "biomass technologies using pebiolc"
/
        biotr
        biotrmod
        biochp
        biohp
        bioigcc
        bioigccc
        biogas
        bioftrec
        bioftcrec
        bioh2
        bioh2c
        bioethl
/
teNoTransform(all_te) "all technologies that do not transform energy but still have investment and O&M costs (like storage or grid)"
/
       storspv       "storage technology for photo voltaic (PV)"
       storwind      "storage technology for wind"
       storcsp       "storage technology for concentrating solar power (CSP)"

       gridspv       "grid between areas with high pv production and the rest"
       gridcsp       "grid between areas with high csp production and the rest"
       gridwind      "grid between areas with high wind production and the rest"   
/
teRegTechCosts(all_te) "all technologies for which we differantiate tech costs"
/
       pc
       igcc      
       ngcc       
       ngt
       gaschp       
       pcc       
       pco
       igccc
       ngccc
       tnrs
       bioigcc
       biogas
       biochp
       geohdr
       hydro
       spv
       csp
       wind      
/

teFlex(all_te)       "all technologies which can benefit from flexibility tax"
/
elh2
***dac
/


teFlexTax(all_te)       "all technologies to which flexibility tax/subsidy applies, flexible technologies are those in teFlex, inflexible technologies those which are not in teFlex"
/
elh2
tdels
/

feForUe(all_enty)    "final energy types that are transformed into useful energys - is filled automatically from the content of fe2ue"
ppfenFromUe(all_in)  "all ppfEn that are equivalent to UE - is filled automatically from the content of fe2ue"

feForEs(all_enty)    "final energy types that are transformed into final energys - is filled automatically from the content of fe2es"
ppfenFromEs(all_in)  "all ppfEn that are equivalent to ES - is filled automatically from the content of fe2ue"
feViaEs2ppfen(all_enty,all_in,all_teEs) "map final energies to the primar production factor - is filled automatically from the content of fe2es and es2ppfen"

fe2ppfEn(all_enty,all_in) "mapping between CES FE variables and ESM FE variables" /  /
***-----------------------------------------------------------------------------
*** Definition of the main set of quantities 'enty':
***-----------------------------------------------------------------------------


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
        sesobio      "secondary energy solids from biomass"
		sesofos      "secondary energy solids from fossil primary energy"
        seel         "secondary energy electricity"
        seh2         "secondary energy hydrogen"
        segabio      "secondary energy gas from biomass"
		segafos      "secondary energy gas from fossil primary energy"
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

        !! emissions from industry sub-sectors
        co2cement      "CO2 emissions from clinker and cement production"
        co2chemicals   "CO2 emissions from chemicals production"
        co2steel       "CO2 emissions from steel production"
/

***-----------------------------------------------------------------------------
*** Definition of subsets of 'enty':
***-----------------------------------------------------------------------------
entyPe(all_enty)      "Primary energy types (PE)"
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
/
peBio(all_enty)      "biomass primary energy types"
/
        pebiolc      "PE biomass lignocellulosic"
        pebios       "PE biomass sugar and starch"
        pebioil      "PE biomass sunflowers, palm oil, etc"
/
peRe(all_enty)    "Renewable primary energy sources"
/
        pegeo        "PE geothermal"
        pehyd        "PE hydropower"
        pewin        "PE wind"
        pesol        "PE solar"
        pebiolc      "PE biomass lignocellulosic"
        pebios       "PE biomass sugar and starch"
        pebioil      "PE biomass sunflowers, palm oil, etc"
/
peFos(all_enty)      "primary energy fossil fuels"
/
        peoil        "PE oil"
        pegas        "PE gas"
        pecoal       "PE coal"
/

peEx(all_enty)    "exhaustible primary energy carriers"
/
        peoil        "PE oil"
        pegas        "PE gas"
        pecoal       "PE coal"
        peur         "PE uranium"
/

peExPol(all_enty)   "primary energy fuels with polynomial"
/
        peur        "PE uranium"
/

peExGrade(all_enty) "exhaustible pe with step as entyPe ex-peExPol - s.b."

peRicardian(all_enty)    "Ricardian PE"

peReComp(all_enty) "Renewable PE used by several technologies, thus the competition between te is modeled by q_limitGeopot equation"
/
        pesol        "PE solar"
/

entySe(all_enty)       "secondary energy types"
/
        seliqbio     "secondary energy liquids from biomass"
		seliqfos     "secondary energy liquids from fossil primary energy"
        sesobio      "secondary energy solids from biomass"
		sesofos      "secondary energy solids from fossil primary energy"
        seel         "SE electricity"
        seh2         "SE hydrogen"
        segabio      "secondary energy gas from biomass"
		segafos      "secondary energy gas from fossil primary energy"
        sehe         "SE district heating nd heat pumps"
/

entySeBio(all_enty)       "biomass secondary energy types"
/
	seliqbio     "secondary energy liquids from biomass"
	sesobio      "secondary energy solids from biomass"
	segabio      "secondary energy gas from biomass"
/

entyFe(all_enty)      "final energy types. Calculated in sets_calculations"

esty(all_esty)      "energy service types. Have to be added by modules."
//
buildMoBio(all_esty) "modern biomass in buildings"
//
entyUe(all_enty)      "Useful energy types"
//

entyFeStat(all_enty)  "final energy types from stationary sector"
/
        fegas        "FE gas stationary"
        fehos        "FE heating oil stationary"
        fesos        "FE solids stationary"
        feels        "FE electricity stationary"
        fehes        "FE district heating (including combined heat and power), and heat pumps stationary"
        feh2s        "FE hydrogen stationary"
/
entyFeTrans(all_enty) "final energy types from transport sector"
/
        fepet        "FE petrol transport"
        fedie        "FE diesel transport"
        feh2t        "FE hydrogen transport"
	feelt        "FE electricity for transport"
/

feForCes(all_enty)   "limit q_balFeForCes to entyFe in fe2ppfEn"

emi(all_enty)      "types of emissions, these emissions are given to the climate module"

emiTe(all_enty)   "types of climate-relevant energy emissions for climate coupling and reporting"
/
        co2     "energy system co2"
        so2     "energy system so2"
        bc      "black carbon from fossil fuel combustion"
        oc      "organic carbon from fossil fuel combustion"
        ch4     "energy system ch4"
        n2o     "energy system n2o"
/
emiExog(all_enty)  "exogenous emissions"
/ 
        so2
        bc
        oc

/
emiAP(all_enty) "Used for allocation of emission factors"
/
        bc
        oc
/
emiMac(all_enty)  "sum over sub-emissions from emiMacSector"
/
        co2
        n2o
        ch4
/
emiMacSector(all_enty)  "types of climate-relevant non-energy emissions with mac curve. Emissions in this set HAVE to be in emiMac2mac as well - if no MAC is available it will be set to zero automatically."
/
        ch4coal    "fugitive emissions from coal mining"
        ch4gas     "fugitive emissions from gas production"
        ch4oil     "fugitive emissions from oil production"
        ch4wstl    "ch4 emissions from solid waste disposal on land"	
        ch4wsts    "ch4 emissions from waste water"	
        ch4rice    "ch4 emissions from rice cultivation (rice_ch4)"
        ch4animals "ch4 emissions from enteric fermentation of ruminants (ent_ferm_ch4)"
        ch4anmlwst "ch4 emissions from animal waste management(awms_ch4)"
        ch4agwaste "ch4 emissions from agricultural waste burning (no MAC available)"
        ch4forest  "ch4 emissions from forest burning (no MAC available)"
        ch4savan   "ch4 emissions from savannah burning (no MAC available)"
        n2oforest  "n2o emissions from forest burning (no MAC available)"
        n2osavan   "n2o emissions from savannah burning (no MAC available)"
        n2otrans   "n2o emissions from transport"
        n2oadac    "n2o emissions from adipic acid production"
        n2onitac   "n2o emissions from nitric acid production"				
        n2ofertin  "n2o emissions from Inorganic fertilizers (inorg_fert_n2o)"
        n2ofertcr  "n2o emissions from decay of crop residues (resid_n2o)"
        n2ofertsom "n2o emissions from soil organic matter loss (som_n2o)"
        n2oanwstc  "n2o emissions from manure applied to croplands (man_crop_n2o)"	
        n2oanwstm  "n2o emissions from animal waste management (awms_n2o)"
        n2oanwstp  "n2o emissions from manure excreted on pasture (man_past_n2o)"
        n2oagwaste "n2o emissions from agricultural waste burning (no MAC available)"		
        n2owaste   "n2o emissions from waste (domestic sewage)"
        co2luc     "co2 emissions from land use change"
        co2cement_process  "co2 from cement production (only process emissions)"
/

MacSector(all_enty)  "sectors for which mac curves exist. Some MACs are used for several emission sectors in emiMacSector."
/
        ch4coal    "coal mining"
        ch4gas     "gas production"
        ch4oil     "oil production"
        ch4wstl    "solid waste disposal on land"	
        ch4wsts    "waste water"	
        ch4rice    "rice cultivation"
        ch4animals "enteric fermentation of ruminants"
        ch4anmlwst "animal waste management"
        n2otrans   "transport"
        n2oadac    "adipic acid production"
        n2onitac   "nitric acid production"				
        n2ofert    "Inorganic fertilizers"
        n2oanwst   "manure applied to croplands"	
        n2owaste   "waste (domestic sewage)"
        co2luc     "land use change"
        co2cement  "cement production (only process emissions)"
        co2chemicals
        co2steel
/

MacSectorMagpie(all_enty)  "land-use sectors for which mac curves exist in REMIND and in MAgPIE"
/
        ch4rice    "rice cultivation"
        ch4animals "enteric fermentation of ruminants"
        ch4anmlwst "animal waste management"
        n2ofert    "Inorganic fertilizers"
        n2oanwst   "manure applied to croplands"	
        co2luc     "land use change"
/

emiMacMagpie(all_enty)  "types of climate-relevant non-energy emissions with mac curve where baseline emissions come from MAgPIE only"
emiMacMagpieN2O(all_enty)  "types of climate-relevant non-energy N2O emissions with mac curve where baseline emissions come from MAgPIE only"
/
        n2ofertin  "n2o emissions from Inorganic fertilizers (inorg_fert_n2o)"
        n2ofertcr  "n2o emissions from decay of crop residues (resid_n2o)"
        n2ofertsom "n2o emissions from soil organic matter loss (som_n2o)"
        n2oanwstc  "n2o emissions from manure applied to croplands (man_crop_n2o)"	
        n2oanwstm  "n2o emissions from animal waste management (awms_n2o)"
        n2oanwstp  "n2o emissions from manure excreted on pasture (man_past_n2o)"
/
emiMacMagpieCH4(all_enty)  "types of climate-relevant non-energy CH4 emissions with mac curve where baseline emissions come from MAgPIE only"
/
        ch4rice    "ch4 emissions from rice cultivation (rice_ch4)"
        ch4animals "ch4 emissions from enteric fermentation of ruminants (ent_ferm_ch4)"
        ch4anmlwst "ch4 emissions from animal waste management(awms_ch4)"	
/
emiMacMagpieCO2(all_enty)  "types of climate-relevant non-energy CH4 emissions with mac curve where baseline emissions come from MAgPIE only"
/
        co2luc     "co2 emissions from land use change"			
/

emiMacExo(all_enty)  "types of climate-relevant non-energy emissions with mac curve where baseline emissions are exogenous"
emiMacExoN2O(all_enty) "types of climate-relevant non-energy N2O emissions with mac curve where baseline emissions are exogenous"
/
        n2oforest  "n2o emissions from forest burning (no MAC available)"
        n2osavan   "n2o emissions from savannah burning (no MAC available)"
		n2oagwaste "n2o emissions from agricultural waste burning (no MAC available)"		
/
emiMacExoCH4(all_enty)  "types of climate-relevant non-energy CH4 emissions with mac curve where baseline emissions are exogenous"
/
        ch4agwaste "ch4 emissions from agricultural waste burning (no MAC available)"	
        ch4forest  "ch4 emissions from forest burning (no MAC available)"
        ch4savan   "ch4 emissions from savannah burning (no MAC available)"	
/

emiFuEx(all_enty)   "fugitive emissions"
/
        ch4coal    "fugitive emissions from coal mining"
        ch4gas     "fugitive emissions from gas production"
        ch4oil     "fugitive emissions from oil production"
/
sectorEndoEmi(all_sectorEmi)   "sectors with endogenous emissions"
/
        indst    "industry"
        res      "residential"
        trans    "transport"
        power    "power"
/
sectorExogEmi(all_sectorEmi) "sectors with exogenous emissions"
/
    solvents
    extraction
    indprocess
/
emi_sectors  "comprehensive sector set used for more detailed emissions accounting (REMIND-EU) and for CH4 tier 1 scaling - potentially to be integrated with similar set all_exogEmi"
/
        power   "public electricity and heat production"
        refining "petroleum refining"
        solids  "manufacture of solid fuels and other energy industries"
        extraction "fugitive emissions from fuel extraction"
        build   "Commercial sector, institutional sector and households"
        indst   "industry (including industrial processes)"
        trans   "transportation"
        agriculture "agriculture (plus forestry and fishing energy use)"
        waste   "waste management"
        cdr     "Transport, capture and storage of CO2"
        lulucf  "Land use,  land use change,  and forestry (LULUCF)"
        bunkers "International bunkers (maritime and aviation)"
        other   "other sectors and multilateral operations"
        indirect
/
sector_types "differentiation of energy and process emissions in each sector"
/
        energy "fuel combustion part (and emissions) of the sector activity"
        process "process sepecific part (and emissions) of the sector activity"
/

entyFe2Sector(all_enty,emi_sectors) "final energy (stationary and transportation) mapping to sectors (industry, buildings, transportation and cdr)"
/
		fegas.build
		fegas.indst
		fehos.build
		fehos.indst
		fesos.build
		fesos.indst
		feels.build
		feels.indst
		fehes.build
		fehes.indst
		feh2s.build
		feh2s.indst
		fepet.trans
		fedie.trans
		feh2t.trans
		feelt.trans
		feels.cdr
		fegas.cdr
		feh2s.cdr
/

ppfEn2Sector(all_in,emi_sectors) "primary energy production factors mapping to sectors"
/
		fegab.build
		fegai.indst
		fehob.build
		fehoi.indst
		fesob.build
		fesoi.indst
		feelb.build
		feeli.indst
		feheb.build
		fehei.indst
		feh2b.build
		feh2i.indst
		ueHDVt.trans
		ueLDVt.trans
		ueelTt.trans
/

all_emiMkt         "emission markets"
/	ETS     "ETS emission market"
	ES      "Effort sharing emission market"
	other	"other market configurations"	
/

sector2emiMkt(emi_sectors,all_emiMkt)  "mapping sectors to emission markets"
/
        indst.ETS
        indst.ES
        build.ES
        trans.ES
        trans.other
		cdr.ETS
/


macSector2emiMkt(all_enty,all_emiMkt)  "mapping mac sectors to emission markets"
/
        ch4coal.ETS      
        ch4gas.ETS       
        ch4oil.ETS       
        ch4wstl.ES       
        ch4wsts.ES       
        ch4rice.ES       
        ch4animals.ES    
        ch4anmlwst.ES    
        ch4agwaste.ES    
        ch4forest.other  
        ch4savan.other   
        n2oforest.other  
        n2osavan.other   
        n2otrans.ES      
        n2oadac.ETS      
        n2onitac.ETS     
        n2ofertin.ES     
        n2ofertcr.ES     
        n2ofertsom.other 
        n2oanwstc.ES     
        n2oanwstm.ES     
        n2oanwstp.ES     
        n2oagwaste.ES    
        n2owaste.ES      
        co2luc.other     
        co2cement_process.ETS 
/
ccsCo2(all_enty)    "only cco2 (???)"
/
        cco2
/
rlf             "cost levels of fossil fuels"
/ 
      1*12 
/
integ           "set of integers for looping etc"
/
	1*100
/
xirog       "parameters decribing exhaustible extraction coss including long-run marginal costs and short term adjustment costs"
/
      xi1, xi2, xi3, xi4, xi5, xi6, xi7, xi8
/
*** emissions exported to MAGICC
  emiRCP "emission types exported to MAGICC"
  /
    FossilCO2
    OtherCO2
    CH4
    N2O
    SOx
    CO
    NMVOC
    NOx
    BC
    OC
    NH3
    CF4
    C2F6
    C6F14
    HFC23
    HFC32
    HFC43-10
    HFC125
    HFC134a
    HFC143a
    HFC227ea
    HFC245fa
    SF6
  /

  p                "parameter for ch4 and n2o waste emissions and co2 cement emissions"
  /
  p1
  p2
  p3
  p4
  /
*** This is a work-around to ensure emissions are printed in correct order.
  numberEmiRCP "number of emission types" / 1 * 23 /

  unitsMagicc "units used for MAGICC"
  /
    GtC
    kt
    Mt
    MtCH4
    MtCO
    MtN
    MtN2O-N
    MtS
  /

***-----------------------------------------------------------------------------
*** Definition of the main characteristics set 'char':
***-----------------------------------------------------------------------------
char            "characteristics of technologies"
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

***-----------------------------------------------------------------------------
*** Definition of subsets of 'char':
***-----------------------------------------------------------------------------
charPeRe(char) "characteristics of renewables"
/
        cost       "marginal costs of production"
        maxprod    "maximum annual production"
/
s_statusTe   "technology status: how close a technology is to market readiness. Scale: 0-3, with 0 'I can go out and build a GW plant today' to 3 'Still some research necessary'"
/ 
      0 * 3 
/
;

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***                 Definition of SETS of MACRO
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------

Sets

  fe_tax_sub_sbi(all_in,all_in) "correspondence between tax and subsidy input data resolution and model sectoral resolution. For FE which takes the pathway I to the CES "
  //
  fe_tax_subEs(all_in,all_esty) "correspondence between tax and subsidy input data resolution and model sectoral resolution. For FE which takes the pathway III to the CES "
  //


***-------------------------------------------------------------------------------
***                 SETS for fragmented policy regimes
***-------------------------------------------------------------------------------
period1(tall) "first commitment period"
/
       2010,2015,2020
/
period2(tall) "second commitment period"
/
       2025,2030,2035,2040,2045,2050
/
period3(tall)"rest of century"
/
       2055,2060,2065,2070,2075,2080,2085,2090,2095,2100
/
period4(tall)      "period 4"
period12(tall)     "period 1 and 2"
period123(tall)    "period 1,2, and 3"
period1234(tall)   "period 1,2,3,and 4"

***-------------------------------------------------------------------------------
***                             HYBRID-SETS
***-------------------------------------------------------------------------------

sol_itr       "iterator for inner solution process within one Negishi iteration"
/
      1*10
/

iteration     "iterator for main (Negishi/Nash) iterations" 
/    
      1*200
/
steps         "iterator for MAC steps" 
/
      1*801
/
;

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***                             Helpful constructs: alias
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
alias(t,t2,t3);
alias(iteration,iteration2);
alias(tall,tall2,tall3);
alias(ttot,ttot2);
alias(opTimeYr,opTimeYr2);
alias(teVRE,teVRE2);
alias(teLoc,teLoc2);
alias(all_te,all_te2);
alias(te,te2,te3);
alias(all_enty,all_enty2);
alias(enty,enty2,enty3,enty4,enty5,enty6,enty7);
alias(entyPE,entyPE2);
alias(entySe,entySe2);
alias(entyFe,entyFe2);
alias(teEs,teEs2);
alias(esty,esty2);
alias(rlf,rlf2);
alias(regi,regi2);
alias(steps,steps2);
alias(all_emiMkt,emiMkt);
alias(emi_sectors,sector);
alias(sector_types,type)

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***                 Definition of  MAPPINGS
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
Sets

*NB* mappings resulting from set opertations
en2en(all_enty,all_enty,all_te)  "all energy conversion mappings"
en2en2(all_enty,all_enty,all_te) "alias of en2en: all energy conversion mappings"
en2se(all_enty,all_enty,all_te)   "all energy conversion mappings producing SE"
te2rlf(all_te,rlf)               "all technologies to grades"

pe2se(all_enty,all_enty,all_te) "map primary energy carriers to secondary"
/
        pegas.seel.ngcc
        pegas.seel.ngccc
        pegas.seel.ngt
        pegas.seel.gaschp
        pegas.segafos.gastr
        pegas.seh2.gash2
        pegas.seh2.gash2c
        pegas.sehe.gashp
        pegas.seliqfos.gasftrec
        pegas.seliqfos.gasftcrec
        pecoal.seel.igcc
        pecoal.seel.igccc
        pecoal.seel.pc
$ifthen setGlobal cm_ccsfosall
        pecoal.seel.pcc
        pecoal.seel.pco
$endif
        pecoal.seel.coalchp
        pecoal.sesofos.coaltr
        pecoal.segafos.coalgas
        pecoal.seh2.coalh2
        pecoal.seh2.coalh2c
        pecoal.sehe.coalhp
        peoil.seliqfos.refliq
        pecoal.seliqfos.coalftrec
        pecoal.seliqfos.coalftcrec
        pebiolc.seliqbio.bioftrec
        pebiolc.seliqbio.bioftcrec
        pebioil.seliqbio.biodiesel
        pebios.seliqbio.bioeths
        pebiolc.seliqbio.bioethl
        peoil.seel.dot
        pebiolc.seel.biochp
        pebiolc.seel.bioigcc
        pebiolc.seel.bioigccc
        pebiolc.seh2.bioh2
        pebiolc.seh2.bioh2c
        pebiolc.sehe.biohp
        pebiolc.sesobio.biotr
        pebiolc.sesobio.biotrmod
        pebiolc.segabio.biogas
        pegeo.seel.geohdr
        pegeo.sehe.geohe
        pehyd.seel.hydro
        pewin.seel.wind
        pesol.seel.spv
        pesol.seel.csp
        pesol.sehe.solhe
        peur.seel.tnrs
        peur.seel.fnrs
/

seAgg(all_enty) "secondary energy aggregations"
/
	all_seliq
	all_seso
	all_sega
/

seAgg2se(all_enty,all_enty) "map secondary energy aggregation to se"
/
	all_seliq.seliqbio
	all_seliq.seliqfos
	all_seso.sesobio
	all_seso.sesofos
	all_sega.segabio
	all_sega.segafos
/

*RP* mappings for storage technologies
VRE2teStor(all_te,teStor)   "mapping to know which technology uses which storage technology"
/
        spv.storspv
        wind.storwind
        csp.storcsp
/

VRE2teVRElinked(all_te,all_te)    "mapping between the technologies requiring storage which use the same fluctutating source (so the shareseel counts half towards the other shareseel)"
/
        spv.csp
        csp.spv
/

*RP* mappings for grid technologies
VRE2teGrid(all_te,teGrid)              "mapping to know which technology needs which grid technology (length/siting)"
/
        spv.gridspv
        wind.gridwind
        csp.gridcsp
/

te2teLoclinked(teLoc,teLoc2)   "mapping between the technologies requiring grids which use similarly sited resources (so the shareseel counts 1/4 towards the other shareseel)"
/
        spv.csp
        csp.spv
/

se2se(all_enty,all_enty,all_te)  "map secondary energy to secondary energy using a technology"
/
        seel.seh2.elh2
        seh2.seel.h2turb
        seel.seh2.elh2VRE
        seh2.seel.h2turbVRE
/

se2fe(all_enty,all_enty,all_te)   "map secondary energy to end-use energy using a technology"
/
        seel.feels.tdels
        segabio.fegas.tdbiogas
        segafos.fegas.tdfosgas
        seliqbio.fehos.tdbiohos
        seliqfos.fehos.tdfoshos
        sesobio.fesos.tdbiosos
        sesofos.fesos.tdfossos
        seh2.feh2s.tdh2s
        sehe.fehes.tdhes
        seel.feelt.tdelt
        seliqbio.fepet.tdbiopet
        seliqfos.fepet.tdfospet
        seliqbio.fedie.tdbiodie
        seliqfos.fedie.tdfosdie
        seh2.feh2t.tdh2t
/
fete(all_enty,all_te) "map final energy to technologies"
fe2ue(all_enty,all_enty,all_te)    "map FE carriers to ES via appliances"
//

fe2es(all_enty,all_esty,all_teEs)    "map FE carriers to ES via ES technologies"
//

pc2te(all_enty,all_enty,all_te,all_enty)    "mapping for own consumption of technologies"
/
        pecoal.seel.coalchp.sehe
        pebiolc.seliqbio.bioethl.seel
        pebiolc.seliqbio.bioftrec.seel
        pebiolc.seliqbio.bioftcrec.seel
        pegas.seel.gaschp.sehe
        pecoal.seh2.coalh2.seel
        pecoal.seh2.coalh2c.seel
        pebiolc.seel.biochp.sehe
        segabio.fegas.tdbiogas.seel
		segafos.fegas.tdfosgas.seel
        pegeo.sehe.geohe.seel
        cco2.ico2.ccsinje.seel
        fedie.uedit.apCarDiEffT.feelt
        fedie.uedit.apCarDiEffH2T.feelt
        fedie.uedit.apCarDiEffH2T.feh2t
/
*NB* mappings for emissions, capture and leakage
emi2te(all_enty,all_enty,all_te,all_enty)    " map emissions to technologies"
/
        pegas.seel.ngcc.co2
        pegas.seel.ngt.co2
        pegas.seel.gaschp.co2
        pegas.seel.ngccc.co2
        pegas.seel.ngccc.cco2
        pegas.segafos.gastr.co2
        pegas.seh2.gash2.co2
        pegas.seh2.gash2c.co2
        pegas.seh2.gash2c.cco2
        pegas.sehe.gashp.co2
        pegas.seel.ngcc.n2o
        pegas.seel.ngt.n2o
        pegas.seel.gaschp.n2o
        pegas.seel.ngccc.n2o
        pegas.segafos.gastr.n2o
        pegas.seh2.gash2.n2o
        pegas.seh2.gash2c.n2o
        pegas.sehe.gashp.n2o
        pegas.seliqfos.gasftrec.co2
        pegas.seliqfos.gasftcrec.co2
        pegas.seliqfos.gasftcrec.cco2
        pecoal.seel.igcc.co2
        pecoal.seel.pc.co2
        pecoal.seel.coalchp.co2
        pecoal.seel.pc.so2
        pecoal.seel.coalchp.so2
        pecoal.seel.pc.bc
        pecoal.seel.coalchp.bc
        pecoal.seel.pc.oc
        pecoal.seel.coalchp.oc
        pecoal.seel.igccc.co2
$ifthen setGlobal cm_ccsfosall
        pecoal.seel.pcc.co2
        pecoal.seel.pco.co2
        pecoal.seel.pcc.cco2
        pecoal.seel.pco.cco2
        pecoal.seel.pcc.n2o
        pecoal.seel.pco.n2o
$endif
        pecoal.seel.igccc.cco2
        pecoal.sesofos.coaltr.co2
        pecoal.sesofos.coaltr.so2
        pecoal.sesofos.coaltr.bc
        pecoal.sesofos.coaltr.oc
        pecoal.sesofos.coaltr.ch4
        pecoal.sehe.coalhp.co2
        pecoal.sehe.coalhp.so2
        pecoal.sehe.coalhp.bc
        pecoal.sehe.coalhp.oc
        pecoal.seh2.coalh2.co2
        pecoal.seh2.coalh2c.co2
        pecoal.seh2.coalh2c.cco2
        pecoal.segafos.coalgas.co2
        pecoal.seliqfos.coalftrec.co2
        pecoal.seliqfos.coalftcrec.co2
        pecoal.seliqfos.coalftcrec.cco2
        pecoal.seel.igcc.n2o
        pecoal.seel.pc.n2o
        pecoal.seel.coalchp.n2o
        pecoal.seel.igccc.n2o
        pecoal.sesofos.coaltr.n2o
        pecoal.sehe.coalhp.n2o
        pecoal.seh2.coalh2.n2o
        pecoal.seh2.coalh2c.n2o
        pecoal.segafos.coalgas.n2o
        peoil.seliqfos.refliq.co2
        peoil.seliqfos.refliq.so2
        peoil.seel.dot.co2
        peoil.seel.dot.so2
        peoil.seel.dot.bc
        peoil.seel.dot.oc
        peoil.seel.dot.n2o
        pebiolc.seliqbio.bioftcrec.co2
        pebiolc.seliqbio.bioftcrec.cco2
        pebiolc.seh2.bioh2c.co2
        pebiolc.seh2.bioh2c.cco2
        pebiolc.sesobio.biotr.bc
        pebiolc.sesobio.biotr.oc
        pebiolc.sesobio.biotrmod.bc
        pebiolc.sesobio.biotrmod.oc
        pebiolc.sesobio.biotr.ch4
        pebiolc.sesobio.biotrmod.ch4
        pebiolc.seel.biochp.bc
        pebiolc.seel.biochp.oc
        pebiolc.sehe.biohp.bc
        pebiolc.sehe.biohp.oc
        pebiolc.seliqbio.bioethl.bc
        pebios.seliqbio.bioeths.bc
        pebioil.seliqbio.biodiesel.bc
        pebiolc.seliqbio.bioethl.oc
        pebios.seliqbio.bioeths.oc
        pebioil.seliqbio.biodiesel.oc
        pebiolc.seh2.bioh2c.n2o
        pebiolc.seel.biochp.n2o
        pebiolc.sehe.biohp.n2o
        pebiolc.sesobio.biotr.n2o
        pebiolc.sesobio.biotrmod.n2o
        pebiolc.seel.bioigccc.n2o
        pebiolc.seel.bioigcc.n2o
        pebiolc.segabio.biogas.n2o
        segabio.fegas.tdbiogas.ch4
        segafos.fegas.tdfosgas.ch4
*        cco2.pco2.ccscomp.co2
*        pco2.tco2.ccspipe.co2
        cco2.ico2.ccsinje.co2
        pebiolc.seel.bioigccc.co2
        pebiolc.seel.bioigccc.cco2
        seliqbio.fehos.tdbiohos.bc
        seliqfos.fehos.tdfoshos.bc
        seliqbio.fedie.tdbiodie.bc
        seliqfos.fedie.tdfosdie.bc
        seliqbio.fepet.tdbiopet.bc
        seliqfos.fepet.tdfospet.bc
        seliqbio.fehos.tdbiohos.oc
        seliqfos.fehos.tdfoshos.oc
        seliqbio.fedie.tdbiodie.oc
        seliqfos.fedie.tdfosdie.oc
        seliqbio.fepet.tdbiopet.oc
        seliqfos.fepet.tdfospet.oc

        segafos.fegas.tdfosgas.co2
        seliqfos.fehos.tdfoshos.co2
        sesofos.fesos.tdfossos.co2
        seliqfos.fepet.tdfospet.co2
        seliqfos.fedie.tdfosdie.co2
/

emi2fuel(all_enty,all_enty) "map emissions to fuel extraction"
/
    pecoal.ch4coal
    pegas.ch4gas
    peoil.ch4oil
/
emiMacSector2emiMac(all_enty,all_enty)   "mapping of sub-emissions to their sum"
/
        (co2luc,co2cement_process)                          .co2
        (n2otrans,n2oadac,n2onitac,n2ofertin,n2ofertcr, n2ofertsom, n2oanwstc,n2oanwstm, n2oanwstp,n2oagwaste,n2oforest,n2osavan,n2owaste).n2o
        (ch4coal,ch4gas,ch4oil,ch4rice,ch4animals,ch4anmlwst,ch4agwaste,ch4forest,ch4savan,ch4wstl,ch4wsts).ch4
/
emiMac2mac(all_enty,all_enty)            "mapping of emission sources to MACs - caution: not all MACs exist, in that case they are zero"
/
        ch4coal.ch4coal 
        ch4gas.ch4gas
        ch4oil.ch4oil
        ch4wstl.ch4wstl
        ch4wsts.ch4wsts
        ch4rice.ch4rice
        ch4animals.ch4animals
        ch4anmlwst.ch4anmlwst
        ch4agwaste.ch4agwaste
        ch4forest.ch4forest
        ch4savan.ch4savan
        n2otrans.n2otrans
        n2oadac.n2oadac
        n2onitac.n2onitac
        (n2ofertin, n2ofertcr, n2ofertsom).n2ofert
        (n2oanwstc, n2oanwstm, n2oanwstp).n2oanwst
        n2oagwaste.n2oagwaste
        n2owaste.n2owaste
        n2osavan.n2osavan
        n2oforest.n2oforest
        co2luc.co2luc
        co2cement_process. co2cement   "process emissions are captured by kiln CCS too"
        co2cement    . co2cement
        co2chemicals . co2chemicals
        co2steel     . co2steel
/

emiMac2sector(all_enty,emi_sectors,sector_types,all_enty)            "mapping of emission sources from MACs to sectors (and emissions)"
/
        (ch4coal, ch4gas, ch4oil).extraction.process.ch4
        (ch4wstl, ch4wsts).waste.process.ch4
        (ch4rice, ch4animals, ch4anmlwst, ch4agwaste).agriculture.process.ch4
        (ch4forest, ch4savan).lulucf.process.ch4

        (n2otrans).trans.process.n2o
        (n2oadac, n2onitac).indst.process.n2o
        (n2owaste).waste.process.n2o
        (n2ofertin, n2ofertcr, n2ofertsom, n2oanwstc, n2oanwstm, n2oanwstp, n2oagwaste).agriculture.process.n2o
        (n2oforest, n2osavan).lulucf.process.n2o
        
        (co2cement_process,co2cement,co2chemicals,co2steel).indst.process.co2
        (co2luc).lulucf.process.co2
/


*NB*111125 emissions from fossil fuel extraction by grade that is on top of combustion
emi2fuelMine(all_enty,all_enty,rlf)   "missions from fossil fuel extraction"
/
        co2.peoil.(4*8)
/
ccs2te(all_enty,all_enty,all_te)   "chain for ccs"
/
*        cco2.pco2.ccscomp
*        pco2.tco2.ccspipe
        cco2.ico2.ccsinje
*        ico2.sco2.ccsmoni
/

ccs2Leak(all_enty,all_enty,all_te,all_enty)   "leakage along ccs chain"
/
*        cco2.pco2.ccscomp.co2
*        pco2.tco2.ccspipe.co2
        cco2.ico2.ccsinje.co2
*        ico2.sco2.ccsmoni.co2
/

pe2rlf(all_enty,rlf)     "map exhaustible energy to grades for qm_fuel2pe"
/
        peoil.(1*8)
        pegas.(1*6)
        pecoal.(1*6)
        pebiolc.(1*2)
        pebios.(5)
        pebioil.(5)
       (peur,pegeo,pehyd,pewin,pesol).1
/

teReComp2pe(all_enty,all_te,rlf)  "map competing technologies to primary energy carrier and grades"
/
        pesol.spv.(1*9)
        pesol.csp.(1*9)
/

demSeOth2te(all_enty,all_te)      "map other se demands not directly following the sedem-route through technologies"
/
  seh2.csp
  segabio.csp
  segafos.csp
/

prodSeOth2te(all_enty,all_te)      "map other se production not directly following the sedem-route through technologies"
/
  seh2.h2curt
/

teSe2rlf(all_te,rlf)        "mapping for techologies to grades. Currently, the information was shifted to teRe2rlfDetail. Thus, teSe2rlf now only has '1' for the rlf values"
/
      (wind,spv,csp,refliq,hydro,geohe,geohdr,solhe,ngcc,ngccc,ngt,gaschp,gashp,gash2,gash2c,gastr,gasftrec,gasftcrec,dot,
       igcc,igccc,pc,coaltr,coalgas,coalh2,coalh2c,coalchp,coalhp,coalftrec,coalftcrec,
       biotr,biotrmod,biogas,bioftrec,bioftcrec,bioh2,bioh2c,biohp,biochp,bioigcc,bioigccc,
       elh2,h2turb,elh2VRE,h2turbVRE,bioethl,bioeths,biodiesel,tnrs,fnrs
$ifthen setGlobal cm_ccsfosall
       pcc, pco
$endif
       ) . 1
/

teRe2rlfDetail(all_te,rlf)        "mapping for se techologies to grades"
/
        wind.(1*9)
        spv.(1*9)
        csp.(1*9)
        hydro.(1*5)
        geohe.1
        geohdr.1
/

teFe2rlf(all_te,rlf)      "mapping for final energy to grades"
/
      (tdels,tdelt,tdbiogas,tdfosgas,tdbiogat,tdfosgat,tdbiohos,tdfoshos,tdh2s,tdh2t,tdbiodie,tdfosdie,tdbiopet,tdfospet,tdbiosos,tdfossos,tdhes) . 1
/

teue2rlf(all_te,rlf)     "mapping for ES production technologies to grades"
//

teCCS2rlf(all_te,rlf)     "mapping for CCS technologies to grades"
/
***      (ccscomp,ccspipe,ccsinje,ccsmoni) . 1
      (ccsinje) . 1
/

teNoTransform2rlf(all_te,rlf)         "mapping for no transformation technologies to grades"
/
      (storspv,storwind,storcsp,gridspv,gridwind,gridcsp,h2curt) . 1
/

opTimeYr2te(all_te,opTimeYr)        "mapping for technologies to yearly lifetime - is filled automatically in generisdata.inc from the lifetime values in generisdata_tech.prn"
tsu2opTimeYr(ttot, opTimeYr)     "mapping for opTimeYr to the used time ttot - will be filled automatically in generisdata.inc"

tsu2opTime5(tall,opTimeYr)     "mapping for spinup time index to lifetime index"
/
1910.96
1915.91
1920.86
1925.81
1930.76
1935.71
1940.66
1945.61
1950.56
1955.51
1960.46
1965.41
1970.36
1975.31
1980.26
1985.21
1990.16
1995.11
2000.6
2005.1
/

sectorEndoEmi2te(all_enty,all_enty,all_te,sectorEndoEmi)	 "map sectors to technologies"
/
        pegas.seel.ngcc.power
        pegas.seel.ngt.power
        seh2.seel.h2turb.power
        pegas.seel.gaschp.power
        pegas.sehe.gashp.power
        pegas.segafos.gastr.indst
        pegas.segafos.gastr.res
        pecoal.seel.pc.power
        pecoal.seel.coalchp.power
        pecoal.sehe.coalhp.power
        pecoal.sesofos.coaltr.indst
        pecoal.sesofos.coaltr.res
        peoil.seliqfos.refliq.trans
        peoil.seliqfos.refliq.indst
        peoil.seliqfos.refliq.res
        peoil.seel.dot.power
        pebiolc.seel.biochp.power
        pebiolc.sehe.biohp.power
        pebiolc.sesobio.biotr.indst
        pebiolc.sesobio.biotr.res
        pebiolc.sesobio.biotrmod.indst
        seliqbio.fehos.tdbiohos.indst
		seliqfos.fehos.tdfoshos.indst
        seliqbio.fehos.tdbiohos.res
		seliqfos.fehos.tdfoshos.res
        seliqbio.fedie.tdbiodie.trans
		seliqfos.fedie.tdfosdie.trans
        seliqbio.fepet.tdbiopet.trans
		seliqfos.fepet.tdfospet.trans
/
emiRCP2emiREMIND "mapping between emission types expected by MAGICC and provided by REMIND"
/
    CO    . CO
    NMVOC . VOC
    NOx   . NOx
    SOx   . SO2
    BC    . BC
    OC    . OC
/
emiFgas2emiRCP(all_enty,emiRCP)   "match F-gases to MAGICC emissions"
/
    emiFgasCF4       . CF4 
    emiFgasC2F6      . C2F6
    emiFgasC6F14     . C6F14
    emiFgasHFC23     . HFC23
    emiFgasHFC32     . HFC32
    emiFgasHFC43-10  . HFC43-10
    emiFgasHFC125    . HFC125
    emiFgasHFC134a   . HFC134a
    emiFgasHFC143a   . HFC143a
    emiFgasHFC227ea  . HFC227ea
    emiFgasHFC245fa  . HFC245fa
    emiFgasSF6       . SF6
/
emiRCP2order "order of emission types expected by MAGICC"
/
    FossilCO2 .  1
    OtherCO2  .  2
    CH4       .  3
    N2O       .  4
    SOx       .  5
    CO        .  6
    NMVOC     .  7
    NOx       .  8
    BC        .  9
    OC        . 10
    NH3       . 11
    CF4       . 12
    C2F6      . 13
    C6F14     . 14
    HFC23     . 15
    HFC32     . 16
    HFC43-10  . 17
    HFC125    . 18
    HFC134a   . 19
    HFC143a   . 20
    HFC227ea  . 21
    HFC245fa  . 22
    SF6       . 23
/
  
emiRCP2unitsMagicc(emiRCP,unitsMagicc) "match units to emission types"
/
    (FossilCO2,OtherCO2)  . GtC
    (CH4)                 . MtCH4
    (N2O)                 . MtN2O-N
    (SOx)                 . MtS
    (CO)                  . MtCO
    (NH3,NOx)             . MtN
    (NMVOC,BC,OC)         . Mt
    (CF4,C2F6,C6F14,HFC23,HFC32,HFC43-10,HFC125,HFC134a,HFC143a,HFC227ea,HFC245fa,SF6) . kt
/



ue2ppfen(all_enty,all_in)      "matching UE in ESM to ppfEn in MACRO"
//

es2ppfen(all_esty,all_in)      "matching ES in ESM to ppfEn in MACRO"
//

;

***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------
***                             Helpful constructs: alias
***-----------------------------------------------------------------------------
***-----------------------------------------------------------------------------

alias(ccs2te,ccs2te2);
alias(pe2se,pe2se2);
alias(se2fe,se2fe2);

*** EOF ./core/sets.gms

