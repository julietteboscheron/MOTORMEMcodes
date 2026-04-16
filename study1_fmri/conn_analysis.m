%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONN batch setup for MOTORMEM functional connectivity analyses %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron
%
% This script specifies and runs CONN toolbox analyses for the MOTORMEM
% dataset using preprocessed functional and anatomical images.
%
% The script:
%   1. Initializes a CONN project
%   2. Imports subject-specific structural, functional, tissue-mask, and ROI files
%   3. Defines task conditions from previously generated onset/duration files
%   4. Specifies motion regressors and denoising parameters
%   5. Runs first-level ROI-to-ROI and seed-to-voxel connectivity analyses
%   6. Runs a gPPI analysis across task conditions
%
% 

clear 
clc
cfg = project_config();
addpath(cfg.toolboxes_root);

sub_list = cfg.subjects;


cd(cfg.conn_root);

%Load subject folders

path_subjects= 'Z:\Projects\Memory_Boscheron_2023_Motormem_MRI\MOTORMEM_BIDS\derivatives\preproc_1';cfg.preproc_root;
folders=dir(path_subjects);
folders={folders.name}';
folders = setdiff(folders,{'.';'..'});

%% Variables to adapt
NumberSubjects = length(folders);
TR = 1.3; 
BATCH_FILENAME = 'Conn_analysis_clustROIs.mat';
ROI_PATH = cfg.masks_root;
ROIs   = char(ls([ROI_PATH '\*.nii']));


%% SETUP

%Define batch properties
clear BATCH;
BATCH.Setup.isnew=1;
BATCH.filename = BATCH_FILENAME;
BATCH.FWHM = 8; %Can be adapted, but always a good start
BATCH.Setup.RT = TR;
BATCH.Setup.nsubjects = NumberSubjects;%
BATCH.Setup.acquisitiontype = 1; % continous (default value)
BATCH.Setup.analyses = [1,2,3]; % ROI to ROI and seed to voxel
BATCH.Setup.voxelmask = 1; %1-fixed template mask; 2-implicit uses subject specific mask
BATCH.Setup.voxelresolution = 3; % functional space used
BATCH.Setup.outputfiles = [0,0,1,1,1]; % write nii volumes for r-maps, p-maps and FDR-p-maps 

