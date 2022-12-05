.PHONY: help docs update-renv update-all-renv check check-fix
.DEFAULT_GOAL := help

# extracts the help text and formats it nicely
HELP_PARSING = 'm <- readLines("Makefile");\
				m <- grep("\#\#", m, value=TRUE);\
				command <- sub("^([^ ]*) *\#\#(.*)", "\\1", m);\
				help <- sub("^([^ ]*) *\#\#(.*)", "\\2", m);\
				cat(sprintf("%-18s%s", command, help), sep="\n")'

help:           ## Show this help.
	@Rscript -e $(HELP_PARSING)

docs:           ## Generate/update model HTML documentation in the doc/ folder
	Rscript -e 'goxygen::goxygen(unitPattern = c("\\[","\\]"), includeCore=T, max_num_edge_labels="adjust", max_num_nodes_for_edge_labels = 15)'
	@echo -e '\nOpen\ndoc/html/index.htm\nin your browser to view the generated documentation.'

update-renv:    ## Upgrade all pik-piam packages in your renv to the respective
                ## latest release, make new snapshot
	Rscript scripts/utils/updateRenv.R

update-all-renv: ## Upgrade all packages (including CRAN packages) in your renv
                 ## to the respective latest release, make new snapshot
	Rscript -e 'renv::update(exclude = "renv")'
	Rscript -e 'renv::snapshot()'

check:          ## Check if the GAMS code follows the coding etiquette
                ## using gms::codeCheck
	Rscript -e 'invisible(gms::codeCheck(strict = TRUE))'

check-fix:      ## Check if the GAMS code follows the coding etiquette
                ## and offer fixing any problems directly if possible
                ## using gms::codeCheck
	Rscript -e 'invisible(gms::codeCheck(strict = TRUE, interactive = TRUE))'
