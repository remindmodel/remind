# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(dplyr)
library(tidyr)
library(quitte)

#' @param i_data quitte object
#' @param scenBaseNoDamage string with scenario name of baseline (NPi) without damages
#' @param scenNoDamage string with scenario name without damages
#' @param scenDamage string with scenario name with damages
#' @param damageName description of damage type (such as high, medium, ...)

computeCostsScen <- function(i_data, scenBaseNoDamage, scenNoDamage, scenDamage, damageName) {
  i_data <- i_data %>%
    mutate(model = paste(model)) %>%
    mutate(scenario = paste(scenario)) %>%
    mutate(region = paste(region)) %>%
    mutate(variable = paste(variable)) %>%
    mutate(unit = paste(unit))

  message("Compute GDP with damages")
  tmp0_gdpwdamages <- i_data %>%
    filter(scenario == scenDamage, variable %in% c("GDP|MER", "GDP|PPP", "Damage factor")) %>%
    select(-unit) %>%
    pivot_wider(names_from="variable", values_from="value") %>%
    mutate(`GDP|MER|w/ Macro-Economic Climate Damage` = `GDP|MER` * `Damage factor`) %>%
    mutate(`GDP|PPP|w/ Macro-Economic Climate Damage` = `GDP|PPP` * `Damage factor`) %>%
    mutate(`GDP|PPP|including chronic physical risk damage estimate` = `GDP|PPP|w/ Macro-Economic Climate Damage`) %>%
    mutate(`GDP|MER|including chronic physical risk damage estimate` = `GDP|MER|w/ Macro-Economic Climate Damage`) %>%
    mutate(unit = "billion US$2017/yr") %>%
    select(-`GDP|MER`, -`GDP|PPP`, -`Damage factor`) %>%
    pivot_longer(names_to="variable", values_to="value", cols=c(-"model", -"scenario", -"region", -"unit", -"period")) %>%
    select(model, scenario, region, variable, unit, period, value)
  tmp0_gdpwdamages$variable[tmp0_gdpwdamages$variable == "GDP|PPP|including chronic physical risk damage estimate"] <- paste0("GDP|PPP|including ", damageName, " chronic physical risk damage estimate")
  tmp0_gdpwdamages$variable[tmp0_gdpwdamages$variable == "GDP|MER|including chronic physical risk damage estimate"] <- paste0("GDP|MER|including ", damageName, " chronic physical risk damage estimate")

  message("Compute climate damage costs")
  tmp1 <- i_data %>%
    filter(scenario == scenDamage, variable %in% c("GDP|MER", "Damage factor")) %>% #, "Consumption"
    select(-unit) %>%
    pivot_wider(names_from="variable", values_from="value") %>%
    mutate(value = `GDP|MER` * `Damage factor`) %>%
    mutate(variable = "GDP|MER") %>%
    mutate(unit = "billion US$2017/yr") %>%
    select(-`GDP|MER`, -`Damage factor`) %>%
    select(model, scenario, region, variable, unit, period, value) %>%
    left_join(
      i_data %>%
        filter(scenario == scenBaseNoDamage) %>%
        filter(variable %in% c("GDP|MER", "Damage factor")) %>% #, "Consumption"
        select(-unit) %>%
        pivot_wider(names_from = "variable", values_from = "value") %>%
        mutate(value = `GDP|MER` * `Damage factor`) %>%
        mutate(variable = "GDP|MER") %>%
        mutate(unit = "billion US$2017/yr") %>%
        select(-scenario, -`GDP|MER`, -`Damage factor`) %>%
        select(model, region, variable, unit, period, value) %>%
        rename(value_ref = value),
      by = c("model", "region", "variable", "unit", "period")
    )

  # Absolute differences
  tmp1_diffabs <- tmp1 %>%
    mutate(value = value - value_ref) %>%
    select(-value_ref) %>%
    mutate(variable = ifelse(variable == "GDP|MER", "Macro-Economic Climate Damage|GDP Change", variable)) #%>%
    #mutate(variable = ifelse(variable == "Consumption", "Macro-Economic Climate Damage|Consumption Change", variable))

  # Recompute global damage values
  tmp1_diffabs <- rbind(
    tmp1_diffabs %>%
      filter(region != "World"),
    tmp1_diffabs %>%
      filter(region != "World") %>%
      group_by(model, scenario, variable, unit, period) %>%
      summarise(value = sum(value)) %>%
      ungroup() %>%
      mutate(region = "World") %>%
      select(model, scenario, region, variable, unit, period, value)
  )

#  # Relative differences
#  tmp1_diffrel <- tmp1 %>%
#    mutate(value = (value - value_ref)/value_ref * 100) %>%
#    select(-value_ref) %>%
#    mutate(variable = ifelse(variable == "GDP|MER", "Macro-Economic Climate Damage|GDP Change", variable)) %>%
#    #mutate(variable = ifelse(variable == "Consumption", "Macro-Economic Climate Damage|Consumption Change", variable)) %>%
#    mutate(unit = "%")

  # Get climate policy costs from scenario without damages and write it to scenario with damages
  tmp2 <- i_data %>%
    filter(scenario == scenNoDamage,
           variable %in% c("Policy Cost|Consumption Loss", "Policy Cost|GDP Loss")) %>%
           mutate(scenario = scenDamage)

  joint <- as_tibble(rbind(tmp1_diffabs, tmp2))

  message("Combine GDP w/ damage, climate damage and policy costs")
  out <- rbind(tmp1_diffabs, tmp2) %>%
    pivot_wider(names_from = "variable", values_from = "value") %>%
    mutate(`Policy Cost and Macro-Economic Climate Damage|GDP Change` = `Macro-Economic Climate Damage|GDP Change`) %>%
    mutate(`Macro-Economic Climate Damage|GDP Change` = `Macro-Economic Climate Damage|GDP Change` - `Policy Cost|GDP Loss`) %>%
    #mutate(`Policy Cost and Macro-Economic Climate Damage|Consumption Change` = `Macro-Economic Climate Damage|Consumption Change`) %>%
    #mutate(`Macro-Economic Climate Damage|Consumption Change` = `Macro-Economic Climate Damage|Consumption Change` + `Policy Cost|Consumption Loss`) %>%
    pivot_longer(names_to = "variable", values_to = "value",
      cols = c("Macro-Economic Climate Damage|GDP Change",
               "Policy Cost|GDP Loss",
               "Policy Cost|Consumption Loss",
               "Policy Cost and Macro-Economic Climate Damage|GDP Change"
    )) %>%
    select(model, scenario, region, variable, unit, period, value) %>%
    rbind(tmp0_gdpwdamages)
  message("Returning damage costs")
  return(out)
}


