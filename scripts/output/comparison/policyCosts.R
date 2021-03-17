# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# policyCosts.R
#
# This script produces a pdf in which the policy costs of policy-runs with 
# respect to specified reference runs are displayed.
# It can be called via the output.R script. If that is the case, the order 
# in which the runs are selected is important:
#   1: policy run 1
#   2: reference run 1
#   3: policy run 2
#   4: reference run 2
# and so on... 
# 

suppressPackageStartupMessages(library(tidyverse))

###########################################################################
# ###### START FUNCTION DEFINITONS ########################################
rm_timestamp <- function(strings,
                         name_timestamp_seperator = "_",
                         timestamp_format = "%Y-%m-%d_%H.%M.%S") {

  # Get regex pattern of timestamp
  regex_timestamp <- gsub("%[mdHMS]", "\\\\d{2}", timestamp_format)
  regex_timestamp <- gsub("%Y", "\\\\d{4}", regex_timestamp)
  regex_timestamp <- paste0(name_timestamp_seperator, regex_timestamp)

  # Substitute timestamps with nothing (thereby removing them)
  my_strings_wo_timeStamp <- sub(regex_timestamp, "", strings)

  return(my_strings_wo_timeStamp)
}


policy_costs_pdf <- function(policy_costs, 
                             fileName="PolicyCost.pdf") {
  
  cat(paste0("A pdf with the name ",crayon::green(fileName)," is being created in the main remind folder.\n"))
  
  template <-  c("\\documentclass[a4paper,landscape,twocolumn]{article}",
                 "\\setlength{\\oddsidemargin}{-0.8in}",
                 "\\setlength{\\evensidemargin}{-0.5in}",
                 "\\setlength{\\topmargin}{-0.8in}",
                 "\\setlength{\\parindent}{0in}",
                 "\\setlength{\\headheight}{0in}",
                 "\\setlength{\\topskip}{0in}",
                 "\\setlength{\\headsep}{0in}",
                 "\\setlength{\\footskip}{0.2in}",
                 "\\setlength\\textheight{0.95\\paperheight}",
                 "\\setlength\\textwidth{0.95\\paperwidth}",
                 "\\setlength{\\parindent}{0in}",
                 "\\usepackage{float}",
                 "\\usepackage[bookmarksopenlevel=section,colorlinks=true,linkbordercolor={0.9882353 0.8352941 0.7098039}]{hyperref}",
                 "\\hypersetup{bookmarks=true,pdfauthor={GES group, PIK}}",
                 "\\usepackage{graphicx}",
                 "\\usepackage[strings]{underscore}",
                 "\\usepackage{Sweave}",
                 "\\begin{document}",
                 "<<echo=false>>=",
                 "options(width=110)",
                 "@")
  
  # Create temporaray folder in which to create the policyCost pdf
  system("mkdir tmp_policyCost")
  
  # Open stream in tmp_folder
  sw <- lusweave::swopen(fileName, folder = "tmp_policyCost", template = template)
  
  # Write title
  lusweave::swlatex(sw,"\\section{Policy Costs}")
  
  # Loop over subsections and create plots
  sub_section_variables <- grep("Policy Cost", names(policy_costs), value = T)
  sub_section_titles <- str_match(sub_section_variables, "\\|(.*) \\(|\\|")[,2]
  
  my_ggplot <- function(data, y_var) {
    gg1 <- ggplot(data) +
      geom_line(aes(x=period, y=!!sym(y_var), color = `Model Output`)) +
      geom_point(aes(x=period, y=!!sym(y_var), color = `Model Output`)) +
      geom_vline(aes(xintercept = min(period)), linetype = 2) +
      facet_wrap("region", ncol = 3, scales = "free_y") +
      xlab("Year") +
      theme_bw() +
      theme(legend.position = "bottom", 
            legend.direction = "vertical",
            legend.title.align=0.5,
            legend.title = element_text(face="bold"),
            axis.title.x = element_text(face="bold"),
            axis.title.y = element_text(face="bold"))
    return(gg1)
  }
  
  for(i in 1:length(sub_section_titles)){
    lusweave::swlatex(sw, paste0("\\subsection{", sub_section_titles[i], "}"))
    
    p <- my_ggplot(filter(policy_costs, region=="GLO"), sub_section_variables[i])
    lusweave::swfigure(sw,print,p,sw_option="height=8,width=8")
    
    p <- my_ggplot(filter(policy_costs, region!="GLO"), sub_section_variables[i])
    lusweave::swfigure(sw,print,p,sw_option="height=9,width=8")
  }
  
  # Close stream to-pdf
  lusweave::swclose(sw)
  
  # Copy pdf from tmp folder to remind folder and delete tmp folder
  system(paste0("mv tmp_policyCost/",fileName," ."))
  system("rm -r tmp_policyCost")
  
}


