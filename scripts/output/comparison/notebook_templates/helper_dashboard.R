# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
## script that prepares the plots
region_plot = "EUR"

require(ggplot2)
require(data.table)
require(plotly)
require(moinput)
require(magclass)
require(rmndt)
require(quitte)
require(devtools)
require(dplyr)
setConfig(forcecache=T)

## Aestethics Options 
aestethics <- list("alpha"=0.6,
                   "line" = list("size"= 0.1),
                   "y-axis" = list("color"="#878787","size"= 1/3.78)
)

## Legends and colors

cols <- c("NG" = "#d11141",
          "Liquids" = "#8c8c8c",
          "Hybrid Liquids" = "#ffc425",
          "Hybrid Electric" = "#f37735",
          "BEV" = "#00b159",
          "Electricity" = "#00b159",
          "FCEV" = "#00aedb",
          "Hydrogen" = "#00aedb",
          "Biodiesel" = "#66a182",
          "Synfuel" = "orchid",
          "Oil" = "#2e4057",
          "International Aviation" = "#9acd32",
          "Domestic Aviation" = "#7cfc00",
          "Bus" = "#32cd32",
          "Passenger Rail" = "#2e8b57",
          "Freight Rail" = "#ee4000",
          "Trucks" = "#ff6a6a",
          "International Shipping" = "#cd2626",
          "Domestic Shipping" = "#ff4040",
          "Shipping" = "#ff4040",
          "Truck" = "#ff7f50",
          "Motorbikes" = "#1874cd",
          "Small Cars" = "#87cefa",
          "Large Cars" = "#6495ed",
          "Van" = "     #40e0d0",
          "LDV" = "#00bfff",
          "Non motorized" = "#da70d6",
          "Freight"="#ff0000",
          "Freight (Inland)" = "#cd5555",
          "Pass non LDV" = "#6b8e23",
          "Pass" = "#66cdaa",
          "Pass non LDV (Domestic)" = "#54ff9f",
          "refined liquids enduse" = "#8c8c8c",
          "FE|Transport|Hydrogen" = "#00aedb",
          "FE|Transport|NG" = "#d11141",
          "FE|Transport|Liquids" = "#8c8c8c",
          "FE|Transport|Electricity" = "#00b159",
          "FE|Transport" = "#1e90ff",
          "FE|Buildings" = "#d2b48c",
          "FE|Industry" = "#919191",
          "ElecEra" = "#00b159",
          "ElecEraWise" = "#68c6a4",
          "HydrHype" = "#00aedb",
          "HydrHypeWise" = "#o3878f",
          "Hydrogen_push" = "#00aedb",
          "Conservative_liquids" = "#113245",
          "ConvCase" = "#113245",
          "Baseline" = "#d11141",
          "ConvCaseWise" = "#d11141",
          "SynSurge" = "orchid",
          "Fossil fuels" = "#113245")

legend_ord_modes <- c("Freight Rail", "Truck", "Shipping", "International Shipping", "Domestic Shipping",  "Trucks",
                      "Motorbikes", "Small Cars", "Large Cars", "Van",
                      "International Aviation", "Domestic Aviation","Bus", "Passenger Rail",
                      "Freight", "LDV", "Pass non LDV", "Freight (Inland)", "Pass non LDV (Domestic)", "Non motorized")

legend_ord_fuels <- c("BEV", "Electricity", "Hybrid Electric", "FCEV", "Hydrogen", "Hybrid Liquids", "Liquids", "Oil", "Biodiesel", "Synfuel", "NG")

legend_ord = c(legend_ord_modes, legend_ord_fuels)

## customize ggplotly

plotlyButtonsToHide <- list('sendDataToCloud', 'zoom2d', 'pan2d', 'select2d', 'lasso2d', 'zoomIn2d', 'zoomOut2d', 'autoScale2d', 'resetScale2d', 'hoverClosestCartesian', 'hoverCompareCartesian', 'zoom3d', 'pan3d', 'orbitRotation', 'tableRotation', 'resetCameraDefault3d', 'resetCameraLastSave3d', 'hoverClosest3d', 'zoomInGeo', 'zoomOutGeo', 'resetGeo', 'hoverClosestGeo', 'hoverClosestGl2d', 'hoverClosestPie', 'resetSankeyGroup', 'toggleHover', 'resetViews', 'toggleSpikelines', 'resetViewMapbox')

