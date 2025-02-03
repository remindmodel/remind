.PHONY: help docs update-renv update-renv-all archive-renv restore-renv check \
	check-fix test test-coupled test-full set-local-calibration
.DEFAULT_GOAL := help

# extracts the help text and formats it nicely
HELP_PARSING = 'm <- grep("\#\#", readLines("Makefile"), value = TRUE);\
                parse <- "^([^[[:space:]]*)[[:space:]]*\#\#[[:space:]]*(.*)";\
                command <- sub(parse, "\\1", m, perl = TRUE);\
                help <- sub(parse, "\\2",  m, perl = TRUE);\
                i <- grep("^$$", command, invert = TRUE)[-1];\
                command[i] <- paste0("\n", command[i]);\
                help[i] <- paste0(" ", help[i]);\
                cat(sprintf("%-*s%s", max(nchar(command)), command, help),\
                    sep = "\n")'

help:            ## Show this help.
	@Rscript -e $(HELP_PARSING)

docs:            ## Generate/update model HTML documentation in the doc/ folder
	Rscript -e 'goxygen::goxygen(unitPattern = c("\\[","\\]"), includeCore=TRUE, max_num_edge_labels="adjust", max_num_nodes_for_edge_labels = 15, startType=NULL); warnings()'
	@echo -e '\nOpen\ndoc/html/index.htm\nin your browser to view the generated documentation.'

update-renv:     ## Upgrade all pik-piam packages in your renv to the respective
                 ## latest release, write renv.lock into archive
	Rscript -e 'piamenv::updateRenv()'

update-renv-all: ## Upgrade all packages (including CRAN packages) in your renv
                 ## to the respective latest release, write renv.lock archive
	@Rscript -e 'renv::update(); piamenv::archiveRenv()'

revert-dev-packages: ## All PIK-PIAM packages that are development versions, i.e.
                     ## that have a non-zero fourth version number component, are
                     ## reverted to the highest version lower than the
                     ## development version.
	@Rscript -e 'piamenv::revertDevelopmentVersions()'

ensure-reqs:     ## Ensure the REMIND library requirements are fulfilled
                 ## by installing updates and new libraries as necessary. Does not
                 ## install updates unless it is required.
	@Rscript -e 'source("scripts/start/ensureRequirementsInstalled.R"); ensureRequirementsInstalled(rerunPrompt="make ensure-reqs")'

archive-renv:    ## Write renv.lock into archive.
	Rscript -e 'piamenv::archiveRenv()'

restore-renv:    ## Restore renv to the state described in interactively
                 ## selected renv.lock from the archive or a run folder.
	Rscript -e 'piamenv::restoreRenv()'

clone-conda: ## Clone the specified conda environment or the active environment to a new environment in the user's home directory or specified DEST
	@if [ -z "$$ENV" ] && [ -z "$$CONDA_DEFAULT_ENV" ]; then \
		echo "No Conda environment specified and no active Conda environment found."; \
		exit 1; \
	elif [ -z "$$ENV" ]; then \
		ENV=$$CONDA_DEFAULT_ENV; \
	fi; \
	TIMESTAMP=$$(date +%Y%m%d); \
	BASENAME=$$(basename $$ENV); \
	DEFAULT_CONDA_ENV_DIR=~/.conda/envs; \
	CLONE_DIR=$${DEST:-$$DEFAULT_CONDA_ENV_DIR/$$BASENAME-clone-$$TIMESTAMP}; \
	echo "Cloning Conda environment: $$ENV"; \
	echo "Cloning to: $$CLONE_DIR"; \
	echo "This might take a few minutes..."; \
	if conda create --prefix $$CLONE_DIR --clone $$ENV; then \
		echo "Done!"; \
		conda env export --prefix $$CLONE_DIR > $$CLONE_DIR.yml; \
		echo "Cloned environment saved to $$CLONE_DIR.yml"; \
	else \
		echo "Cloning failed or was interrupted."; \
		exit 1; \
	fi;

