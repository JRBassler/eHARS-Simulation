
# Simulation of eHARS data

## Overview
The success of Ending the HIV Epidemic: A Plan for America (EHE) will depend on innovative, targeted, population specific interventions. Achieving early and sustained viral suppression (VS) following diagnosis of HIV infection is critical to improving outcomes for persons with HIV (PWH) and reducing transmission.  A deeper understanding of the socio-contextual factors driving geographic variability of VS can also guide the development of evidence-informed public health approaches to achieve timely individual and population viral control. This simulation is designed to randomly create realistic geographic components that could exist in Enhanced HIV/AIDS Reporting System (eHARS) data for each state, while accounting for the variability in this data that occurs over time. The simulated data created in the program can allow for researchers to troubleshoot development of analytic methods, while reducing the time needed from their public health department partners. The synthetic data set that is created in this code is entirely simulated and does not match any information of actual PWH in the states that are used in the simulation. 


## Purpose: Advancing collaboration between academia and state health departments to end the HIV epidemic in the Deep South
More details on our current National Institute of Allergy and Infectious Diseases-funded study, Road to Zero (R01AI142690), and the process to create the synthetic data set our simulation creates is available here:


## eHARS Data
Public health agencies collect information on diagnosis and laboratory testing for PWH and maintain the CDC-developed eHARS which contains this information. eHARS is a standardized document-based surveillance database used by state health departments to collect and manage case reports, lab reports, and other documentation on persons with HIV (PWH) and subsequently report to the CDC. The following link will direct you to more materials about eHARS and the HIV Surveillance Supplemental Reports.

https://www.cdc.gov/hiv/library/reports/hiv-surveillance.html


## Simulation
The code and materials provided here are designed to match naming conventions, variable formatting, variable length, and possible values of eHARS data. The synthetic data set that is created in this code is entirely simulated and does not match any information of actual PWH in the states that are used in the simulation. The code has been commented throughout its implementation and is regularly updated. 

### Geographic Data
For the purposes of the Road to Zero analysis, a geographic component is necessary to conduct spatial analysis. Simulated addresses are created using the GeoNames Postal Code dataset. The main GeoNames gazetteer data extract is here: http://download.geonames.org/export/dump/. The "address_sim" data set includes geocoded addresses for Alabama, Mississippi, and Louisiana, based on the aforementioned data. 


### Process
The code is designed to be run in the following order:

"01.     eHARS Data Simulation v1.1"
        -     Creates eHARS variables, that are in part, to be used for testing Road to Zero project code
        -     Output includes synthetic data sets that match eHARS data sets.
"02.     eHARS Data Management - Viral Suppression v1.1"
        -     Organizes the synthetic eHARS data set into a analysis data set; again, for the specific needs of the Road to Zero Project. 
        -     Specifically, a variables that are not in eHARS, include the date that a PWH first becomes virally suppressed, and the time (in days) between the date a PWH is diagnosed with HIV and the date they become virally suppressed. 
        -     The attached code uses Alabama as a sample, but would be re-run, after changing the state global macro to complete data management specific to other states. 
        -     Other states included are Louisiana and Mississippi.
"03.     RTZ Formats and Macros v1.1"
        -      This is only necessary if the sample analysis (04) is ran.
"04.     RTZ Descriptive Analysis v1.1"
        -      Sample survival analysis of the synthetic data set
        -      Event: VS
        -      Time: Days between HIV diagnosis and VS
        -      Censoring: Death, missing dates, elite controller (i.e., VS on first recorded viral load), or survival time estimate is not possible

### Steps

Step 1: Download all of the files and save to a directory that will be referenced/added to the programs themselves in order for the code to be run and save data sets.

Step 2: If states, other than Alabama, Mississippi, and Louisiana are intended to be used, use "00.    Address Data" and update accordingly to satisfy your needs.             Additional changes would be needed to be made in the subsequent  programs to accurately simulate geographic variables. 

Step 3: Run all programs in succession, but take care to replace global variables; specifically, the variables that correspond with the locations of the saved code; and most importantly specify your specific file path name in each SAS program.

Step 4: Please contact if you have any questions, comments, or suggestions!




