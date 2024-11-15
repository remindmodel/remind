# Required software

REMIND requires some auxiliary software to run. Please make sure you have the following software installed on your system. To ensure interoperability with REMIND, the version of the software should match the versions given in the list below. *Note*: an `X` in a version string denotes a wildcard that can be any number:

- `GAMS` (version `47.X`) from [here](https://www.gams.com/47/)
    - After installation, please make sure to add the GAMS installation directory to the PATH environmental variable of your operating system. 
    - *Note*: GAMS is proprietary software and requires a license key to run. In case you do not already have a GAMS license, we can provide you with a temporary one. Please refer to the [GAMS license](#gams-license) section below.
- `R` (version `4.3.X`): 
    - *Linux installation procedure*: R is distributed by a number of popular Linux distributions. On Ubuntu, for instance, open a terminal and run
        ```bash
        sudo apt-get install r-base # Requires administrator privileges
        ```
        Further installation instructions (e.g., for non-Ubuntu Linux) can be found on the [`R` homepage](https://cran.r-project.org/bin/linux/ubuntu/fullREADME.html)
    - The *Windows installation procedure* is a bit more involved. Download the `R-4.3.2-win.exe` installer [here](https://cran.r-project.org/bin/windows/base/old/4.3.2/), as well as `Rtools43` (installation instructions can be found [here](https://cran.r-project.org/bin/windows/Rtools/), the installer itself [here](https://cran.r-project.org/bin/windows/Rtools/rtools43/files/rtools43-5958-5975.exe))
    - *Optional*: To view and edit GAMS and R source code, please have a text editor installed. We recommend using [RStudio](https://posit.co/download/rstudio-desktop/)
- `git`: We use the version control software `git` to download REMIND and keep track of changes to the source code. Follow the official [installation instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for your system.

# Installing REMIND

The REMIND installation procedure is mediated by the version control software git. Version control is essential to collaborative software development. This paragraph briefly outlines our approach to obtain and personalize the source code of REMIND. If not otherwise specified, run these commands in a shell (for Linux we recommend `bash`, for Windows we recommend `PowerShell`).

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

We have acquired a GAMS license for all participants in the REMIND Workshop for external users. Please note that the license will expire on *December 06, 2024*. To install the license, copy the following six lines to the clipboard. Then, open GAMS Studio and click on `Help > GAMS Licensing` or `Help > About GAMS`, depending on your version of GAMS Studio. A message box will notify you that a GAMS license has been found on the clipboard. If 'Yes' is clicked, the new license will be installed automatically and presented via the "About GAMS" dialog.

```
Course_License_________________________________S241106|0002AO-GEN
Potsdam-Institut_f._Klimafolgenforschung_e.V.,___________________
1382890301BACOCPKNM5GEPTSN_______________________________________
21250202010101010101010101_______________________________________
DCE3853______g_7_______________________________A_Course__________
License_Admin:_Lavinia.Baumstark@pik-potsdam.de__________________
```

For more detailed installation instructions, you can please consult the [GAMS Support Website](https://www.gams.com/latest/docs/UG_MAIN.html#UG_INSTALL)
