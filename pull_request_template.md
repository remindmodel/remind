## Purpose of this PR

## Type of change

> **NOTE** Make sure to select the items relevant to your PR by placing an "x" in the brackets. *Delete* the lines you left empty. This way the progress tracker accurately reflects the status of the PR. Leave *unfinished* elements in the checklist unchecked so we know how far along you are.

### Parts concerned:
- [ ] GAMS Code
- [ ] R-scripts
- [ ] Documentation (GAMS incode documentation, comments, tutorials)
- [ ] Input data / CES parameters
- [ ] CI/CD
- [ ] Other (please give a description)

### Impact:
- [ ] Bug fix
- [ ] Refactoring
- [ ] New feature
- [ ] Change of parameters or input data
- [ ] Minor change (default scenarios show only small differences)
- [ ] Fundamental change of results of default scenarios

## Checklist

All must be ticked in the end (if you want to merge)
Dont delete any line

- [ ] Must: My code follows the [coding etiquette](https://github.com/remindmodel/remind/blob/develop/main.gms#L80)
- [ ] Must: I explained my changes within the PR, particularly in hard-to-understand areas
- [ ] Must: I checked that the [in-code documentation](https://github.com/remindmodel/remind/blob/develop/main.gms#L120) is up-to-date
- [ ] I adjusted the reporting in [`remind2`](https://github.com/pik-piam/remind2) where it was needed
- [ ] I adjusted `forbiddenColumnNames` in [readCheckScenarioConfig.R](https://github.com/remindmodel/remind/blob/develop/scripts/start/readCheckScenarioConfig.R) in case the PR leads to deprecated switches
raus: - [ ] I checked the `log.txt` file of my runs for newly introduced summation, fixing or variable name errors
- [ ] I executed the automated model tests (`make test`) after my final commit and all tests pass (`FAIL 0`)
- [ ] I updated the `CHANGELOG.md` [correctly](https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Standards-for-Writing-a-Changelog) (added, removed, changed, CES, ...s)

## Further information (optional):

* Runs with these changes are here:
* Comparison of results (what changes by this PR?): 
