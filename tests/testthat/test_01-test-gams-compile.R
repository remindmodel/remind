# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that(
  'gams -a=c works on stock configuration',
  {
    expect_equal(
      attr(localSystem2('gams', 'main.gms -a=c -errmsg=1 -pw=185 -ps=0'),
	   'status'),
      0)
  })
