Running more than one REMIND scenario
================
Oliver Richters
10 January, 2022

You can start a bundle of REMIND runs using the settings from a scenario_config_XYZ.csv:

``` bash
Rscript start.R config/scenario_config_XYZ.csv
```

The `scenario_config_XYZ.csv` files in the `./config` folder can be edited in a text editor or with a spreadsheet software (Excel, LibreOffice Calc).

Viewed as a spreadsheet, the first row contains the column titles, while subsequent rows each contain a remind run.

The first two columns are mandatory and usually placed at the beginning.

* `title` contains a unique identifier for each run, which must not contain a `.` and must not end with a `_`.
* `start` is a boolean switch, either 1 if the run is to be executed once run with `start.R`, or 0 if not.

Subsequent columns allow to overwrite the model configuration normally defined and explained in [`./config/default.cfg`](../develop/config/default.cfg).
They may contain values for parameters such as `cm_rcp_scen` and module realizations such as `exponential` for [`./module/carbonprice/`](../modules/45_carbonprice). They substitute these defaults by the respective cell value for each run. If you leave a cell empty, the default value is used, that may change over time as REMIND progresses. Note that the cell need not contain only a single value, but for example module realization [`47_regipol/regiCarbonPrice`](../develop/modules/47_regipol/regiCarbonPrice) allows to specify in the parameter `cm_regiCO2target` to enter comma separated values `2020.2050.USA.year.netGHG 1, 2020.2050.EUR.year.netGHG 1` to specify emission goals for multiple regions.

<img src="figures/scenario-config-explanation.png" width="100%" style="display: block; margin: auto;" />

Usually at the end, you find columns starting with `path_gdx`:

* `path_gdx` allows to specify initial conditions for the run, overwriting the usual initial conditions taken from the calibration files found in [`./config/gdx-files/`](../config/gdx-files/files).
* `path_gdx_ref` points to the run used for all `t < cm_startyear`, which can be used for example for delayed transition scenarios, and which is also used as a comparison for the policy cost calculation.
* `path_gdx_bau` points to the run used as business as usual (BAU) scenario, for example for runs using [`45_carbonprice/NDC`](../modules/45_carbonprice/NDC), where some countries specify emission as percentage reduction compared to BAU.

These three columns starting with `path…` can either be left empty or used to point to either finished runs or other rows of the current model execution:
* provide a path to an existing `gdx` file such as `./output/SSP2-Base_2021-12-24_19.30.00/fulldata.gdx`. For subfolders of `./output/`, writing the folder name `SSP2-Base_2021-12-24_19.30.00` is sufficient.
* provide the entry of a `title` of another row, such as `SSP2-Base`.
  * If the run with this `title` is set to `start = 1`, then runs that point to this `title` are turned into “subsequent runs“ that will be started after the linked one is finished. Note that in this case, the REMIND code must not change until the `full.gms` file of the last subsequent run was generated. Don't `git checkout` other branches or manually edit REMIND files.
  * If the run with this `title` is set to `start = 0` or does not exist in the `scenario_config_XYZ.csv` file, the function `configure_cfg` of [`start.R`](../start.R) searches in `./output` for folder with that title which contain a `fulldata.gdx` and whose `log.txt` states `REMIND run finished!`, and then picks the one with the latest date and time in the folder name. Appending a `_` to a `path_gdx…` entry, yielding for example `BAU_Nash_`, forces REMIND to take `fulldata.gdx` from earlier `BAU_Nash` runs, but avoids to be counted as a subsequent run. This way, you can quickly switch between the two options.

The image above shows these possibilities used for `path_gdx_ref`. Run `RCP20` has a complete path specified but will not be executed because `start = 0`. `RCP37` provides only the folder name, `RCP26_subsequent` waits for `SSP2-Base` to be finished, and `RCP26_forceoldrun` selects the latest already finished `SSP2-Base` run in the output folder and starts immediately. If you set `start = 0` also for `SSP2-Base`, then `RCP26_subsequent` will also try to find an old run in a folder that looks like `SSP2-Base_YYYY-MM-DD_HH.MM.SS`.

Everything in the row after a `#` is interpreted as comment. Best use it as first character in the first column to structure the file. Using `#` elsewhere else can lead to unexpected data losses of the cells that follow in the row.

If you want to switch off the use of a column, either temporarily or to add some comments, add a dot before the parameter name, which then may read `.cm_startyear` and is then ignored. Don't use that for the five mandatory columns.
