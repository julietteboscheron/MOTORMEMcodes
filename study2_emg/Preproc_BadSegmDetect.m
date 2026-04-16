%% What does this do?
% Preproc_BadSegmDetect opens the fieldtrip databrowser where we tag
% artefacts and actual movement in the raw data.

GeneralVariables;
exp_session = cfg_input.exp_session;
subj = cfg_input.subj;
rectif_lvl = num2str(cfg_input.rectif_lvl);
block = cfg_input.label;

if length(subj) > 1
    error('Should enter the number of one subject only');
end

% Init
disp(['Starting bad segment detection on subject ' num2str(subj)]);

% Load epoch data
if cfg_input.flag_rectif == 1, str_rectif = 'rectif'; else, str_rectif = ''; end
if cfg_input.flag_bsl == 1, str_bsl = 'bsl_'; else, str_bsl = ''; end
%load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_' block 'epochs_' str_rectif rectif_lvl 'Hz_' str_bsl exp_session '_' cfg_input.epoch_label '.mat']);
load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_' block 'epochs_' str_bsl exp_session '_' cfg_input.epoch_label '.mat']);

% Start visual twitch detection
cfg = [];
% cfg.channel=cfg_input.channel
outp = ft_databrowser(cfg, data_epoch);

% Save twitch definition
badsegm = outp.artfctdef.visual.artifact;
save(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_badsegm_left' exp_session '_' cfg_input.epoch_label '.mat'], 'badsegm', '-v7.3');

a = 0;