# Python support in REMIND

For support contact [Tonn Rüter](mailto:tonn.rueter@pik-potsdam.de)

Python is a high-level, interpreted programming language known for its readability and versatility. In REMIND, Python is essential for coupling to specialized models, such as those used for climate assessment reporting. These models often require advanced data processing and integration with other tools, which Python in conjecture with R `reticulate` facilitates efficiently.

## REMIND Python Doctrine

Python support is enabled by default in REMIND and is necessary to couple to specialized models, e.g. for climate assessment reporting. This can be verified in the `default.cfg` file where `cfg$pythonEnabled` is set to `"on"`. Users need to set the `cfg$pythonPath` variable to point to an appropriate Python environment. On the PIK cluster, the `conda` environment can be found in `/p/projects/rd3mod/python/environments/scm_magicc7_hpc/`. It is best practice to clone this default environment into one's home directory when using the PIK cluster, see [`make` commands below](#environment-creation-integrity-and-archiving). Further management of the Python environment, such as updating Python packages environments, is a responsibility of the user. 

REMIND scripts do not alter the Python environment, ensuring that the environment remains stable and predictable throughout the usage of REMIND. For repeatability a lockfile is generated for each REMIND run that archives the state of the Python environment. This ensures that the exact environment used for a specific run can be recreated if needed to ensure repeatability. In case a virtual Python environment like `conda` or `venv` is used, the user needs to make sure to activate it before starting a REMIND run. After starting a REMIND run, checks ensure that all necessary dependencies are available.

### Environment Creation, Integrity, and Archiving

REMIND supports using your system Python installation via `pip`, but also *virtual Python environments* like `conda` and `venv`. Among these, `conda` is the preferred option due to its ease of use and robust package management. For more details on installing `conda`, refer to the [Installing `conda`](#installing-conda) section.

The provided Makefile includes targets to create or clone a Python environment:
- `make clone-conda`: Clones an existing `conda` environment. Note: Users of the PIK cluster should activate the default environment at `/p/projects/rd3mod/python/environments/scm_magicc7_hpc/`, then use `make conda-clone` to create their own version
- `make create-conda`: Creates a new `conda` environment based on the `py_requirements.txt` file.

### Leveraging `reticulate`

To interface with other models or libraries, it is often necessary to call Python code because the model itself is written in Python or bindings are available in Python. REMIND has Python support via the R library `reticulate`. One can, for example, execute an R script from GAMS, then use `reticulate::import` to import Python libraries. For more information on using `reticulate`, refer to the [Documentation](https://rstudio.github.io/reticulate/).

### Handling Warnings

When using REMIND, you might encounter warnings about the inability to verify the version of certain Python packages installed from specific repositories. These warnings occur because the installed Python packages do not retain information about their origin, only their version number. This version number is meaningless if the package was installed from a dedicated repository. Therefore, when using the PIK cluster default REMIND Python environment, you can safely disregard these warnings. They are simply a result of the package management system's inability to verify the origin of the installed packages.

## REMIND & Anaconda

`conda` is an open-source package and environment management system for Windows, macOS, and Linux. It simplifies installing and managing Python dependencies and environments, making it ideal for running REMIND. For users running REMIND on their desktop, any Python installation will do; however, we recommend using `conda` for its ease of managing dependencies and environments.

### `conda` Environment for REMIND/MAGICC7 Operation on the Cluster

> **Note** This section assumes that you have access to the PIK HPC, have followed the instructions in the REMIND group-internal Wiki on [how to access the PIK HPC]((https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Cluster-Access)) and configure your [Python cluster environment](https://gitlab.pik-potsdam.de/rse/rsewiki/-/wikis/Cluster#for-python-users).

To ensure `climate-assessment` and `MAGICC7` are available when running REMIND on the PIK high performance cluster (HPC), follow these steps after logging in and before initiating a REMIND run that requires MAGICC7 (e.g., climate reporting). On the HPC (`foote.pik-potsdam.de`) activate the conda environment:

```bash
source activate /p/projects/rd3mod/python/environments/scm_magicc7_hpc
```

This setup ensures the correct Python versions are available. To deactivate the conda environment, type `conda deactivate`. **Please do not alter the conda environment as changes would affect all users.**

With the conda environment activated, you can start a climate assessment report from your REMIND folder with:

```sh
Rscript output.R
```

and navigate through the selection process as usual.

### Installing `conda`

This is not necessary when running REMIND on the PIK cluster. If you are on a Desktop machine or are using another shared computing infrastructure, ask your local IT department if `conda` is available for your system. For Desktop users here's a brief overview of how to install `conda`. Follow these steps:

1. **Download the `conda` installer**:
    - *Recommended*: For Miniconda (a minimal installer for `conda`): [Miniconda Distribution](https://docs.conda.io/en/latest/miniconda.html)
    - *Optional*: For Anaconda (includes `conda` and many scientific packages): [Anaconda Distribution](https://www.anaconda.com/products/distribution#download-section)

2. **Run the installer**:
    - On Windows, double-click the `.exe` file
    - On macOS and Linux, open a terminal and run:
        ```sh
        bash path/to/installer.sh
        ```

3. **Follow the prompts** to complete the installation.

4. **Verify the installation** by opening a terminal or command prompt and running:
    ```sh
    conda --version
    ```

### Creating a `conda` Environment from `py_requirements.txt`

To create a new `conda` environment from the `config/py_requirements.txt` file that comes with REMIND, you can use the `make create-conda` target in the Makefile. This will create a new `conda` environment with Python 3.11 and the packages specified in the requirements file.

- Create a new environment with the default name `remind` in the default directory (`$HOME/.conda/envs`):
    ```sh
    make create-conda
    ```

- Create a new environment with a specified name:
    ```sh
    make create-conda ENV=my_new_env
    ```

- Create a new environment in a specified directory:
    ```sh
    make create-conda DEST=/path/to/directory
    ```

- Create a new environment with a specified name in a specified directory:
    ```sh
    make create-conda ENV=my_new_env DEST=/path/to/directory
    ````

### Cloning the REMIND `conda` environment on the PIK cluster

To clone a `conda` environment, you can use the `make clone-conda` target in the Makefile. This will clone the specified `conda` environment or the active environment to a new environment in the user's home directory or a specified destination.

- Clone the active environment:
    ```sh
    make clone-conda
    ```
- Clone a specified environment:
    ```sh
    make clone-conda ENV=my_env
    ```
- Clone a specified environment to a custom directory:
    ```sh
    make clone-conda ENV=my_env DEST=~/my_custom_directory
    ```

#### Renaming a `conda` Environment
If you need to rename the cloned environment, follow these steps:

1. Activate the cloned environment:
    ```sh
    conda activate /path/to/cloned-env
    ```

2. Export the environment state to a YAML file:
    ```sh
    conda env export > cloned-env.yml
    ```

3. Create a new environment with the desired name from the YAML file:
    ```sh
    conda env create -f cloned-env.yml -n new-env-name
    ```

4. Remove the old cloned environment:
    ```sh
    conda remove --prefix /path/to/cloned-env --all
    ```

These steps ensure that the environment is properly renamed without breaking `conda`'s environment management