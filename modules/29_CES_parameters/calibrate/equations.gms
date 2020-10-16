*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/equations.gms
$offOrder
q29_pathConstraint (t_29,regi_dyn29(regi),in) $(putty_compute_in(in)
                                      AND (ord(t_29) lt card(t_29))) ..
v29_cesdata(t_29 + 1,regi,in) =e=
  (1- pm_delta_kap(regi,in))**pm_dt(t_29+1) * v29_cesdata(t_29,regi,in)
                                 + (pm_cumDeprecFactor_old(t_29+1,regi,in) *  v29_cesdata_putty(t_29,regi,in))                                  
                                 + (pm_cumDeprecFactor_new(t_29+1,regi,in) *  v29_cesdata_putty(t_29+1,regi,in))
                                 ;
q29_ratioTotalPutty (t_29,regi_dyn29(regi),out,in,in2) $ (putty_compute_in(in)
                                                AND putty_compute_in(in2)
                                                AND cesOut2cesIn(out,in)
                                                AND cesOut2cesIn2(out,in2)
                                                AND ( NOT sameAs(in,in2))
                                                )   ..
                        
                       v29_ratioTotalPutty(t_29,regi,out,in,in2)
                       =e=
                       (v29_cesdata_putty(t_29,regi,in)
                        )/v29_cesdata_putty(t_29,regi,in2)
                       /
                       (pm_cesdata(t_29,regi,in,"quantity")
                       /pm_cesdata(t_29,regi,in2,"quantity")
                       )
                       ;
                                 
                                 
q29_esubsConstraint(t,regi_dyn29(regi),out,in,in2) $ ( ipf_putty(out) 
                                                AND putty_compute_in(in)
                                                AND putty_compute_in(in2)
                                                AND t_29hist_last(t)
                                                AND pm_cesdata_sigma(t,out) eq -1 
                                                AND cesOut2cesIn(out,in)
                                                AND cesOut2cesIn2(out,in2)
                                                AND ppfKap(in)
                                                AND ( NOT ppfKap(in2))) ..
     v29_puttyTechDiff(t,regi,out) =e=      p29_capitalUnitProjections(regi,in2,"0") 
                                             /  p29_capitalUnitProjections(regi,in,"0") 
                                             - 
                                             v29_cesdata_putty(t,regi,in2)
                                             /v29_cesdata_putty(t,regi,in)
                                             ;
                                             
    
                         
q29_putty_obj..                                 
v29_putty_obj =e= 5e-1 * sum ((t_29,regi_dyn29(regi),in)$(putty_compute_in(in)
                                      AND (ord(t_29) lt card(t_29)))                  
                                      , power( v29_cesdata_putty(t_29+1,regi,in)      !! Limit the variations from one period to another
                                                - v29_cesdata_putty(t_29,regi,in)
                                                
                                       ,2)
                   )
                   +
                   sum((t_29,regi_dyn29(regi),in)$putty_compute_in(in)
                   ,power( v29_cesdata(t_29,regi,in)                           !! Be as close as possible as the aggregate trajectory
                           - pm_cesdata(t_29,regi,in,"quantity")
                           ,6)
                   )
                   +  sum ((t_29hist_last(t),regi_dyn29(regi), out),
                          power ( v29_puttyTechDiff(t,regi,out),
                          2)
                          )
                   + 1e-6 * sum ((t_29, regi_dyn29(regi),out, in,in2) $(putty_compute_in(in)
                                                AND putty_compute_in(in2)
                                                AND cesOut2cesIn(out,in)
                                                AND cesOut2cesIn2(out,in2)
                                                AND ( NOT sameAs(in,in2))
                                                ), !! penalise the large differences in ratios between inputs for Total quantities (pm_cesdata) and putty quantities (pm_cesdata_putty)
                     power ( v29_ratioTotalPutty(t_29,regi,out,in,in2),
                     2)
                     )
                          ;                           
                   
$onOrder



q29_outputtech(regi_dyn29(regi),ipf(out),index_Nr)$( (pm_cesdata_sigma("2015",out) eq -1) AND  p29_capitalUnitProjections(regi,out,index_Nr))..
   
    v29_outputtech(regi,out,index_Nr)
  =e=
    sum ((cesOut2cesIn(out,in), t_29hist_last(t)),
      pm_cesdata(t,regi,in,"xi")
    * ( 
        pm_cesdata(t,regi,in,"eff")
      * p29_capitalUnitProjections(regi,in,index_Nr)
      )
   ** v29_rho(regi,out)
    )
 ** (1 / v29_rho(regi,out))
;

q29_esub_obj..

    v29_esub_err 
    =e=
    sum ((out,regi_dyn29(regi),index_Nr, t_29hist_last(t))$((pm_cesdata_sigma("2015",out) eq -1) AND  p29_capitalUnitProjections(regi,out,index_Nr)),
    (1 + pm_cesdata(t,regi,out,"quantity")) **2  !! weight by regional size of the service demand
    *
    (
      power (
             ( p29_output_estimation(regi,out)
              / v29_outputtech(regi,out,index_Nr)
              )
              - 1
              , 2
      )
      +
      power (
             ( v29_outputtech(regi,out,index_Nr)
              / p29_output_estimation(regi,out)
             )
             -1 
             ,2
      )
      )
    );  

    
  
*** EOF ./modules/29_CES_parameters/calibrate/equations.gms

