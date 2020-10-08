# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#- User section ----
# CO2 tax value in ref_year in 10^12 US$(2005)/GtC = 1000 US$(2005)/tC

# Export options
p_varname      = "p45_tau_co2_tax"
p_fpath        = "../modules/45_carbonprice/exogenous/input/p45_tau_co2_tax.inc"
#-------------------

# Options
growth <- "linear" # choose among const, linear, or exp
ref_year <- 2030
start_year <- 2020
s_co2TaxRefyear = 30.0
s_co2TaxStartyear = 6.0
s_co2TaxRefyear = s_co2TaxRefyear * (44/12) /1000
s_co2TaxStartyear = s_co2TaxStartyear*(44/12) /1000

#var_name <- paste0("s_co2Tax",as.character(ref_year))

#- Time and region dimensions ----
#t = c(seq(2005,2055,5), seq(2060,2110,10), 2130, 2150)
#r = c("AFR", "CHN", "EUR", "IND", "JPN", "LAM", "MEA", "OAS", "ROW", "RUS", "USA")
t = c(seq(2005,2055,5), seq(2060,2110,10), 2130, 2150)
r = "regi"

v_tax <- vector(length=length(t))
v_tax[1:grep(start_year,t)-1] <- 0
l <- grep(start_year,t) # timestep counter

	#- Generate CO2 tax ----

if (growth=="exp") {
	#v_tax = s_co2Tax2020*(44/12)/1000*1.05**(t-2020)
	for (kt in seq(start_year,2055,5)) {
		v_tax[[l]] <- 0.2*sum(s_co2TaxRefyear*1.05**(-ref_year+seq(kt-2,kt+2,1)))
		l <- l+1
	}
	for (kt in 2060) {
		v_tax[[l]] <- (1/7.5)*(sum(s_co2TaxRefyear*1.05**(-ref_year+seq(kt-2,kt+4,1)))+0.5*s_co2TaxRefyear*1.05**(-ref_year+kt+5))
		l <- l+1
	}
	for (kt in seq(2070,2100,10)) {
		v_tax[[l]] <- 0.1*(0.5*s_co2TaxRefyear*1.05**(-ref_year+kt-5)+sum(s_co2TaxRefyear*1.05**(-ref_year+seq(kt-4,kt+4,1)))+0.5*s_co2TaxRefyear*1.05**(-ref_year+kt+5))
		l <- l+1
	}
	v_tax[l:length(t)] <- v_tax[[l-1]]

} else if (growth == "const") {

	v_tax[l:length(v_tax)] <- s_co2TaxStartyear

} else if (growth == "linear") {
	slope <- (s_co2TaxRefyear - s_co2TaxStartyear)/(ref_year - start_year)
	for (kt in seq(start_year,2055,5)) {
		v_tax[[l]] <- 0.2*sum(s_co2TaxStartyear + slope*seq(kt-2-start_year,kt+2-start_year,1))
		l <- l+1
	}
	for (kt in 2060) {
		v_tax[[l]] <- (1/7.5)*(sum(s_co2TaxStartyear + slope*seq(kt-2-start_year,kt+4-start_year,1))+0.5*(s_co2TaxStartyear + slope*(kt+5-start_year)))
		l <- l+1
	}
	for (kt in seq(2070,2100,10)) {
		v_tax[[l]] <- 0.1*(0.5*(s_co2TaxStartyear + slope*(kt-5-start_year))+sum(s_co2TaxStartyear + slope*seq(kt-4-start_year,kt+4-start_year,1))+0.5*(s_co2TaxStartyear + slope*(kt+5-start_year)))
		l <- l+1
	}
	v_tax[l:length(t)] <- v_tax[[l-1]]

}


#- Export data ----
# Header
cat("*==========================================================*\n", file=p_fpath, append=FALSE)
cat("*=              Exogenous CO2 tax level                   =*\n", file=p_fpath, append=TRUE)
cat("*==========================================================*\n", file=p_fpath, append=TRUE)
cat("*= authors: hilare@pik-potsdam.de ,giannou@pik-potsdam.de =*\n", file=p_fpath, append=TRUE)
cat(paste("*= date  :", Sys.time(), "                          =*\n", sep=""), file=p_fpath, append=TRUE)
cat("*= generated with r_gen_co2_tax.r                         =*\n", file=p_fpath, append=TRUE)
cat("*= units: 10^12 US$(2005)/GtC                             =*\n", file=p_fpath, append=TRUE)
cat("*==========================================================*\n", file=p_fpath, append=TRUE)
cat("\n", file=p_fpath, append=TRUE)

# Content
# Loop over time dimension
for (kt in t) {
  # Loop over regions
  for (kr in r) {
    cat(
      paste(
        p_varname, 
        "(\"", 
          as.character(kt), "\",", 
          as.character(kr), 
        ")=", 
        as.character(v_tax[which(t == kt)]), ";\n", sep=""
      ), 
      file=p_fpath, 
      append=TRUE
    )
  }
}
cat("\n", file=p_fpath, append=TRUE)
cat("* EOF generated with r_gen_co2_tax.r\n", file=p_fpath, append=TRUE)
