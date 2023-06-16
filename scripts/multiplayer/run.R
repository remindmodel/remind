folder <- getwd()
message("\n### ", Sys.info()[["user"]], " checking at ", Sys.time(), ".")
Rfile <- "run.R"
if (! basename(folder) == "multiplayer" || ! file.exists(Rfile)) {
  message("Setting working directory to scripts/multiplayer.")
  setwd(file.path("scripts", "multiplayer"))
  if (! basename(getwd()) == "multiplayer" || ! file.exists(Rfile)) {
    stop("No idea where you are. Please run 'Rscript scripts/multiplayer/start.R' in your REMIND directory")
  }
}
lockID <- gms::model_lock(file = ".lock")
bashfile <- "slurmjobs.sh"
if (file.exists(bashfile)) {
  sq <- system(paste0("squeue -u ", Sys.info()[["user"]], " -o '%q %j' | grep -v multiplayer"), intern = TRUE)
  freepriority <- max(0, 4 - sum(grepl("^priority ", sq)))
  code <- readLines(con = bashfile)
  start <- min(freepriority, length(code))
  message("# With ", freepriority, " free priority slots and ", length(code), " runs waiting, starting ", start, " runs.")
  if (start > 0) {
    for (c in code[seq(start)]) {
      message("\n", c)
      exitCode <- system(c)
      if (0 < exitCode) {
        message("System call failed, not deleting the above line.")
      }
      code <- setdiff(code, c)
    }
    if (length(code) > 0) {
      write(code, file = bashfile, append = FALSE)
      message("\n# Still ", length(code), " runs left.")
    } else {
      file.remove(bashfile)
      message("\n# ", bashfile, " emptied.")
    }
  }
} else {
  message("# ", bashfile, " does not exist, skipping.")
}
gms::model_unlock(lockID)
system(paste0("sbatch --qos=short --wrap='Rscript ", Rfile, "' --job-name=multiplayer --output=log.txt ",
              "--error=log.txt --open-mode=append --time=10 --begin=now+15minutes"))
message("### ", Sys.info()[["user"]], " will be back in 15 minutes.\n\n")
