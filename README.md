# REMIND - REgional Model of INvestments and Development

  <https://www.pik-potsdam.de/research/transformation-pathways/models/remind>

## WHAT IS REMIND?
The *REgional Model of INvestments and Development* (REMIND)
is a modular open source multi-regional model incorporating the economy, 
the climate system and a detailed representation of the energy sector. 
It solves for an inter-temporal Pareto optimum in economic and energy investments in the model regions, 
fully accounting for interregional trade in goods, energy carriers and emissions allowances. 
REMIND allows for the analysis of technology options and policy proposals for climate mitigation.
The macro-economic core of REMIND is a Ramsey-type optimal growth model 
in which intertemporal global welfare is optimized subject to equilibrium constraints.

## DOCUMENTATION
<!-- The model documentation for version 2.1 can be found at XXX.-->
A most recent version of the documentation can also be extracted from the
model source code via the R package goxygen
(https://github.com/pik-piam/goxygen). To extract the documentation, install the
package and run the main function `(goxygen(unitPattern = c("\\[","\\]"), includeCore=T, use_advanced_interfacePlot_function=T))`
in the main folder of the model.
The resulting documentation can be found in the folder "doc".

Please pay attention to the REMIND Coding Etiquette when you modify the code
(if you plan on contributing to the REMIND official repository).
The Coding Etiquette is found in the documentation section of the file main.gms.
It explains also the used name conventions and other structural characteristics.

## TUTORIALS

Tutorials can be found in the form of markdown files in the repository:

https://github.com/remindmodel/remind/tree/develop/tutorials

## COPYRIGHT
Copyright 2006-2020 Potsdam Institute for Climate Impact Research (PIK)

## LICENSE
This program is free software: you can redistribute it and/or modify
it under the terms of the **GNU Affero General Public License** as published by
the Free Software Foundation, **version 3** of the License or later. You should
have received a copy of the GNU Affero General Public License along with this
program. See the LICENSE file in the root directory. If not, see
https://www.gnu.org/licenses/agpl.txt

Under Section 7 of AGPL-3.0, you are granted additional permissions described
in the REMIND License Exception, version 1.0 (see LICENSE file).

## NOTES
Following the principles of good scientific practice it is recommended
to make the source code available in the events of model based publications
or model-based consulting.

When using a modified version of **REMIND** which is not identical to versions
in the official main repository at https://github.com/remindmodel add a suffix
to the name to allow distinguishing versions (format **REMIND-suffix**).

## SYSTEM REQUIREMENTS
The full model is quite resource heavy and works best on machines with high CPU clock
and memory. Recommended is a machine with Windows, MacOS or Linux, with at least
16GB of memory and a Core i7 CPU or similar.

## HOW TO INSTALL
REMIND requires *GAMS* (https://www.gams.com/) including licenses for the
solvers *CONOPT* for its core calculations. As the model
benefits significantly of recent improvements in *GAMS* and *CONOPT* it is
recommended to work with the most recent versions of both.
Please make sure that the GAMS installation path is added to the PATH variable
of the system.

In addition *R* (https://www.r-project.org/) is required for pre- and
postprocessing and run management (needs to be added to the PATH variable
as well).

Some R packages are required to run REMIND. All except of one (`gdxrrw`) are
either distributed via the offical R CRAN or via a separate repository hosted at
PIK (PIK-CRAN). Before proceeding PIK-CRAN should be added to the list of
available repositories via:
```
options(repos = c(CRAN = "@CRAN@", pik = "https://rse.pik-potsdam.de/r/packages"))
```

On Windows you need to install Rtools
(https://cran.r-project.org/bin/windows/Rtools/) and add it to the system PATH
variable. After that you can run the following lines of code:


All packages can be installed via `install.packages`

```
pkgs <- c("gdxrrw",
          "ggplot2",
          "curl",
          "gdx",
          "magclass",
          "madrat",
          "mip",
          "lucode",
          "remind",
          "lusweave",
          "luscale",
          "goxygen",
          "luplot")
install.packages(pkgs)
```
For post-processing model outputs *Latex* is required
(https://www.latex-project.org/get/). To be seen by the model it also needs to
added to the PATH variable of your system.

## HOW TO CONFIGURE
Model run settings are set in `config/default.cfg` (or another config file of
the same structure). New model scenarios can be created by adding a column to
`config/scenario_config.csv`

## HOW TO RUN
To run the model execute `Rscript start.R` (or `source("start.R")` from within
R) in the main folder of the model.
Make sure that the config file has been set correctly before
starting the model.

## HOW TO CONTRIBUTE
We are interested in working with you! Contact us through GitHub
(https://github.com/remindmodel) or by E-mail (remind@pik-potsdam.de) if you have
found and/or fixed a bug, developed a new model feature, have ideas for further
model development or suggestions for improvements. We are open to
any kind of contribution. Our aim is to develop an open, transparent and
meaningful energy-economy-model, and to get a better
understanding of the underlying processes and possible futures. Join us in doing
so!

## DEPENDENCIES
Model dependencies **must be publicly available** and should be Open Source.
Development aim is to rather minimize than expand dependencies on non-free
and/or non open source software. That means that besides currently existing
dependencies on GAMS, the `gdxrrw` R package and the corresponding solvers there
should be no additional dependencies of this kind and that these existing
dependencies should be resolved in the future if possible.

If a new R package is added as dependency this package should fulfill the
following requirements:
* The package is published under an Open Source license
* The package is distributed through CRAN or PIK-CRAN (the PIK-based,
  but publicly available package repository).
* The package source code is available through a public, version controlled
  repository such as GitHub

For other dependencies comparable measures should apply. When a dependency is
added this dependency should be added to the *HOW TO INSTALL* section in the
README file of the model (mentioning the depencendy and explaining
how it can be installed). If not all requirements can be fulfilled by the new
dependency this case should be discussed with the model maintainer
(remind@pik-potsdam.de) to find a good solution for it.

## INPUT DATA

In order to allow other researchers to reproduce and use work done with REMIND
one needs to make sure that all components necessary to perform a run can be
shared. One of these components is the input data. As proprietary data usually
does not allow its free distribution it should generally be avoided.

When adding a new data source, make sure that it can be freely shared with
others. If this is not the case please consider using a different source or
solution.

Data preparation should ideally be performed with the **madrat** data processing
framework (https://github.com/pik-piam/madrat). This makes sure that the
processing is reproducible and links properly to the already existing data
processing for REMIND.

In case that these recommendations can not be followed we would be happy if you
could discuss that issue with the REMIND development team
(remind@pik-potsdam.de).

## CONTACT
remind@pik-potsdam.de

## KNOWN BUGS

## TROUBLESHOOTING
Please contact remind@pik-potsdam.de

## CITATION
See file CITATION.cff or the documentation of the model for information how
to cite the model.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3730919.svg)](https://doi.org/10.5281/zenodo.3730919)

## AUTHORS
See list of authors in CITATION.cff

## CHANGELOG
See log on GitHub (https://github.com/remindmodel)
