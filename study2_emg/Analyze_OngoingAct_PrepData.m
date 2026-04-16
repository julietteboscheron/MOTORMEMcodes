function Analyze_OngoingAct_PrepData(cfg_input)

GeneralVariables;
exp_session = cfg_input.exp_session;
subj_list = cfg_input.subj_list;
cond = cfg_input.cond;

% Time window for the baseline correction and for analysis
if strcmp(cfg_input.epoch_label, 'Reliving')  % Baseline taken on Memory cue period
    t_WoI = [1 14];
elseif strcmp(cfg_input.epoch_label, 'WholeTrial')  % Baseline taken on Fixation period
    t_WoI = [0 16];  % Free reliving period
    %t_WoI = [-4 0];  % Memory cue period
    %t_WoI = [0 8];  % Free reliving period, 1st half
    %t_WoI = [8 16];  % Free reliving period, 2nd half
    %t_WoI = [0 5];
    %t_WoI = [5 10];
    %t_WoI = [10 15];
    %t_WoI = [];  % To skip computation of averages over time
end


 %% debugging individuals
% for isubj = 1:length(subj_list)
%     subj = subj_list(isubj);
% 
%     if cfg_input.flag_rectif ~= 0, str_rectif = ['rectif' num2str(cfg_input.flag_rectif) 'Hz_']; else, str_rectif = ''; end
%     if cfg_input.flag_bsl == 1, str_bsl = 'bsl_'; else, str_bsl = ''; end
% 
%     % Load ongoing activity data
%     load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_OngoingAct_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat']);
% 
%     % Load behavior data
%     if strcmp(cond, 'trial_cond')
%         load(['../Data_/DataProcessed_/s' num2str(subj) '/databehav_trialcond.mat']);
%         nconds = 2;
%     elseif strcmp(cond, 'SDT')
%         load(['../Data_/DataProcessed_/s' num2str(subj) '/databehav_SDTcond.mat']);
%         nconds = 4;
%     end
% 
%     trial_count = 0;
% 
%     % Proceed for each condition
%     for icond = 1:nconds
%         data_trials = data_OngoingAct.([cond '_' num2str(icond)]);
% 
%         % Apply low-pass filter to all trials
%         for itrl = 1:length(data_trials.trial)
%             trial_data = data_trials.trial{itrl};
% 
%             % Interpolate NaNs if not too many
%             if sum(isnan(trial_data(1, :))) < length(trial_data(1, :)) / 2
%                 trial_data = fillgaps(trial_data);  % 'fillgaps' is a hypothetical function; replace with appropriate MATLAB function or custom interpolation
%                 data_trials.trial{itrl} = trial_data;
%             end
% 
%             cfg = [];
%             cfg.lpfilter = 'yes';
%             cfg.lpfreq = 2;
%            % trial_data = ft_preprocessing(cfg, trial_data);
% 
%             data_trials.trial{itrl} = trial_data;
%         end
% 
%         % Plot each trial for the current subject and condition
%         for itrl = 1:length(data_trials.trial)
%             trial_data = data_trials.trial{itrl};
%             if all(isnan(trial_data(:)))  % skip plotting if data is all NaNs
%                 continue;
%             end
% 
%             trial_count = trial_count + 1;  % update trial count
% 
%             % Right foot plot
%             figure(Fig_Act_Right);
%             subplot(9, 3, trial_count);  % adjust as needed
%             plot(data_trials.time{itrl}, trial_data(2,:), 'Color', col_Act.right.(['cond' num2str(icond)]));
%             title(['Trial ' num2str(trial_count) ' - Cond ' num2str(icond)]);
%             xlim([min(data_trials.time{itrl}) max(data_trials.time{itrl})]);
% 
%             % Left foot plot
%             figure(Fig_Act_Left);
%             subplot(9, 3, trial_count);  % adjust as needed
%             plot(data_trials.time{itrl}, trial_data(1,:), 'Color', col_Act.left.(['cond' num2str(icond)]));
%             title(['Trial ' num2str(trial_count) ' - Cond ' num2str(icond)]);
%             xlim([min(data_trials.time{itrl}) max(data_trials.time{itrl})]);
%         end
%     end
% end

%% Loop on subjects
for isubj = 1:length(subj_list)

    subj = subj_list(isubj);
    disp(['Computing subject ' num2str(subj)]);


    if cfg_input.flag_rectif < 0
        str_rectif = 'rectifOnly_';
    elseif cfg_input.flag_rectif > 0
        str_rectif = ['rectif' num2str(cfg_input.flag_rectif) 'Hz_'];
    else
        str_rectif = '';
    end
    
    if cfg_input.flag_bsl == 1
        str_bsl = 'bslsub_'; 
    elseif cfg_input.flag_bsl == 2
        str_bsl = 'bslnorm_';
    else 
        str_bsl = 'nobslcorr_'; 
    end

    % Load ongoing activity data
    load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_OngoingAct_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat']);

    % Load behavior data
    if strcmp(cond, 'trial_cond')
        load(['../Data_/DataProcessed_/s' num2str(subj) '/databehav_trialcond.mat']);
        nconds = 2;
    elseif strcmp(cond, 'SDT')
        load(['../Data_/DataProcessed_/s' num2str(subj) '/databehav_SDTcond.mat']);
        nconds = 4;
    end

    % Proceed for each condition
    for icond = 1:nconds

