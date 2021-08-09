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

SETS
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
$IFTHEN.WindOff %cm_wind_offshore% == "1"
        windoff         "wind offshore power converters"
$ENDIF.WindOff
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
        tdsyngas        "transmission and distribution for gas from synthetic origin to stationary users"
        tdbiogai        "transmission and distribution for gas from biomass origin to industry"
	tdfosgai        "transmission and distribution for gas from fossil origin to industry"
        tdbiogab        "transmission and distribution for gas from biomass origin to buildings"
	tdfosgab        "transmission and distribution for gas from fossil origin to buildings"
        tdbiogat        "transmission and distribution for gas from biomass origin to transportation"
	tdfosgat        "transmission and distribution for gas from fossil origin to transportation"
        tdsyngat        "transmission and distribution for gas from synthetic origin to transportation"
        tdbiohos        "transmission and distribution for heating oil from biomass origin to transportation"
        tdfoshos        "transmission and distribution for heating oil from fossil origin to stationary users"
        tdsynhos        "transmission and distribution for heating oil from synthetic origin to stationary users"
        tdbiohoi        "transmission and distribution for heating oil from biomass origin to industry"
	tdfoshoi        "transmission and distribution for heating oil from fossil origin to industry"
        tdbiohob        "transmission and distribution for heating oil from biomass origin to buildings"
        tdfoshob        "transmission and distribution for heating oil from fossil origin to buildings"
        tdh2s           "transmission and distribution for hydrogen to stationary users"
        tdh2t           "transmission and distribution for hydrogen to transportation"
        tdbiodie        "transmission and distribution for diesel from biomass origin to stationary users"
        tdfosdie        "transmission and distribution for diesel from fossil origin to stationary users"
        tdsyndie        "transmission and distribution for diesel from synthetic origin to stationary users"
	tdbiopet        "transmission and distribution for petrol from biomass origin to stationary users"
        tdfospet        "transmission and distribution for petrol from fossil origin to stationary users"
        tdsynpet        "transmission and distribution for petrol from synthetic origin to stationary users"
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
        storwind        "storage technology for wind onshore"
$IFTHEN.WindOff %cm_wind_offshore% == "1"
        storwindoff     "storage technology for wind offshore"
$ENDIF.WindOff
        storcsp         "storage technology for concentrating solar power (CSP)"
*RP* grid technology
        gridspv         "grid between areas with high pv production and the rest"
        gridcsp         "grid between areas with high csp production and the rest"
        gridwind        "grid between areas with high wind onshore production and the rest"
$IFTHEN.WindOff %cm_wind_offshore% == "1"
        gridwindoff     "grid between areas with high wind offshore production and the rest"
$ENDIF.WindOff

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
*** FS: H2 transmission & distribution helper technologies for industry & buildings
        tdh2i   "helper technologies (without cost) to avoid sudden H2 use switching in buildings and industry"
        tdh2b   "helper technologies (without cost) to avoid sudden H2 use switching in buildings and industry"
*** technologies related to trading
        pipeline
        shipping
        shipping_Mport
        shipping_Xport
        shipping_vessels
/

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
$IFTHEN.WindOff %cm_wind_offshore% == "1"
        windoff         "wind offshore power converters"
$ENDIF.WindOff
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
        tdsyngas        "transmission and distribution for gas from synthetic origin to stationary users"
        tdbiogat        "transmission and distribution for gas from synthetic origin to transportation"
        tdfosgat        "transmission and distribution for gas from biomass origin to transportation"
        tdsyngat        "transmission and distribution for gas from synthetic origin to transportation"
        tdbiohos        "transmission and distribution for heating oil from biomass origin to stationary users"
        tdfoshos        "transmission and distribution for heating oil from fossil origin to stationary users"
        tdsynhos        "transmission and distribution for heating oil from synthetic origin to stationary users"
        tdh2s           "transmission and distribution for hydrogen to stationary users"
        tdh2t           "transmission and distribution for hydrogen to transportation"
        tdbiodie        "transmission and distribution for diesel from biomass origin to stationary users"
        tdfosdie        "transmission and distribution for diesel from fossil origin to stationary users"
        tdsyndie        "transmission and distribution for diesel from synthetic origin to stationary users"
        tdbiopet        "transmission and distribution for petrol from biomass origin to stationary users"
	tdfospet        "transmission and distribution for petrol from fossil origin to stationary users"
        tdsynpet        "transmission and distribution for petrol from synthetic origin to stationary users"
        tdbiosos        "transmission and distribution for solids from biomass origin to stationary users"
        tdfossos        "transmission and distribution for solids from fossil origin to stationary users"
        tdhes           "transmission and distribution for heat to stationary users"
*** FS: H2 transmission & distribution helper technologies for industry & buildings
        tdh2i   "helper technologies (without cost) to avoid sudden H2 use switching in buildings and industry"
        tdh2b   "helper technologies (without cost) to avoid sudden H2 use switching in buildings and industry"

*        ccscomp         "compression of co2, CCS related"
*        ccspipe         "transportation of co2, CCS related"
        ccsinje         "injection of co2, CCS related"
*        ccsmoni         "monitoring of co2, CCS related"

        storspv         "storage technology for photo voltaic"
        storwind        "storage technology for wind onshore"
$IFTHEN.WindOff %cm_wind_offshore% == "1"
        storwindoff     "storage technology for wind offshore"
