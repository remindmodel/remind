#!/bin/bash

mkdir -p ./trademodel_data/

gdxdump fulldata.gdx Format=csv Symb=tradeEnty2Mode             > ./trademodel_data/tradeEnty2Mode.dat

gdxdump fulldata.gdx Format=csv Symb=p24_Xport_iter             > ./trademodel_data/p24_Xport_iter.dat
gdxdump fulldata.gdx Format=csv Symb=p24_Mport_iter             > ./trademodel_data/p24_Mport_iter.dat

gdxdump fulldata.gdx Format=csv Symb=p24_shipment_quan_iter     > ./trademodel_data/p24_shipment_quan_iter.dat
gdxdump fulldata.gdx Format=csv Symb=p24_cap_tradeTransp_iter   > ./trademodel_data/p24_cap_tradeTransp_iter.dat
