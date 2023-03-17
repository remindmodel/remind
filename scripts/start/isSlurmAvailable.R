#' Is Slurm Avaiable
#'
#' Checks whether slurm is available so that jobs can be submitted, e.g., via \code{sbatch ...}.
#'
#' @return \code{logical(1)}. Whether slurm is available.
isSlurmAvailable <- function() {
  return(suppressWarnings(system2("srun", stdout = FALSE, stderr = FALSE) != 127))
}