## Load files
EJmode_all = readRDS("EJmode_all.RDS")
EJroad_all = readRDS("EJroad_all.RDS")
fleet_all = readRDS("fleet_all.RDS")
salescomp_all = readRDS("salescomp_all.RDS")
ESmodecap_all = readRDS("ESmodecap_all.RDS")
ESmodeabs_all = readRDS("ESmodeabs_all.RDS")
CO2km_int_newsales_all = readRDS("CO2km_int_newsales_all.RDS")
EJpass_all = readRDS("EJfuelsPass_all.RDS")
emipSource_all = readRDS("emipSource_all.RDS")

## scenarios
scens = unique(EJmode_all$scenario)

## plot functions
vintcomparisondash = function(dt, scen){
  
  dt = dt[year %in% seq(2020, 2050, 5)]
  dt[, year := as.character(year)]
  dt = dt[region == region_plot & scenario == scen]
  dt = dt[,.(value = sum(value)), by = c("region", "technology", "year")]
  dt[, details := paste0("Vehicles: ", round(value, 0), " [million]", "<br>", "Technology: ", technology, "<br>", "Region: ", region," <br>", "Year: ", year) ]
  plot = ggplot()+
    geom_bar(data = dt,
             aes(x = year, y = value, group = technology, text = details, fill = technology, width=.75), position="stack", stat = "identity", width = 0.5)+
    guides(fill = guide_legend(reverse=TRUE))+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1, size = 8),
          axis.text.y = element_text(size=8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"),
          legend.position = "none")+
    scale_alpha_discrete(breaks = c(1,0), name = "Status", labels = c("Vintages","New additions")) +
    guides(linetype=FALSE,
           fill=guide_legend(reverse=FALSE, title="Transport mode"))+
    scale_fill_manual(values = cols)+
    ylim(0, 650)+
    labs(x = "", y = "")
  
  
  plot = ggplotly(plot, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE)%>%
    layout(yaxis=list(title='[million veh]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$technology))
  
  output = list(plot = plot,
                vars = vars)
}


vintscen_dash = function(dt){
  dt[, scenario := ifelse(scenario == "NDC_ConvCase", "Baseline", scenario)]
  dt = dt[year %in% c(2020, 2030, 2050)]
  dt[, year := as.character(year)]
  dt = dt[region == region_plot]
  dt = dt[,.(value = sum(value)), by = c("region", "technology", "year", "scenario")]
  dt[, scenario := gsub(".*_", "", scenario)]
  dt[, scenario := factor(scenario, levels = c("Baseline", "ConvCase", "HydrHype", "ElecEra", "SynSurge"))]
  dt[, details := paste0("Vehicles: ", round(value, 0), " [million]", "<br>", "Technology: ", technology, "<br>", "Region: ", region," <br>", "Year: ", year) ]
  g1 = ggplot()+
    geom_bar(data = dt[year %in% c(2030, 2050)],
             aes(x = scenario, y = value, group = technology, text = details, fill = technology, width=.75), position="stack", stat = "identity", width = 0.5)+
    guides(fill = guide_legend(reverse=TRUE))+
    facet_wrap(~year, nrow = 1)+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1, size = 8),
          axis.text.y = element_blank(),
          axis.line = element_line(size = 0.5, colour = "grey"),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"),
          legend.position = "none")+
    scale_alpha_discrete(breaks = c(1,0), name = "Status", labels = c("Vintages","New additions")) +
    guides(linetype=FALSE,
           fill=guide_legend(reverse=FALSE, title="Transport mode"))+
    scale_fill_manual(values = cols)+
    ylim(0, 650)+
    labs(x = "", y = "")
  
  g2 = ggplot()+
    geom_bar(data = dt[year == 2020 & scenario == "ConvCase"][, scenario := "Historical"],
             aes(x = scenario, y = value, group = technology, text = details, fill = technology, width=.75), position="stack", stat = "identity", width = 0.5)+
    guides(fill = guide_legend(reverse=TRUE))+
    facet_wrap(~year, nrow = 1)+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1, size = 8),
          axis.text.y = element_text(size=8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"),
          legend.position = "none")+
    scale_alpha_discrete(breaks = c(1,0), name = "Status", labels = c("Vintages","New additions")) +
    guides(linetype=FALSE,
           fill=guide_legend(reverse=FALSE, title="Transport mode"))+
    scale_fill_manual(values = cols)+
    ylim(0, 650)+
    labs(x = "", y = "")
  
  
  plot = subplot(ggplotly(g2, tooltip = c("text")), ggplotly(g1, tooltip = c("text")), nrows = 1, widths = c(0.12,0.88))
  
  
  plot = ggplotly(plot) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE)%>%
    layout(yaxis=list(title='[million veh]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$technology))
  
  output = list(plot = plot,
                vars = vars)
}



salescomdash = function(dt, scen){
  
  dt = dt[region == region_plot & scenario == scen & year %in% seq(2020, 2050, 5)]
  dt[, year := as.numeric(as.character(year))]
  dt[, details := paste0("Share: ", round(shareFS1*100, digits = 0), " %", "<br>", "Technology: ", technology, "<br>", "Region: ", region," <br>", "Year: ", year) ] 
  ## normalize shares so to have sum to 1
  dt[, shareFS1 := round(shareFS1*100, digits = 0)]
  dt[, shareFS1 := shareFS1/sum(shareFS1), by = c("region", "year")]
  plot = ggplot()+
    geom_bar(data = dt, aes(x = year,y = round(shareFS1*100,0), group = technology, fill = technology, text = details), position = position_stack(), stat = "identity")+
    theme_minimal()+
    scale_fill_manual("Technology", values = cols)+
    expand_limits(y = c(0,1))+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1, size = 8),
          axis.text.y = element_text(size=8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"),
          legend.position = "none")+
    labs(x = "", y = "")
  
  plot = ggplotly(plot, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE)%>%
    layout(yaxis=list(title='[%]', titlefont = list(size = 10)))
  
  ## vars used for creating the legend in the dashboard
  vars = as.character(unique(dt$technology))
  
  output = list(plot = plot,
                vars = vars)
  
  return(output)
}

