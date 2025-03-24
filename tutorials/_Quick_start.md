# Quick Start guide 
This quick start guide is based on the other tutorials. It is only directly applicable if you have access to the HPC PIK.
* If you are a PIK member not yet set up on the HPC, look at these [instructions from RSE](https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Cluster-Access)*.
  
# 1. Getting the code
*I recommend VScode but any terminal with git will be fine*. *If you do not have git set up and don't know how to do it see the sparse instructions at [RSE git](https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Git-Setup) or ask chat gpt "how can I setup git in \[vscode | wsl | windows\] and connect my github account".*

- Fork the [REMIND repo](https://github.com/remindmodel/remind/tree/develop) to your github account
	- You can uncheck "develop only" but we will fix this below
- clone the code (instead of a full github clone and checkout)
	-  `cloneremind https://github.com/<yourusername>/remind.git DESTINATION_FOLDER`
	- why? this will keep the data references from the HPC and reduce the size of the operation
- Check the state of your repo
	- navigate to your repo `cd myrepo`
	- `git remote -v`
- Switch to a stable release
	- run `git fetch --all --tags` if you forgot to get the tags
	- switch to a (hopefully) e.g. stable release `git checkout tags/v3.4.0 -b release-3.4.0`

 See tutorial [01](https://github.com/remindmodel/remind/blob/develop/tutorials/01_GettingREMIND.md) for more details.
 
# 2. Preliminaries

## Overview of Remind code
Read [REMIND - REgional Model of INvestments and Development – Overview](https://rse.pik-potsdam.de/doc/remind/3.2.0/) or equivalently the comment starting `main.gams` . This will be helpful in terms of understanding the code.
This [tutorial](https://www.gams.com/latest/docs/UG_Tutorial.html) is recommended by the group.
## !! Renv !!
Note that REMIND **releases do not come with a locked environment** ([see the associated issue, which may be closed by the time you start](https://github.com/remindmodel/development_issues/issues/528)). This means that you will need to restore the version corresponding to your release: for example `make historic-reqs v=2024-12-11` where the date should be replaced with that of the release (see [here](https://github.com/remindmodel/development_issues/issues/528)) 

# 3. Your first run
*Note <some_text> indicate place holders*
*To learn about the HPC and slurm have a look at [the IT HPC guide](https://www.pik-potsdam.de/en/institute/about/it-services/hpc/hpc-2024/hpc-2024-documentation/hpc-2024-documentation)* (you can use remind without knowing anything about high performance computers or the slurm job manager)

- make a copy of `config/scenario_config.csv` -> `config/<myfirstrun_cfg>.csv` 
	-  keep only 2-3 rows, say those in table1
	-  **NB: the config uses German delimiters `;`**
	- `scenario_config.csv` represents all the possible scenarios. The others don't really belong in a code repo but are there
	- How the config.csv work is explained in [the REMIND tutorial 03](https://github.com/remindmodel/remind/blob/develop/tutorials/03_RunningBundleOfRuns.md)
	- do not edit `default.cfg` which is actually an R script
- check your run
	- `Rscript start.R --test config/<myfirstrun_cfg>.csv`
	- press enter to (mock) submit to the priority queue
- launch your run
	- `Rscript start.R config/<myfirstrun_cfg>.csv`
	- press enter to submit to the priority queue 

| Name            | Descriptor        |
| --------------- | ----------------- |
| SSP2-NPi2025    | Current policies  |
| SSP2-PkBudg500  | 1.5C no overshoot |
| SSP2-PkBudg1000 | 2.C               |

# 4. Check the status of your run

- in a bash terminal on the hpc (e.g. in vscode) type  `squeue -u $USER` your job should appear there
	- you can also define a more power alias such as `alias sq='squeue -u $USER -o "%.18i %.9P %q %.30j %.8u %.5T %.10M %.9l %.6D %R"'` in your `.bashrc` and run that
	- if needed you can also check the state of the hpc with `sinfo` and `sacct` commands
- you should get an email once your run finishes
	- remind runs in about 3 hours

>[!warning] Failed runs with release versions
> note that remind releases are not currently shipped with an exact (locked) environment and you may therefore run into dependency issues.

# 5. Look at your results

## Generating a PDF
*This should be your first step*. If you are at PIK, have a look at [compareScenarios in remind2](https://pik-piam.r-universe.dev/articles/remind2/compareScenariosRemind2.html)

In short, from your REMIND folder run
- `Rscript output.R`
- Select comparison across runs: `2: Comparison across runs`
- and then `compareScenarios2`
- submit to priority (Not sure how to deal with this if you are not on cluster)
	- this takes on the order of 15 minutes on the hpc cluster (!?)
	- your results will be saved to your code root folder



