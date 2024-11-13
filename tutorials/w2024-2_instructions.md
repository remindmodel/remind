# Required software

REMIND requires some auxiliary software to run. Please make sure you have the following software installed on your system. To ensure interoperability with REMIND, the version of the software should match the versions given in the list below. *Note*: a `X` in a version string denotes a wild card that can be any number:

- `GAMS` (version `47.X`) from [here](https://www.gams.com/47/)
    - After installation please make sure to add the GAMS installation directory to the PATH environmental variable of your operating system. 
    - *Note*: GAMS is a proprietary software and requires a license key to run. In case you do not already have a GAMS license we can provide you with a temporary one. Please refer to the [GAMS license](#gams-license) section below
- `R` (version `4.3.X`): 
    - *Linux installation procedure*: R is distributed by a number of popular Linux distributions. On Ubuntu for instance, open a terminal and run
        ```bash
        sudo apt-get install r-base # Requires administrator privileges
        ```
        Further installation instructions (e.g. for non-Ubuntu Linux) can be found on the [`R` homepage](https://cran.r-project.org/bin/linux/ubuntu/fullREADME.html)
    - The *Windows installation procedure* is a bit more involved. Download the `R-4.3.2-win.exe` installer [here](https://cran.r-project.org/bin/windows/base/old/4.3.2/), as well as `Rtools43` (installation instructions can be found [here](https://cran.r-project.org/bin/windows/Rtools/), the installer itself [here](https://cran.r-project.org/bin/windows/Rtools/rtools43/files/rtools43-5958-5975.exe))
        *Optional*: To view and edit GAMS resp. R source code, please have a text editor installed. We recommend to use [Rstudio](https://posit.co/download/rstudio-desktop/)
- `git`: We use the version control software `git` to download REMIND and keep track of changes to the source code. Follow the official [installation instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for your system

# Installing REMIND

The REMIND installation procedure is mediated by the version control software git. Version control is essential to collaborative software development. This paragraph briefly lines out our approach to obtain and personalize the source code of REMIND. If not otherwise specified run these command in a shell (for Linux we recommend `bash`, for Windows we recommend `PowerShell`)

- Set-up an user account on [github.com](https://github.com/) or use your existing account
- In a terminal, navigate to the directory in which you want to store the REMIND folder. Clone the REMIND source code by running 
    ```bash
    git clone https://github.com/remindmodel/remind.git remind
    ```
- Change into the newly created directory and check out the workshop version of REMIND:
    ```bash
    cd remind # Assuming you cloned remind as described above
    git checkout workshop2024
    ``` 
- Start R once in the `remind` folder to initiate the R environment 

# GAMS license

