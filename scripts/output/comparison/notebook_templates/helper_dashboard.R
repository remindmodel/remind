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
          "ConvCaseWise" = "#d11141")

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
EJLDV_all = readRDS("EJLDV_all.RDS")
fleet_all = readRDS("fleet_all.RDS")
salescomp_all = readRDS("salescomp_all.RDS")
ESmodecap_all = readRDS("ESmodecap_all.RDS")
CO2km_int_newsales_all = readRDS("CO2km_int_newsales_all.RDS")
EJfuels_all = readRDS("EJfuels_all.RDS")
emidem_all = readRDS("emidem_all.RDS")

## scenarios
scens = unique(EJmode_all$scenario)

## plot functions
vintcomparisondash = function(dt, scen){
  
  dt = dt[year %in% c(2015, 2030, 2050)]
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
    labs(x = "", y = "")
  
  
  plot = ggplotly(plot, tooltip = c("text")) %>%
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE)%>%
    layout(yaxis=list(title='[million veh]', titlefont = list(size = 10)))
  
  vars = as.character(unique(dt$technology))
  
  output = list(plot = plot,
                vars = vars)
}

salescomdash = function(dt, scen){
  
  dt = dt[region == region_plot & scenario == scen & year <=2050]
  dt[, year := as.numeric(as.character(year))]
  dt[, details := paste0("Share: ", round(shareFS1*100, digits = 0), " %", "<br>", "Technology: ", technology, "<br>", "Region: ", region," <br>", "Year: ", year) ] 
  plot = ggplot()+
    geom_bar(data = dt, aes(x = year,y = round(shareFS1*100, digits = 0), group = technology, fill = technology, text = details), position = position_stack(), stat = "identity")+
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
  dt[, details := paste0("Demand: ", round(cap_dem, digits = 0), ifelse(mode == "pass", " [pkm/cap]",  " [tkm/cap]"), "<br>", "Vehicle: ", vehicle_type_plot, "<br>", "Region: ", region," <br>", "Year: ", year) ] 
  
  plot_pass = ggplot()+
    geom_area(data = dt[mode == "pass"], aes(x = year, y = cap_dem, group = vehicle_type_plot, fill = vehicle_type_plot, text = details), position= position_stack())+
    labs(x = "", y = "")+
    theme_minimal()+
    scale_fill_manual("Vehicle Type", values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    scale_x_continuous(breaks = c(2015, 2030, 2050))+
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
    scale_x_continuous(breaks = c(2015, 2030, 2050))+
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
    layout(yaxis=list(title='[pkm/cap]', titlefont = list(size = 10)))
  plot_frgt = ggplotly(plot_frgt, tooltip = c("text")) %>% 
    config(modeBarButtonsToRemove=plotlyButtonsToHide, displaylogo=FALSE) %>%
    layout(yaxis=list(title='[tkm/cap]', titlefont = list(size = 10)))
  
  vars_pass = as.character(unique(dt[mode == "pass"]$vehicle_type_plot))
  vars_frgt = as.character(unique(dt[mode == "freight"]$vehicle_type_plot))
  
  output = list(plot = list(plot_pass = plot_pass, plot_frgt = plot_frgt),
                vars = list(vars_pass = vars_pass, vars_frgt = vars_frgt))
  
  return(output)
  
}

EJfuels_dash = function(dt, scen){
  dt = dt[region == region_plot & scenario == scen & year >= 2015  & year <= 2050]
  dt[, details := paste0("Demand: ", round(demand_EJ, digits = 0), " [EJ]","<br>", "Technology: ", subtech, "<br>", "Region: ", region," <br>", "Year: ", year) ]
  
  plot = ggplot()+
    geom_area(data = dt, aes(x = year, y = demand_EJ, group = subtech, fill = subtech, text = details), position= position_stack())+
    theme_minimal()+
    scale_fill_manual("Technology",values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    labs(x = "", y = "")+
    scale_x_continuous(breaks = c(2015, 2030, 2050))+
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
    scale_x_continuous(breaks = c(2015, 2030, 2050))+
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

EJLDVdash <- function(dt, scen){
  
  dt[, technology := factor(technology, levels = legend_ord)]
  dt = dt[region == region_plot & scenario == scen & year >= 2015 & year <= 2050]
  dt[, details := paste0("Demand: ", round(demand_EJ, digits = 1), " [EJ]","<br>", "Technology: ", technology, "<br>", "Region: ", region," <br>", "Year: ", year) ]
  
  plot = ggplot()+
    geom_area(data = dt, aes(x=year, y=demand_EJ, group = technology, fill = technology, text = details), position= position_stack())+
    labs(x = "", y = "")+
    theme_minimal()+
    scale_fill_manual("Technology", values = cols, breaks=legend_ord)+
    expand_limits(y = c(0,1))+
    scale_x_continuous(breaks = c(2015, 2030, 2050))+
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

emidem_dash = function(dt, scen){
  dt = dt[region == region_plot & scenario == scen & year <= 2050]
  
  plot = ggplot()+
    geom_line(data = dt, aes(x = year, y = value, text = ""))+
    labs(x = "", y = "")+
    theme_minimal()+
    expand_limits(y = c(0,1))+
    scale_x_continuous(breaks = c(2015, 2030, 2050))+
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
    layout(yaxis=list(title='[MtCO<sub>2</sub>]', titlefont = list(size = 10)))
  
  return(plot)
  
}

legend = list()

create_plotlist = function(scens, salescomp_all, fleet_all, ESmodecap_all, EJfuels_all, CO2km_int_newsales_all, EJLDV_all){
  output = NULL
  for (scen in scens) {
    
    ## attribute scenario name
    if (grepl("ConvCase", scen)) {
      scenname = "ConvCase"
    } else if (grepl("ElecEra", scen)) {
      scenname = "ElecEra"
    } else if (grepl("HydrHype", scen)) {
      scenname = "HydrHype"
    } else if (grepl("SynSurge", scen)) {
      scenname = "SynSurge"
    }
    
    ## CO2 tax pathway
    emiscen = gsub("_.*", "", scen)
    
    ## sales
    salescomp = salescomdash(salescomp_all, scen)
    ## vintages
    vintcomp = vintcomparisondash(fleet_all, scen)
    ## energy services demand
    ESmodecap = ESmodecapdash(ESmodecap_all, scen)
    ## final energy demand
    EJfuels = EJfuels_dash(EJfuels_all, scen) ## Final Energy demand all modes, passenger and freight
    ## CO2 intensity new sales LDVs
    CO2km_int_newsales = CO2km_intensity_newsalesdash(CO2km_int_newsales_all, scen)
    ## final energy LDVs by fuel
    EJLDV = EJLDVdash(EJLDV_all, scen)
    ## emissions transport demand
    emidem = emidem_dash(emidem_all, scen)

    ## collect plots
    output[[scenname]]$plot$vintcomp = vintcomp$plot
    output[[scenname]]$plot$salescomp = salescomp$plot
    output[[scenname]]$plot$ESmodecap_pass = ESmodecap$plot$plot_pass
    output[[scenname]]$plot$ESmodecap_frgt = ESmodecap$plot$plot_frgt
    output[[scenname]]$plot$EJfuels = EJfuels$plot
    output[[scenname]]$plot$CO2km_int_newsales = CO2km_int_newsales
    output[[scenname]]$plot$EJLDV = EJLDV$plot
    output[[scenname]]$plot$emidem = emidem
    output[[scenname]]$emiscen = emiscen
  }
    
  
  legend$'Sales composition'$contents <- lapply(salescomp$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Sales composition'$contents) <- salescomp$vars
  legend$'Per capita Passenger Transport Energy Services Demand'$contents <- lapply(ESmodecap$vars$vars_pass, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Per capita Passenger Transport Energy Services Demand'$contents) <- ESmodecap$vars$vars_pass
  legend$'Per capita Freight Transport Energy Services Demand'$contents <- lapply(ESmodecap$vars$vars_frgt, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Per capita Freight Transport Energy Services Demand'$contents) <- ESmodecap$vars$vars_frgt
  legend$'Final energy LDVs by fuel'$contents <- lapply(EJLDV$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Final energy LDVs by fuel'$contents) <- EJLDV$vars
  legend$'Transport Final Energy Demand'$contents <- lapply(EJfuels$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Transport Final Energy Demand'$contents) <- EJfuels$vars
  legend$'Fleet composition'$contents <- lapply(vintcomp$vars, function(var) { return(list("fill"=toString(cols[var]),"linetype"=NULL)) })
  names(legend$'Fleet composition'$contents) <- vintcomp$vars

  output$legend = legend
  return(output)
  
}

plotlist = create_plotlist(scens, salescomp_all, fleet_all, ESmodecap_all, EJfuels_all, CO2km_int_newsales_all, EJLDV_all)
