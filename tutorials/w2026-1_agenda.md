# REMIND Workshop for external users 

[ZOOM Link]([TBD])

Agenda [TBD]/2026

- Date: [TBD], 1:00-4:30 pm
- Please note that the sessions are recorded for PIK-internal training purposes

## Pre-workshop ([TBD]) Agenda

Ensure that all participants have all necessary software installed (Windows, Linux, *no Mac*)

- Installing REMIND and components on your local computer (Tonn)
  - GAMS, R, access to input data
  - Please also consider the [installation instructions](w2026-2_instructions.md)

- `testOneRegi` is nice but maybe we have a better test example

## Day 1 - [TBD] - 1:00-4:30 pm

### 1:00 - 2:00 SESSION 1 - CONTENT OVERVIEW (Renato, [Slides TBD])
- Macro, welfare, CES function, Nash
- Energy system (PE to UE), overview of sectors
- Techno economic assumptions
- Extraction
- Coupled models (EDGE, MAgPIE, MAGICC, PyPSA, SIMSON)
- Limitations

### 2:00-2:15 BREAK

### 2:15-3:15 SESSION 2 - CODE STRUCTURE (Lavinia/Falk, [Slides TBD])
 - Pre- and postprocessing (Lavinia)
 - Core, modules, file structure and their order, solve loop (preloop, ...) (Lavinia)
 - `main.gms` (Lavinia)
 - How to add a realization and a module (add to tutorials) (Lavinia)
 - Github repos (REMIND, piam R packages, input data) (Falk)
 - Where to find tutorials (Falk)

### 3:15-3:30 BREAK

### 3:30-4:30 SESSION 3 - POLICY IMPLEMENTATION (Laurin, [Slides TBD])
- CO2-target -> emission budget -> carbon tax 
- Tax mechanism 
- Climate impacts in remind 
- Cascade: NPi, NPi2026, policy

## Day 2 - [TBD] - 1:00-4:30

### 1:00 - 2:00 SESSION 1 - CALIBRATION (Jakob, [Slides TBD])
- CES function and what is loaded/calibrated 
- CES parameter realization "load" vs. "calibrate" (when and why to calibrate)
- How to calibrate

### 2:00-2:15 BREAK

### 2:15-3:45 SESSION 2 - SECTORS
- Transport (30min) (Alex, [Slides TBD])
- Buildings (30min) (Ricarda, [Slides TBD])
- Industry (30min) (Jakob, [Slides TBD])

### 3:45-4:00 BREAK 

### 4:00-4:30 SESSION 3 - REMIND CONFIGURATION (David K., [Slides TBD])
- Scenario configuration (`main.gms`, `default.cfg`, `scenario_confing.csv`) and running REMIND (including cascades) (David K.)

## Day 3 - [TBD] - 1:00-4:30

### 1:00 - 1:30 SESSION 1 - CONTRIBUTING TO REMIND (David K., [Slides TBD])
- Make your changes to code 
- Run `make test`
- Use PRs with template 

### 1:30 - 2:00 SESSION 2 - running REMIND and setting up REMIND scenarios
- Solve problems installing and running REMIND (Tonn/Falk)

### 2:00-2:15 BREAK

### 2:15-3:15 SESSION 3 - VIEWING RESULTS (Pascal, [Slides TBD])
- Viewing the results (compare scenarios, validation tool, solve problems) (Pascal)

### 3:15-3:30 BREAK 

### 3:30-4:30 SESSION 3 - Q&A + HANDS-ON
- Solve problems installing and running REMIND (Tonn/Falk, all)