create-conda: ## Create a conda environment from the config/py_requirements.txt file
	@if [ ! -f config/py_requirements.txt ]; then \
		echo "Requirements file not found: config/py_requirements.txt"; \
		exit 1; \
	fi; \
	ENV=$${ENV:-remind}; \
	DEST=$${DEST:-$$HOME/.conda/envs}; \
	echo "Creating Conda environment: $$DEST/$$ENV with Python 3.11"; \
	mkdir -p $$DEST; \
	conda create --prefix $$DEST/$$ENV python=3.11 -y; \
	echo "Activating Conda environment: $$ENV"; \
	. $$(conda info --base)/etc/profile.d/conda.sh && conda activate $$DEST/$$ENV && \
	echo "Installing requirements from config/py_requirements.txt"; \
	pip install -r config/py_requirements.txt; \
	echo "Conda environment $$ENV created and requirements installed successfully in $$DEST with Python 3.11.";

check:           ## Check if the GAMS code follows the coding etiquette
                 ## using gms::codeCheck
	Rscript -e 'options(warn = 1); invisible(gms::codeCheck(strict = TRUE));'

check-fix:       ## Check if the GAMS code follows the coding etiquette
                 ## and offer fixing any problems directly if possible
                 ## using gms::codeCheck
	Rscript -e 'options(warn = 1); invisible(gms::codeCheck(strict = TRUE, interactive = TRUE));'

test:            ## Test if the model compiles and runs without running a full
                 ## scenario. Tests take about 15 minutes to run.
	$(info Tests take about 15 minutes to run, please be patient)
	@Rscript -e 'testthat::test_dir("tests/testthat")'

test-fix:        ## First run codeCheck interactively, then test if the model compiles and runs without
                 ## running a full scenario. Tests take about 15 minutes to run.
	$(info Tests take about 18 minutes to run, please be patient)
	@./scripts/utils/SOFEOF
	@Rscript -e 'rlang::with_options(warn = 1, invisible(gms::codeCheck(strict = TRUE, interactive = TRUE))); testthat::test_dir("tests/testthat");'
	@echo "Do not forget to commit possible changes done by codeCheck to not_used.txt files"
	@git add -p modules/*/*/not_used.txt

test-coupled:    ## Test if the coupling with MAgPIE works. Takes significantly
                 ## longer than 60 minutes to run and needs slurm and magpie
                 ## available
	$(info Coupling tests take around 75 minutes to run, please be patient)
	@TESTTHAT_RUN_SLOW=TRUE Rscript -e 'testthat::test_file("tests/testthat/test_20-coupled.R")'

test-coupled-slurm: ## test-coupled, but on slurm
	$(info Coupling tests take around 75 minutes to run. Sent to slurm, find log in test-coupled.log)
	make ensure-reqs
	@sbatch --qos=priority --wrap="make test-coupled" --job-name=test-coupled --mail-type=END,FAIL --time=180 --output=test-coupled.log --comment="test-coupled.log"

test-full:       ## Run all tests, including coupling tests and a default
                 ## REMIND scenario. Takes several hours to run.
	$(info Full tests take more than an hour to run, please be patient)
	@TESTTHAT_RUN_SLOW=TRUE Rscript -e 'testthat::test_dir("tests/testthat")'

test-full-slurm: ##test-full, but on slurm
	$(info Full tests take more than an hour to run, please be patient)
	make ensure-reqs
	@sbatch --qos=priority --wrap="make test-full" --job-name=test-full --mail-type=END,FAIL --output=test-full.log --comment="test-full.log"

test-validation: ## Run validation tests, requires a full set of runs in the output folder
	$(info Run validation tests, requires a full set of runs in the output folder)
	@TESTTHAT_RUN_SLOW=TRUE Rscript -e 'testthat::test_dir("tests/testthat/validation")'	

set-local-calibration:		## set up local calibration results directory
	@./scripts/utils/set-local-calibration.sh
	$(info Local calibration has been set. Now use `collect_calibration` script in calibration_results/ directory )