%         % Resample data
%         %%% Would have to do it at the beginning of the analysis pipeline!
%         cfg = [];
%         cfg.resamplefs = 100;
%         cfg.method = 'resample';
%         data_OngoingAct.([cond '_' num2str(icond)]) = ft_resampledata(cfg, data_OngoingAct.([cond '_' num2str(icond)]));

        % Average over trials (nanmean)
        cfg = [];
        cfg.nanmean = 'yes';
        data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]) = ft_timelockanalysis(cfg, data_OngoingAct.([cond '_' num2str(icond)]));

        % Include padding to avoid artifacts?
%         cfg = [];
%         cfg.lpfilter = 'yes';
%         cfg.lpfreq = 2;
%         data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]) = ft_preprocessing(cfg, data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]));

        % Omit the first sample after filtering if artifacts
%         data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).time = data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).time(1500:end);
%         data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).avg = data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).avg(:,1500:end);

        % Plot time course for current subject
%         figure(Fig_Act_Right); subplot(3, 9, isubj); hold on;
%         plot(data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).time, data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).avg(2,:), 'col', col_Act.right.(['cond' num2str(icond)]));
%         figure(Fig_Act_Left); subplot(3, 9, isubj); hold on;
%         plot(data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).time, data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]).avg(1,:), 'col', col_Act.left.(['cond' num2str(icond)]));

        % Average over time window of interest
        if ~isempty(t_WoI)
            cfg = [];
            cfg.avgovertime = 'yes';
            cfg.latency = t_WoI;
            cfg.nanmean = 'yes';
            data_trl_avgTime.(['s' num2str(subj)]).(['cond' num2str(icond)]) = ft_selectdata(cfg, data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]));
        else
            data_trl_avgTime.(['s' num2str(subj)]).(['cond' num2str(icond)]) = [];
        end
    end

%     figure(Fig_Act_Right); subplot(3, 9, isubj); title(subj, 'Right'); xlim([min(data_trl.(['s' num2str(subj)]).cond1.time) max(data_trl.(['s' num2str(subj)]).cond1.time)]); ylim([0.85 1.30]);
%     figure(Fig_Act_Left); subplot(3, 9, isubj); title(subj, 'Left'); xlim([min(data_trl.(['s' num2str(subj)]).cond1.time) max(data_trl.(['s' num2str(subj)]).cond1.time)]); ylim([0.85 1.30]);


    % Average trials for each condition foot / no foot
    cfg = [];
    cfg.keepsampleinfo = 'no';

    if strcmp(cfg_input.cond, 'trial_cond')
        footTrials = data_OngoingAct.trial_cond_1;
        nofootTrials = data_OngoingAct.trial_cond_2;
    else
        footTrials = ft_appenddata(cfg, data_OngoingAct.SDT_2, data_OngoingAct.SDT_4);
        nofootTrials = ft_appenddata(cfg, data_OngoingAct.SDT_1, data_OngoingAct.SDT_3);
    end
    cfg = [];
    cfg.nanmean = 'yes';
    data_trl.(['s' num2str(subj)]).foot = ft_timelockanalysis(cfg, footTrials);
    data_trl.(['s' num2str(subj)]).nofoot = ft_timelockanalysis(cfg, nofootTrials);

    % Apply low-pass filter, to retain only slow variations in activity
%     cfg = [];
%     cfg.lpfilter = 'yes';
%     cfg.lpfreq = 2;
%     data_trl.(['s' num2str(subj)]).foot = ft_preprocessing(cfg, data_trl.(['s' num2str(subj)]).foot);
%     data_trl.(['s' num2str(subj)]).nofoot = ft_preprocessing(cfg, data_trl.(['s' num2str(subj)]).nofoot);
%     
    if ~isempty(t_WoI)
        cfg = [];
        cfg.avgovertime = 'yes';
        cfg.latency = t_WoI;
        cfg.nanmean = 'yes';
        data_trl_avgTime.(['s' num2str(subj)]).foot = ft_selectdata(cfg, data_trl.(['s' num2str(subj)]).foot);
        data_trl_avgTime.(['s' num2str(subj)]).nofoot = ft_selectdata(cfg, data_trl.(['s' num2str(subj)]).nofoot);
    else
        data_trl_avgTime.(['s' num2str(subj)]).foot = [];
        data_trl_avgTime.(['s' num2str(subj)]).nofoot = [];
    end

end

% Save data
save(['../Data_/Group_/dataAnalyze_data_trl_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat'], 'data_trl', '-v7.3');
if ~isempty(t_WoI)
    save(['../Data_/Group_/dataAnalyze_data_trl_avgTime_' num2str(t_WoI(1)) 'to' num2str(t_WoI(2)) str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat'], 'data_trl_avgTime', '-v7.3');
end





