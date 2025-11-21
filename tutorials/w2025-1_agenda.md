# REMIND Workshop for external users 

[ZOOM Link](https://pik-potsdam.zoom-x.de/j/67657481652?pwd=VcfRaMtIXUaJtI5nWTY4gPEU4SXn4W.1)

Agenda 11/2025

- Date: Wed 19.11. - Fri 21.11.2025, 1:00-4:30 pm
- Please note that the sessions are recorded for PIK-internal training purposes

## Pre-workshop (17.11. and 18.11.2025) Agenda

Ensure that all participants have all necessary software installed (Windows, Linux, *no Mac*)

- Installing REMIND and components on your local computer (Tonn)
  - GAMS, R, access to input data
  - Please also consider the [installation instructions](w2025-2_instructions.md)

- `testOneRegi` is nice but maybe we have a better test example

## Day 1 - Wed 19.11. - 1:00-4:30 pm

### 1:00 - 2:00 SESSION 1 - CONTENT OVERVIEW (Renato, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D1S1-Remind_Overview_Renato_Rodrigues.pdf), [Discount rate details](https://github.com/Renato-Rodrigues/miscellany/blob/main/Discount%20rate.md))
- Macro, welfare, CES function, Nash
- Energy system (PE to UE), overview of sectors
- Techno economic assumptions
- Extraction
- Coupled models (EDGE, MAgPIE, MAGICC, PyPSA, SIMSON)
- Limitations

### 2:00-2:15 BREAK

### 2:15-3:15 SESSION 2 - CODE STRUCTURE (Lavinia/Falk, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D1S2-Code_Structure.pdf))
 - Pre- and postprocessing (Lavinia)
 - Core, modules, file structure and their order, solve loop (preloop, ...) (Lavinia)
 - `main.gms` (Lavinia)
 - How to add a realization and a module (add to tutorials) (Lavinia)
 - Github repos (REMIND, piam R packages, input data) (Falk)
 - Where to find tutorials (Falk)

### 3:15-3:30 BREAK

### 3:30-4:30 SESSION 3 - POLICY IMPLEMENTATION (Laurin, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D1S3-Policy_implementation_Laurin_K%c3%b6hler-Schindler.pdf))
- CO2-target -> emission budget -> carbon tax 
- Tax mechanism 
- Climate impacts in remind 
- Cascade: NPi, NPi2025, policy

## Day 2 - Thu 20.11. - 1:00-4:30

### 1:00 - 2:00 SESSION 1 - CALIBRATION (Jakob, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D2S1-Calibration_Jakob_Duerrwaechter.pdf))
- CES function and what is loaded/calibrated 
- CES parameter realization "load" vs. "calibrate" (when and why to calibrate)
- How to calibrate

### 2:00-2:15 BREAK

### 2:15-3:45 SESSION 2 - SECTORS
- Transport (30min) (Alex, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D2S2P1-Transport_Sector_Alex_Hagen.pdf))
- Buildings (30min) (Ricarda, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D2S2P2-Buildings_Sector_Ricarda_Rosemann.pdf))
- Industry (30min) (Jakob, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D2S2P3-Industry_Sector_Jakob_Duerrwaechter.pdf))

### 3:45-4:00 BREAK 

### 4:00-4:30 SESSION 3 - REMIND CONFIGURATION (David K., [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D2S3-Scenario_configuration_David_Klein.pdf))
- Scenario configuration (`main.gms`, `default.cfg`, `scenario_confing.csv`) and running REMIND (including cascades) (David K.)

## Day 3 - Fri 21.11. - 1:00-4:30

### 1:00 - 1:30 SESSION 1 - CONTRIBUTING TO REMIND (David K., [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D3S1-Git_Workflow_David_Klein.pdf))
- Make your changes to code 
- Run `make test`
- Use PRs with template 

### 1:30 - 2:00 SESSION 2 - running REMIND and setting up REMIND scenarios
- Solve problems installing and running REMIND (Tonn/Falk)

### 2:00-2:15 BREAK

### 2:15-3:15 SESSION 3 - VIEWING RESULTS (Pascal, [Slides](https://rse.pik-potsdam.de/data/remind/public/presentations/REMIND-WS2025-D3S2-Output_Analysis_Pascal_Weigmann.pdf))
- Viewing the results (compare scenarios, validation tool, solve problems) (Pascal)

### 3:15-3:30 BREAK 

### 3:30-4:30 SESSION 3 - Q&A + HANDS-ON
- Solve problems installing and running REMIND (Tonn/Falk, all)
