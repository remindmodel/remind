# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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

# TODO: Loading magclass shouldn't actually be necessary... but running on the 
# cluster without doing so throws an error...
suppressPackageStartupMessages(library(magclass)) 

# Function defintions
get_run_names <- function(filepaths) {
  # The run names are found between a "/" and the time-stamp of the run.
  run_names <- str_match(filepaths, pattern = "^.*\\/(.*)(_....-..-..*)$")[,2]
  
  # If for some reason there isn't a time-stamp, return the name of the folder
  if (any(is.na(run_names))) {
    run_names <- str_match(filepaths, pattern = "^.*\\/(.*)\\/.*$")[,2]
  }
  return(run_names)
}

policy_costs_pdf <- function(policy_costs,  fileName="PolicyCost.pdf") {
  
  cat(paste0("A pdf with the name ",crayon::green(fileName)," is being created.\n"))
  
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

# Check for an object called "source_include". If found, that means, this script
# is being called from another (output.R most likely), and the input variables
# are already in the environment. If not found, the input variables are given
# default values, and made over-writable with command line values.
if(!exists("source_include")) {
  # Set default value
  outputdirs <- c("../../femulator_hq/remind_runs_lab/base_allT_lab_0point7_2020-03-12_09.36.25",
                  "../../femulator_hq/remind_runs_lab/base_allT_lab_0point95_2020-03-16_15.35.20",
                  "../../femulator_hq/remind_runs_lab/base_allT_lab_0point7_2020-03-12_09.36.25",
                  "../../femulator_hq/remind_runs_lab/base_allT_lab_0point8_2020-03-12_09.36.24")   
  # Make over-writtable from command line
  lucode::readArgs("outputdirs")
  
}

# Check that the input variable "outputdirs" has an even number of entries.
if (length(outputdirs) %% 2!=0) {
  cat(paste0(crayon::red("\nERROR: "), "The number of directories is not even!\n"))
  cat("Remember, the order in which you choose the directories should be:\n")
  cat("\t1: policy run 1\n\t2: reference run 1\n\t3: policy run 2\n\t4: reference run 2\nand so on...\n")
  cat(crayon::red("\nStopping execution now.\n\n"))
  stop("Number of directories is not even!")
}

# Get gdx paths
pol_gdxs <- paste0(outputdirs[seq(1,length(outputdirs),2)], "/fulldata.gdx")
ref_gdxs <- paste0(outputdirs[seq(2,length(outputdirs),2)], "/fulldata.gdx")

# Get run names
pol_names <- get_run_names(pol_gdxs)
ref_names <- get_run_names(ref_gdxs)

# Define pol-ref, policyCost pair names
pc_pairs <- paste0(pol_names, "_w.r.t_",ref_names)

# If scrpit was called from output.R, check with user if the pol-ref pairs are the 
# ones he wanted. 
if(exists("source_include")) {
  cat(crayon::blue("\nPlease confirm the set-up:\n"))
  cat("From the order with which you selected the directories, the following policy-cost curves will be created:\n")
  cat(crayon::green(paste0("\t", pc_pairs ,"\n")))
  cat("Is that what you intended?\n")
  cat(paste0("Type '",crayon::green("y"),"' to continue, '",crayon::red("n"),"' to abort: "))
  user_input <- get_line()
  if(!user_input %in% c("y","Y","yes")) {
    cat(crayon::red("\nShame... \n"))
    cat("Remember, the order in which you choose the directories should be:\n")
    cat("\t1: policy run 1\n\t2: reference run 1\n\t3: policy run 2\n\t4: reference run 2\nand so on...\n")
    cat(crayon::red("\nStopping execution now.\n\n"))
    stop("Wrong set up.")
  } else cat(crayon::green("Great!\n"))
}

# Tell the user what's going on
cat(crayon::blue("\nPolicy cost computations:\n"))

# Get Policy costs for every policy-reference pair
tmp_policy_costs <- mapply(remind::reportPolicyCosts, pol_gdxs, ref_gdxs, SIMPLIFY = FALSE) %>% 
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

# Tell the user what's going on
cat(crayon::green("Done!\n"))

# Create Pdf
cat(crayon::blue("\nPdf creation:\n"))
time_stamp <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")
policy_costs_pdf(policy_costs, fileName = paste0("PolicyCost",time_stamp,".pdf"))
cat(crayon::green("Done!\n\n"))
