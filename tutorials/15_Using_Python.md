# Using Python to Interface with Other Models
Mika Pflüger (mika.pflueger@pik-potsdam.de)
Tonn Rüter (tonn.rueter@pik-potsdam.de)

## Introduction

To interface with other models or libraries, it is often necessary to call Python code because the model itself is written in Python or bindings are available in Python.
REMIND has Python support via [reticulate](https://rstudio.github.io/reticulate/) using virtual environments, but it is disabled by default.

## Using Python in REMIND

First, you have to make sure that you have Python installed and available in your environment.
Run `Rscript scripts/utils/checkSetup.R` to check if REMIND finds your Python.
If not, repair that by installing Python and making sure it is on your PATH.

Next, you have to enable REMIND's Python integration by setting `cfg$pythonEnabled` to `on` in `config/default.cfg`.

Add Python libraries you want to use to the `requirements.txt` file in the main remind folder.
They will be installed into the Python virtual environment on the next start of REMIND.

Then you can use Python via [reticulate](https://rstudio.github.io/reticulate/).
For example, execute an R script from GAMS, then use `reticulate::import` to import Python libraries, the python virtual environment will automatically be used.

## REMIND & Anaconda

Conda is an open-source package and environment management system for Windows, macOS, and Linux. It simplifies installing and managing Python dependencies and environments, making it ideal for running REMIND. For users running REMIND on their desktop, any Python installation will do; however, we recommend using Conda for its ease of managing dependencies and environments.

### Installing Conda

This is not necessary when running REMIND on the PIK cluster. If you are on a Desktop machine or are using another shared computing infrastructure, ask your local IT department if `conda` is available for your system. For Desktop users here's a brief overview of how to install Conda. Follow these steps:

1. **Download the Conda installer**:
    - For Anaconda (includes Conda and many scientific packages): [Anaconda Distribution](https://www.anaconda.com/products/distribution#download-section)
    - For Miniconda (a minimal installer for Conda): [Miniconda Distribution](https://docs.conda.io/en/latest/miniconda.html)

2. **Run the installer**:
    - On Windows, double-click the `.exe` file. Follow the instructions
    - On macOS and Linux, open a terminal and run:
        ```sh
        bash path/to/installer.sh
        ```

3. **Follow the prompts** to complete the installation.

4. **Verify the installation** by opening a terminal or command prompt and running:
    ```sh
    conda --version
    ```

### Creating a Conda Environment from `py_requirements.txt`

To create a new Conda environment from the `config/py_requirements.txt` file that comes with REMIND, you can use the `make create-conda` target in the Makefile. This will create a new Conda environment with Python 3.11 and the packages specified in the requirements file.

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

To clone a Conda environment, you can use the `make clone-conda-env` target in the Makefile. This will clone the specified Conda environment or the active environment to a new environment in the user's home directory or a specified destination.

- Clone the active environment:
    ```sh
    make clone-conda-env
    ```
- Clone a specified environment:
    ```sh
    make clone-conda-env ENV=my_env
    ```
- Clone a specified environment to a custom directory:
    ```sh
    make clone-conda-env ENV=my_env DEST=~/my_custom_directory
    ```

#### Renaming a Conda Environment
If you need to rename the cloned environment, follow these steps:

1. Activate the cloned environment:
    ```sh
    conda activate /path/to/cloned-env
    ```

2. Export the environment to a YAML file:
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

These steps ensure that the environment is properly renamed without breaking Conda's environment management