$ENDIF.WindOff
        storcsp         "storage technology for concentrating solar power"

        gridspv         "grid between areas with high pv production and the rest"
        gridcsp         "grid between areas with high csp production and the rest"
        gridwind        "grid between areas with high wind onshore production and the rest"
$IFTHEN.WindOff %cm_wind_offshore% == "1"
        gridwindoff     "grid between areas with high wind offshore production and the rest"
$ENDIF.WindOff
        pipeline
        shipping
        shipping_Mport
        shipping_Xport
        shipping_vessels
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
  inco0_d         "Initial investment costs given in $(2015)/kW(output) capacity. Per 1000km."
  incolearn       "Investment costs that can be reduced through learning. Unit: $/kW"
  floorcost       "Floor investment costs for learning technologies. Unit: $/kW"
  eta             "conversion efficiency"
  eta_d           "conversion efficieny, i.e. the amount of energy NOT lost in transportation. Per 1000km."
  omf             "fixed o&m"
  omf_d           "fixed o&m per 1000km"
  omv             "variable o&m"
  omv_d           "variable o&m per 1000km"
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

alias(ttot,t,tttot);

SCALAR cm_startyear "first optimized modelling time step [year]"
/ 2005 /;

PARAMETERS
    pm_ttot_val(ttot)                                    "value of ttot set element"
    p_tall_val(tall)                                     "value of tall set element"
    pm_ts(tall)                                          "(t_n+1 - t_n-1)/2 for a timestep t_n"
    pm_dt(tall)                                          "difference to last timestep"
;

SET opTimeYr            "actual life time of ??? in years"
/
        1*100
/
;
alias(opTimeYr,opTimeYr2);

SETS
opTimeYr2te(all_te,opTimeYr)        "mapping for technologies to yearly lifetime - is filled automatically in generisdata.inc from the lifetime values in generisdata_tech.prn"
tsu2opTimeYr(ttot, opTimeYr)     "mapping for opTimeYr to the used time ttot - will be filled automatically in generisdata.inc"
;

PARAMETERS
p_tsu2opTimeYr_h(ttot,opTimeYr)                      "parameter to generate pm_tsu2opTimeYr",
pm_tsu2opTimeYr(ttot,opTimeYr)                       "parameter that counts opTimeYr regarding tsu2opTimeYr apping"
;

PARAMETER pm_omeg (all_regi,opTimeYr,all_te)                          "technical depreciation parameter, gives the share of a capacity that is still usable after tlt. [none/share, value between 0 and 1]";

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


***---------------------------------------------------------------------------
*** Import and set global data
***---------------------------------------------------------------------------
table fm_dataglob(char,all_te)  "energy technology characteristics: investment costs, O&M costs, efficiency, learning rates ..."
$include "./core/input/generisdata_tech.prn"
$include "./core/input/generisdata_trade.prn"
;

PARAMETER pm_data(all_regi,char,all_te)                        "Large array for most technical parameters of technologies; more detail on the individual technical parameters can be found in the declaration of the set 'char' ";
PARAMETER p_aux_lifetime(all_regi,all_te)                             "auxiliary parameter for calculating life times, calculated externally in excel sheet";

pm_data(all_regi,char,all_te) = fm_dataglob(char,all_te);

pm_omeg(regi,opTimeYr,te) = 0;

*** FS: use lifetime of tdh2s for tdh2b and tdh2i technologies
*** which are only helper technologies for consistent H2 use in industry and buildings
pm_data(regi,"lifetime","tdh2i") = pm_data(regi,"lifetime","tdh2s");
pm_data(regi,"lifetime","tdh2b") = pm_data(regi,"lifetime","tdh2s");

loop(regi,
        p_aux_lifetime(regi,te) = 5/4 * pm_data(regi,"lifetime",te);
        loop(te,
                if(p_aux_lifetime(regi,te) > 0,
                loop(opTimeYr,
                        pm_omeg(regi,opTimeYr,te) = 1 - ((opTimeYr.val-0.5) / p_aux_lifetime(regi,te))**4 ;
                        opTimeYr2te(te,opTimeYr)$(pm_omeg(regi,opTimeYr,te) > 0 ) =  yes;
                        if( pm_omeg(regi,opTimeYr,te) <= 0,
                                pm_omeg(regi,opTimeYr,te) = 0;
                                opTimeYr2te(te,opTimeYr) =  no;
                        );
                )
                );
        );
);

display p_aux_lifetime;

*LB* calculate mapping tsu2opTimeYr
alias(ttot, tttot);
tsu2opTimeYr(ttot,opTimeYr) =  no;
tsu2opTimeYr(ttot,"1") =  yes;
loop(ttot,
   loop(opTimeYr,
      loop(tttot $(ord(tttot) le ord(ttot)),
         if(opTimeYr.val = pm_ttot_val(ttot)-pm_ttot_val(tttot)+1,
            tsu2opTimeYr(ttot,opTimeYr) =  yes;
         );
      );
   );
);

p_tsu2opTimeYr_h(ttot,opTimeYr) = 0;
p_tsu2opTimeYr_h(ttot,opTimeYr) $tsu2opTimeYr(ttot,opTimeYr) = 1 ;
pm_tsu2opTimeYr(ttot,opTimeYr)$tsu2opTimeYr(ttot,opTimeYr)
= sum(opTimeYr2 $ (ord(opTimeYr2) le ord(opTimeYr)), p_tsu2opTimeYr_h(ttot,opTimeYr2));
