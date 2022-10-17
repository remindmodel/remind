.PHONY: help docs update-renv
.DEFAULT_GOAL := help

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

docs:           ## Generate/update model HTML documentation in the doc/ folder
	Rscript -e 'goxygen::goxygen(unitPattern = c("\\[","\\]"), includeCore=T, max_num_edge_labels="adjust", max_num_nodes_for_edge_labels = 15)'
	echo -e 'Open\ndoc/html/index.htm\nin your browser to view the generated documentation.'

update-renv:    ## Upgrade all pik-piam packages in your renv to the respective latest release, make new snapshot
	Rscript scripts/utils/updateRenv.R

update-all-renv: ## Upgrade all packages (including CRAN packages) in your renv to the respective latest release, make new snapshot
	Rscript -e 'renv::update()'
	Rscript -e 'renv::snapshot()'
