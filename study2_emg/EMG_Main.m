%%
% This is the Main from which the EMG analysis (ongoing activity as well as
% frequential) is done. See individual scripts for more comments.
%%
clear
clc
close all

%% Init
% Prepare fieldtrip

%% For Mac%% 
%ft_path = '../Toolbox_/fieldtrip-20240111';

%% For Windows %%
ft_path = 'Z:\Projects\Memory_Boscheron_2024_Motormem_EMG_PS\Toolbox_\fieldtrip-20240111';

addpath(ft_path);
ft_defaults;
addpath('Tools');

% Subject list

% Removing subjects 58 and 59 for analysis since they had no triggers

%subj_list = setdiff(51:80, [54, 58, 59, 64, 75, 79]);
subj_list = setdiff(51:80, [58, 59]);

% Select session: 'encoding' or 'recall'
exp_session = 'recall';


%% Get behavior
cfg = [];
cfg.subj_list = subj_list;
Preproc_Behav(cfg);


%% Preproc: convert data to fieldtrip format
cfg = [];
cfg.subj_list = subj_list;
cfg.exp_session = exp_session;
Preproc_dataRaw2ft(cfg);

%% Preproc: process raw continuous EMG data
cfg = [];
cfg.subj_list = subj_list;
cfg.exp_session = exp_session;
cfg.channel = {'right_tibialis_anterior', 'left_tibialis_anterior'};
cfg.bsfilter = 'yes';  % Bandstop filter on 50Hz and harmonics 
cfg.bsfreq = [48 52;
              98 102;
             148 152;
             198 202;
             248 252;
             298 302;
             348 352;
             398 402];

cfg.flag_rectif = -1;  % 0: no rectification; or enter lpf value to apply after rectification (computed: 20, 10, 5, 2); -1, only rectif no filter
Preproc_processRaw(cfg);

%% Preproc: find and process triggers
cfg = [];
cfg.subj_list = subj_list;
cfg.exp_session = exp_session;
Preproc_triggers(cfg);

%% Preproc: epoch data
% Event codes:
% BLOCK 1 and 2 :
% Event codes :
% 1 -> word cue
% 2 -> FR start
% 3 -> FR end


cfg = [];
cfg.subj_list = subj_list;
cfg.exp_session = exp_session;
cfg.flag_rectif = -1;
cfg.iblock = [1 2]; % Block(s) number
cfg.event_code = 2; % See event codes above
cfg.epoch_label = 'WholeTrial';
cfg.t_pretrigger = -10;  % start epoch, seconds before trigger
cfg.t_posttrigger = 16; % end epoch, seconds after trigger
cfg.flag_bsl = 0; % 0 (1: compute baseline correction, but not coded in this function)
Preproc_epoch(cfg);

%% Preproc: epoch baseline data

% BLOCK Baseline :
% Event codes :
% 1 -> rest block
% 3 -> imagery
% 6 -> max contraction right & left

cfg = [];
cfg.subj_list = subj_list;
cfg.exp_session = exp_session;
cfg.flag_rectif = 20;
cfg.iblock = ['baseline']; % Block(s) number
cfg.event_code = 6; % See event codes above
cfg.epoch_label = 'WholeTrial';
cfg.t_pretrigger = -2;  % start epoch, seconds before trigger
cfg.t_posttrigger = 15; % end epoch, seconds after trigger
cfg.flag_bsl = 0; % 0 (1: compute baseline correction, but not coded in this function)
Preproc_baseline_epoch(cfg);

%% Preproc: visual inspection of the data
% Skipping subject 4

%%% Twitch analysis: Detect twitches
% Criteria:
% - amplitude: at least 2x the general amplitude of the signal or have the typical shape
% - short time window
% - proper movement should not be included (much higher amplitude, longer time window)
% - 2 peaks are part of the same twitch event if the activity between the peaks is higher than ongoing activity
% - periodic peaks are not counted as twitches here
% --> DISCARDED
cfg = [];
cfg.subj = 51;  % Here should enter only subject at a time
cfg.exp_session = exp_session;
cfg.flag_rectif = 1;
cfg.rectif_lvl = 20;
cfg.flag_bsl = 0; 
cfg.epoch_label = 'WholeTrial';
Preproc_TwitchDetect(cfg);


%%% Ongoing activity analysis: detect "bad" segments of data
% - Bursts (more extended in time) of similar amplitude as ongoing activity stay if not in baseline period
cfg = [];
cfg.subj = 52;  % One subject at a time
cfg.exp_session = exp_session;
cfg.flag_rectif = 0;
cfg.rectif_lvl = 0;
cfg.flag_bsl = 0; 
% cfg.channel= %% channel %%
cfg.label = [''] ; % can be : 'baseline_maxrightleft_', 'baseline_maxright_' , 'baseline_maxleft_' 'baseline_imagery_' or '' for block1 and 2
cfg.epoch_label = 'WholeTrial';
Preproc_BadSegmDetect(cfg);


%% divide_badsegm
cfg = [];
cfg.subj_list = setdiff(51:80, [58, 59]);
cfg.exp_session = exp_session;
cfg.flag_rectif = 20;
cfg.flag_bsl = 0; 
cfg.epoch_label = 'WholeTrial';
cfg.cond = 'trial_cond'; 
cfg.leg= 'right';

divide_badsegm(cfg);

%% Compute ongoing activity
cfg = [];
cfg.subj_list = setdiff(51:80, [58, 59, 64, 75, 79]);
cfg.exp_session = exp_session;
cfg.flag_rectif = -1;
cfg.flag_bsl = 1; % 0 no baseline correction, 1 baseline substraction, 2 baseline normalization
cfg.epoch_label = 'WholeTrial';
cfg.cond = 'trial_cond';  % 'trial_cond': foot/no foot condition; 'SDT': signal detection theory conditions
Compute_OngoingAct(cfg);


%% Analysis
    
% Prepare data for analysis (averaging over trials/time...)
cfg = [];
cfg.subj_list = setdiff(51:80, [54, 58, 59, 64, 75, 79]);
cfg.exp_session = exp_session;
cfg.flag_rectif = -1;
cfg.flag_bsl = 1; 
cfg.epoch_label = 'WholeTrial';
cfg.cond = 'trial_cond';  % 'trial_cond': foot/no foot condition; 'SDT': signal detection theory conditions
Analyze_OngoingAct_PrepData(cfg);

% Analyze ongoing activity
cfg = [];
cfg.subj_list = setdiff(51:80, [54, 58, 59, 64, 75, 79]);
cfg.exp_session = exp_session;
cfg.flag_rectif = -1;
cfg.flag_bsl = 1; 
cfg.epoch_label = 'WholeTrial';
cfg.cond = 'trial_cond';  % 'trial_cond': foot/no foot condition; 'SDT': signal detection theory conditions
Analyze_OngoingAct(cfg);


