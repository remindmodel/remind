Running more than one REMIND scenarios
================

You can start a bundle of REMIND runs using the settings from a scenario_config_XYZ.csv:

``` bash
Rscript start.R config/scenario_config_XYZ.csv
```

The `scenario_config_XYZ.csv` files in the `./config` folder can be edited in a text editor or with a spreadsheet software (Excel, LibreOffice Calc).

Viewed as a spreadsheet, the first row contains the column titles, while subsequent rows each contain a remind run.

<img src="figures/scenario-config-explanation.png" width="100%" style="display: block; margin: auto;" />

Five columns are mandatory, the first two usually placed at the beginning, the last three usually at the end.

* `title` contains a unique identifier for each run, which must not contain a `.` and should not end with a `_`.
* `start` is a boolean switch, either 1 if the run is to be executed once run with `start.R`, or 0 if not.
* `path_gdx` allows to specify initial conditions for the run, overwriting the usual initial conditions taken from the calibration files found in [`./config/gdx-files/`](https://github.com/remindmodel/remind/blob/develop/config/gdx-files/files).
* `path_gdx_ref` points to the run used for all `t < cm_startyear`, which can be used for example for delayed transition scenarios, and which is also used as a comparison for the policy cost calculation.
* `path_gdx_bau` points to the run used as business as usual (BAU) scenario, for example for runs using [`45_carbonprice/NDC`](https://github.com/remindmodel/remind/tree/develop/modules/45_carbonprice/NDC), where some countries specify emission as percentage reduction compared to BAU.

The three columns starting with `path…` can either be left empty or used to point to either finished runs or other rows of the current model execution:
* provide a path to an existing `gdx` file such as `./output/SSP2-Base_2021-12-24_19.30.00/fulldata.gdx`. For subfolders of `./output/`, writing `SSP2-Base_2021-12-24_19.30.00` is sufficient.
* provide the entry of a `title` of another row such as `SSP2-Base`.
  * If the run with this `title` is set to `start = 1`, then the turns that points to this is turned into a “subsequent run“ that will be started after the linked one is finished. Note that in this case, the REMIND code must not change until the `full.gms` file of the last subsequent run was generated. Don't checkout other github branches or manually edit REMIND files.
  * If the run with this `title` is set to `start = 0` or does not exist in the `scenario_config_XYZ.csv` file, the function `configure_cfg` of [`start.R`](https://github.com/remindmodel/remind/blob/develop/start.R) searches in `./output` for folders with the name which contain a `fulldata.gdx` and picks the one with the latest date and time in the folder name, not checking whether this run has converged.

The image above shows all three possibilities. Run `RCP37` waits until `BAU_Nash` is finished, while `RCP26` uses an old run as reference and can be started immediately. `RCP20` will not be started because `start = 0`. If you set `start = 0` also for `BAU_Nash`, then `RCP37` will also try to find an old run in a folder that looks like `BAU_Nash_YYYY-MM-DD_HH.MM.SS`. If you add a `_` to the `path_gdx...`, yielding for example `BAU_Nash_`, REMIND still finds `fulldata.gdx` from earlier runs, but avoids to be counted as a subsequent run. This way, you can quickly switch between the two options. Of course, no run should have the title `BAU_Nash_` in this case.

The other columns allow to specify different parameters that are normally defined and explained in [`./config/default.cfg`](https://github.com/remindmodel/remind/blob/develop/config/default.cfg) to be substituted by the respective cell value for each run. If you leave a cell empty, the default value is used, that may change over time as REMIND progresses. Note that the cell need not contain only a single value, but for example realization [`47_regipol/regiCarbonPrice`](https://github.com/remindmodel/remind/tree/develop/modules/47_regipol/regiCarbonPrice) allows to specify in the parameter `cm_regiCO2target` to enter comma separated values `2020.2050.USA.year.netGHG 1, 2020.2050.EUR.year.netGHG 1` to specify emission goals for multiple regions.

Everything in the row after a `#` is interpreted as comment. Best use it as first character in the first column to structure the file. Using `#` elsewhere else can lead to unexpected data losses of the cells that follow in the row.

If you want to switch off the use of a column, either temporarily or to add some comments, add a dot before the parameter name, which then may read `.cm_startyear` and is then ignored. Don't use that for the five mandatory columns.
