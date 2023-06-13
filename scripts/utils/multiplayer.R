lockID <- gms::model_lock()
bashfile <- "multiplayer.sh"
if (! file.exists(bashfile)) bashfile <- file.path("scripts", "utils", bashfile)
if (file.exists(bashfile)) {
  sq <- system(paste0("squeue -u ", Sys.info()[["user"]], " -o '%q %j' | grep -v multiplayer"), intern = TRUE)
  freepriority <- max(0, 4 - sum(grepl("^priority ", sq)))
  message(freepriority)
  code <- readLines(con = bashfile)
  start <- min(freepriority, length(code))
  message(Sys.info()[["user"]], " starting ", start, " runs at ", Sys.time(), ".")
  if (start > 0) {
    for (c in code[seq(start)]) {
      exitCode <- system(c)
      if (0 < exitCode) {
        message("System call failed, not deleting line ", c, ".")
      }
      code <- setdiff(code, c)
    }
    if (length(code) > 0) {
      write(code, file = bashfile, append = FALSE)
      message("Still ", length(code), " open.")
    } else {
      file.remove(bashfile)
      message(bashfile, " emptied.")
    }
  }
} else {
  message(bashfile, " does not exist, skipping.")
}
Rfile <- "multiplayer.R"
if (! file.exists(Rfile)) Rfile <- file.path("scripts", "utils", Rfile)
if (file.exists(Rfile) {
  system(paste0("sbatch --qos=standby --wrap='Rscript ", Rfile, "' --job-name=multiplayer --output=multiplayer.out --error=multiplayer.out --open-mode=append --time=10 --begin=now+15minutes"))
}
gms::model_unlock(lockID)

