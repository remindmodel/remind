# basics
REMIND uses [renv](https://rstudio.github.io/renv/) for managing required R packages. When starting R from the REMIND folder the corresponding renv is automatically activated. This means that packages are installed to and loaded from the renv subfolder instead of the usual package library. Thus, updates in the global package library do not affect REMIND. This is especially important on multi-user systems where packages may be loaded by some users while others are updating these packages. In such a situation, the loaded packages are no longer valid and R crashes. Another advantage of renv is that it can document exactly which packages are currently installed, and it makes it easy to go back to a previous package configuration via `renv.lock` files.

## REMIND renv structure
### main renv
- used when starting R in main folder, e.g. `Rscript start.R` or `Rscript output.R`
- should not have renv.lock to prevent confusion when that gets out of sync with the package library
- modify via `piamenv` functions, see below

### run renv
- each run has its own run renv and renv.lock documenting the package environment
- when starting a run the main renv is copied to the run folder
- the run renv is used for the run itself and automatic post-processing
- run renvs should ensure reproducibility, so they must never change

## modifying renv
- to modify your renv use `piamenv` functions described below
- alternatively run `make <target>` on the command line
- `make` is pre-installed except on Windows, run `winget install gnuwin32.make` to install it there
- `make help` will print a list of available targets

### update renv
- updates all pik-piam packages in main renv
- writes updated renv.lock to renv/archive
- when starting a run packages are updated automatically if `options(autoRenvUpdates = TRUE)` is set otherwise possible updates are displayed
- run manually with `piamenv::updateRenv()` (`make update-renv`)

### restore renv
- resets main renv to state recorded in renv.lock file from renv/archive or from existing run folder
- useful for using the same renv as a colleague or for reproducing results of an old run
- run `piamenv::restoreRenv('path/to/renv.lock')`
- or choose renv.lock interactively with `piamenv::restoreRenv()` (`make restore-renv`)

# advanced
## renv files
### renv.lock
- text file which lists for each installed package:
	- version
	- source repo (CRAN, GitHub, ...)
- any renv can be reset to state described in renv.lock (see "restore renv")

### .Rprofile
- in the main REMIND folder (not to be confused with your personal ~/.Rprofile)
- sourced whenever R is started in the same folder as the .Rprofile
- activates the corresponding renv
- one time only: installs all dependencies into renv

### renv folder
- auto-generated and managed by renv, includes the following:
- renv settings
- actual package library
- archive folder for {timestamp}_renv.lock files

## renv functions
The `piamenv` functions explained earlier should cover all common tasks, use the following for more control.
- `renv::install("package@2.3.4")` install specific package version
- `renv::install("githubuser/package", ref = "<commit hash>")` install package from GitHub, optionally provide commit hash
- `renv::install("/p/tmp/username/yourpackagefolder")` install package from sources
- `renv::remove("package")` uninstall package
- `renv::update(exclude = "renv")` (`make update-renv-all`) update all packages except renv (please do not update renv itself)
- `renv::update("package")` update package
- `renv::snapshot()` write renv.lock
- `renv::status()` show differences between library and renv.lock
- `piamenv::archiveRenv()` (`make archive-renv`) write renv.lock to renv/archive
- renv documentation: https://rstudio.github.io/renv/

## package development
When testing packages in development use `renv::install("githubuser/package")` to install the package from your fork. Do not set `options(autoRenvUpdates = TRUE)` and be careful with updates, your custom package might get overwritten otherwise.

# legacy snapshots
Before REMIND started using renv it was using so-called "snapshots" to get a stable package environment. You can restore this snapshot machinery (and disable renv) by renaming `.snapshot.Rprofile` -> `.Rprofile`. If you do, please make sure to *not* commit your changes to `.Rprofile`. Coupled REMIND-MAgPIE runs can now be run using renv, so there is no need to use snapshots anymore. Snapshot support will be removed soon.