#' @param mifdata quitte object or csv or xlsx file name
#' @param damagestrings string that differentiate runs with integrated damage
#'    from those without. names(damagestrings) contains the classification
#'    of the risk such as medium or high.
#' @param scenBaseNoDamage string with scenario name of baseline (NPi) without damages
#' @param keepNoDamages boolean whether runs without damages should be kept in the returned data
calculateDamages <- function(mifdata, damagestrings, scenBaseNoDamage, keepNoDamages = FALSE) {
  mifdata <- droplevels(quitte::as.quitte(mifdata))
  if (all(damagestrings == "")) {
    message("no damagestringe found, returning data")
    return(mifdata)
  }
  if (is.null(names(damagestrings))) names(damagestrings) <- gsub("^_|_$", "", damagestrings)
  names(damagestrings) <- ifelse(names(damagestrings) == "", damagestrings, names(damagestrings))
  if (! scenBaseNoDamage %in% levels(mifdata$scenario)) {
    stop("Baseline without damages is missing in mifdata: ", scenBaseNoDamage)
  }

  # construct vectors of damage scenarios and corresponding no-damage scenarios
  scenDamages <- NULL
  scenNoDamages <- NULL
  for (d in seq_along(damagestrings)) {
    scenD <- grep(damagestrings[d], levels(mifdata$scenario), value = TRUE)
    names(scenD) <- rep(names(damagestrings)[d], length(scenD))
    scenNoD <- gsub(damagestrings[d], "", scenD)
    scenDamages <- c(scenDamages, scenD[scenNoD %in% levels(mifdata$scenario)])
    scenNoDamages <- c(scenNoDamages, scenNoD[scenNoD %in% levels(mifdata$scenario)])
  }
  message("Mappings found: ", paste0(scenDamages, " -> ", scenNoDamages, collapse = ", "))
  if (length(scenDamages) == 0) {
    message("No scenario containing damagestring=", damagestrings, " found in mifdata.")
    return(mifdata)
  }

  message("Recompute global damage factor")
  # Recompute global damage factor (weighted average)
  mifdata <- rbind(
    mifdata %>%
      filter(!(variable == "Damage factor" & region == "World")),
    mifdata %>%
      filter(variable %in% c("GDP|PPP", "Damage factor"), region != "World") %>%
      select(-unit) %>%
      pivot_wider(names_from="variable", values_from="value") %>%
      left_join(
        mifdata %>%
          filter(variable == c("GDP|PPP"), region == "World") %>%
          select(-region, -variable, -unit) %>%
          rename(gdp_world = value),
        by = c("model", "scenario", "period")) %>%
      group_by(model, scenario, period) %>%
      summarise(value = sum(`Damage factor` * `GDP|PPP`/gdp_world)) %>%
      ungroup() %>%
      mutate(region = "World") %>%
      mutate(variable = "Damage factor") %>%
      mutate(unit = "1") %>%
      select(model, scenario, region, variable, unit, period, value)
  )

  # Recompute global SCC (SCC is uniform across regions, so we just pick USA here)
  mifdata <- rbind(
    mifdata %>%
      filter(!(variable == "Price|Carbon|SCC" & region == "World")),
    mifdata %>%
      filter(variable == "Price|Carbon|SCC" & region == "USA") %>%
      mutate(region = "World")
  )

  # remove now old data from calculations
  mifdata <- mifdata %>%
    filter(! grepl("chronic physical risk damage estimate|Macro-Economic Climate Damage", variable))

  # remove later from new calculations
  deleteFromMifdata <- c("Policy Cost|GDP Loss", "Policy Cost and Macro-Economic Climate Damage|GDP Change",
                         "Macro-Economic Climate Damage|GDP Change", "Policy Cost|Consumption Loss")
  deleteFromCostdata <- c("GDP|PPP", "GDP|MER", "Damage factor", "Macro-Economic Climate Damage|GDP Change",
                          "Policy Cost and Macro-Economic Climate Damage|GDP Change")
  # Compute costs
  cat("Compute costs...\n")
  returndata <- NULL

  for (s in seq_along(scenDamages)) {
    costdata <- computeCostsScen(mifdata, scenBaseNoDamage, scenNoDamages[s], scenDamages[s], names(scenDamages)[s]) %>%
        filter(! (variable == "Policy Cost|Consumption Loss" & is.na(value))) %>%
        filter(! variable %in% deleteFromCostdata)
    dataDamage <- mifdata %>%
      filter(scenario %in% scenDamages[s]) %>%
      filter(! variable %in% deleteFromMifdata) %>%
      rbind(costdata)
    returndata <- rbind(returndata, dataDamage)
  }
  if (keepNoDamages) {
    returndata <- rbind(filter(mifdata, ! scenario %in% scenDamages), returndata)
  }
  return(droplevels(returndata))
}

