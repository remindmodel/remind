#!/bin/bash

mkdir -p ./trademodel_data/

# dump import and export quantities from input.gdx
gdxdump input.gdx Symb=vm_Mport | grep "pegas'.L " | sed "s/'.'pegas'.L /,/g" | sed "s/'\.'/,/g" | sed "s/'//g" | sed "s/, //g" > ./trademodel_data/pegas_Mports.dat
gdxdump input.gdx Symb=vm_Xport | grep "pegas'.L " | sed "s/'.'pegas'.L /,/g" | sed "s/'\.'/,/g" | sed "s/'//g" | sed "s/, //g" > ./trademodel_data/pegas_Xports.dat

# dump prices from input.gdx
gdxdump input.gdx Symb=p_peprice | grep "pegas" | sed "s/'.'pegas' /,/g" | sed "s/'\.'/,/g" | sed "s/'//g" | sed "s/, //g" > ./trademodel_data/p_peprice_pegas.dat
gdxdump input.gdx Symb=pm_seprice | grep "seh2" | sed "s/'.'seh2' /,/g" | sed "s/'\.'/,/g" | sed "s/'//g" | sed "s/, //g" > ./trademodel_data/pm_seprice_seh2.dat
