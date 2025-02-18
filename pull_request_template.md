## Purpose of this PR


## Type of change

(Make sure to delete from the Type-of-change list the items not relevant to your PR)

- [ ] Bug fix 
- [ ] Refactoring
- [ ] New feature 
- [ ] Minor change (default scenarios show only small differences)
- [ ] Fundamental change
- [ ] This change requires a documentation update


## Checklist:

- [ ] My code follows the [coding etiquette](https://github.com/remindmodel/remind/blob/develop/main.gms#L80)
- [ ] I performed a self-review of my own code
- [ ] I explained my changes within the PR, particularly in hard-to-understand areas
- [ ] I checked that the [in-code documentation](https://github.com/remindmodel/remind/blob/develop/main.gms#L120) is up-to-date
- [ ] I adjusted the reporting in [`remind2`](https://github.com/pik-piam/remind2) where it was needed
- [ ] I adjusted `forbiddenColumnNames` in [readCheckScenarioConfig.R](https://github.com/remindmodel/remind/blob/develop/scripts/start/readCheckScenarioConfig.R) in case the PR leads to deprecated switches
- [ ] I checked the `log.txt` file of my runs for newly introduced summation, fixing or variable name errors
- [ ] All automated model tests pass, executed after my final commit (`FAIL 0` in the output of `make test`)
- [ ] The changelog `CHANGELOG.md` [has been updated correctly](https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Standards-for-Writing-a-Changelog)

## Further information (optional):

* Runs with these changes are here:
* Comparison of results (what changes by this PR?): 

