.PHONY: help docs update-renv update-all-renv check check-fix
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
                 ## Upgrade all packages in python venv, if python venv exists
	Rscript -e 'renv::update(exclude = "renv")'
	Rscript -e 'renv::snapshot()'
	[ -e ".venv/bin/python" ] && .venv/bin/python -mpip install --upgrade pip wheel
	[ -e ".venv/bin/python" ] && .venv/bin/python -mpip install --upgrade --upgrade-strategy eager -r requirements.txt

check:          ## Check if the GAMS code follows the coding etiquette
                ## using gms::codeCheck
	Rscript -e 'invisible(gms::codeCheck(strict = TRUE))'

check-fix:      ## Check if the GAMS code follows the coding etiquette
                ## and offer fixing any problems directly if possible
                ## using gms::codeCheck
	Rscript -e 'invisible(gms::codeCheck(strict = TRUE, interactive = TRUE))'