write_new_reporting <- function(mif_path, 
                                scen_name, 
                                new_polCost_data) {
  
  new_mif_path <- paste0(substr(mif_path,1,nchar(mif_path)-4),"_adjustedPolicyCosts.mif")
  
  cat(paste0("A mif file with the name ",crayon::green(paste0("REMIND_generic_",scen_name,"_adjustedPolicyCosts.mif"))," is being created in the ",scen_name," output folder.\n"))
  
  my_data <- magclass::read.report(mif_path) 
  my_variables <- grep("Policy Cost", magclass::getNames(my_data[[1]][[1]]), value = TRUE, invert = T)
  
  magclass::getSets(new_polCost_data)[1] <- "region"
  magclass::getSets(new_polCost_data)[2] <- "year"
  magclass::getSets(new_polCost_data)[3] <- "variable"
  
  my_data <- magclass::mbind(my_data[[1]][[1]][,,my_variables], new_polCost_data)
  my_data <- magclass::add_dimension(my_data,dim=3.1,add = "model",nm = "REMIND")
  my_data <- magclass::add_dimension(my_data,dim=3.1,add = "scenario",nm = scen_name)
  
  magclass::write.report(my_data, file = new_mif_path, ndigit = 7, skipempty = FALSE)
  
  return(new_mif_path)
}


report_transfers <- function(pol_mif, ref_mif) {
  
  # Read in reporting files
  pol_run <- magclass::read.report(pol_mif,as.list = F)
  ref_run <- magclass::read.report(ref_mif,as.list = F)
  
  # Get model and scenario names
  md <- magclass::getItems(pol_run,3.2)
  sc <- magclass::getItems(pol_run,3.1)
  
  # Tell the user what's going on
  cat(paste0("Adding ",crayon::green("transfers")," to ",paste0("REMIND_generic_",sc,"_adjustedPolicyCosts.mif"),".\n"))
  

  # Get gdploss 
  gdploss <- pol_run[,,"Policy Cost|GDP Loss (billion US$2005/yr)"]
  # Add rel gdploss (not in percent)
  gdploss_rel <- magclass::setNames(pol_run[,,"Policy Cost|GDP Loss|Relative to Reference GDP (percent)"]/100,
                                    "Policy Cost|GDP Loss|Relative to Reference GDP")
  # Get gdp
  gdp_ref <- ref_run[,,"GDP|MER (billion US$2005/yr)"]
  gdp_policy <- pol_run[,,"GDP|MER (billion US$2005/yr)"]
  
  # Calculate difference to global rel gdploss  
  delta_gdploss <- gdploss_rel[,,] - gdploss_rel["GLO",,]
  # Calculate transfer required to equalize rel gdploss across regions
  delta_transfer <- magclass::setNames(delta_gdploss * gdp_ref, 
                                       "Policy Cost|Transfers equal effort (billion US$2005/yr)")
  delta_transfer_rel <- 100*magclass::setNames(delta_transfer/gdp_ref, 
                                               "Policy Cost|Transfers equal effort|Relative to Reference GDP (percent)")
  

  # Calculate new gdp variables
  gdp_withtransfers <- magclass::setNames(gdp_policy + delta_transfer,
                                          "GDP|MER|w/ transfers equal effort (billion US$2005/yr)")
  gdploss_withtransfers <- magclass::setNames(gdp_ref - gdp_withtransfers, 
                                              "Policy Cost|GDP Loss|w/ transfers equal effort (billion US$2005/yr)")
  gdploss_withtransfers_rel <- 100*magclass::setNames(gdploss_withtransfers/gdp_ref,
                                                      "Policy Cost|GDP Loss|w/ transfers equal effort|Relative to Reference GDP (percent)")
  
  # Correct sets
  magclass::getSets(delta_transfer, fulldim = F)[3] <- "variable"
  magclass::getSets(delta_transfer_rel, fulldim = F)[3] <- "variable"
  magclass::getSets(gdp_withtransfers, fulldim = F)[3] <- "variable"
  magclass::getSets(gdploss_withtransfers, fulldim = F)[3] <- "variable"
  magclass::getSets(gdploss_withtransfers_rel, fulldim = F)[3] <- "variable"

  # Bind together
  my_transfers <- NULL
  my_transfers <- magclass::mbind(my_transfers, delta_transfer) %>% 
    magclass::mbind(delta_transfer_rel) %>% 
    magclass::mbind(gdp_withtransfers) %>% 
    magclass::mbind(gdploss_withtransfers) %>% 
    magclass::mbind(gdploss_withtransfers_rel)
  
  pol_run <- magclass::read.report(pol_mif)
  pol_run <- magclass::mbind(pol_run[[1]][[1]][,,], my_transfers) %>% 
    magclass::add_dimension(dim=3.1,add = "model",nm = md) %>% 
    magclass::add_dimension(dim=3.1,add = "scenario",nm = sc)
  
  magclass::write.report(pol_run, file = pol_mif, ndigit = 7, skipempty = FALSE)
  
  return(my_transfers)
}
# ###### END FUNCTION DEFINITONS ########################################
###########################################################################




