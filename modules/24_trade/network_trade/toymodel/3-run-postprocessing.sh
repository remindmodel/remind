#!/bin/bash

# dump and convert import and export quantities from SSP2
gdxdump ./toymodel_output/results.gdx Symb=v24_shipment_quan | grep "'.L " | sed "s/'\.'/,/g" | sed "s/'.L /,/g" | sed "s/'//g" | sed "s/, //g" > ./toymodel_output/shipmentquan.dat
gdxdump ./toymodel_output/results.gdx Symb=v24_cap_tradeTransp | grep "'.L " | sed "s/'\.'/,/g" | sed "s/'.L /,/g" | sed "s/'//g" | sed "s/, //g" > ./toymodel_output/cap_tradeTransp.dat
