test_that("all gms files have SOF and EOF statements", {
  grepnotavailable <- Sys.which("grep") == ""
  if (! grepnotavailable) {
    files <- paste0("../../", c("core/", "modules/", paste0("modules/", c("*/", "*/*/"))), "*.gms")
    SOF <- try(system(paste("grep -L '\\*\\*\\* *SOF.*$'", paste(files, collapse = " ")), intern = TRUE), silent = TRUE)
    EOF <- try(system(paste("grep -L '\\*\\*\\* *EOF.*$'", paste(files, collapse = " ")), intern = TRUE), silent = TRUE)
    missingSOFEOF <- sub("../../", "", sort(unique(c(SOF, EOF))), fixed = TRUE)
    expect_length(missingSOFEOF, 0)
    if (length(missingSOFEOF) > 0) {
      warning("These gms files lack SOF or EOF statements:\n", paste(missingSOFEOF, collapse = "\n"),
              "\nAdd '*** SOF' at the beginning and '*** EOF' at the end of the files and then run './scripts/utils/SOFEOF'")
    }
  }
})
