function Preproc_TwitchDetect(cfg_input)

GeneralVariables;
exp_session = cfg_input.exp_session;
subj = cfg_input.subj;
rectif_lvl = num2str(cfg_input.rectif_lvl);

if length(subj) > 1
    error('Should enter the number of one subject only');
end

% Init
disp(['Starting twitch detection on subject ' num2str(subj)]);


% Load epoch data
if cfg_input.flag_rectif == 1, str_rectif = 'rectif'; else, str_rectif = ''; end
if cfg_input.flag_bsl == 1, str_bsl = 'bsl_'; else, str_bsl = ''; end
load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_epochs_' str_rectif rectif_lvl 'Hz_' str_bsl exp_session '_' cfg_input.epoch_label '.mat']);

% Start visual twitch detection
cfg = [];
outp = ft_databrowser(cfg, data_epoch);

% Save twitch definition
twitches = outp.artfctdef.visual.artifact;
save(['../Data_/DataProcessed_/s'  num2str(subj) '/dataft_twitches_' exp_session '_' cfg_input.epoch_label '.mat'], 'twitches', '-v7.3');

a = 0;