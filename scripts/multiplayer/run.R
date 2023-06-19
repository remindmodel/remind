folder <- getwd()
message("\n### ", Sys.info()[["user"]], " checking at ", Sys.time(), ".")
Rfile <- "run.R"
if (basename(folder) == "multiplayer" && file.exists(Rfile)) {
  setwd(file.path("..", ".."))
}
multiplayerfolder <- file.path("scripts", "multiplayer")
lockID <- try(gms::model_lock(folder = multiplayerfolder, file = ".lock", timeout1 = 0.05), silent = TRUE)
if (inherits(lockID, "try-error")) {
  message("Could not get lock within 3 minutes, skipping.")
} else {
  bashfile <- file.path(multiplayerfolder, "slurmjobs.sh")
  if (file.exists(bashfile)) {
    sq <- system(paste0("squeue -u ", Sys.info()[["user"]], " -o '%q %j' | grep -v multiplayer"), intern = TRUE)
    freepriority <- max(0, 4 - sum(grepl("^priority ", sq)))
    code <- readLines(con = bashfile)
    code <- code[code != ""]
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
      write(code, file = bashfile, append = FALSE)
      message("\n# Still ", length(code), " runs left.")
    }
  } else {
    stop("### ", bashfile, " does not exist, stopping multiplayer mode for ", Sys.info()[["user"]])
  }
  gms::model_unlock(lockID)
}
mins <- 30
setwd(multiplayerfolder)
system(paste0("sbatch --qos=short --wrap='Rscript --vanilla ", Rfile, "' --job-name=multiplayer ",
              "--output=log.txt --error=log.txt --open-mode=append --time=5 --begin=now+", mins, "minutes"))
message("### ", Sys.info()[["user"]], " will be back in ", mins, " minutes.\n")
