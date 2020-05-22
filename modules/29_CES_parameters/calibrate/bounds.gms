
$ontext
if (%c_CES_calibration_iteration% le 4, !! c_CES_calibration_iteration
  vm_cesIO.fx(t,regi_dyn29(Regi),industry_ue_calibration_target_dyn37(in))
  = pm_cesdata(t,regi,in,"quantity");
);

if (    %c_CES_calibration_iteration% ge 4
    AND %c_CES_calibration_iteration% le 6, !! c_CES_calibration_iteration
  vm_cesIO.fx(t,regi_dyn29(Regi),in_industry_dyn37(ppf(in)))
  = p29_cesIO_load(t,regi,in);
);
$offtext

