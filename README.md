# REMIND - REgional Model of INvestments and Development

[![CodeCheck Status](https://github.com/remindmodel/remind/workflows/check/badge.svg)](https://github.com/remindmodel/remind/actions) 

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

A model description paper on REMIND 2.1 has been published in Geoscientific Model Development (GMD): https://doi.org/10.5194/gmd-14-6571-2021 .

The model documentation for version 3.2.0 can be found at https://rse.pik-potsdam.de/doc/remind/3.2.0 .

The most recent version of the documentation can also be extracted from the
model source code via the R package goxygen
(https://github.com/pik-piam/goxygen). To extract the documentation, run `make docs`
in the main folder of the model.
The resulting documentation can be found in the folder `doc/`.

Please pay attention to the REMIND Coding Etiquette when you modify the code
(if you plan on contributing to the REMIND official repository).
The Coding Etiquette is found in the documentation section of the file main.gms.
It explains also the used name conventions and other structural characteristics.
To automatically check if some aspects of the coding etiquette, you can run
`make check` in the main folder of the model.

## TUTORIALS

Tutorials can be found in the form of markdown files in the repository:

https://github.com/remindmodel/remind/tree/develop/tutorials

## COPYRIGHT
Copyright 2006-2023 Potsdam Institute for Climate Impact Research (PIK)

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
Please refer to the [installation guide](tutorials/01_GettingREMIND.md).

## HOW TO CONFIGURE
Model run settings are set in `config/default.cfg` and `main.gms` (or another config file of
the same structure). New model scenarios can be created by adding a row to
`config/scenario_config.csv`

## HOW TO RUN
Please refer to the tutorials on how to
[use the default settings](tutorials/02_RunningREMIND.md) and how to
[run multiple scenarios](tutorials/03_RunningBundleOfRuns.md).

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

## MODEL OUTPUT

By default the results for a model run are written to an individual results folder within the "output/" folder of the model. The two most important output files are the fulldata.gdx and the REMIND_generic_*scenario-name*.mif. The fulldata.gdx is the technical output of the GAMS optimization and contains all quantities that were used during the optimization in unchanged form. The mif-file is a csv file of certain format and is synthetized from the fulldata.gdx by post-processing scripts. It can be read in any text editor or spreadsheet program and is well suited for a quick look at the results and for further analysis.

## CONTACT
remind@pik-potsdam.de

## KNOWN BUGS

## TROUBLESHOOTING
Please contact remind@pik-potsdam.de

## CITATION
See file CITATION.cff or the documentation of the model for information how
to cite the model.

[![DOI](https://zenodo.org/badge/226360184.svg)](https://zenodo.org/badge/latestdoi/226360184)

## AUTHORS
See list of authors in CITATION.cff

## CHANGELOG
See [CHANGELOG.md](CHANGELOG.md) on GitHub.
