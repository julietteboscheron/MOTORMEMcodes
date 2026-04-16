function cfg = project_config()
% PROJECT_CONFIG
% Central configuration file for Motormem analysis
%
% Modify ONLY this file to adapt paths to your machine

%% ------------------ ROOT PATH ------------------

% Path to the root of the repository
cfg.project_root = 'Z:\Projects\Memory_Boscheron_2023_Motormem_MRI\nhb_repo';
cfg.code_root = fullfile(cfg.project_root, 'code');
cfg.toolboxes_root = fullfile(cfg.project_root, 'toolboxes');

%% ------------------ DATA ------------------

cfg.data_root = fullfile(cfg.project_root, 'demo_dataset'); % demo dataset
cfg.derivatives_root = fullfile(cfg.data_root, 'derivatives');
cfg.preproc_root = fullfile(cfg.derivatives_root, 'preproc');
cfg.sourcedata_root = fullfile(cfg.data_root, 'sourcedata'); % footloc events
cfg.masks_root = fullfile(cfg.sourcedata_root, 'masks'); % footloc events

%% ------------------ FIRST LEVEL ------------------

cfg.firstlevel_root = fullfile(cfg.derivatives_root, '1stlevel');
cfg.firstlevel_reliving_root = fullfile(cfg.firstlevel_root, 'reliving');
cfg.firstlevel_reliving_whole_root = fullfile(cfg.firstlevel_reliving_root, 'whole_period');
cfg.firstlevel_reliving_half_root = fullfile(cfg.firstlevel_reliving_root, 'half_period');
cfg.firstlevel_localiser_root = fullfile(cfg.derivatives_root, 'localiser');

%% ------------------ SECOND LEVEL ------------------
cfg.secondlevel_root = fullfile(cfg.derivatives_root, '2ndlevel');
cfg.secondlevel_reliving_root = fullfile(cfg.secondlevel_root, 'reliving');
cfg.secondlevel_pm_root = fullfile(cfg.secondlevel_root, 'parametricmod');
cfg.secondlevel_footloc_root = fullfile(cfg.secondlevel_root, 'footloc');

%% ------------------ CONN ------------------

cfg.conn_root = fullfile(cfg.derivatives_root, 'conn_analysis');

%% ------------------ SUBJECTS ------------------

cfg.subjects = { ...
    'sub-06','sub-08','sub-10','sub-11','sub-12','sub-13','sub-14',...
    'sub-15','sub-16','sub-17','sub-18','sub-19','sub-20','sub-21',...
    'sub-23','sub-24','sub-25','sub-28','sub-29','sub-31','sub-33',...
    'sub-34','sub-35','sub-36','sub-37','sub-38','sub-39','sub-40',...
    'sub-42','sub-43'};

cfg.subjects_oldnames = {'sub06', 'sub08', 'sub10', 'sub11', 'sub12',...
    'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub19',...
    'sub20', 'sub21', 'sub23', 'sub24', 'sub25', 'sub28', 'sub29',...
    'sub31', 'sub33', 'sub34', 'sub35', 'sub36', 'sub37', 'sub38',...
    'sub39', 'sub40', 'sub42', 'sub43'};

%% ------------------ CONTRASTS ------------------

% Reliving (activation)
cfg.contrast.reliving_foot = 'con_0003.nii';
cfg.contrast.reliving_nofoot = 'con_0004.nii';

% Parametric modulation
cfg.contrast.pm_foot = 'con_0001.nii';
cfg.contrast.pm_nofoot = 'con_0002.nii';

%% ------------------ SOFTWARE ------------------

cfg.TR = 1.3;
end