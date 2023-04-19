env <- paste0("unset R_PROFILE_USER;unset TESTTHAT;")
withr::with_dir("../..", {
  returnCode <- system2(
    "make", "ensure-reqs",
    env=env
  )
})
if (returnCode != 0) {
  stop("Not all requirements installed. Follow instructions above and re-start tests.")
}
