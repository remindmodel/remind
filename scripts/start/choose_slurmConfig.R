#######################################################################
############### Select slurm partitiion ###############################
#######################################################################

get_line <- function(){
  # gets characters (line) from the terminal or from a connection
  # and returns it
  if(interactive()){
    s <- readline()
  } else {
    con <- file("stdin")
    s <- readLines(con, 1, warn=FALSE)
    on.exit(close(con))
  }
  return(s);
}

choose_slurmConfig <- function() {
  
  slurm <- suppressWarnings(ifelse(system2("srun",stdout=FALSE,stderr=FALSE) != 127, TRUE, FALSE))
  if (slurm) { 
    modes <- c(" 1: SLURM standby               12   nash H12             [recommended]",
               " 2: SLURM standby               13   nash H12 coupled",
               " 3: SLURM standby               16   nash H12+",
               " 4: SLURM standby                1   nash debug, testOneRegi, reporting",
               "-----------------------------------------------------------------------",
               " 5: SLURM priority              12   nash H12             [recommended]",
               " 6: SLURM priority              13   nash H12 coupled",
               " 7: SLURM priority              16   nash H12+",
               " 8: SLURM priority               1   nash debug, testOneRegi, reporting",
               "-----------------------------------------------------------------------",
               " 9: SLURM short                 12   nash H12",
               "10: SLURM short                 16   nash H12+",
               "11: SLURM short                  1   nash debug, testOneRegi, reporting",
               "12: SLURM medium                 1   negishi",
               "13: SLURM long                   1   negishi")

    cat("\nCurrent cluster utilization:\n")
    system("sclass")
    cat("\n")

    cat("\nPlease choose the SLURM configuration for your submission:\n")
    cat("    QOS             tasks per node   suitable for\n=======================================================================\n")
    #cat(paste(1:length(modes), modes, sep=": " ),sep="\n")
    cat(modes,sep="\n")
    cat("=======================================================================\n")
    cat("Number: ")
    identifier <- get_line()
    identifier <- as.numeric(strsplit(identifier,",")[[1]])
    comp <- switch(identifier,
                   "1" = "--qos=standby --nodes=1 --tasks-per-node=12"  , # SLURM standby  - task per node: 12 (nash H12) [recommended]
                   "2" = "--qos=standby --nodes=1 --tasks-per-node=13"  , # SLURM standby  - task per node: 13 (nash H12 coupled)
                   "3" = "--qos=standby --nodes=1 --tasks-per-node=16"  , # SLURM standby  - task per node: 16 (nash H12+)
                   "4" = "--qos=standby --nodes=1 --tasks-per-node=1"   , # SLURM standby  - task per node:  1 (nash debug, test one regi)
                   "5" = "--qos=priority --nodes=1 --tasks-per-node=12" , # SLURM priority - task per node: 12 (nash H12) [recommended]
                   "6" = "--qos=priority --nodes=1 --tasks-per-node=13" , # SLURM priority - task per node: 13 (nash H12 coupled)
                   "7" = "--qos=priority --nodes=1 --tasks-per-node=16" , # SLURM priority - task per node: 16 (nash H12+)
                   "8" = "--qos=priority --nodes=1 --tasks-per-node=1"  , # SLURM priority - task per node:  1 (nash debug, test one regi)
                   "9" = "--qos=short --nodes=1 --tasks-per-node=12"    , # SLURM short    - task per node: 12 (nash H12)
                  "10" = "--qos=short --nodes=1 --tasks-per-node=16"    , # SLURM short    - task per node: 16 (nash H12+)
                  "11" = "--qos=short --nodes=1 --tasks-per-node=1"     , # SLURM short    - task per node:  1 (nash debug, test one regi)
                  "12" = "--qos=medium --nodes=1 --tasks-per-node=1"    , # SLURM medium   - task per node:  1 (negishi)
                  "13" = "--qos=long --nodes=1 --tasks-per-node=1"      ) # SLURM long     - task per node:  1 (negishi)
                  
    if(is.null(comp)) stop("This type is invalid. Please choose a valid type")
  } else {
    comp <- "direct"
  }

  return(comp)
}