ESmodecapdash = function(dt, scen){
  dt = dt[region == region_plot & scenario == scen & year <= 2050]
  dt[, details := paste0("Demand: ", round(cap_dem, digits = 0), ifelse(mode == "pass", " [km]",  " [tkm/cap]"), "<br>", "Vehicle: ", vehicle_type_plot, "<br>", "Region: ", region," <br>", "Year: ", year) ] 
  
  plot_pass = ggplot()+
    geom_area(data = dt[mode == "pass"], aes(x = year, y = cap_dem, group = vehicle_type_plot, fill = vehicle_type_plot, text = details), position= position_stack())+
    labs(x = "", y = "")+
    theme_minimal()+
    scale_fill_manual("Vehicle Type", values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    ylim(0,32000)+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey"))
  
  plot_frgt = ggplot()+
    geom_area(data = dt[mode == "freight"], aes(x=year, y=cap_dem, group = vehicle_type_plot, fill = vehicle_type_plot, text = details), position= position_stack())+
    labs(x = "", y = "")+
    theme_minimal()+
    scale_fill_manual("Vehicle Type", values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    ylim(0,64000)+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey")) 
  
  plot_pass = ggplotly(plot_pass, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[km]', titlefont = list(size = 10)))
  plot_frgt = ggplotly(plot_frgt, tooltip = c("text")) %>% 
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[tkm/cap]', titlefont = list(size = 10)))
  
  vars_pass = as.character(unique(dt[mode == "pass"]$vehicle_type_plot))
  vars_frgt = as.character(unique(dt[mode == "freight"]$vehicle_type_plot))
  
  output = list(plot = list(plot_pass = plot_pass, plot_frgt = plot_frgt),
                vars = list(vars_pass = vars_pass, vars_frgt = vars_frgt))
  
  return(output)
  
}



ESmodeabs_dash = function(dt, scen){
  dt = dt[region == region_plot & scenario == scen & year <= 2050]
  dt[, details := paste0("Demand: ", round(demand_F, digits = 1), ifelse(mode == "pass", " [trillion pkm]",  " [trillion tkm]"), "<br>", "Vehicle: ", vehicle_type_plot, "<br>", "Region: ", region," <br>", "Year: ", year) ] 
  
  plot_pass = ggplot()+
    geom_area(data = dt[mode == "pass"], aes(x = year, y = demand_F, group = vehicle_type_plot, fill = vehicle_type_plot, text = details), position= position_stack())+
    labs(x = "", y = "")+
    theme_minimal()+
    scale_fill_manual("Vehicle Type", values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    ylim(0, 17)+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey"))
  
  plot_pass = ggplotly(plot_pass, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[trillion pkm]', titlefont = list(size = 10)))

  vars_pass = as.character(unique(dt[mode == "pass"]$vehicle_type_plot))
  
  output = list(plot = plot_pass,
                vars = vars_pass)
  
  return(output)
  
}


EJpass_dash = function(dt, scen){
  dt = dt[region == region_plot & scenario == scen & year >= 2020  & year <= 2050 & sector == "trn_pass"]
  dt[, details := paste0("Demand: ", round(demand_EJ, digits = 0), " [EJ]","<br>", "Technology: ", subtech, "<br>", "Region: ", region," <br>", "Year: ", year) ]
  
  plot = ggplot()+
    geom_area(data = dt, aes(x = year, y = demand_EJ, group = subtech, fill = subtech, text = details), position= position_stack())+
    theme_minimal()+
    scale_fill_manual("Technology",values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    ylim(0, 20)+
    labs(x = "", y = "")+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey"))
  
  plot = ggplotly(plot, tooltip = c("text")) %>% 
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[EJ]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$subtech))
  
  output = list(plot = plot,
                vars = vars)
  
  return(output)
}

EJpass_scen_dash = function(dt){
  dt[, scenario := ifelse(scenario == "NDC_ConvCase", "Baseline", scenario)]
  dt[, subtech := factor(subtech, levels = legend_ord)]
  dt = dt[region == region_plot & year %in% c(2020, 2030, 2050) & sector == "trn_pass"]
  dt[, details := paste0("Demand: ", round(demand_EJ, digits = 0), " [EJ]","<br>", "Technology: ", subtech, "<br>", "Region: ", region," <br>", "Year: ", year) ]
  dt[, scenario := gsub(".*_", "", scenario)]
  dt[, scenario := factor(scenario, levels = c("Baseline", "ConvCase", "HydrHype", "ElecEra", "SynSurge"))]
  
  g1 = ggplot()+
    geom_bar(data = dt[year %in% c(2030, 2050)], aes(x = scenario, y = demand_EJ, group = subtech,
                                                     fill = subtech, 
                                                     text = details, width=.75), 
             position="stack", stat = "identity", width = 0.5)+
    facet_wrap(~year, nrow = 1)+
    theme_minimal()+
    scale_fill_manual("Technology",values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    ylim(0, 25)+
    labs(x = "", y = "")+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_blank(),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey"))
  
  
  g2 = ggplot()+
    geom_bar(data = dt[year == 2020 & scenario == "ConvCase"][, scenario := "Historical"], aes(x = scenario, y = demand_EJ, group = subtech,
                                                                                               fill = subtech, 
                                                                                               text = details, width=.75), 
             position="stack", stat = "identity", width = 0.5)+
    facet_wrap(~year, nrow = 1)+
    theme_minimal()+
    scale_fill_manual("Technology",values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    ylim(0, 25)+
    labs(x = "", y = "")+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey"))
  
  
  plot = subplot(ggplotly(g2, tooltip = c("text")), ggplotly(g1, tooltip = c("text")), nrows = 1, widths = c(0.12,0.88))
  
  plot = ggplotly(plot) %>% 
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[EJ]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$subtech))
  
  output = list(plot = plot,
                vars = vars)
  
  return(output)
}

CO2km_intensity_newsalesdash = function(dt, scen){
  historical_values = data.table(year = c(2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018), emi = c(159, 157, 145, 140, 137, 132, 128, 124, 120, 119, 119, 120))
  historical_values[, details := "Historical values"]
  targets = data.table(name = c("2021 target", "2025 target", "2030 target"), value = c(95, 95*(1-0.15), 95*(1-0.37)))
  targets[, details := paste0("Policy target")] 
  
  targets[, details_blank := ""]
  dt = dt[!is.na(gCO2_km_ave) & region == region_plot & scenario == scen  & year <= 2050]
  plot = ggplot()+
    geom_line(data = dt[year >=2020], aes(x = year, y = gCO2_km_ave))+
    geom_point(data = historical_values, aes(x = year, y = emi, text = details), color = "grey20")+
    geom_hline(data = targets, aes(yintercept = value, linetype = name, text = details), color = "grey20", size=0.1)+
    geom_text(data = targets, aes(y = value+5, x = c(2025, 2030, 2035), label = name, text = details_blank), size = 3)+
    expand_limits(y = c(0,1))+
    labs(x = "", y = "")+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey"))+
    guides(linetype = FALSE)
  
  plot = ggplotly(plot, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[gCO<sub>2</sub>/km]', titlefont = list(size = 10)))
  
  return(plot)
}


CO2km_intensity_newsales_scen_dash = function(dt){
  dt[, scenario := ifelse(scenario == "NDC_ConvCase", "Baseline", scenario)]
  historical_values = data.table(year = c(2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018), emi = c(159, 157, 145, 140, 137, 132, 128, 124, 120, 119, 119, 120))
  historical_values[, details := "Historical values"]
  targets = data.table(name = c("2021 target", "2025 target", "2030 target"), value = c(95, 95*(1-0.15), 95*(1-0.37)))
  targets[, details := paste0("Policy target")] 
  
  targets[, details_blank := ""]
  dt = dt[!is.na(gCO2_km_ave) & region == region_plot & year <= 2050]
  dt[, scenario := gsub(".*_", "", scenario)]
  dt[, details := paste0(scenario)]
  
  plot = ggplot()+
    geom_line(data = dt[year >=2020], aes(x = year, y = gCO2_km_ave, color = scenario, text = details))+
    geom_point(data = historical_values, aes(x = year, y = emi, text = details), color = "grey20")+
    geom_hline(data = targets, aes(yintercept = value, linetype = name, text = details), color = "grey20", size=0.1)+
    geom_text(data = targets, aes(y = value+5, x = c(2025, 2030, 2035), label = name, text = details_blank), size = 3)+
    expand_limits(y = c(0,1))+
    labs(x = "", y = "")+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90,  size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size = 8),
          strip.background = element_rect(color = "grey"),
          axis.line = element_line(size = 0.5, colour = "grey"))+
    guides(linetype = FALSE)+
    scale_color_manual(values = cols)
  
  plot = ggplotly(plot, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[gCO<sub>2</sub>/km]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$scenario))
  
  output = list(plot = plot,
                vars = vars)
  
  return(output)
}


EJLDVdash <- function(dt, scen){
  dt = dt[subsector_L1 == "trn_pass_road_LDV_4W"]
  dt[, technology := factor(technology, levels = legend_ord)]
  dt = dt[region == region_plot & scenario == scen & year >= 2020 & year <= 2050]
  dt[, details := paste0("Demand: ", round(demand_EJ, digits = 1), " [EJ]","<br>", "Technology: ", technology, "<br>", "Region: ", region," <br>", "Year: ", year) ]
  
  plot = ggplot()+
    geom_area(data = dt, aes(x=year, y=demand_EJ, group = technology, fill = technology, text = details), position= position_stack())+
    labs(x = "", y = "")+
    theme_minimal()+
    scale_fill_manual("Technology", values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    ylim(0, 16)+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90, size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"))
  
  plot = ggplotly(plot, tooltip = c("text")) %>% 
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[EJ]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$technology))
  
  output = list(plot = plot,
                vars = vars)
  
  return(output)
  
}

emip_dash = function(dt, scen){
  dt[, year:= as.numeric(year)]
  dt = dt[region == region_plot & scenario == scen & year <= 2050 & year >= 2020]
  dt = dcast(dt, region + year + scenario  ~ source, value.var = "emi")
  
  dt = melt(dt, id.vars = c("region", "year", "scenario"))
  dt[variable == "synf", type := "Synfuel"]
  dt[variable == "h2", type := "Hydrogen"]
  dt[variable == "elp", type := "Electricity"]
  dt[variable == "liq", type := "Fossil fuels"]
  dt[variable == "synf" & value <0, value := 0]
  
  dt[, details := paste0("Emissions: ", round(value, digits = 0), " [MtCO<sub>2</sub>]", "<br>", "Type: ", type, "<br>", "Region: ", region," <br>", "Year: ", year) ] 
  
  
  plot = ggplot()+
    geom_bar(data = dt[year >= 2020], aes(x = year, y = value, text = details, fill = type, group = type), position = position_stack(), stat = "identity")+
    labs(x = "", y = "")+
    theme_minimal()+
    expand_limits(y = c(0,1))+
    ylim(-80,1800)+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90, size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"))+
    scale_color_manual(values = cols)+
    scale_fill_manual(values = cols)
  
  plot = ggplotly(plot, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[MtCO<sub>2</sub>]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$type))
  
  
  output = list(plot = plot,
                vars = vars)
  return(output)
  
}

