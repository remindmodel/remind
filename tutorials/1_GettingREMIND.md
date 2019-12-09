This guide will give you a brief technical introduction in how to run and use the model REMIND.
================
Felix Schreyer (<felix.schreyer@pik-potsdam.de>), Lavinia Baumstark (<baumstark@pik-potsdam.de>)
30 April, 2019

Introduction
--------------

As normal runs with REMIND take quite a while (from a couple of hours to several days), you normally don't want to run them locally (i.e., on your own machine) but on the cluster provided by the IT-services. The first step is to access the Cluster. In general, there are three ways how to access the Cluster:
	
1. Putty console 
2. WinSCP 
3. Windows Explorer, click on network drive (only possible if you are in PIK LAN)

They all have their upsides and downsides. Don't worry! If they are new to you, you will figure out what is best for which kind of task after some time and get more famliar just by your practice. Using either Putty or the network drive in Windows Explorer, the first step is:

adjust .Rprofile
-----------------
First, log onto the Cluster via WinSCP and open the file `/home/username/.profile` in a text editor. Add these two lines and save the file.

``` bash
module load piam 
umask 0002
```
This loads the piam environment once you log onto the Cluster via Putty the next time. This envrionment will enable you to manage the runs that you do on the Cluster. Next, you need to specify the kind of run you would like to do. 
   	
Find a Place to Start
-----------------------

Create a folder on the Cluster where you want to store REMIND. It is recommended not to use the `home` directory. For your first experiments you can use the /p/tmp/YourPIKName/ directory (only stored for 3 months) and create a following folder:

``` bash
p/tmp/YourPIKName/REMIND
```
(in case you are using Putty and are not familiar with unix commands, google a list of basic unix commands, you will need `mkdir` to create a folder). Go inside this folder.

Now, you need to download REMIND into this folder. The download works via git. In this way, different people can develop the model simultaneously and changes can be traced back and undone in case the merged code does not work as it is supposed to. Cloning a new REMIND version via git is always possible. However, before pushing your changes to the common version for the first time, please talk to the research software engineering group. They are happy to give you an introduction.

Cloning REMIND
--------------------

To clone REMIND via Windows Explorer: Right-click in your REMIND folder and choose `git clone` (if not availble, install tortoise git or ask the RSE group). Insert <https://gitlab.pik-potsdam.de/REMIND/REMIND}>
as `URL of repository`. On command line use

``` bash
			git clone git@gitlab.pik-potsdam.de:REMIND/REMIND.git
```

and hit enter. This will download the REMIND version in the current folder.


Great, you now have REMIND!

