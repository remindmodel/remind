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
    modes <- c(" SLURM standby ",
               " SLURM priority"
               )

    cat("\nCurrent cluster utilization:\n")
    system("sclass")
    cat("\n")

    cat("\nPlease choose run submission type:\n")
    cat(paste(1:length(modes), modes, sep=": " ),sep="\n")
    cat("Number: ")
    identifier <- get_line()
    identifier <- as.numeric(strsplit(identifier,",")[[1]])
    comp <- switch(identifier,
                   "1" = "--qos=standby --nodes=1 --tasks-per-node=1"   ,
                   "2" = "--qos=priority --nodes=1 --tasks-per-node=1"  )
                  
    if(is.null(comp)) stop("This type is invalid. Please choose a valid type")
  } else {
    comp <- "direct"
  }

  return(comp)
}