emipscen_dash = function(dt){
  dt = dt[region == region_plot & year <= 2050 & year >= 2015]
  dt[, year := as.numeric(year)]
  
  dt[, scenario := ifelse(scenario == "NDC_ConvCase", "Baseline", scenario)]
  dt[, scenario := gsub(".*_", "", scenario)]
 
  dt = dcast(dt, region + year + scenario  ~ source, value.var = "emi")
  
  dt[, tot := h2 + synf + elp + liq]
  dt = melt(dt, id.vars = c("region", "year", "scenario"))
  dt[variable == "tot", type := "Passenger transport emissions, supply and demand"]
  dt[variable == "synf", type := "Synfuels"]
  dt[variable == "h2", type := "Hydrogen"]
  dt[variable == "elp", type := "Electricity"]
  dt[variable == "liq", type := "Fossil fuels"]

  dt[, details := scenario ] 
  
  ptot = ggplot()+
    geom_line(data = dt[variable == "tot"], aes(x = year, y = value, text = details, group = scenario, color = scenario))+
    labs(x = "", y = "")+
    theme_minimal()+
    expand_limits(y = c(0,1))+
    ylim(0,1800)+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90, size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"))+
    scale_color_manual(values = cols)
  
  ptot = ggplotly(ptot, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[MtCO<sub>2</sub>]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$scenario))
  
  
  pfos = ggplot()+
    geom_line(data = dt[variable == "liq"], aes(x = year, y = value, text = scenario, group = scenario, color = scenario))+
    labs(x = "", y = "")+
    theme_minimal()+
    expand_limits(y = c(0,1))+
    ylim(0, 1800)+
    scale_x_continuous(breaks = c(2020, 2030, 2050))+
    theme(axis.text.x = element_text(angle = 90, size = 8, vjust=0.5, hjust=1),
          axis.text.y = element_text(size = 8),
          axis.title = element_text(size = 8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          title = element_text(size = 8),
          legend.position = "none",
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"))+
    scale_color_manual(values = cols)
  
  pfos = ggplotly(pfos, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[MtCO<sub>2</sub>]', titlefont = list(size = 10)))
  
  plot = list(pfos = pfos, ptot = ptot, vars = vars)
  
  return(plot)
  
}


salescom_scen_dash = function(dt){
  dt[, scenario := as.character(scenario)]
  dt[, scenario := ifelse(scenario == "NDC_ConvCase", "Baseline", scenario)]
  dt = dt[region == region_plot & year %in% c(2020, 2030, 2050)]
  dt[, year := as.numeric(as.character(year))]
  dt[, scenario := gsub(".*_", "", scenario)]
  dt[, scenario := factor(scenario, levels = c("Baseline", "ConvCase", "HydrHype", "ElecEra", "SynSurge"))]
  ## normalize shares so to have sum to 1
  dt[, shareFS1 := round(shareFS1*100, digits = 0)]
  dt[, shareFS1 := shareFS1/sum(shareFS1), by = c("region", "year", "scenario")]
  dt[, details := paste0("Share: ", round(shareFS1*100, 0), " %", "<br>", "Technology: ", technology, "<br>", "Region: ", region," <br>", "Year: ", year) ] 
  g1 = ggplot()+
    geom_bar(data = dt[year %in% c(2030, 2050)], aes(x = scenario,y = shareFS1, group = technology, fill = technology, text = details), position = position_stack(), stat = "identity")+
    theme_minimal()+
    scale_fill_manual("Technology", values = cols)+
    expand_limits(y = c(0,1))+
    facet_wrap(~year, nrow = 1)+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1, size = 8),
          axis.text.y = element_blank(),
          axis.line = element_line(size = 0.5, colour = "grey"),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"),
          legend.position = "none")+
    labs(x = "", y = "")
  
  
  g2 = ggplot()+
    geom_bar(data = dt[year == 2020 & scenario == "ConvCase"][, scenario := "Historical"], aes(x = scenario,y = round(shareFS1*100, digits = 0), group = technology, fill = technology, text = details), position = position_stack(), stat = "identity")+
    theme_minimal()+
    scale_fill_manual("Technology", values = cols)+
    expand_limits(y = c(0,1))+
    facet_wrap(~year, nrow = 1)+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1, size = 8),
          axis.text.y = element_text(size=8),
          axis.line = element_line(size = 0.5, colour = "grey"),
          axis.title = element_text(size = 8),
          title = element_text(size = 8),
          strip.text = element_text(size=8),
          strip.background = element_rect(color = "grey"),
          legend.position = "none")+
    labs(x = "", y = "")
  
  
  plot = subplot(ggplotly(g2, tooltip = c("text")), ggplotly(g1, tooltip = c("text")), nrows = 1, widths = c(0.12,0.88))
  
  plot = ggplotly(plot) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE)%>%
    layout(yaxis=list(title='[%]', titlefont = list(size = 10)))
  
  ## vars used for creating the legend in the dashboard
  vars = as.character(unique(dt$technology))
  
  output = list(plot = plot,
                vars = vars)
  
  return(output)
}

