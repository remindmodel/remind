#!/bin/bash
#===========================================================
# gdx_rename - Change item names 
#===========================================================
# description: gdx_rename calls an R script that 
#   renames a given list of items.
# author: Jerome Hilaire
# email: hilaire@pik-potsdam.de
# history:
#   - 2015-10-08: Updating R script with latest name changes
#   - 2015-03-04: Can process a directory containing several gdxs
#   - 2015-02-16: Creation
#===========================================================

# Check number of arguments
if [ "$#" -lt 1 ]; then
  echo 'Please provide a gdx path and optionally a revision number'
  echo ' '
  echo 'Example:'
  echo 'gdx_rename.sh gdx_path [revision_number]' 
  exit -1
fi

# Check case (single gdx file or directory of gdx?)
echo "Checking case..."
if [ -d $1 ]; then
  echo "  > directory of gdxs"
  f_case="dir"
else 
  f_validgdx=$(basename $1 | cut -d'.' -f2)
  if [ -f $1 ] && [ $f_validgdx == "gdx" ]; then
    echo "  > single gdx file"
  else
    echo "Error: please provide a valid gdx file."
    exit -1
  fi
fi

# Generate temporary R script
echo "Generating R script..."
echo " 
library(gdx)

args=(commandArgs(TRUE))

# path to the gdx you want to rename
gdx <- args[[1]]

# renaming parameter and variables
if (length(args) == 1) {
  gdx_rename(gdx,
    magicc_emi        = 'p_MAGICC_emi',
    ts                = 'pm_ts',
    s_earlyreti       = 'sm_earlyreti', 
    s_tgn2pgc         = 'sm_tgn2pgc', 
    regi2RCP_region   = 'p_regi_2_MAGICC_regions', 
    s_tgch42pg        = 'sm_tgch42pg', 
    s_tmp             = 'sm_tmp', 
#    s_c_so2           = 'sm_c_so2', 
    s_tax_time        = 's21_tax_time', 
    s_tax_value       = 's21_tax_value',  
    conv_cap_2_MioLDV = 'pm_conv_cap_2_MioLDV', 
    s_before          = 's80_before', 
    s_after           = 's80_after',
    p_limits_wp4_rcp  = 'pm_emiAPexo', 
    p_ratio_ppp       = 'pm_shPPPMER', 
    p_vintage_in      = 'pm_vintage_in',
    p_datafe          = 'pm_dataFE',
    p_ttot_val        = 'pm_ttot_val', 
    p_t_interpolate   = 'p80_t_interpolate', 
    c_iterative_target_adj = 'cm_iterative_target_adj', 
    c_co2_tax_2020         = 'cm_co2_tax_2020', 
    c_macscen              = 'c_macscen', 
    c_bioenergy_tax        = 'cm_bioenergy_tax', 
    c_startyear            = 'cm_startyear', 
    c_export_tax_scen      = 'c_export_tax_scen', 
    c_gdximport_target     = 'cm_gdximport_target', 
    c_SSP_forcing_adjust   = 'c_SSP_forcing_adjust',
    p_share_ind_fesos      = 'pm_share_ind_fesos', 
    p_share_ind_fesos_bio  = 'pm_share_ind_fesos_bio', 
    p_share_ind_fehos      = 'pm_share_ind_fehos', 
    p_share_trans          = 'pm_share_trans',
    p_petradecost_Mp_en    = 'pm_costsPEtradeMp', 
    f_data_weathering_graderegi = 'f33_data_weathering_graderegi',
    p_nw                   = 'p80_nw',
    c_nucscen              = 'cm_nucscen',
    q_co2eq                = 'q_co2eq',
    pm_costsPEtradeMp      = 'pm_costsPEtradeMp', 
    vm_welfare             = 'v_welfare',
    pm_tau_fe_sub          = 'p21_tau_fe_sub', 
    pm_datapop             = 'pm_pop',
    p_datalab              = 'pm_lab',
    p80_pvp                = 'pm_pvp', 
    p80_pvpRegi            = 'pm_pvpRegi',
#-- 5152 -----
    p_w         = 'pm_w',
    v_emicap    = 'vm_perm',
    v_co2eqGlob = 'vm_co2eqGlob',
    v_banking   = 'vm_banking',
    v_vari      = 'vm_cesIO',
    v_invest    = 'vm_invMacro',
    v_deltacap  = 'vm_deltaCap',
    v_pedem     = 'vm_demPe',
    v_seprod    = 'vm_prodSe',
    v_feprod    = 'vm_prodFe',
    v_fedem     = 'v_demFe',
    vm_peprod   = 'vm_prodPe',
    v_sedem     = 'v_demSe',
#-- Power module creation - version 7452 -----
    q_limitCapTeChp		= 'q32_limitCapTeChp',
    q_limitSolarWind	= 'q32_limitSolarWind',
    q_shSeEl			= 'q32_shSeEl',
    q_shStor			= 'q32_shStor',
    q_storloss			= 'q32_storloss',
    q_operatingReserve	= 'q32_operatingReserve',
    q_usableSe         	= 'q32_usableSe',
    q_usableSeTe        = 'q32_usableSeTe',
    q_limitCapTeStor	= 'q32_limitCapTeStor',
    q_limitCapTeGrid	= 'q32_limitCapTeGrid',
    v_demFe        		= 'v_demFe',
    v_demSe        		= 'vm_demSe',
    v_co2CCS        	= 'vm_co2CCS',
    v_shStor        	= 'v32_shStor',
    v_usableSe        	= 'vm_usableSe',
    v_capDistr        	= 'vm_capDistr',
    v_shSeEl        	= 'v32_shSeEl',
    v_usableSeTe        = 'vm_usableSeTe',
    v_storloss        	= 'v32_storloss',
	p_shCHP        		= 'p32_shCHP',
	p_dataren   		= 'pm_dataren',
	p_storexp   		= 'p32_storexp',
	p_gridexp   		= 'p32_gridexp',
	p_grid_factor   	= 'p32_grid_factor',
	p_factorStorage   	= 'p32_factorStorage',
	p_correct   		= 'pm_correct'
  )
} else {
  version <- args[[2]]
  if (version == '5152') {
    gdx_rename(gdx,
      p_w         = 'pm_w',
      v_emicap    = 'vm_perm',
      v_co2eqGlob = 'vm_co2eqGlob',
      v_banking   = 'vm_banking',
      v_vari      = 'vm_cesIO',
      v_invest    = 'vm_invMacro',
      v_deltacap  = 'vm_deltaCap',
      v_pedem     = 'vm_demPe',
      v_seprod    = 'vm_prodSe',
      v_feprod    = 'vm_prodFe',
      v_fedem     = 'v_demFe',
      vm_peprod   = 'vm_prodPe',
      v_sedem     = 'v_demSe'
    )
  }
}" > gdx_rename.R.tmp

# Run R script
echo "Running R script..."
if [ -d $1 ]; then
  for k_file in $1/*.gdx; do
    f_validgdx=$(basename $k_file | cut -d'.' -f2)
    if [ -f $k_file ] && [ $f_validgdx == "gdx" ]; then 
      fname=$(basename $k_file)
      echo "  > $fname"
      Rscript gdx_rename.R.tmp $k_file $2
      echo " "
    fi
  done
else
  fname=$(basename $1)
  echo "  > $fname"
  Rscript gdx_rename.R.tmp $1 $2
fi

# Clean up
echo "Cleaning up..."
rm gdx_rename.R.tmp
