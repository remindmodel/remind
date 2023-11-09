.PHONY: help docs update-renv update-renv-all archive-renv restore-renv check check-fix test test-coupled test-full
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
	Rscript -e 'goxygen::goxygen(unitPattern = c("\\[","\\]"), includeCore=T, max_num_edge_labels="adjust", max_num_nodes_for_edge_labels = 15); warnings()'
	@echo -e '\nOpen\ndoc/html/index.htm\nin your browser to view the generated documentation.'

update-renv:     ## Upgrade all pik-piam packages in your renv to the respective
                 ## latest release, write renv.lock into archive
	Rscript -e 'piamenv::updateRenv()'

update-renv-all: ## Upgrade all packages (including CRAN packages) in your renv
                 ## to the respective latest release, write renv.lock archive
                 ## Upgrade all packages in python venv, if python venv exists
	@Rscript -e 'renv::update(exclude = "renv"); piamenv::archiveRenv()'
	@if [ -e "./venv/bin/python" ]; then \
		pv_maj=$$( .venv/bin/python -V | sed 's/^Python \([0-9]\).*/\1/' ); \
		pv_min=$$( .venv/bin/python -V | sed 's/^Python [0-9]\.\([0-9]\+\).*/\1/' ); \
		if (( 3 == $$pv_maj )) && (( 7 <= $$pv_min )) && (( $pv_min < 11 )); then \
			.venv/bin/python -mpip install --upgrade pip wheel; \
			.venv/bin/python -mpip install --upgrade --upgrade-strategy eager -r requirements.txt; \
		fi \
	fi

ensure-reqs:     ## Ensure the REMIND library requirements are fulfilled
                 ## by installing updates and new libraries as necessary. Does not
                 ## install updates unless it is required.
	@Rscript -e 'source("scripts/start/ensureRequirementsInstalled.R"); ensureRequirementsInstalled(rerunPrompt="make ensure-reqs")'
	@if [ -e "./venv/bin/python" ]; then \
		pv_maj=$$( .venv/bin/python -V | sed 's/^Python \([0-9]\).*/\1/' ); \
		pv_min=$$( .venv/bin/python -V | sed 's/^Python [0-9]\.\([0-9]\+\).*/\1/' ); \
		if (( 3 == $$pv_maj )) && (( 7 <= $$pv_min )) && (( $pv_min < 11 )); then \
			.venv/bin/python -mpip -qq install -r requirements.txt; \
		fi \
	fi

archive-renv:    ## Write renv.lock into archive.
	Rscript -e 'piamenv::archiveRenv()'

restore-renv:    ## Restore renv to the state described in interactively
                 ## selected renv.lock from the archive or a run folder.
	Rscript -e 'piamenv::restoreRenv()'

check:           ## Check if the GAMS code follows the coding etiquette
                 ## using gms::codeCheck
	Rscript -e 'invisible(gms::codeCheck(strict = TRUE))'

check-fix:       ## Check if the GAMS code follows the coding etiquette
                 ## and offer fixing any problems directly if possible
                 ## using gms::codeCheck
	Rscript -e 'invisible(gms::codeCheck(strict = TRUE, interactive = TRUE))'

test:            ## Test if the model compiles and runs without running a full
                 ## scenario. Tests take about 10 minutes to run.
	$(info Tests take about 20 minutes to run, please be patient)
	@Rscript -e 'testthat::test_dir("tests/testthat")'

test-coupled:    ## Test if the coupling with MAgPIE works. Takes significantly
                 ## longer than 60 minutes to run and needs slurm and magpie
                 ## available
	$(info Coupling tests take around 75 minutes to run, please be patient)
	@TESTTHAT_RUN_SLOW=TRUE Rscript -e 'testthat::test_file("tests/testthat/test_20-coupled.R")'

test-coupled-slurm: ## test-coupled, but on slurm
	$(info Coupling tests take around 75 minutes to run. Sent to slurm, find log in test-coupled.log)
	@sbatch --qos=priority --wrap="make test-coupled" --job-name=test-coupled --mail-type=END --output=test-coupled.log --comment="test-coupled.log"

test-full:       ## Run all tests, including coupling tests and a default
                 ## REMIND scenario. Takes significantly longer than 10 minutes to run.
	$(info Full tests take more than an hour to run, please be patient)
	@TESTTHAT_RUN_SLOW=TRUE Rscript -e 'testthat::test_dir("tests/testthat")'
test-validation: ## Run validation tests, requires a full set of runs in the output folder
	$(info Run validation tests, requires a full set of runs in the output folder)
	@TESTTHAT_RUN_SLOW=TRUE Rscript -e 'testthat::test_dir("tests/testthat/validation")'	
