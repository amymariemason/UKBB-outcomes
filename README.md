# Stata_outcomes
There are several options here for creating a new outcome field that combines self-report fields, HES data and ONS and primary care datasets. 
(NOTE: Diabetes and Cancer are still being updated, do not use this for those outcomes - revert back to the master branch for those) 

This program has a control sheet: bespoke_outcome_v2.1.xls and a set of Stata.do files, controlled from Master.do

Together you can define custom outcomes that combine results from HES, ONS, some of the self-report fields and the primary care dataset.  
Events are taken to be any match to any completed field (OR match) and people are defined as either cases (1) or controls (0).  
The most recent update can also seperate events into incident and prevalent, giving the earliest known such date. 

**************************************************************
The Control sheet:

Open this and edit the sheet to include the outcome codes you want to indicate a case.

Completer: Include your name so that others know who created the definition
Outcome name: This becomes the description for the variable in the stata output, as well as an immediate summary for those using the control sheet. 
Suggested variable name: This is used to generate all variables associated with this outcome. This must be less than 14 characters long or the program will fail to run. e.g. {name} is the main outome, {name}nSR is the main outcome excluding any cases that came only from self-reported variables. 
ICD-9 codes: These are matched to the 41271 datafields (included main and secondary diagnoses from hospital inpatient episodes)
ICD-10 codes: These are matched to the 41270 datafields (included main and secondary diagnoses from hospital inpatient episodes)
Death 40001, 40002	: These are matched to the 40001, 40002 datafields (included main and secondary causes from ONS)
Self-report 20002	: These are matched to the 20002 datafields (self-reported non-cancer illnesses) using datacoding 6 (http://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=6 ) Note: the coding value not the node value. 
Self-report 20004	: These are matched to the 20002 datafields (self-reported operations) using datacoding 5 (http://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=5 )
Self-report 6150: These are matched to the 6150 datafield (self-reported Vascular/heart problems diagnosed by doctor) using datacoding 100605 (http://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=100605 ) 
Self-report 6152	: These are matched to the 6152 datafields (self-reported 	Blood clot, DVT, bronchitis, emphysema, asthma, rhinitis, eczema, allergy diagnosed by doctor) using datacoding 100610 (http://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=100610 ) 
Self-report 6153	: These are matched to the 6153 datafields (self-reported 	Medication for cholesterol, blood pressure, diabetes, or take exogenous hormones) in WOMEN ONLY using datacoding 100626 (http://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=100626 ) 
Self-report 6177: These are matched to the 6177 datafields (self-reported 	Medication for cholesterol, blood pressure, diabetes) in MEN ONLY using datacoding 100625 (http://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=100625). 
Procedures (OPCS): These are matched to datafields 41272 & 41273 (HES reported operation codes in OPCS4 and OPCS3, respectively) using datacodings 240 & 259.
Use Primary Care	: "YES" here will cause an additional dataset to be created, giving this outcome in the primary care subset. This subset is restricted to participants who were registered at certain GPs, and restricted to the dates for which we have continual coverage post baseline. 
Match ICD10 Primary Care Codes: "YES" here will attempt to automate matching of ICD10 codes to Read V2 and Read V3 codes. This is described in more detail on the Primary Care Matching Key. It is *highly* recommended that you specify codes instead wherever possible.  
Read V3 Primary Care Codes: These are matched to truncated raw primary care data for UK Biobank, using Read V3 codes
Read V2 Primary Care Codes: These are matched to truncated raw primary care data for UK Biobank, using Read V2 codes
Prevalent/Incident: "YES" here will cause additional output for this variable - cases will be split into prevalent and incident, and time to event in years since baseline for incident events. 
Comments on definition: Long description of the outcome definition; used to describe the outcome in detail and how it differs/overlaps with other definitions
Other comments: Free text

Note: Codes must be comma seperated. ".X" at the end of a code causes a wildcard match that agrees with the start of your code. Simply adding X at the end will not have this effect, and will cause missed outcomes (e.g. 600.1.X not 600.1X). Otherwise the program looks for an exact match

*************************************************************
The .do files

The config section at the start of the Master.do file must be edited to give the location of the relevant files. 

**************************************************************
INSTRUCTIONS ON HOW TO EXTRACT DATA 

OFFICIAL ADVICE 
Raw data

The raw data can be found at the following location:
\\ME-FILER1\GROUPS3$\CEU-BIOBANK DATA\Biobank\BioBank_Data\P7439\Supplied_Data

This directory includes all standard, HES, Primary Care and withdrawal data. Standard datasets have been validated and decrypted. Please refer to the following guide for details of how to convert data-fields of interest: 
http://biobank.ctsu.ox.ac.uk/~bbdatan/Accessing_UKB_data_v2.0.pdf

Helper programs and the encoding file can be found in each standard dataset directory. For information on the contents of the standard datasets please refer to the ‘README.xlsx’ file, ‘Summary.csv’ file, together with the ‘.html’ and ‘fields.ukb’ files within each dataset directory. 

UNOFFICIAL GUIDE to data extraction

1) Find the data
(A) As of 05/02/2020 the P7439 data is at: \\Me-filer1\groups3$\CEU-Biobank data\Biobank\BioBank_Data\P7439\Supplied_Data. 
The fields are spread accross several files and you may need to do multiple conversions to get all of them.
(B) You are looking for a file of the form ukb7437.enc_ukb, an encoding file called "encoding.ukb" & a conversion application called ukbconv. A text file in the same document called fields.ukb lists what fields are available in each dataset. 
(C) You also need the HES datasets: e.g. hesin_oper_20191011 & hesin_diag_20191011
(D) You also need the withdrawal list: e.g. w7439_20181016
(E) You might want a copy of the primary care data
(F) Copy all of these accross to a local directory on your own C drive. e.g. C:\UKBB\data\

3) create a list of the required variables as a txt file 
Note: the conversion program takes many hours, you want to check and double check you have every field you need before running.
e.g. my_fields.txt 
(A) ENSURE that this file takes the same format as the "fields.ukb" file (i.e. 1 field number per line).
(B) The converted fields will have the format “F-I.A” (or “F_I_A”), where F is the field ID, I is the instance index and A is the array index. 
(C) You may find it useful to use the “Browse” section of the “Online showcase of UK Biobank resources”
(http://biobank.ctsu.ox.ac.uk/showcase/label.cgi) when compiling your list of fields to convert.
(D) There is a recommended minimum list of these for each program at the end of this document. 
(E) Save in relevant dataset directory e.g.  C:\UKBBdata\data_20191105_38375\my_fields.txt

4) use the UKBB extract tool:
(A)  Open the Command Prompt (i.e. cmd.exe) 
(B) Navigate to the location of the ukbconv program: 
cd C:\UKBB\data
(C) For each dataset that you wish to convert, run the converter (ukb_conv), 
ukb_conv C:\UKBB\data\ukb38375.enc_ukb stata -iC:\UKBBdata\data_20191105_38375\my_fields.txt -
oC:\UKBBdata\data_20191105_38375\ukb38375_stata
**** Note:
* must be entered on a single line & specifies: 
** (a) Location of the dataset (e.g. C:\UKBB\data\ukb38375.enc_ukb ),
** (b) Format to convert to (e.g. stata),
** (c) input: Location of the fields file (e.g. -iC:\UKBBdata\data_20191105_38375\my_fields.txt)
** (d) output: Location of the converted dataset
(e.g. -
oC:\UKBBdata\data_20191105_38375\ukb38375_stata)
(D) this will create a .log logfile,.raw datafile, .dct dictionary file & .do Stata command file. 
(E) run the .do file; save the resulting dataset.
(F) delete the .raw & .enc_ukb files as they are very large; unless you have further extractions to run. 

***************************************************************

***************************************************************
LISTS OF VARIABLES TO EXTRACT
***************************************************************

CORE
6150
6152
6177
6153 
20002
20004
40001
40002


PREVALENT/INCIDENT (Core +)
53
54
40000
20008
3627
3994
2966
4056
3786
4012
3992
3761
4022

CANCER  (Core +)
20001
40013
40006
40011

FAMILY
20107
20110
20111

DIABETES 

31
2976
2986
4041
6153
6177
20002
20003
20009
21000


FULL LIST

6150
6152
6177
6153 
20002
20004
40001
40002
53
40000
20008
3627
3994
2966
4056
3786
4012
3992
3761
4022
20001
40013
40006
40011
20107
20110
20111
31
2976
2986
4041
6153
6177
20002
20003
20009
21000






