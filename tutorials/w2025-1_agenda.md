# REMIND Workshop for external users 

ZOOM: https://pik-potsdam.zoom-x.de/j/67657481652?pwd=VcfRaMtIXUaJtI5nWTY4gPEU4SXn4W.1

Agenda 11/2025

- Date: Wed 19.11. - Fri 21.11.2025, 1:00-4:30 pm
- ask people to use names and switch on video when asking questions
- recording

## Pre-workshop (17.11. and 18.11.2025) Agenda

### ensure that all participants have all installed (Windows, Linux, no Mac)
INSTALLING REMIND

- installing REMIND and components on your local computer (Tonn)
  - gams, R, access to input data

- `testOneRegi`is nice but maybe we have a better test example

## Day 1 - Wed 19.11. - 1:00-4:30 pm

### 1:00 - 2:00 SESSION 1 - CONTENT OVERVIEW (Renato)
- macro, welfare, CES function, Nash
- energy system (PE->UE), overview of sectors
- techno economic assumptions
- extraction
- coupled models (EDGE, MAgPIE, MAGICC, PyPSA, SIMSON)
- limitations

### 2:00-2:15 BREAK

### 2:15-3:15 SESSION 2 - CODE STRUCTURE (Lavinia/Falk)
 - Pre- and postprocessing (Lavinia)
 - core, modules, file structure and their order, solve loop (preloop, ...) (Lavinia)
 - main.gms (Lavinia)
 - how to add a realization and a module (add to tutorials) (Lavinia)
 - github repos (REMIND, piam R packages, input data) (Falk)
 - where to find tutorials (Falk)

### 3:15-3:30 BREAK

### 3:30-4:30 SESSION 3 - POLICY IMPLEMENTATION (Laurin)
- CO2-target -> emission budget -> carbon tax 
- tax mechanism 
- climate imapcts in remind 
- cascade: NPi, NPi2025, policy

## Day 2 - Thu 20.11. - 1:00-4:30

### 1:00 - 2:00 SESSION 1 - CALIBRATION (Jakob)
- CES function and what is loaded/calibrated 
- CES parameter realization "load" vs. "calibrate" (when and why to calibrate)
- How to calibrate

### 2:00-2:15 BREAK

### 2:15-3:45 SESSION 2 - SECTORS
- transport (30min) (Alex)
- buildings (30min) (Ricarda)
- industry (30min) (Jakob)

### 3:45-4:00 BREAK 

### 4:00-4:30 SESSION 3 - REMIND CONFIGURATION (David K.)
- scenario configuration (default.cfg, scenario_confing.csv, input data) and running REMIND (including iterations) (David K.)

## Day 3 - Fri 21.11. - 1:00-4:30

### 1:00 - 1:30 SESSION 1 - CONTRIBUTING TO REMIND (David K.)
- make your changes to code 
- run make test 
- use PRs with template 

### 1:30 - 2:00 SESSION 2 - running REMIND and setting up REMIND scenarios
- solve problems installing and running REMIND (Tonn/Falk)

### 2:00-2:15 BREAK

### 2:15-3:15 SESSION 3 - VIEWING RESULTS
- viewing the results (compare scenarios, validation tool, solve problems) (Pascal)

### 3:15-3:30 BREAK 

### 3:30-4:30 SESSION 3 - Q&A + HANDS-ON
- helping hands
- solve problems installing and running REMIND (Tonn/Falk?, all)


# Questions we ask for registration:

Testlink: XXX

- Name
- Affiliation
- Do you use REMIND results?
   - If yes: from which data base and project?
- Do you already use the REMIND code? 
   - I looked into the REMIND GitHub repository
   - I cloned REMIND code
   - I had a closer look at the REMIND code
   - I installed the needed R-packages for running REMIND
   - I started a REMIND run
   - I successfully completed a REMIND run
   - I tried to use REMIND to answer a research question
- Did you attend REMIND workshop 2024?
- What do you envisage to aply REMIND for?
- What would you like to learn at this REMIND workshop?
- Daten/Videozustimmung


# Invitation

### Invitation text

Dear researcher and stakeholder interested in REMIND,

We are pleased to invite you to an online REMIND introductory workshop in November 2025, which for the secound time is aimed at external users. The first two days will provide an overview of the model as well as a technical look at the code and its structure. The third day will focus on working with REMIND. If you aim for running REMIND, we will offer pre-workshop-sessions for helping you setting up your system.

The workshop will take place online from
Wed 19.11. - Fri 21.11.2025
from 1:00 - 4:30 p.m. CET (12:00 - 3:30 p.m. UTC)

Mon 17.11. and Tue 18.11.2025 at 1 p.m. - Sesssions for setting up the system 

Please register for the event via the following link by 1st November: https://eveeno.com/remind-workshop2025

AGENDA (preliminary): 
   - Day 1 - Wed 19.11. - 1:00-4:30 - CONTENT
      - 1:00 - 2:00 SESSION 1 - CONTENT OVERVIEW (macroeconomic core, energy system, sectors, coupled models)
      - 2:15 - 3:15 SESSION 2 - CODE STRUCTURE (repositories, code structure, configuration)
      - 3:30 - 4:30 SESSION 3 - POLICY IMPLEMENTATOION (tax mechanism, definition of NPi and emission budgets)
   - Day 2 - Thu 20.11. - 1:00-4:30 - CONTENT
       - 1:00 - 2:00 SESSION 1 - REMIND CALIBRATION (CES function and how to calibrate)      
       - 2:15 - 3:45 SESSION 2 - SECTORS (transport, buildings, industry)
       - 4:00 - 4:30 SESSION 3 - REMIND CONFIGURATION
   - Day 3 - Thu 21.11. - 1:00-4:30 - HANDS-ON
      - 1:00 - 1:30 SESSION 1 - CONTRIBUTING TO REMIND (how to make changes to the code, test and deploy them) 
      - 1:30 - 2:00 SESSION 2 - running REMIND and setting up REMIND scenarios
      - 2:15 - 3:15 SESSION 3 - VIEWING RESULTS
      - 3:30 - 4:30 SESSION 4 - Q&A + HANDS-ON

Kind regards,
Lavinia Baumstark (on behalf of the REMIND-Team)

### where to distribute?
- IAMC newsletter
- REMIND and MAgPIE group

# Topics to cover (potentially) based on questionnaire

Expectation management at the beginning: we will not be able to solve all individual software problems, we can only solve individual cases as examples for everyone.