for i = 1:length(folders)
    disp(['*******************************' i '*****************************'])
    BATCH.Setup.rois = [];
    BATCH.Setup.rois.names = cellstr(ROIs);
        for h=1:size(ROIs,1)
            BATCH.Setup.rois.files{h}{1}= fullfile(ROI_PATH,ROIs(h,:)); 
          BATCH.Setup.rois.mask(h) = 1; %1 mask/0 not mask each ROI with Gray matter voxels 
            
        end
    
    BATCH.Setup.rois.dimensions = repmat({1},1,length(cellstr(ROIs)));%takes the mean times series for each ROIs 
    BATCH.Setup.rois.power = repmat({1},1,length(cellstr(ROIs)));
    
    
    %SET FOR ENCODING      
    Anat_folder = [path_subjects char(folders(i,:)) '\\anat\\'];
    Func_folder = [path_subjects  char(folders(i,:)) '\\func\\'];

    if i == 9 || i==13 
        onsetdurations1 = load(fullfile(cfg.sourcedata_root, subject_id, 'func', char(folders(i,:)), 'onsetsdurations_ALLTRL_block2', char(folders(i,:)), '.mat'));
        onsetdurations2.names = []; onsetdurations2.onsets = []; onsetdurations2.durations = [];
    elseif i == 30
        onsetdurations1 = load(fullfile(cfg.sourcedata_root, subject_id, 'func', char(folders(i,:)), 'onsetsdurations_ALLTRL_block3', char(folders(i,:)), '.mat'));
        onsetdurations2.names = []; onsetdurations2.onsets = []; onsetdurations2.durations = [];
    else
        onsetdurations1 = load(fullfile(cfg.sourcedata_root, subject_id, 'func', char(folders(i,:)), 'onsetsdurations_ALLTRL_block1', char(folders(i,:)), '.mat'));
        onsetdurations2 = load(fullfile(cfg.sourcedata_root, subject_id, 'func', char(folders(i,:)), 'onsetsdurations_ALLTRL_block2', char(folders(i,:)), '.mat'));
    end
    
        t1_file{i} = char(ls([Anat_folder 'wsub*.nii']));
        BATCH.Setup.structurals{i} = {[Anat_folder t1_file{i}]};
    % 
        c1_file{i} = spm_select('FPList',Anat_folder,'^wc1');
        c2_file{i} = spm_select('FPList',Anat_folder,'^wc2');
        c3_file{i} = spm_select('FPList',Anat_folder,'^wc3');
    
    % specificy structural data per subject
        BATCH.Setup.masks.Grey.files{i} = c1_file{i};
        BATCH.Setup.masks.Grey.dimensions=1;
        BATCH.Setup.masks.White.files{i} = c2_file{i};
        BATCH.Setup.masks.White.dimensions=1;
        BATCH.Setup.masks.CSF.files{i} = c3_file{i};
        BATCH.Setup.masks.CSF.dimensions=1; 
    
    % specify conditions per subject {ncond}{nsub}{nsess}: 
    if i==9 ||  i ==13
        BATCH.Setup.functionals{i}{1} ={spm_select('expand',fullfile([Func_folder ls([Func_folder ['swu*' char(folders(i,:)) '_task-reliv_run-02*']])]))};
    elseif i == 30
        BATCH.Setup.functionals{i}{1} ={spm_select('expand',fullfile([Func_folder ls([Func_folder ['swu*' char(folders(i,:)) '_task-reliv_run-03*']])]))};
    else
        BATCH.Setup.functionals{i}{1} ={spm_select('expand',fullfile([Func_folder ls([Func_folder ['swu*' char(folders(i,:)) '_task-reliv_run-01*']])]))};
        BATCH.Setup.functionals{i}{2} ={spm_select('expand',fullfile([Func_folder ls([Func_folder ['swu*' char(folders(i,:)) '_task-reliv_run-02*']])]))};
    end
    BATCH.Setup.conditions.names = {'FreeRecallFoot', 'FreeRecallNoFoot','FreeRecall','FixCross', 'RecogFoot', 'RecogNoFoot', 'Recog'}; %of course, to adapt according to your conditions of interest
    
     % specify conditions per subject {ncond}{nsub}{nsess} 
    Index_FreeRecall1 = contains(onsetdurations1.names,'free');
    Index_Recog1 = contains(onsetdurations1.names,'recog'); 
    Index_Foot1 = contains(onsetdurations1.names,'_foot');
    Index_NoFoot1 = contains(onsetdurations1.names,'nofoot');

    Index_Fix1 = contains(onsetdurations1.names,'fix');
    
    if i == 9 || i==13 || i ==30
        Index_FreeRecall2 = [];
        Index_Recog2 = [];
        Index_Foot2 = [];
        Index_NoFoot2 = [];
        Index_Fix2 = [];
    else
        Index_FreeRecall2 = contains(onsetdurations2.names,'free');
        Index_Recog2 = contains(onsetdurations2.names,'recog');
        Index_Foot2 = contains(onsetdurations2.names,'_foot');
        Index_NoFoot2 = contains(onsetdurations2.names,'nofoot');
        Index_Fix2 = contains(onsetdurations2.names,'fix');
    end
    
    FreeRecallFoot1 = intersect(find(Index_FreeRecall1),find(Index_Foot1));
    FreeRecallFoot2 =  intersect(find(Index_FreeRecall2),find(Index_Foot2));
    FreeRecallNoFoot1 = intersect(find(Index_FreeRecall1),find(Index_NoFoot1));
    FreeRecallNoFoot2 =  intersect(find(Index_FreeRecall2),find(Index_NoFoot2));
    RecogFoot1 = intersect(find(Index_Recog1),find(Index_Foot1));
    RecogFoot2 =  intersect(find(Index_Recog2),find(Index_Foot2));
    RecogNoFoot1 = intersect(find(Index_Recog1),find(Index_NoFoot1));
    RecogNoFoot2 =  intersect(find(Index_Recog2),find(Index_NoFoot2));
    FixFoot1 = intersect(find(Index_Foot1),find(Index_Fix1));
    FixFoot2 = intersect(find(Index_Foot2),find(Index_Fix2));
    FixNoFoot1 = intersect(find(Index_NoFoot1),find(Index_Fix1));
    FixNoFoot2 = intersect(find(Index_NoFoot2),find(Index_Fix2));

    % first block
    
    BATCH.Setup.conditions.onsets{1}{i}{1} = cell2mat(onsetdurations1.onsets(FreeRecallFoot1))*TR;
    BATCH.Setup.conditions.durations{1}{i}{1} = cell2mat(onsetdurations1.durations(FreeRecallFoot1))*TR;
    
    BATCH.Setup.conditions.onsets{2}{i}{1} = cell2mat(onsetdurations1.onsets(FreeRecallNoFoot1))*TR;
    BATCH.Setup.conditions.durations{2}{i}{1} =cell2mat(onsetdurations1.durations(FreeRecallNoFoot1))*TR;
    
    BATCH.Setup.conditions.onsets{3}{i}{1} =  [cell2mat(onsetdurations1.onsets(FreeRecallFoot1)); cell2mat(onsetdurations1.onsets(FreeRecallNoFoot1))]*TR;
    BATCH.Setup.conditions.durations{3}{i}{1} = [cell2mat(onsetdurations1.durations(FreeRecallFoot1)); cell2mat(onsetdurations1.durations(FreeRecallNoFoot1))]*TR;
    
    BATCH.Setup.conditions.onsets{4}{i}{1} = [cell2mat(onsetdurations1.onsets(FixFoot1));cell2mat(onsetdurations1.onsets(FixNoFoot1))]*TR;
    BATCH.Setup.conditions.durations{4}{i}{1} = [cell2mat(onsetdurations1.durations(FixFoot1));cell2mat(onsetdurations1.durations(FixNoFoot1))]*TR;
    
    BATCH.Setup.conditions.onsets{5}{i}{1} = cell2mat(onsetdurations1.onsets(RecogFoot1))*TR;
    BATCH.Setup.conditions.durations{5}{i}{1} = cell2mat(onsetdurations1.durations(RecogFoot1))*TR;
    
    BATCH.Setup.conditions.onsets{6}{i}{1} = cell2mat(onsetdurations1.onsets(RecogNoFoot1))*TR;
    BATCH.Setup.conditions.durations{6}{i}{1} =cell2mat(onsetdurations1.durations(RecogNoFoot1))*TR;
    
    BATCH.Setup.conditions.onsets{7}{i}{1} = [cell2mat(onsetdurations1.onsets(RecogFoot1));cell2mat(onsetdurations1.onsets(RecogNoFoot1))]*TR;
    BATCH.Setup.conditions.durations{7}{i}{1} = [cell2mat(onsetdurations1.durations(RecogFoot1));cell2mat(onsetdurations1.durations(RecogNoFoot1))]*TR;
    
    
    % second block
    
    BATCH.Setup.conditions.onsets{1}{i}{2} = cell2mat(onsetdurations2.onsets(FreeRecallFoot2))*TR;
    BATCH.Setup.conditions.durations{1}{i}{2} = cell2mat(onsetdurations2.durations(FreeRecallFoot2))*TR;
    
    BATCH.Setup.conditions.onsets{2}{i}{2} = cell2mat(onsetdurations2.onsets(FreeRecallNoFoot2))*TR;
    BATCH.Setup.conditions.durations{2}{i}{2} = cell2mat(onsetdurations2.durations(FreeRecallNoFoot2))*TR;
    
    BATCH.Setup.conditions.onsets{3}{i}{2} =  [cell2mat(onsetdurations2.onsets(FreeRecallFoot2)); cell2mat(onsetdurations2.onsets(FreeRecallNoFoot2))]*TR;
    BATCH.Setup.conditions.durations{3}{i}{2} = [cell2mat(onsetdurations2.durations(FreeRecallFoot2)); cell2mat(onsetdurations2.durations(FreeRecallNoFoot2))]*TR;
    
    BATCH.Setup.conditions.onsets{4}{i}{2} = [cell2mat(onsetdurations2.onsets(FixFoot2));cell2mat(onsetdurations2.onsets(FixNoFoot2))]*TR;
    BATCH.Setup.conditions.durations{4}{i}{2} = [cell2mat(onsetdurations2.durations(FixFoot2));cell2mat(onsetdurations2.durations(FixNoFoot2))]*TR;
    
    BATCH.Setup.conditions.onsets{5}{i}{2} = cell2mat(onsetdurations2.onsets(RecogFoot2))*TR;
    BATCH.Setup.conditions.durations{5}{i}{2} = cell2mat(onsetdurations2.durations(RecogFoot2))*TR;
    
    BATCH.Setup.conditions.onsets{6}{i}{2} = cell2mat(onsetdurations2.onsets(RecogNoFoot2))*TR;
    BATCH.Setup.conditions.durations{6}{i}{2} =cell2mat(onsetdurations2.durations(RecogNoFoot2))*TR;
    
    BATCH.Setup.conditions.onsets{7}{i}{2} = [cell2mat(onsetdurations2.onsets(RecogFoot2));cell2mat(onsetdurations2.onsets(RecogNoFoot2))]*TR;
    BATCH.Setup.conditions.durations{7}{i}{2} = [cell2mat(onsetdurations2.durations(RecogFoot2));cell2mat(onsetdurations2.durations(RecogNoFoot2))]*TR;
    
    BATCH.Setup.conditions.missingdata=1;
    
    BATCH.Setup.done = 1; % run the SETUP step

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(folders)
    Func_folder = [path_subjects  char(folders(i,:)) '\\func\\'];
    %% DENOISING
