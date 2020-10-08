*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS/presolve.gms
*** Update sector shares
loop ((t,regi)$( t.val ge 2005 ),
  !! share in solids
  if (sum(fe2ppfen("fesos",in), p11_cesIO(t,regi,in)) gt 0,
    p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi)
    = sum(fe_tax_sub_sbi("fehos",in), p11_cesIO(t,regi,in))
    / sum(fe2ppfen("fesos",in), p11_cesIO(t,regi,in));

    p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi)
    = p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi);
  else
    p11_share_sector(t,"pecoal","sesofos","coaltr","indst",regi)
    = pm_share_ind_fesos(t,regi);

    if (sum(fe_tax_sub_sbi("fesoi",in), p11_cesIO("2005",regi,in)) gt 0,
      p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi)
      = pm_share_ind_fesos_bio(t,regi)
      * sum(fe_tax_sub_sbi("fesoi",in), p11_cesIO(t,regi,in))
      / sum(fe_tax_sub_sbi("fesoi",in), p11_cesIO("2005",regi,in));
    else
      !! When calibrating to a new region set with insufficient data coverage in
      !! the gdx, vm_cesIO will be all zero.  In that case, simply split 50/50.
      p11_share_sector(t,"pebiolc","sesobio","biotr","indst",regi) = 0.5;
    );
  );

  p11_share_sector(ttot,"pecoal","sesofos","coaltr","res",regi)
  = 1 - p11_share_sector(ttot,"pecoal","sesofos","coaltr","indst",regi);

  p11_share_sector(ttot,"pebiolc","sesobio","biotr","res",regi)
  = 1 - p11_share_sector(ttot,"pebiolc","sesobio","biotr","indst",regi);

  !! share in liquids
  if (sum(fe2ppfen("fehos",in), p11_cesIO(t,regi,in)) gt 0,
    p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi)
    = sum(fe_tax_sub_sbi("fehoi",in), p11_cesIO(t,regi,in))
    / sum(fe2ppfen("fehos",in), p11_cesIO(t,regi,in));
  else
    p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi)
    = pm_share_ind_fehos(t,regi)
  );

  p11_share_sector(t,"seliqfos","fehos","tdfoshos","res",regi)
  = 1 - p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","trans",regi)
  = pm_share_trans(t,regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","indst",regi)
  = (1 - pm_share_trans(t,regi))
  * p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi);

  p11_share_sector(t,"peoil","seliqfos","refliq","res",regi)
  = (1 - pm_share_trans(t,regi))
  * (1 - p11_share_sector(t,"seliqfos","fehos","tdfoshos","indst",regi));

  !! share in gases
  if (sum(fe2ppfen("fegas",in), p11_cesIO(t,regi,in)) gt 0,
    p11_share_sector(t,"pegas","segafos","gastr","indst",regi)
    = sum(fe_tax_sub_sbi("fegai",in), p11_cesIO(t,regi,in))
    / sum(fe2ppfen("fegas",in), p11_cesIO(t,regi,in));
  else
    p11_share_sector(t,"pegas","segafos","gastr","indst",regi)
    = pm_share_ind_fehos(t,regi);
  );

  p11_share_sector(t,"pegas","segafos","gastr","res",regi)
  = 1 - p11_share_sector(t,"pegas","segafos","gastr","indst",regi);
);

display vm_cesIO.l;

*** EOF ./modules/11_aerosols/exoGAINS/presolve.gms
