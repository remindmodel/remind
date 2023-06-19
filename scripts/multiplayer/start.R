folder <- getwd()
Rfile <- "run.R"
if (! basename(folder) == "multiplayer" || ! file.exists(Rfile)) {
  setwd(file.path("scripts", "multiplayer"))
  if (! basename(getwd()) == "multiplayer" || ! file.exists(Rfile)) {
    stop("No idea where you are. Please run 'Rscript scripts/multiplayer/start.R' from your REMIND directory.")
  }
}

bashfile <- "slurmjobs.sh"
if (! file.exists(bashfile)) {
  lockID <- try(gms::model_lock(file = ".lock", timeout1 = 0.05), silent = TRUE)
  if (inherits(lockID, "try-error")) {
    stop("Could not get lock within 3 minutes, skipping.")
  } else {
    write("", file = bashfile, append = TRUE)
    gms::model_unlock(lockID)
  }
}

command <- paste0("sbatch --qos=short --wrap='Rscript --vanilla ", Rfile, "' --job-name=multiplayer --output=log.txt ",
                  "--error=log.txt --open-mode=append --time=5")

squeueresult <- suppressWarnings(system(paste0("squeue -u ", Sys.info()[["user"]], " -h -o '%j %Z' | grep multiplayer"), intern = TRUE))
if (any(squeueresult == paste("multiplayer", getwd()))) {
  message("\n### A multiplayer job is already running for your user in this folder. Skipping.")
} else {
  message("\n### Thanks for entering multiplayer mode.")
  message("A slurm job named 'multiplayer' on the 'short' qos will be started.")
  message("It tries to start new runs on 'priority' slots regularly and starts itself again.")
  message("If you are ready, delete 'scripts/multiplayer/slurmjobs.sh' which will stop all multiplayer runs.")
  message("Check 'scripts/multiplayer/log.txt' to see the progress.")
  system(command)
}