# Check for an object called "source_include". If found, that means, this script
# is being called from another (output.R most likely), and the input variable 
# "outputdirs" is already in the environment. If not found, "outputdirs" is given
# default values, and made over-writable with the command line.
if(!exists("source_include")) {
  # Set default value
  outputdirs <- c("base_noEffChange_2020-03-09_17.16.28/",
                  "base_allT_lab_1point25_2020-03-27_16.12.35/",
                  "base_allT_lab_1point25_2020-03-27_16.12.35/",
                  "base_noEffChange_2020-03-09_17.16.28/")   
  special_requests <- c("2")
  # Make over-writtable from command line
  lucode2::readArgs("outputdirs","special_requests")
}



# Go into a while loop, until the user is happy with his input, or gives up and exits
happy_with_input <- FALSE
while (!happy_with_input) {
  # Check that "outputdirs" has an even number of entries.
  if (length(outputdirs) %% 2!=0) {
    cat(paste0(crayon::red("\nERROR: "), "The number of directories is not even!\n"))
    cat("Remember, your choice of directories should be made in the follwing manner:\n")
    cat("\t1: policy run 1\n\t2: reference run 1\n\t3: policy run 2\n\t4: reference run 2\nand so on...\n")
    if (exists("choose_folder")) {
      outputdirs <- choose_folder("./output",crayon::blue("Please reselect your ouput folders"))
      outputdirs <- paste0("output/",outputdirs)
    } else {
      cat(crayon::red("\nStopping execution now.\n\n"))
      stop("Number of directories is not even!")
    }
    next()
  }
  
  # Get gdx paths
  pol_gdxs <- paste0(outputdirs[seq(1,length(outputdirs),2)], "/fulldata.gdx")
  ref_gdxs <- paste0(outputdirs[seq(2,length(outputdirs),2)], "/fulldata.gdx")
  
  # Get run names
  pol_names <- rm_timestamp(basename(dirname(pol_gdxs)))
  ref_names <- rm_timestamp(basename(dirname(ref_gdxs)))
  
  # Define pol-ref, policyCost pair names
  pc_pairs <- paste0(pol_names, "_w.r.t_",ref_names)
  
  # If this scrpit was called from output.R, check with user if the pol-ref pairs 
  # are the ones she wanted. 
  if(exists("source_include")) {
    cat(crayon::blue("\nPlease confirm the set-up:\n"))
    cat("From the order with which you selected the directories, the following policy costs will be computed:\n")
    cat(crayon::green(paste0("\t", pc_pairs ,"\n")))
    cat("Is that what you intended?\n")
    cat(paste0("Type '",crayon::green("y"),"' to continue, '",crayon::blue("r"),"' to reselect output directories, '",crayon::red("n"),"' to abort: "))
    
    user_input <- get_line()
    
    if(user_input %in% c("y","Y","yes")) {
      happy_with_input <- TRUE
      cat(crayon::green("Great!\n"))
      
      # Get special requests from user
      cat(crayon::blue("\nDo you have any special requests?\n"))
      cat("1: Skip creation of adjustedPolicyCost reporting\n")
      cat("2: Add transfers to adjustedPolicyCost reporting\n")
      cat("3: Skip plot creation\n")
      cat("4: Plot until 2150 in pdf\n")
      cat("Type the number (or numbers seperated by a comma) to choose the special requests, or nothing to continue without any: ")
      special_requests <- get_line() %>% str_split(",",simplify = T) %>% as.vector()
      
    } else if(user_input %in% c("r","R","reselect")) {
      if (exists("choose_folder")) {
        cat("Remember, the order in which you choose the directories should be:\n")
        cat("\t1: policy run 1\n\t2: reference run 1\n\t3: policy run 2\n\t4: reference run 2\nand so on...\n")
        outputdirs <- choose_folder("./output",crayon::blue("Reselect your ouput folders now"))
        outputdirs <- paste0("output/",outputdirs)
      } else {
        cat(crayon::red("\nStopping execution now.\n\n"))
        stop("Couldn't find choosefolder() function")
      }
    } else {
      cat(crayon::red("\nGood-bye (windows xp shutting down music)... \n"))
      cat(crayon::red("\nStopping execution now.\n\n"))
      stop("I can't figure this **** out. I give up. ")
    }
  } else {
    happy_with_input <- TRUE
  }
}


