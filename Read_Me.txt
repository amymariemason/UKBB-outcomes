Author: Amy Mason

There are several options here for creating a new outcome field that combines self-report fields, HES data and 

DIABETES: The diabetes folder contains an algorithm that updates the published algorithm to encorporate data after baseline. It will need updating when new data is published, but doesn't need adjusting otherwise.

CANCER: This is two files (Add_cancer_subsets.do & bespoke_outcome_cancer_v5.xlsx). This adds variables for the cancers and their subtypes in biobank with more than 400 events in biobank (as of August 2019). 
 - bespoke_outcome_cancer_v5.xlsx contains the definitions of the cancers. It can be duplicated and adjusted to change the definitions. 
- add_cancer_subsets.do takes these definitions and defines two variables for each one, with ("{variable name}")and without ("{variable name}_nSR") self report information. This file will need adjusting in the first few lines to include links to the appropiete data files. 
Events are taken to be any match to any completed field (OR match) and people are defined as either cases (1) or controls (0). No date information is captured - see Elias' file for an extention to capture incident vs. prevalent information. 


OTHER OUTCOMES: This is two files (bespoke_outcome_current.xlsx and Add_outcome.do). This adds variables for CVD and other variables using HES (primary and secondary fields), selfreport fields and death certificate information.  

- bespoke_outcome_current contains various definitions for outcomes. To add a new outcome, simply add another line to the excel file. 

-Add_outcome.do takes these definitions and defines two variables for each one, with ("{variable name}")and without ("{variable name}_nSR") self report information. This file will need adjusting in the first few lines to include links to the appropiete data files. 

Events are taken to be any match to any completed field (OR match) and people are defined as either cases (1) or controls (0). No date information is captured - see Elias' file for an extention to capture incident vs. prevalent information. 

INCIDENT/PREVALENT - This is two files (bespoke_outcome_current.xlsx and Add_outcome_incident_prevalent.do). Elias' extension for the OTHER OUTCOMES set. It takes the same control sheet but outputs events as incident and prevalent instead.

AMM 18/10/2019
