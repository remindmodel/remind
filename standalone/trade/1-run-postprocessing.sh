#!/bin/bash

mkdir -p ./trademodel_data/

# dump and convert import and export quantities from SSP2
gdxdump fulldata.gdx Symb=v24_shipment_quan | grep "'.L " | sed "s/'\.'/,/g" | sed "s/'.L /,/g" | sed "s/'//g" | sed "s/, //g" > ./trademodel_data/shipmentquan.dat
gdxdump fulldata.gdx Symb=v24_cap_tradeTransp | grep "'.L " | sed "s/'\.'/,/g" | sed "s/'.L /,/g" | sed "s/'//g" | sed "s/, //g" > ./trademodel_data/cap_tradeTransp.dat