%s{ncovariate}{nsub}{nses} 
BATCH.Setup.covariates.names = {'motion'};
    if i==9 || i==13
        BATCH.Setup.covariates.files{1}{i}{1} = spm_select('FPlist',Func_folder,'rp_.*run-02.*\.txt$');% mvt
        BATCH.Setup.covariates.files{1}{i}{2} = [];% mvt
    elseif i ==30
        BATCH.Setup.covariates.files{1}{i}{1} = spm_select('FPlist',Func_folder,'rp_.*run-03.*\.txt$');% mvt
        BATCH.Setup.covariates.files{1}{i}{2} = [];% mvt
    else
        BATCH.Setup.covariates.files{1}{i}{1} = spm_select('FPlist',Func_folder,'rp_.*run-01.*\.txt$');% mvt
        BATCH.Setup.covariates.files{1}{i}{2} = spm_select('FPlist',Func_folder,'rp_.*run-02.*\.txt$');% mvt
    end
end

BATCH.Setup.done = 1; % run the SETUP step

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Denoising

BATCH.Preprocessing.filter               = [0.008, 0.09]; % set the passband filter limits
BATCH.Preprocessing.confounds.names      = {'White Matter', 'CSF', 'motion'};
BATCH.Preprocessing.confounds.dimensions = {'1','1','6',};
BATCH.Preprocessing.confounds.deriv      = {'0','0','1'};
BATCH.Preprocessing.done                 = 1; % run the PREPROCESSING/denoising step
conn_batch(BATCH);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% FIRST-LEVEL ANALYSIS
clear BATCH


