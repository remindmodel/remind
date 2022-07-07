*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWTCint/sets.gms

sets
isoTC(iso) "list of countries affected by TC damages" 
/
	AUS,BGD,BHS,BLZ,BRB,CAN,CHN,CUB,DOM,FJI,GTM,HKG,HND,HTI,IND,JAM,JPN,KHM,KOR,LAO,
	LCA,LKA,MDG,MEX,MMR,MOZ,MUS,NCL,NIC,PHL,PNG,PRI,SLB,THA,TON,TWN,USA,VCT,VNM,VUT,WSM 
/	

regi2isoTC(all_regi,isoTC) "map regions to TC countries"
/
	CAZ . (AUS,CAN)
	CHA . (CHN,HKG,TWN)
	IND . (IND)
	JPN . (JPN)
	LAM . (BHS,BLZ,BRB,CUB,DOM,GTM,HND,HTI,JAM,LCA,MEX,NIC,PRI,VCT)
	OAS . (BGD,FJI,KHM,KOR,LAO,LKA,MMR,NCL,PHL,PNG,SLB,THA,TON,VNM,VUT,WSM)
	SSA . (MDG,MOZ,MUS) 
/

all_TCspec "TC damage distribution quantiles" 
/estimates_mean,estimates_median,estimates_95,estimates_83,estimates_17,estimates_05/

all_SSPscen "all 5 SSP scenarios" 
/SSP1,SSP2,SSP3,SSP4,SSP5/

all_TCpers "all possible persistencies of TC damages"
/0,1,2,3,4,5,6,7,8/

;

*** EOF ./modules/50_damages/KWTCint/sets.gms