legend = list()

create_plotlist = function(scens, salescomp_all, fleet_all, ESmodecap_all, EJfuels_all, CO2km_int_newsales_all, EJLDV_all){
  output = NULL
  
  ## for loop to produce scenario specific results
  for (scen in scens) {
    
    ## attribute scenario name
    if (grepl("Budg1100_ConvCase", scen)) {
      scenname = "ConvCase"
    } else if (grepl("Budg1100_ElecEra", scen)) {
      scenname = "ElecEra"
    } else if (grepl("Budg1100_HydrHype", scen)) {
      scenname = "HydrHype"
    } else if (grepl("Budg1100_SynSurge", scen)) {
      scenname = "SynSurge"
    } else if (grepl("NDC_ConvCase", scen)) {
      scenname = "ConvCase NoTax"
    }
    
    ## CO2 tax pathway
    emiscen = gsub("_.*", "", scen)
    emiscen_names = c("Budg1100" = "2 degrees target",
                      "NDC" = "Baseline")
    emiscen = unname(emiscen_names[emiscen])
    
    ## sales
    salescomp = salescomdash(salescomp_all, scen)
    ## vintages
    vintcomp = vintcomparisondash(fleet_all, scen)
    ## energy services demand per capita
    ESmodecap = ESmodecapdash(ESmodecap_all, scen)
    ## energy services demand, total
    ESmodeabs = ESmodeabs_dash(ESmodeabs_all, scen)
    ## final energy demand
    EJpassfuels = EJpass_dash(EJpass_all, scen) ## Final Energy demand all modes, passenger
    ## CO2 intensity new sales LDVs
    CO2km_int_newsales = CO2km_intensity_newsalesdash(CO2km_int_newsales_all, scen)
    ## final energy LDVs by fuel
    EJLDV = EJLDVdash(EJroad_all, scen)
    ## emissions passenger transport demand and upstream emissions
    emip = emip_dash(emipSource_all, scen)
    
    ## collect plots
    output[[scenname]]$plot$vintcomp = vintcomp$plot
    output[[scenname]]$plot$salescomp = salescomp$plot
    output[[scenname]]$plot$ESmodecap_pass = ESmodecap$plot$plot_pass
    output[[scenname]]$plot$ESmodecap_frgt = ESmodecap$plot$plot_frgt
    output[[scenname]]$plot$ESmodeabs = ESmodeabs$plot
    output[[scenname]]$plot$EJpassfuels = EJpassfuels$plot
    output[[scenname]]$plot$CO2km_int_newsales = CO2km_int_newsales
    output[[scenname]]$plot$EJLDV = EJLDV$plot
    output[[scenname]]$plot$emip = emip$plot
    output[[scenname]]$emiscen = emiscen
  }
  
  ## for loop to produce the comparison plots
  ## vintages
  vintscen = vintscen_dash(fleet_all)
  ## CO2 intensity of new sales
  CO2km_intensity_newsales_scen = CO2km_intensity_newsales_scen_dash(CO2km_int_newsales_all)
  ## Final energy demand
  EJpassfuels_scen = EJpass_scen_dash(EJpass_all)
  ## sales
  salescom_scen = salescom_scen_dash(salescomp_all)
  ## emissions
  emip_scen = emipscen_dash(emipSource_all)
  
  
  output[["comparison"]]$plot$vintscen = vintscen$plot
  output[["comparison"]]$plot$CO2km_intensity_newsales_scen = CO2km_intensity_newsales_scen$plot
  output[["comparison"]]$plot$EJpassfuels_scen = EJpassfuels_scen$plot
  output[["comparison"]]$plot$salescom_scen = salescom_scen$plot
  output[["comparison"]]$plot$emipfos_scen = emip_scen$pfos
  output[["comparison"]]$plot$emiptot_scen = emip_scen$ptot
  
  
  
  legend$'Sales composition'$contents <- lapply(salescomp$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Sales composition'$contents) <- salescomp$vars
  legend$'Sales composition'$description <- "<p>Composition of sales of light duty vehicles</p>"
  
  legend$'Distance traveled per capita'$contents <- lapply(ESmodecap$vars$vars_pass, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Distance traveled per capita'$contents) <- ESmodecap$vars$vars_pass
  legend$'Distance traveled per capita'$description <- "<p>Average distance traveled per capita by transport mode</p>"
  
  legend$'Total Passenger Transport Energy Services Demand'$contents <- lapply(ESmodeabs$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Total Passenger Transport Energy Services Demand'$contents) <- ESmodeabs$vars
  legend$'Total Passenger Transport Energy Services Demand'$description <- "<p>Energy services demand, passenger transport</p>"
  
  legend$'Passenger transport emissions supply and demand'$contents <- lapply(emip$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Passenger transport emissions supply and demand'$contents) <- emip$vars
  legend$'Passenger transport emissions supply and demand'$description <- "<p>Passenger transport emissions supply and demand<p>"
  
  
  legend$'Emission intensity of new sales'$description <- "CO<sub>2</sub> intensity of light duty vehicles sales, historical and projected values"
  
  legend$'Per capita Freight Transport Energy Services Demand'$contents <- lapply(ESmodecap$vars$vars_frgt, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Per capita Freight Transport Energy Services Demand'$contents) <- ESmodecap$vars$vars_frgt
  
  legend$'Final energy LDVs by fuel'$contents <- lapply(EJLDV$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Final energy LDVs by fuel'$contents) <- EJLDV$vars
  legend$'Final energy LDVs by fuel'$description <- "<p>Final energy demand, light duty vehicles, by fuel</p>"
  
  
  legend$'Transport Passenger Final Energy Demand'$contents <- lapply(EJpassfuels$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Transport Passenger Final Energy Demand'$contents) <- EJpassfuels$vars
  legend$'Transport Passenger Final Energy Demand'$description <- "<p>Final energy demand, passenger transport (international aviation excluded)</p>"
  
  legend$'Fleet composition'$contents <- lapply(vintcomp$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Fleet composition'$contents) <- vintcomp$vars
  legend$'Fleet composition'$description <- "<p>Composition of light duty vehicles fleet in selected years</p>"
  
  
  legend$'Fleet composition comparison'$contents <- lapply(vintscen$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Fleet composition comparison'$contents) <- vintscen$vars
  legend$'Fleet composition comparison'$description <- "<p>Composition of light duty vehicles fleet in selected years</p>"
  
  
  legend$'Emission intensity, new sales comparison'$contents <- lapply(CO2km_intensity_newsales_scen$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Emission intensity, new sales comparison'$contents) <- CO2km_intensity_newsales_scen$vars
  legend$'Emission intensity, new sales comparison'$description <- "<p>CO<sub>2</sub> intensity of light duty vehicles sales, historical and projected values</p>"
  
  legend$'Comparison of passenger final energy demand'$contents <- lapply(EJpassfuels_scen$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Comparison of passenger final energy demand'$contents) <- EJpassfuels_scen$vars
  legend$'Comparison of passenger final energy demand'$description <- "<p>Final energy demand, passenger transport (international aviation excluded)</p>"
  
  legend$'Comparison of sales composition'$contents <- lapply(salescom_scen$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Comparison of sales composition'$contents) <- salescom_scen$vars
  legend$'Comparison of sales composition'$description <- "<p>Composition of sales of light duty vehicles in selected years</p>"
  
  legend$'Comparison of passenger transport emissions supply and demand'$contents <- lapply(emip_scen$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Comparison of passenger transport emissions supply and demand'$contents) <- emip_scen$vars
  legend$'Comparison of passenger transport emissions supply and demand'$description <- "<p>Emissions from supply and demand, passenger transport  (includes electricity-related, hydrogen-related, synfuels-related emissions)</p>"
  
  legend$'Comparison of passenger tailpipe emissions from fossil fuels'$contents <- lapply(emip_scen$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Comparison of passenger tailpipe emissions from fossil fuels'$contents) <- emip_scen$vars
  legend$'Comparison of passenger tailpipe emissions from fossil fuels'$description <- "<p>Tailpipe emissions of passenger transport, derived from fossil fuels consumption</p>"
  
  output$legend = legend
  return(output)
  
}

plotlist = create_plotlist(scens, salescomp_all, fleet_all, ESmodecap_all, EJfuels_all, CO2km_int_newsales_all, EJLDV_all)
