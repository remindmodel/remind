#!/bin/bash

### change directory to REMIND root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )";
#echo $SCRIPT_DIR;
cd "$SCRIPT_DIR/../../../../";
#pwd;



### run GAMS toy model code
gams ./modules/24_trade/network_trade/toymodel/toymodel.gms --trade_toy_model="ON";
mv toymodel.lst ./modules/24_trade/network_trade/toymodel/