load( [BATCH_FILENAME 'CONN_x'])
BATCH.filename = BATCH_FILENAME;
BATCH.Analysis.analysis_number = 1;
BATCH.Analysis.type = 3; % do ROI to ROI and seed to voxel analysis
BATCH.Analysis.measure = 1; % measure bivariate correlation
BATCH.Analysis.weight = 2; % use hrf as weight
BATCH.Analysis.sources.names = cellstr(ROIs);
BATCH.Analysis.sources.dimensions = repmat({1},1,length(cellstr(ROIs)));
BATCH.Analysis.sources.deriv = repmat({0},1,length(cellstr(ROIs)));
BATCH.Analysis.done = 1; % run the ANALYSIS step for ROI to ROI and seed to voxel
BATCH.vvAnalysis.done = 0; % run the ANALYSIS step for voxel to voxel
%% SECOND LEVEL ANALYSIS
BATCH.Results.foldername                      = [BATCH_FILENAME '\GROUPANALYSIS\'];
BATCH.Results.analysis_number                 = 1;
BATCH.Results.between_conditions.effect_names = {'FreeRecallFoot', 'FreeRecallNoFoot','FreeRecall','FixCross', 'RecogFoot', 'RecogNoFoot', 'Recog'};

BATCH.Results.between_sources.effect_names    = cellstr(ROIs);
BATCH.Results.display                          = 0;
BATCH.Results.done                             = 1;

 conn_batch(BATCH);
% 
%% FIRST-LEVEL ANALYSIS
clear BATCH

load( [BATCH_FILENAME 'CONN_x'])
BATCH.filename = BATCH_FILENAME;
BATCH.Analysis.analysis_number = 1;
BATCH.Analysis.name = 'gPPI';
BATCH.Analysis.type = 3; % do ROI to ROI and seed to voxel 
BATCH.Analysis.measure = 3; % measure bivariate regression
BATCH.Analysis.weight = 2; % use hrf as weight
BATCH.Analysis.modulation = 1; % gPPI analysis

BATCH.Analysis.sources.names = cellstr(ROIs);  
BATCH.Analysis.sources.dimensions = repmat({1},1,length(cellstr(ROIs)));  
BATCH.Analysis.sources.deriv = repmat({0},1,length(cellstr(ROIs)));
BATCH.Analysis.done = 1; % run the ANALYSIS step for ROI to ROI 
BATCH.Analysis.overwrite = 1;
 conn_batch(BATCH);
