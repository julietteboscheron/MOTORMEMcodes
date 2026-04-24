# MOTORMEM fMRI Analysis Pipeline

This repository contains MATLAB scripts used to preprocess, model, and analyze the MOTORMEM fMRI dataset, investigating motor reinstatement during episodic memory retrieval.

A demo dataset is available at https://zenodo.org/records/19561204?token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6IjRjMjliNmQ0LTMzNmQtNDZjZS1hZjBmLTMzODk4NjZmMmRjNyIsImRhdGEiOnt9LCJyYW5kb20iOiJmMjZkYTFjY2RmNWM5ODE2MzYzYjAzNzJjOWViYjQ1ZiJ9.L7uOYBuoWTVetym1FsgXuJEOa9SqXl1sxhlLrkW0BPgFYlUdf6yf8yl9-6mlELmDk0PvyxOkg5ru0i6EZk5JeA.

The full dataset will be made public soon but is not yet available due to its large size (120gb) and ethical restrictions with human fMRI data.

---

## System requirements

### Software

The pipeline was developed and tested with:

- MATLAB (R2021a or later recommended)
- SPM12 v7487 
- CONN toolbox (version 21a or later)

All toolboxes must be added to the MATLAB path prior to running the scripts.

1. Clone or download this repository
2. Install MATLAB
3. Download and install:
   - SPM12: https://www.fil.ion.ucl.ac.uk/spm/
   - CONN toolbox: https://web.conn-toolbox.org/
4. Update paths in:
```matlab
project_config.m
```

Typical installation time: ~10–20 minutes (excluding MATLAB/toolbox installation)

### Operating systems tested

- Windows 10  
- macOS (Unix-based systems)

### Hardware requirements

No non-standard hardware is required.  

---

### Scripts

1. Preprocessing  
   `fmri_preprocessing.m`

2. Event extraction  
   `specify_onsetsandurations_runs.m`  
   `specify_onsetsandurations_footloc.m`  

3. First-level analyses  
   `specifyfirstlevel_relivingwhole.m`  
   `specifyfirstlevel_relivinghalf.m`  
   `specifyfirstlevel_footloc.m`  

4. Second-level analyses  
   `secondlevelrelivinganalysis.m`  
   `secondlevelPManalysis.m`  

5. Foot localiser analysis  
   `localizers_definition.m`  
   `footloc_ttest.m`  

6. Functional connectivity  
   `conn_analysis.m`  

Scripts are designed to be run sequentially, although each step can be executed independently once its inputs are available.

---

### Expected output

- Preprocessed functional images (normalized, smoothed)
- First-level SPM models and contrast images
- Second-level statistical maps
- ROI masks (left/right M1) ans t-test results
- CONN connectivity results

---

### Expected runtime (demo dataset)

- Preprocessing: ~30–60 minutes per subject  
- First-level models: ~10–20 minutes per subject  
- CONN analysis: ~2 hours total  


---

## Reproducibility notes

- All paths and parameters are centralized in project_config.m  
- Subject-specific adjustments (e.g., missing runs, corrected trials) are explicitly coded in scripts  
- For reproducibility, these subject-specific adjustments are preserved as implemented.

---

## Author

Juliette Boscheron  
EPFL — Laboratory of Cognitive Neuroscience  
