.PHONY: help docs update-renv update-all-renv check
.DEFAULT_GOAL := help

help:           ## Show this help.
	@sed -e '/##/ !d' -e '/sed/ d' -e 's/^\([^ ]*\) *##\(.*\)/\1^\2/' \
		$(MAKEFILE_LIST) | column -ts '^'

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