# Get Policy costs for every policy-reference pair
cat(crayon::blue("\nComputing Policy costs:\n"))
tmp_policy_costs_magpie <- mapply(remind::reportPolicyCosts, pol_gdxs, ref_gdxs, SIMPLIFY = FALSE) 
cat(crayon::green("Done!\n"))


# Create "adjustedPolicyCost" reporting file
if (!"1" %in% special_requests) {
  cat(crayon::blue("\nCreating new reportings:\n"))
  pol_mifs <- paste0(dirname(pol_gdxs), "/REMIND_generic_", pol_names, ".mif")
  new_reporting_files <- mapply(write_new_reporting, pol_mifs, pol_names, tmp_policy_costs_magpie)
  cat(crayon::green("Done!\n"))
}


# Add transfer variables to "adjustedPolicyCost" reporting file
if ("2" %in% special_requests && !"1" %in% special_requests) {
  cat(crayon::blue("\nComputing transfers:\n"))
  ref_mifs <- paste0(dirname(ref_gdxs), "/REMIND_generic_", ref_names, ".mif")
  transfer_info <- mapply(report_transfers, new_reporting_files, ref_mifs, SIMPLIFY = F)
  cat(crayon::green("Done!\n"))
}


# Create Pdf
if (!"3" %in% special_requests) {
  cat(crayon::blue("\nCreating plots:\n"))
  
  # Add transfers, if they exist
  if (exists("transfer_info")) {
    tmp_policy_costs_magpie <- mapply(magclass::mbind, tmp_policy_costs_magpie, transfer_info, SIMPLIFY = F)
  }
  
  tmp_policy_costs <- tmp_policy_costs_magpie %>% 
    lapply(quitte::as.quitte) %>% 
    lapply(select, region, period, data, value)
  
  # Combine results in single tibble, with names like "Pol_w.r.t_Ref"
  policy_costs <- rename(tmp_policy_costs[[1]], !!sym(paste0(pol_names[1], "_w.r.t_",ref_names[1])):=value)
  if (length(tmp_policy_costs)>1){
    for (i in 2:length(tmp_policy_costs)) {
      policy_costs <- tmp_policy_costs[[i]] %>% 
        rename(!!sym(paste0(pol_names[i], "_w.r.t_",ref_names[i])):=value) %>% 
        left_join(policy_costs, tmp_policy_costs[[i]], by=c("region", "period", "data"))
    }
  }
  # and do some pivotting
  policy_costs <- policy_costs %>% 
    pivot_longer(cols = matches(".*w\\.r\\.t.*"), names_to = "Model Output") %>% 
    pivot_wider(names_from = data)
  
  # By default, plots are only created until 2100
  if (!"4" %in% special_requests) {
    policy_costs <- policy_costs %>% filter(period<=2100)
  }
  
  time_stamp <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")
  policy_costs_pdf(policy_costs, fileName = paste0("PolicyCost",time_stamp,".pdf"))
  cat(crayon::green("Done!\n"))
}

cat("\n")