nodamagefolder <- "output"
nodamagescenarios <- c("d_delfrag", "d_strain", "o_2c", "h_cpol", "o_lowdem", "o_1p5c", "h_ndc")
curpol <- "h_cpol"
stopifnot(curpol %in% nodamagescenarios)
nodamageiter <- 5
nodamagemifs <- file.path(nodamagefolder, paste0("C_", nodamagescenarios, "-rem-", nodamageiter),
                          paste0("REMIND_generic_C_", nodamagescenarios, "-rem-", nodamageiter, ".mif"))
nodamage <- quitte::as.quitte(nodamagemifs)
levels(nodamage$scenario) <- gsub("-rem-[0-9]+", "", levels(nodamage$scenario))

runnames <- lucode2::getScenNames(outputdir)

damagestrings <- c(medium = "_KLW_d50")

for (r in runnames) {
  message("\n## Deriving mif for ", r)
  mif <- file.path(outputdir, paste0("REMIND_generic_", r, ".mif"))
  filebeforedamagecosts <- gsub("REMIND_generic", "REMIND_beforedamagecosts", mif)
  if (! file.exists(filebeforedamagecosts)) file.copy(mif, filebeforedamagecosts)
  q <- quitte::as.quitte(mif)
  levels(q$scenario) <- gsub("-rem-[0-9]+", "", levels(q$scenario))
  damcosts <- calculateDamages(rbind(q, nodamage), damagestrings, paste0("C_", curpol), keepNoDamages = FALSE)
  q <- quitte::as.quitte(damcosts)
  message("Finished this run (should only be a single name): ", paste(levels(q$scenario), collapse = ", "))
  levels(q$scenario) <- r
  quitte::write.mif(q, mif)
  message("See ", gsub("REMIND_generic", "REMIND_beforedamagecosts", mif), " and ", mif, ".")
}
