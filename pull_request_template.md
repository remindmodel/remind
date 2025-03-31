## Purpose of this PR

*Please explain your PR here.*

## Type of change

*Indicate the items relevant for your PR by replacing* :white_medium_square: *with* :ballot_box_with_check:.\
*Do not delete any lines. This makes it easier to understand which areas are affected by your changes and which are not.*

### Parts concerned
- :white_medium_square: GAMS Code
- :white_medium_square: R-scripts
- :white_medium_square: Documentation (GAMS incode documentation, comments, tutorials)
- :white_medium_square: Input data / CES parameters
- :white_medium_square: CI/CD (continuous integration/development)
- :white_medium_square: Other (please give a description)

### Impact
- :white_medium_square: Bug fix
- :white_medium_square: Refactoring
- :white_medium_square: New feature
- :white_medium_square: Change of parameters or input data
- :white_medium_square: Minor change (default scenarios show only small differences)
- :white_medium_square: Fundamental change of results of default scenarios

## Checklist

*Do not delete any line. Leave **unfinished** elements unchecked so others know how far along you are.\
In the end all checkboxes must be ticked before you can merge*.

- [ ] **I executed the automated model tests (`make test`) after my final commit and all tests pass (`FAIL 0`)**
- [ ] **I adjusted the reporting in [`remind2`](https://github.com/pik-piam/remind2) if and where it was needed**
- [ ] My code follows the [coding etiquette](https://github.com/remindmodel/remind/blob/develop/main.gms#L80)
- [ ] I explained my changes within the PR, particularly in hard-to-understand areas
- [ ] I checked that the [in-code documentation](https://github.com/remindmodel/remind/blob/develop/main.gms#L120) is up-to-date
- [ ] I adjusted `forbiddenColumnNames` in [readCheckScenarioConfig.R](https://github.com/remindmodel/remind/blob/develop/scripts/start/readCheckScenarioConfig.R) in case the PR leads to deprecated switches
- [ ] I updated the `CHANGELOG.md` [correctly](https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Standards-for-Writing-a-Changelog) (added, changed, fixed, removed, input data/calibration)

## Further information (optional)

* Runs with these changes are here:
* Comparison of results (what changes by this PR?): 
