# basics
REMIND uses [renv](https://rstudio.github.io/renv/) for managing required R packages. When starting R from the REMIND folder the corresponding renv is automatically activated. This means that packages are installed to and loaded from the renv subfolder instead of the usual package library. Thus updates in the global package library do not affect REMIND which is especially important on multi-user systems where packages may be loaded by some users while others are updating these packages. In such a situation the loaded packages are no longer valid and R crashes. Another advantage of renv is that it documents exactly which packages are currently installed, and it makes it easy to go back to a previous package configuration via `renv.lock` files.

## REMIND renv structure
### main renv
- used when starting R in main folder, e.g. `Rscript output.R`
- modify via scripts, see below

### run renv
- each run has its own run renv
- standalone/first run: main renv is copied to run folder; if you set `options(autoRenvUpdates = TRUE)` the updateRenv script is run before copying
- subsequent runs: renv from the previous run is copied -> all runs in a cascade use the same renv
- run renv is used for the run itself and automatic post-processing
- run renvs should ensure reproducibility, so they must never change

## scripts
### updateRenv
- path: scripts/utils/updateRenv.R
- updates all pik-piam packages in main renv
- copies updated renv.lock to archive

### restoreRenv
- path: scripts/utils/restoreRenv.R
- resets main renv to earlier state recorded in renv.lock file from the archive or from previous runs
- run as `Rscript scripts/utils/restoreRenv.R path/to/renv.lock` to restore given lockfile

# advanced
## renv files
### renv.lock
- text file which lists for each installed package:
	- version
	- source repo (CRAN, GitHub, ...)
- any renv can be reset to state described in renv.lock

### .Rprofile
- sourced whenever R is started in the same folder as the .Rprofile
- activates the corresponding renv

### renv folder
- auto-generated and managed by renv
- renv settings
- actual package library
- renv.lock archive folder

## renv.lock archive
### renv/archive folder
- renv.lock is copied here after updating packages
- restore renv.lock using restoreRenv script

### archiveRenv
- path: scripts/utils/archiveRenv.R
- copies timestamp-renamed main renv.lock to archive
- only need to run this manually after using renv functions directly, see below

## renv functions
The scripts explained earlier should cover all common tasks, use the following for more control.
- `renv::install("package@2.3.4")` install specific package version
- `renv::install("githubuser/package", ref = "<commit hash>")` install package from GitHub, optionally provide commit hash
- `renv::install("/p/tmp/username/yourpackagefolder")` install package from sources
- `renv::remove("package")` uninstall package
- `renv::update(exclude = "renv")` update all packages except renv (please do not update renv itself)
- `renv::update("package")` update package
- `renv::status()` show differences between library and renv.lock
- `renv::snapshot()` write state of library to renv.lock
- renv documentation: https://rstudio.github.io/renv/

## package development
When testing packages in development use `renv::install("githubuser/package")` to install the package from your fork. Do not set `options(autoRenvUpdates = TRUE)`, otherwise your custom package might get overwritten by auto updates.

# legacy snapshots
Before REMIND started using renv it was using so-called "snapshots" to get a stable package environment. You can restore this snapshot machinery (and disable renv) by renaming `.snapshot.Rprofile` -> `.Rprofile`. If you do, please make sure to *not* commit your changes to `.Rprofile`. For coupled model runs you need to use snapshots, renv does not cover that use case yet. Snapshot support will be removed when coupled model runs are possible with renv.
