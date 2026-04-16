# EMG Analysis Pipeline (MOTORMEM)

## Overview
This repository contains MATLAB scripts used to preprocess and analyze EMG recordings acquired during the MOTORMEM experiment. 
The pipeline focuses on quantifying subthreshold motor activity during episodic memory retrieval.

Raw data available at: 10.5281/zenodo.19561204.
---

## Dependencies

- MATLAB (R2021a or later recommended)
- FieldTrip toolbox (fieldtrip-20240111)

All toolboxes must be added to the MATLAB path prior to running the scripts.

1. Clone or download this repository
2. Install MATLAB
3. Download and install:
   - FieldTrip toolbox: https://www.fieldtriptoolbox.org/


---

## Pipeline

1. Behavioral preprocessing  
   `Preproc_Behav.m`

2. Conversion to FieldTrip  
   `Preproc_dataRaw2ft.m`

3. Continuous EMG preprocessing  
   `Preproc_processRaw.m`

4. Trigger detection  
   `Preproc_triggers.m`

5. Epoching  
   `Preproc_epoch.m`  
   `Preproc_baseline_epoch.m`

6. Artifact detection  
   `Preproc_BadSegmDetect.m`  
   `Preproc_TwitchDetect.m`  
   `divide_badsegm.m`

7. EMG computation  
   `Compute_OngoingAct.m`

8. Group analysis  
   `Analyze_OngoingAct.m`  
   `Analyze_OngoingAct_PrepData.m`

---

## Running the Pipeline

Run:
```matlab
EMG_Main.m
```

---

## Outputs

- Preprocessed EMG data
- Epoched trials
- Artifact annotations
- Trial-wise EMG measures
- CSV files for statistical analysis

---

## Reproducibility

- Paths are defined in `GeneralVariables.m`
- Some steps require manual artifact rejection
- Subject-specific exclusions are explicitly coded

---

## Author

Mariana Babo-Rebelo, Pepijn Schoenmakers and Juliette Boscheron  
EPFL — Laboratory of Cognitive Neuroscience
