%% What does this do?
% Analyze_OngoingAct creates the figures and performs all
% analyses on the subthreshold, ongoing EMG activity. Alternative analysis
% attempts are found at the bottom of this script. 
clear all
cfg_input = [];
cfg_input.subj_list = setdiff(51:80, [54, 58, 59, 64, 73, 75, 79]);
cfg_input.exp_session = 'recall';
cfg_input.flag_rectif = -1;
cfg_input.flag_bsl = 1; 
cfg_input.epoch_label = 'WholeTrial';
cfg_input.cond = 'trial_cond';  % 'trial_cond': foot/no foot condition; 'SDT': signal detection theory conditions


GeneralVariables;
exp_session = cfg_input.exp_session;
subj_list = cfg_input.subj_list;
cond = cfg_input.cond;

% function Analyze_OngoingAct(cfg_input)

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

% Start figures
%  Fig_Act_Left  = figure('Color', [1 1 1], 'Position', [20 50 1920 1080]);
%  Fig_Act_Right = figure('Color', [1 1 1], 'Position', [20 50 1920 1080]);
if strcmp(cond, 'trial_cond')
    col_Act.left.cond1 = [0.6 0.6 0.9]; % Left foot: pastel blue, foot condition
    col_Act.left.cond2 = [0.9 0.6 0.6];    % Left foot: pastel red, no foot condition
    col_Act.right.cond1 = [0 80 239]/255;  % Right foot: dark blue, foot condition
    col_Act.right.cond2 = [162 0 37]/255;  % Right foot: red, no foot condition
    col_Act.right.cond3 = [0, 0.3137, 0];  % Dark green
    col_Act.right.cond4 = [96 169 23]/255; % Hit: bright green
    col_PwSp.right.cond1 = [0 80 239]/255;  % Right foot: dark blue, foot condition
    col_PwSp.right.cond2 = [162 0 37]/255;  % Right foot: red, no foot condition
elseif strcmp(cond, 'SDT')  
    col_Act.left.cond1 = [229 20 0]/255;   % Correct rejection: bright red
    col_Act.left.cond2 = [227 200 0]/255;  % Miss: dark red
    col_Act.left.cond3 = [0 80 239]/255;   % False alarm: dark green 
    col_Act.left.cond4 = [96 169 23]/255;  % Hit: bright green
    col_Act.right.cond1 = [229 20 0]/255;  % Correct rejection: bright red
    col_Act.right.cond2 = [227 200 0]/255; % Miss: dark red
    col_Act.right.cond3 = [0 80 239]/255;  % False alarm: dark green
    col_Act.right.cond4 = [96 169 23]/255; % Hit: bright green
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
    %load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_OngoingAct_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '_noBSL.mat']);

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

%         % Average over trials (nanmean)
        cfg = [];
        cfg.nanmean = 'yes';
        data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]) = ft_timelockanalysis(cfg, data_OngoingAct.([cond '_' num2str(icond)]));
        
%         %Average trials for each condition foot / no foot
%         cfg = [];
%         cfg.keepsampleinfo = 'no';
    
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

        % Include padding to avoid artifacts?
%         cfg = [];
%         cfg.lpfilter = 'yes';
%         cfg.lpfreq = 2;
%         data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]) = ft_preprocessing(cfg, data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]));

        % % Omit the first sample after filtering if artifacts
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

%     cfg = [];
%     cfg.lpfilter = 'yes';
%     cfg.lpfreq = 2;
%     data_trl.(['s' num2str(subj)]).foot = ft_preprocessing(cfg, data_trl.(['s' num2str(subj)]).foot);
%     data_trl.(['s' num2str(subj)]).nofoot = ft_preprocessing(cfg, data_trl.(['s' num2str(subj)]).nofoot);

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

%% Load data
load('../Data_/Group_/dataAnalyze_data_trl.mat');
if ~isempty(t_WoI)
    load(['../Data_/Group_/dataAnalyze_data_trl_avgTime_' num2str(t_WoI(1)) 'to' num2str(t_WoI(2)) '.mat']);
end

%% Plot average time course, foot vs no foot conditions
cfg = [];
% gd_avg.foot = ft_timelockgrandaverage(cfg, data_trl.s51.foot, data_trl.s52.foot, data_trl.s53.foot, data_trl.s54.foot, data_trl.s55.foot, data_trl.s56.foot, data_trl.s57.foot, data_trl.s60.foot, data_trl.s61.foot, data_trl.s62.foot, data_trl.s63.foot, data_trl.s64.foot, data_trl.s65.foot, data_trl.s66.foot, data_trl.s67.foot, data_trl.s68.foot, data_trl.s69.foot, data_trl.s70.foot, data_trl.s71.foot, data_trl.s72.foot, data_trl.s73.foot, data_trl.s74.foot, data_trl.s76.foot, data_trl.s77.foot, data_trl.s78.foot, data_trl.s80.foot);
% gd_avg.nofoot = ft_timelockgrandaverage(cfg, data_trl.s51.nofoot, data_trl.s52.nofoot, data_trl.s53.nofoot, data_trl.s54.nofoot, data_trl.s55.nofoot, data_trl.s56.nofoot, data_trl.s57.nofoot, data_trl.s60.nofoot, data_trl.s61.nofoot, data_trl.s62.nofoot, data_trl.s63.nofoot, data_trl.s64.nofoot, data_trl.s65.nofoot, data_trl.s66.nofoot, data_trl.s67.nofoot, data_trl.s68.nofoot, data_trl.s69.nofoot, data_trl.s70.nofoot, data_trl.s71.nofoot, data_trl.s72.nofoot, data_trl.s73.nofoot, data_trl.s74.nofoot, data_trl.s76.nofoot, data_trl.s77.nofoot, data_trl.s78.nofoot, data_trl.s80.nofoot);
gd_avg.foot = ft_timelockgrandaverage(cfg, data_trl.s51.foot, data_trl.s52.foot, data_trl.s53.foot, data_trl.s55.foot, data_trl.s56.foot, data_trl.s57.foot, data_trl.s60.foot, data_trl.s61.foot, data_trl.s62.foot, data_trl.s63.foot, data_trl.s65.foot, data_trl.s66.foot, data_trl.s67.foot, data_trl.s68.foot, data_trl.s69.foot, data_trl.s70.foot, data_trl.s71.foot, data_trl.s72.foot, data_trl.s73.foot, data_trl.s74.foot, data_trl.s76.foot, data_trl.s77.foot, data_trl.s78.foot, data_trl.s80.foot);
gd_avg.nofoot = ft_timelockgrandaverage(cfg, data_trl.s51.nofoot, data_trl.s52.nofoot, data_trl.s53.nofoot, data_trl.s55.nofoot, data_trl.s56.nofoot, data_trl.s57.nofoot, data_trl.s60.nofoot, data_trl.s61.nofoot, data_trl.s62.nofoot, data_trl.s63.nofoot, data_trl.s65.nofoot, data_trl.s66.nofoot, data_trl.s67.nofoot, data_trl.s68.nofoot, data_trl.s69.nofoot, data_trl.s70.nofoot, data_trl.s71.nofoot, data_trl.s72.nofoot, data_trl.s73.nofoot, data_trl.s74.nofoot, data_trl.s76.nofoot, data_trl.s77.nofoot, data_trl.s78.nofoot, data_trl.s80.nofoot);

figure('Color', [1 1 1]); hold on;
plot(gd_avg.foot.time, gd_avg.foot.avg(2,:), 'col', col_PwSp.right.cond1, 'LineWidth', 2);
plot(gd_avg.nofoot.time, gd_avg.nofoot.avg(2,:), 'col', col_PwSp.right.cond2, 'LineWidth', 2);
legend('Foot', 'No foot', 'FontSize', 14);
set(gca, 'FontSize', 17);
ylabel('Ongoing activity (microV)');
xlabel('Time (s)');
hold off;

cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfreq = 2;
data_condFoot = ft_preprocessing(cfg, gd_avg.foot);
data_condNoFoot = ft_preprocessing(cfg, gd_avg.nofoot);

figure('Color', [1 1 1]); hold on;
if strcmp(cfg.cond, 'trial_cond')
    plot(data_condFoot.time, data_condFoot.avg(2,:), 'col', col_PwSp.right.cond1, 'LineWidth', 2);
    plot(data_condNoFoot.time, data_condNoFoot.avg(2,:), 'col', col_PwSp.right.cond2, 'LineWidth', 2);
else
%     plot(data_condFoot.time, data_condFoot.avg(1,:), 'col', col_Act.right.cond4, 'LineWidth', 2);
%     plot(data_condNoFoot.time, data_condNoFoot.avg(1,:), 'col', col_Act.right.cond1, 'LineWidth', 2);
end

% Set plot parameters
%xlim([-9.8 max(gd_avg.foot.time)]);
%ylim([0.97 1.03]);
legend('Foot', 'No foot', 'FontSize', 14);
set(gca, 'FontSize', 17);
ylabel('Ongoing activity (microV)');
xlabel('Time (s)');

hold off
%% Clustering analysis over time

% Grand average over subjects, keeping subject data
cfg = [];
cfg.keepindividual = 'yes';
gd_avg_foot = ft_timelockgrandaverage(cfg, data_trl.s51.foot, data_trl.s52.foot, data_trl.s53.foot, data_trl.s55.foot, data_trl.s56.foot, data_trl.s57.foot, data_trl.s60.foot, data_trl.s61.foot, data_trl.s62.foot, data_trl.s63.foot, data_trl.s65.foot, data_trl.s66.foot, data_trl.s67.foot, data_trl.s68.foot, data_trl.s69.foot, data_trl.s70.foot, data_trl.s71.foot, data_trl.s72.foot, data_trl.s73.foot, data_trl.s74.foot, data_trl.s76.foot, data_trl.s77.foot, data_trl.s78.foot, data_trl.s80.foot);
gd_avg_nofoot = ft_timelockgrandaverage(cfg, data_trl.s51.nofoot, data_trl.s52.nofoot, data_trl.s53.nofoot, data_trl.s55.nofoot, data_trl.s56.nofoot, data_trl.s57.nofoot, data_trl.s60.nofoot, data_trl.s61.nofoot, data_trl.s62.nofoot, data_trl.s63.nofoot, data_trl.s65.nofoot, data_trl.s66.nofoot, data_trl.s67.nofoot, data_trl.s68.nofoot, data_trl.s69.nofoot, data_trl.s70.nofoot, data_trl.s71.nofoot, data_trl.s72.nofoot, data_trl.s73.nofoot, data_trl.s74.nofoot, data_trl.s76.nofoot, data_trl.s77.nofoot, data_trl.s78.nofoot, data_trl.s80.nofoot);

% Prepare stats
cfg = [];
cfg.channel = 'right_tibialis_anterior';
cfg.latency = [0 16];
cfg.method = 'ft_statistics_montecarlo';  % use the Monte Carlo method to calculate probabilities
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.correctm = 'cluster';
cfg.clusterstatistic = 'maxsum';
cfg.clusteralpha = 0.05; % this can be changed
cfg.tail = 0;  % two-sided test
cfg.clustertail = 0;
cfg.alpha = 0.05;
cfg.correcttail = 'prob';  % https://www.fieldtriptoolbox.org/faq/why_should_i_use_the_cfg.correcttail_option_when_using_statistics_montecarlo/#correct-probabilities
cfg.numrandomization = 1000;  % Ex: 500 for quick testing, 10000 for more stable results

%% Prepare design
nsubj = length(subj_list);
design = zeros(2,2*nsubj);
for i = 1:nsubj
  design(1,i) = i;
end
for i = 1:nsubj
  design(1,nsubj+i) = i;
end
design(2,1:nsubj)        = 1;
design(2,nsubj+1:2*nsubj) = 2;
cfg.design = design;
cfg.uvar  = 1;
cfg.ivar  = 2;

%% Compute stats
stat_in_time = ft_timelockstatistics(cfg, gd_avg_foot, gd_avg_nofoot);
disp(['First pos cluster: p=' num2str(stat_in_time.posclusters(1).prob) ', in ' num2str(min(stat_in_time.time(stat_in_time.posclusterslabelmat==1))) ' to ' num2str(max(stat_in_time.time(stat_in_time.posclusterslabelmat==1)))]);

%% Average activity per WoI with s.e.m

% Define time windows
time_windows = [-10 -5; -5 0; 0 5; 5 10; 10 15];

% Define colours
pastelRed = [0.9 0.6 0.6];
pastelBlue = [0.6 0.6 0.9];

% Initialize arrays to store the averages and SEMs for each window and each condition
avg_foot_left = zeros(size(time_windows, 1), 1);
sem_foot_left = zeros(size(time_windows, 1), 1);
avg_nofoot_left = zeros(size(time_windows, 1), 1);
sem_nofoot_left = zeros(size(time_windows, 1), 1);
avg_foot_right = zeros(size(time_windows, 1), 1);
sem_foot_right = zeros(size(time_windows, 1), 1);
avg_nofoot_right = zeros(size(time_windows, 1), 1);
sem_nofoot_right = zeros(size(time_windows, 1), 1);

% Compute the averages and SEMs for each window
for i = 1:size(time_windows, 1)
    % Indices for left foot
    idx_foot_left = find(data_condFoot.time >= time_windows(i, 1) & data_condFoot.time <= time_windows(i, 2));
    avg_foot_left(i) = mean(data_condFoot.avg(1, idx_foot_left));
    sem_foot_left(i) = std(data_condFoot.avg(1, idx_foot_left)) %/ sqrt(length(idx_foot_left));

    idx_nofoot_left = find(data_condNoFoot.time >= time_windows(i, 1) & data_condNoFoot.time <= time_windows(i, 2));
    avg_nofoot_left(i) = mean(data_condNoFoot.avg(1, idx_nofoot_left));
    sem_nofoot_left(i) = std(data_condNoFoot.avg(1, idx_nofoot_left)) %/ sqrt(length(idx_nofoot_left));

    % Indices for right foot
    idx_foot_right = find(data_condFoot.time >= time_windows(i, 1) & data_condFoot.time <= time_windows(i, 2));
    avg_foot_right(i) = mean(data_condFoot.avg(2, idx_foot_right));
    sem_foot_right(i) = std(data_condFoot.avg(2, idx_foot_right)) %/ sqrt(length(idx_foot_right));

    idx_nofoot_right = find(data_condNoFoot.time >= time_windows(i, 1) & data_condNoFoot.time <= time_windows(i, 2));
    avg_nofoot_right(i) = mean(data_condNoFoot.avg(2, idx_nofoot_right));
    sem_nofoot_right(i) = std(data_condNoFoot.avg(2, idx_nofoot_right)) %/ sqrt(length(idx_nofoot_right));
end

% Plot the results
figure('Color', [1 1 1]); hold on;

% Plotting averages with error bars for left leg
errorbar(1:5, avg_foot_left, sem_foot_left, 'o-', 'Color', pastelBlue, 'MarkerSize', 1, 'LineWidth', 1, 'MarkerFaceColor', pastelBlue);
errorbar(1:5, avg_nofoot_left, sem_nofoot_left, 'o-', 'Color', pastelRed, 'MarkerSize', 1, 'LineWidth', 1, 'MarkerFaceColor', pastelRed);

% Plotting averages with error bars for right leg
errorbar(1:5, avg_foot_right, sem_foot_right, 'o-', 'Color', col_Act.right.cond1, 'MarkerSize', 1, 'LineWidth', 1, 'MarkerFaceColor', col_Act.right.cond1);
errorbar(1:5, avg_nofoot_right, sem_nofoot_right, 'o-', 'Color', col_Act.right.cond2, 'MarkerSize', 1, 'LineWidth', 1, 'MarkerFaceColor', col_Act.right.cond2);

% Set plot parameters
xlim([0.5 5.5]);
xticks(1:5);
xticklabels({'[-10, -5]', '[-5, 0]', '[0, 5]','[5, 10]', '[10, 15]'});
ylim([0.99 1.01]);
yticks(0.99:0.005:1.01);
legend('Foot Left', 'No Foot Left', 'Foot Right', 'No Foot Right', 'FontSize', 14);
set(gca, 'FontSize', 14);
ylabel('Average EMG activity (microV)');
xlabel('Time windows');




%% Plot average activity over time window of interest
cfg = [];
% gd_avg_WoI.foot = ft_timelockgrandaverage(cfg, data_trl_avgTime.s51.foot, data_trl_avgTime.s52.foot, data_trl_avgTime.s53.foot, data_trl_avgTime.s54.foot, data_trl_avgTime.s55.foot, data_trl_avgTime.s56.foot, data_trl_avgTime.s57.foot, data_trl_avgTime.s60.foot, data_trl_avgTime.s61.foot, data_trl_avgTime.s62.foot, data_trl_avgTime.s63.foot, data_trl_avgTime.s64.foot, data_trl_avgTime.s65.foot, data_trl_avgTime.s66.foot, data_trl_avgTime.s67.foot, data_trl_avgTime.s68.foot, data_trl_avgTime.s69.foot, data_trl_avgTime.s70.foot, data_trl_avgTime.s71.foot, data_trl_avgTime.s72.foot, data_trl_avgTime.s73.foot, data_trl_avgTime.s74.foot, data_trl_avgTime.s76.foot, data_trl_avgTime.s77.foot, data_trl_avgTime.s78.foot, data_trl_avgTime.s80.foot);
% gd_avg_WoI.nofoot = ft_timelockgrandaverage(cfg, data_trl_avgTime.s51.nofoot, data_trl_avgTime.s52.nofoot, data_trl_avgTime.s53.nofoot,data_trl_avgTime.s54.nofoot, data_trl_avgTime.s55.nofoot, data_trl_avgTime.s56.nofoot, data_trl_avgTime.s57.nofoot, data_trl_avgTime.s60.nofoot, data_trl_avgTime.s61.nofoot, data_trl_avgTime.s62.nofoot, data_trl_avgTime.s63.nofoot, data_trl_avgTime.s64.nofoot, data_trl_avgTime.s65.nofoot, data_trl_avgTime.s66.nofoot, data_trl_avgTime.s67.nofoot, data_trl_avgTime.s68.nofoot, data_trl_avgTime.s69.nofoot, data_trl_avgTime.s70.nofoot, data_trl_avgTime.s71.nofoot, data_trl_avgTime.s72.nofoot, data_trl_avgTime.s73.nofoot, data_trl_avgTime.s74.nofoot, data_trl_avgTime.s76.nofoot, data_trl_avgTime.s77.nofoot, data_trl_avgTime.s78.nofoot, data_trl_avgTime.s80.nofoot);figure('Color', [1 1 1]); hold on;
% gd_avg_WoI.foot = ft_timelockgrandaverage(cfg, data_trl_avgTime.s51.foot, data_trl_avgTime.s52.foot, data_trl_avgTime.s53.foot, data_trl_avgTime.s55.foot, data_trl_avgTime.s56.foot, data_trl_avgTime.s57.foot, data_trl_avgTime.s60.foot, data_trl_avgTime.s61.foot, data_trl_avgTime.s62.foot, data_trl_avgTime.s63.foot, data_trl_avgTime.s65.foot, data_trl_avgTime.s66.foot, data_trl_avgTime.s67.foot, data_trl_avgTime.s68.foot, data_trl_avgTime.s69.foot, data_trl_avgTime.s70.foot, data_trl_avgTime.s71.foot, data_trl_avgTime.s72.foot, data_trl_avgTime.s73.foot, data_trl_avgTime.s74.foot, data_trl_avgTime.s76.foot, data_trl_avgTime.s77.foot, data_trl_avgTime.s78.foot, data_trl_avgTime.s80.foot);
% gd_avg_WoI.nofoot = ft_timelockgrandaverage(cfg, data_trl_avgTime.s51.nofoot, data_trl_avgTime.s52.nofoot, data_trl_avgTime.s53.nofoot, data_trl_avgTime.s55.nofoot, data_trl_avgTime.s56.nofoot, data_trl_avgTime.s57.nofoot, data_trl_avgTime.s60.nofoot, data_trl_avgTime.s61.nofoot, data_trl_avgTime.s62.nofoot, data_trl_avgTime.s63.nofoot, data_trl_avgTime.s65.nofoot, data_trl_avgTime.s66.nofoot, data_trl_avgTime.s67.nofoot, data_trl_avgTime.s68.nofoot, data_trl_avgTime.s69.nofoot, data_trl_avgTime.s70.nofoot, data_trl_avgTime.s71.nofoot, data_trl_avgTime.s72.nofoot, data_trl_avgTime.s73.nofoot, data_trl_avgTime.s74.nofoot, data_trl_avgTime.s76.nofoot, data_trl_avgTime.s77.nofoot, data_trl_avgTime.s78.nofoot, data_trl_avgTime.s80.nofoot);figure('Color', [1 1 1]); hold on;
gd_avg_WoI.foot = ft_timelockgrandaverage(cfg, data_trl_avgTime.s51.foot, data_trl_avgTime.s52.foot, data_trl_avgTime.s53.foot, data_trl_avgTime.s55.foot, data_trl_avgTime.s56.foot, data_trl_avgTime.s57.foot, data_trl_avgTime.s60.foot, data_trl_avgTime.s61.foot, data_trl_avgTime.s62.foot, data_trl_avgTime.s63.foot, data_trl_avgTime.s65.foot, data_trl_avgTime.s66.foot, data_trl_avgTime.s67.foot, data_trl_avgTime.s68.foot, data_trl_avgTime.s69.foot, data_trl_avgTime.s70.foot, data_trl_avgTime.s71.foot, data_trl_avgTime.s72.foot, data_trl_avgTime.s74.foot, data_trl_avgTime.s76.foot, data_trl_avgTime.s77.foot, data_trl_avgTime.s78.foot, data_trl_avgTime.s80.foot);
gd_avg_WoI.nofoot = ft_timelockgrandaverage(cfg, data_trl_avgTime.s51.nofoot, data_trl_avgTime.s52.nofoot, data_trl_avgTime.s53.nofoot, data_trl_avgTime.s55.nofoot, data_trl_avgTime.s56.nofoot, data_trl_avgTime.s57.nofoot, data_trl_avgTime.s60.nofoot, data_trl_avgTime.s61.nofoot, data_trl_avgTime.s62.nofoot, data_trl_avgTime.s63.nofoot, data_trl_avgTime.s65.nofoot, data_trl_avgTime.s66.nofoot, data_trl_avgTime.s67.nofoot, data_trl_avgTime.s68.nofoot, data_trl_avgTime.s69.nofoot, data_trl_avgTime.s70.nofoot, data_trl_avgTime.s71.nofoot, data_trl_avgTime.s72.nofoot, data_trl_avgTime.s74.nofoot, data_trl_avgTime.s76.nofoot, data_trl_avgTime.s77.nofoot, data_trl_avgTime.s78.nofoot, data_trl_avgTime.s80.nofoot);figure('Color', [1 1 1]); hold on;


figure('Color', [1 1 1]); hold on;


% Bar plot for left foot (avg(1) for left)
bar(categorical({'Foot'}), gd_avg_WoI.foot.avg(2), 'FaceColor', col_Act.right.cond1);
bar(categorical({'No foot'}), gd_avg_WoI.nofoot.avg(2), 'FaceColor', col_Act.right.cond2);
% bar(categorical({'Foot'}), gd_avg_WoI.foot.avg(1), 'FaceColor', col_Act.right.cond1);
% bar(categorical({'No foot'}), gd_avg_WoI.nofoot.avg(1), 'FaceColor', col_Act.right.cond2);

nsubj = length(subj_list);
for isubj = 1:nsubj
%       if isubj ~= 2
        subj = subj_list(isubj);
%        plot(1:2, [data_trl_avgTime.(['s' num2str(subj)]).foot.avg(2) data_trl_avgTime.(['s' num2str(subj)]).nofoot.avg(2)], '.-', 'Color', [0.8 0.8 0.8], 'MarkerSize', 10);
%        plot(1:2, [data_trl_avgTime.(['s' num2str(subj)]).foot.avg(1) data_trl_avgTime.(['s' num2str(subj)]).nofoot.avg(1)], '.-', 'Color', [0.8 0.8 0.8], 'MarkerSize', 10);


         y_values = [data_trl_avgTime.(['s' num2str(subj)]).foot.avg(2), ...
                data_trl_avgTime.(['s' num2str(subj)]).nofoot.avg(2)];
    
        % Plot individual subject lines
        plot(1:2, y_values, '.-', 'Color', [0.8 0.8 0.8], 'MarkerSize', 10);
        
        % Add subject names next to each point
%         text(1, y_values(1), ['s' num2str(subj)], 'FontSize', 12, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
%         text(2, y_values(2), ['s' num2str(subj)], 'FontSize', 12, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

%          continue
%      end
end
% ylim([0.96 1.02]);
% yticks(0.96:0.01:1.02);
ylabel('Mean ongoing activity (A.U)')
set(gca,'FontSize',17);


%%
%to svae for R plotting

% Create empty arrays
subject_col = {};
condition_col = {};
value_col = [];

nsubj = length(subj_list);

for isubj = 1:nsubj
    subj = subj_list(isubj);
    subj_str = ['s' num2str(subj)];

    foot_val = data_trl_avgTime.(subj_str).foot.avg(2);
    nofoot_val = data_trl_avgTime.(subj_str).nofoot.avg(2);

    subject_col{end+1,1} = subj_str;
    condition_col{end+1,1} = 'foot';
    value_col(end+1,1) = foot_val;

    subject_col{end+1,1} = subj_str;
    condition_col{end+1,1} = 'nofoot';
    value_col(end+1,1) = nofoot_val;
end

T = table(subject_col, condition_col, value_col, ...
    'VariableNames', {'subject', 'condition', 'value'});

writetable(T, 'Z:\Projects\Memory_Boscheron_2023_Motormem_MRI\figures\foot_vs_nofoot_EMG_0_16.csv')



%%

% Initialize empty vectors
right_foot_val = [];
right_nofoot_val = [];

% Loop through subject list and collect avg(2) values
for i = 1:length(subj_list)
    subj_id = subj_list(i);
    subj_field = ['s' num2str(subj_id)];

    % Extract the second channel (right TA) average for foot and nofoot
    right_foot_val(i) = data_trl_avgTime.(subj_field).foot.avg(2);
    right_nofoot_val(i) = data_trl_avgTime.(subj_field).nofoot.avg(2);
end

% Optionally convert to column vectors (useful for some statistical functions)
right_foot_val = right_foot_val(:);
right_nofoot_val = right_nofoot_val(:);

nsubj = length(right_foot_val);
% Compute group means and SEM
mean_foot = mean(right_foot_val);
mean_nofoot = mean(right_nofoot_val);
sem_foot = std(right_foot_val) / sqrt(nsubj);
sem_nofoot = std(right_nofoot_val) / sqrt(nsubj);

% Set color (same as earlier)
col_foot = col_Act.right.cond1;
col_nofoot = col_Act.right.cond2;

figure('Color', [1 1 1], 'Position', [600, 500, 500, 500]); hold on;
x = [1, 2];

% Bars (transparent, no edges)
bar(x(1), mean_foot, 0.6, 'FaceColor', [0.7, 0.7, 0.7], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
bar(x(2), mean_nofoot, 0.6, 'FaceColor', [0.7, 0.7, 0.7], 'FaceAlpha', 0.4, 'EdgeColor', 'none');

% Error bars
errorbar(x(1), mean_foot, sem_foot, 'k', 'LineWidth', 1.2, 'CapSize', 10);
errorbar(x(2), mean_nofoot, sem_nofoot, 'k', 'LineWidth', 1.2, 'CapSize', 10);

% Individual subject lines and points
for i = 1:nsubj
    plot(x, [right_foot_val(i), right_nofoot_val(i)], '-', 'Color', [0.6 0.6 0.6 0.3], 'LineWidth', 0.8);
    scatter(x, [right_foot_val(i), right_nofoot_val(i)], 30, [0.2 0.2 0.2], 'filled', 'MarkerFaceAlpha', 0.2);
end

% Axes and labels
xticks(x); xticklabels({'Foot', 'No Foot'});
ylabel('Mean ongoing activity (AU)');
set(gca, 'FontSize', 14, 'Box', 'off');

% Y-axis padding and tick control
all_vals = [right_foot_val; right_nofoot_val];
buffer = 0.05 * range(all_vals);
%ylim([min(all_vals) - buffer, max(all_vals) + buffer]);
ymax = 0.1;  % maximum of your desired y-axis
ylim([-0.15 ymax]);
yticks(-0.15:0.05:0.1);


% Optional significance marker
[~, p] = ttest(right_foot_val, right_nofoot_val);
if p < 0.05

      y_star = ymax - 0.02;
    line([1 2], [y_star y_star], 'Color', 'k', 'LineWidth', 1.2);
    text(1.5, y_star + 0.005, '**', 'FontSize', 20, 'HorizontalAlignment', 'center');

end


saveas(gcf, 'final_0_16_plot_EMG.tiff');











%% Creation of data matrix for anova laterality*condition

nsubj = length(subj_list);  
data_matrix = zeros(nsubj, 4); 

for i = 1:nsubj
    subj_code = ['s' num2str(subj_list(i))];  % Subject code in data_trl_avgTime
    % Row order: LeftFoot, LeftNoFoot, RightFoot, RightNoFoot
    data_matrix(i, 1) = data_trl_avgTime.(subj_code).foot.avg(1);    % Left Foot
    data_matrix(i, 2) = data_trl_avgTime.(subj_code).nofoot.avg(1);  % Left NoFoot
    data_matrix(i, 3) = data_trl_avgTime.(subj_code).foot.avg(2);    % Right Foot
    data_matrix(i, 4) = data_trl_avgTime.(subj_code).nofoot.avg(2);  % Right NoFoot
end

% Create a vectorized form of the data for rm_anova2
data_vector = reshape(data_matrix, [], 1);  

subj_vector = repmat(subj_list, 4, 1); 
subj_vector = reshape(subj_vector, [], 1); 

% Factors definition
% Factor 1: Laterality (Left, Right)
% Factor 2: Condition (Foot, No Foot)
F1 = repmat([1; 1; 2; 2], nsubj, 1);  % 1 for Left, 2 for Right
F2 = repmat([1; 2; 1; 2], nsubj, 1);  % 1 for Foot, 2 for No Foot

% Factor Names
FACTNAMES = {'Laterality', 'Condition'};

disp(size(data_vector));  % Should show [100x1]
disp(size(subj_vector));  % Should show [100x1]
disp(size(F1));           % Should show [100x1]
disp(size(F2));           % Should show [100x1]


% Run the repeated measures ANOVA
results = rm_anova2(data_vector, subj_vector, F1, F2, FACTNAMES);

% Display results
disp(results);



%% export data_matrix

nsubj = length(subj_list);  
data_matrix = zeros(nsubj, 4); 

for i = 1:nsubj
    subj_code = ['s' num2str(subj_list(i))];  % Subject code in data_trl_avgTime
    % Row order: LeftFoot, LeftNoFoot, RightFoot, RightNoFoot
    data_matrix(i, 1) = data_trl_avgTime.(subj_code).foot.avg(1);    % Left Foot
    data_matrix(i, 2) = data_trl_avgTime.(subj_code).nofoot.avg(1);  % Left No Foot
    data_matrix(i, 3) = data_trl_avgTime.(subj_code).foot.avg(2);    % Right Foot
    data_matrix(i, 4) = data_trl_avgTime.(subj_code).nofoot.avg(2);  % Right No Foot
end

subj_vector = repmat(subj_list, 4, 1); 
subj_vector = reshape(subj_vector, [], 1); 

% Convert data_matrix to a table with appropriate column and row names
column_names = {'LeftFoot', 'LeftNoFoot', 'RightFoot', 'RightNoFoot'};
row_names = arrayfun(@(x) ['Subject' num2str(x)], subj_list, 'UniformOutput', false);
data_table = array2table(data_matrix, 'VariableNames', column_names, 'RowNames', row_names);

% Save the table to a CSV file
writetable(data_table, 'data_matrix_WoI_0_16.csv', 'WriteRowNames', true);

% Provide feedback that the file has been saved
disp('Data matrix has been saved to data_matrix_WoI_0_16.csv');



%% Both sides one plot:

figure('Color', [1 1 1]); hold on;

% Define pastel colors for the bars
pastelRed = [0.9 0.6 0.6];
pastelBlue = [0.6 0.6 0.9];

% Bar plot for left foot (avg(1) for left)
b1 = bar(categorical({'Left Foot'}), gd_avg_WoI.foot.avg(1), 'FaceColor', pastelBlue);
b2 = bar(categorical({'Left No Foot'}), gd_avg_WoI.nofoot.avg(1), 'FaceColor', pastelRed);

% Bar plot for right foot (avg(2) for right)
b3 = bar(categorical({'Right Foot'}), gd_avg_WoI.foot.avg(2), 'FaceColor', col_Act.right.cond1);
b4 = bar(categorical({'Right No Foot'}), gd_avg_WoI.nofoot.avg(2), 'FaceColor', col_Act.right.cond2);

% Plot data for each subject
for isubj = 1:nsubj
    % Get the subject index from the list
    subj = subj_list(isubj);

    % Plot a line connecting all four points
    % Combine data from both left and right conditions into one array
    all_data = [
        data_trl_avgTime.(['s' num2str(subj)]).foot.avg(1), ...
        data_trl_avgTime.(['s' num2str(subj)]).nofoot.avg(1), ...
        data_trl_avgTime.(['s' num2str(subj)]).foot.avg(2), ...
        data_trl_avgTime.(['s' num2str(subj)]).nofoot.avg(2)
    ];

    % Plot the combined data
    plot(1:4, all_data, '.-', 'Color', [0.8 0.8 0.8], 'MarkerSize', 10);
end

% Adjust the x-axis and y-axis limits and ticks
%ylim([0.94 1.02]);
%yticks(0.94:0.01:1.02);
ylabel('Mean ongoing activity');
set(gca,'FontSize',14);




%% with error bars
% Compute the means for left foot and no foot (avg(1))
left_foot_means = gd_avg_WoI.foot.avg(1);
left_nofoot_means = gd_avg_WoI.nofoot.avg(1);

% Collect all individual data points for SEM calculation
% left_foot_data = [data_trl_avgTime.s51.foot.avg(1), data_trl_avgTime.s52.foot.avg(1), data_trl_avgTime.s53.foot.avg(1), data_trl_avgTime.s55.foot.avg(1), data_trl_avgTime.s56.foot.avg(1), data_trl_avgTime.s57.foot.avg(1), data_trl_avgTime.s60.foot.avg(1), data_trl_avgTime.s61.foot.avg(1), data_trl_avgTime.s62.foot.avg(1), data_trl_avgTime.s63.foot.avg(1), data_trl_avgTime.s65.foot.avg(1), data_trl_avgTime.s66.foot.avg(1), data_trl_avgTime.s67.foot.avg(1), data_trl_avgTime.s68.foot.avg(1), data_trl_avgTime.s69.foot.avg(1), data_trl_avgTime.s70.foot.avg(1), data_trl_avgTime.s71.foot.avg(1), data_trl_avgTime.s72.foot.avg(1), data_trl_avgTime.s73.foot.avg(1), data_trl_avgTime.s74.foot.avg(1), data_trl_avgTime.s76.foot.avg(1), data_trl_avgTime.s77.foot.avg(1), data_trl_avgTime.s78.foot.avg(1), data_trl_avgTime.s80.foot.avg(1)];
% left_nofoot_data = [data_trl_avgTime.s51.nofoot.avg(1), data_trl_avgTime.s52.nofoot.avg(1), data_trl_avgTime.s53.nofoot.avg(1), data_trl_avgTime.s55.nofoot.avg(1), data_trl_avgTime.s56.nofoot.avg(1), data_trl_avgTime.s57.nofoot.avg(1), data_trl_avgTime.s60.nofoot.avg(1), data_trl_avgTime.s61.nofoot.avg(1), data_trl_avgTime.s62.nofoot.avg(1), data_trl_avgTime.s63.nofoot.avg(1), data_trl_avgTime.s65.nofoot.avg(1), data_trl_avgTime.s66.nofoot.avg(1), data_trl_avgTime.s67.nofoot.avg(1), data_trl_avgTime.s68.nofoot.avg(1), data_trl_avgTime.s69.nofoot.avg(1), data_trl_avgTime.s70.nofoot.avg(1), data_trl_avgTime.s71.nofoot.avg(1), data_trl_avgTime.s72.nofoot.avg(1), data_trl_avgTime.s73.nofoot.avg(1), data_trl_avgTime.s74.nofoot.avg(1), data_trl_avgTime.s76.nofoot.avg(1), data_trl_avgTime.s77.nofoot.avg(1), data_trl_avgTime.s78.nofoot.avg(1), data_trl_avgTime.s80.nofoot.avg(1)];
left_foot_data = [data_trl_avgTime.s51.foot.avg(1), data_trl_avgTime.s52.foot.avg(1), data_trl_avgTime.s53.foot.avg(1), data_trl_avgTime.s55.foot.avg(1), data_trl_avgTime.s56.foot.avg(1), data_trl_avgTime.s57.foot.avg(1), data_trl_avgTime.s60.foot.avg(1), data_trl_avgTime.s61.foot.avg(1), data_trl_avgTime.s62.foot.avg(1), data_trl_avgTime.s63.foot.avg(1), data_trl_avgTime.s65.foot.avg(1), data_trl_avgTime.s66.foot.avg(1), data_trl_avgTime.s67.foot.avg(1), data_trl_avgTime.s68.foot.avg(1), data_trl_avgTime.s69.foot.avg(1), data_trl_avgTime.s70.foot.avg(1), data_trl_avgTime.s71.foot.avg(1), data_trl_avgTime.s72.foot.avg(1), data_trl_avgTime.s74.foot.avg(1), data_trl_avgTime.s76.foot.avg(1), data_trl_avgTime.s77.foot.avg(1), data_trl_avgTime.s78.foot.avg(1), data_trl_avgTime.s80.foot.avg(1)];
left_nofoot_data = [data_trl_avgTime.s51.nofoot.avg(1), data_trl_avgTime.s52.nofoot.avg(1), data_trl_avgTime.s53.nofoot.avg(1), data_trl_avgTime.s55.nofoot.avg(1), data_trl_avgTime.s56.nofoot.avg(1), data_trl_avgTime.s57.nofoot.avg(1), data_trl_avgTime.s60.nofoot.avg(1), data_trl_avgTime.s61.nofoot.avg(1), data_trl_avgTime.s62.nofoot.avg(1), data_trl_avgTime.s63.nofoot.avg(1), data_trl_avgTime.s65.nofoot.avg(1), data_trl_avgTime.s66.nofoot.avg(1), data_trl_avgTime.s67.nofoot.avg(1), data_trl_avgTime.s68.nofoot.avg(1), data_trl_avgTime.s69.nofoot.avg(1), data_trl_avgTime.s70.nofoot.avg(1), data_trl_avgTime.s71.nofoot.avg(1), data_trl_avgTime.s72.nofoot.avg(1), data_trl_avgTime.s74.nofoot.avg(1), data_trl_avgTime.s76.nofoot.avg(1), data_trl_avgTime.s77.nofoot.avg(1), data_trl_avgTime.s78.nofoot.avg(1), data_trl_avgTime.s80.nofoot.avg(1)];

% Calculate SEM for left foot and no foot
left_foot_sem = std(left_foot_data) / sqrt(length(left_foot_data));
left_nofoot_sem = std(left_nofoot_data) / sqrt(length(left_nofoot_data));

% Compute the means for right foot and no foot (avg(2))
right_foot_means = gd_avg_WoI.foot.avg(2);
right_nofoot_means = gd_avg_WoI.nofoot.avg(2);

% Collect all individual data points for SEM calculation
% right_foot_data = [data_trl_avgTime.s51.foot.avg(2), data_trl_avgTime.s52.foot.avg(2), data_trl_avgTime.s53.foot.avg(2), data_trl_avgTime.s55.foot.avg(2), data_trl_avgTime.s56.foot.avg(2), data_trl_avgTime.s57.foot.avg(2), data_trl_avgTime.s60.foot.avg(2), data_trl_avgTime.s61.foot.avg(2), data_trl_avgTime.s62.foot.avg(2), data_trl_avgTime.s63.foot.avg(2), data_trl_avgTime.s65.foot.avg(2), data_trl_avgTime.s66.foot.avg(2), data_trl_avgTime.s67.foot.avg(2), data_trl_avgTime.s68.foot.avg(2), data_trl_avgTime.s69.foot.avg(2), data_trl_avgTime.s70.foot.avg(2), data_trl_avgTime.s71.foot.avg(2), data_trl_avgTime.s72.foot.avg(2), data_trl_avgTime.s73.foot.avg(2), data_trl_avgTime.s74.foot.avg(2), data_trl_avgTime.s76.foot.avg(2), data_trl_avgTime.s77.foot.avg(2), data_trl_avgTime.s78.foot.avg(2), data_trl_avgTime.s80.foot.avg(2)];
% right_nofoot_data = [data_trl_avgTime.s51.nofoot.avg(2), data_trl_avgTime.s52.nofoot.avg(2), data_trl_avgTime.s53.nofoot.avg(2), data_trl_avgTime.s55.nofoot.avg(2), data_trl_avgTime.s56.nofoot.avg(2), data_trl_avgTime.s57.nofoot.avg(2), data_trl_avgTime.s60.nofoot.avg(2), data_trl_avgTime.s61.nofoot.avg(2), data_trl_avgTime.s62.nofoot.avg(2), data_trl_avgTime.s63.nofoot.avg(2), data_trl_avgTime.s65.nofoot.avg(2), data_trl_avgTime.s66.nofoot.avg(2), data_trl_avgTime.s67.nofoot.avg(2), data_trl_avgTime.s68.nofoot.avg(2), data_trl_avgTime.s69.nofoot.avg(2), data_trl_avgTime.s70.nofoot.avg(2), data_trl_avgTime.s71.nofoot.avg(2), data_trl_avgTime.s72.nofoot.avg(2), data_trl_avgTime.s73.nofoot.avg(2), data_trl_avgTime.s74.nofoot.avg(2), data_trl_avgTime.s76.nofoot.avg(2), data_trl_avgTime.s77.nofoot.avg(2), data_trl_avgTime.s78.nofoot.avg(2), data_trl_avgTime.s80.nofoot.avg(2)];
right_foot_data = [data_trl_avgTime.s51.foot.avg(2), data_trl_avgTime.s52.foot.avg(2), data_trl_avgTime.s53.foot.avg(2), data_trl_avgTime.s55.foot.avg(2), data_trl_avgTime.s56.foot.avg(2), data_trl_avgTime.s57.foot.avg(2), data_trl_avgTime.s60.foot.avg(2), data_trl_avgTime.s61.foot.avg(2), data_trl_avgTime.s62.foot.avg(2), data_trl_avgTime.s63.foot.avg(2), data_trl_avgTime.s65.foot.avg(2), data_trl_avgTime.s66.foot.avg(2), data_trl_avgTime.s67.foot.avg(2), data_trl_avgTime.s68.foot.avg(2), data_trl_avgTime.s69.foot.avg(2), data_trl_avgTime.s70.foot.avg(2), data_trl_avgTime.s71.foot.avg(2), data_trl_avgTime.s72.foot.avg(2), data_trl_avgTime.s74.foot.avg(2), data_trl_avgTime.s76.foot.avg(2), data_trl_avgTime.s77.foot.avg(2), data_trl_avgTime.s78.foot.avg(2), data_trl_avgTime.s80.foot.avg(2)];
right_nofoot_data = [data_trl_avgTime.s51.nofoot.avg(2), data_trl_avgTime.s52.nofoot.avg(2), data_trl_avgTime.s53.nofoot.avg(2), data_trl_avgTime.s55.nofoot.avg(2), data_trl_avgTime.s56.nofoot.avg(2), data_trl_avgTime.s57.nofoot.avg(2), data_trl_avgTime.s60.nofoot.avg(2), data_trl_avgTime.s61.nofoot.avg(2), data_trl_avgTime.s62.nofoot.avg(2), data_trl_avgTime.s63.nofoot.avg(2), data_trl_avgTime.s65.nofoot.avg(2), data_trl_avgTime.s66.nofoot.avg(2), data_trl_avgTime.s67.nofoot.avg(2), data_trl_avgTime.s68.nofoot.avg(2), data_trl_avgTime.s69.nofoot.avg(2), data_trl_avgTime.s70.nofoot.avg(2), data_trl_avgTime.s71.nofoot.avg(2), data_trl_avgTime.s72.nofoot.avg(2), data_trl_avgTime.s74.nofoot.avg(2), data_trl_avgTime.s76.nofoot.avg(2), data_trl_avgTime.s77.nofoot.avg(2), data_trl_avgTime.s78.nofoot.avg(2), data_trl_avgTime.s80.nofoot.avg(2)];

% Calculate SEM for right foot and no foot
right_foot_sem = std(right_foot_data) / sqrt(length(right_foot_data));
right_nofoot_sem = std(right_nofoot_data) / sqrt(length(right_nofoot_data));

% Plotting the bars and error bars for both left and right foot and no foot
figure('Color', [1 1 1]); hold on;

% Define pastel colors for the bars
pastelRed = [0.9 0.6 0.6];
pastelBlue = [0.6 0.6 0.9];

% Bar plot for left foot and no foot
bar(categorical({'Left TA Foot Condition'}), left_foot_means, 'FaceColor', pastelBlue);
bar(categorical({'Left TA No Foot Condition'}), left_nofoot_means, 'FaceColor', pastelRed);

% Bar plot for right foot and no foot
bar(categorical({'Right TA Foot Condition'}), right_foot_means, 'FaceColor', col_Act.right.cond1);
bar(categorical({'Right TA No Foot Condition'}), right_nofoot_means, 'FaceColor', col_Act.right.cond2);

% Adding error bars for left foot and no foot
errorbar(categorical({'Left TA Foot Condition'}), left_foot_means, left_foot_sem, 'k', 'linestyle', 'none');
errorbar(categorical({'Left TA No Foot Condition'}), left_nofoot_means, left_nofoot_sem, 'k', 'linestyle', 'none');

% Adding error bars for right foot and no foot
errorbar(categorical({'Right TA Foot Condition'}), right_foot_means, right_foot_sem, 'k', 'linestyle', 'none');
errorbar(categorical({'Right TA No Foot Condition'}), right_nofoot_means, right_nofoot_sem, 'k', 'linestyle', 'none');

% Adjust the x-axis and y-axis limits and ticks
% ylim([0.985 1.005]);
% yticks(0.985:0.005:1.005);
ylabel('Mean ongoing activity');
set(gca, 'FontSize', 17);

hold off;



%% T-test 
% ttest_datafoot = [data_trl_avgTime.s51.foot.avg(1), data_trl_avgTime.s52.foot.avg(1), data_trl_avgTime.s53.foot.avg(1), data_trl_avgTime.s55.foot.avg(1), data_trl_avgTime.s56.foot.avg(1), data_trl_avgTime.s57.foot.avg(1), data_trl_avgTime.s60.foot.avg(1), data_trl_avgTime.s61.foot.avg(1), data_trl_avgTime.s62.foot.avg(1), data_trl_avgTime.s63.foot.avg(1), data_trl_avgTime.s65.foot.avg(1), data_trl_avgTime.s66.foot.avg(1), data_trl_avgTime.s67.foot.avg(1), data_trl_avgTime.s68.foot.avg(1), data_trl_avgTime.s69.foot.avg(1), data_trl_avgTime.s70.foot.avg(1), data_trl_avgTime.s71.foot.avg(1), data_trl_avgTime.s72.foot.avg(1), data_trl_avgTime.s73.foot.avg(1), data_trl_avgTime.s74.foot.avg(1), data_trl_avgTime.s76.foot.avg(1), data_trl_avgTime.s77.foot.avg(1), data_trl_avgTime.s78.foot.avg(1), data_trl_avgTime.s80.foot.avg(1)];
% ttest_datanofoot = [data_trl_avgTime.s51.nofoot.avg(1), data_trl_avgTime.s52.nofoot.avg(1), data_trl_avgTime.s53.nofoot.avg(1), data_trl_avgTime.s55.nofoot.avg(1), data_trl_avgTime.s56.nofoot.avg(1), data_trl_avgTime.s57.nofoot.avg(1), data_trl_avgTime.s60.nofoot.avg(1), data_trl_avgTime.s61.nofoot.avg(1), data_trl_avgTime.s62.nofoot.avg(1), data_trl_avgTime.s63.nofoot.avg(1), data_trl_avgTime.s65.nofoot.avg(1), data_trl_avgTime.s66.nofoot.avg(1), data_trl_avgTime.s67.nofoot.avg(1), data_trl_avgTime.s68.nofoot.avg(1), data_trl_avgTime.s69.nofoot.avg(1), data_trl_avgTime.s70.nofoot.avg(1), data_trl_avgTime.s71.nofoot.avg(1), data_trl_avgTime.s72.nofoot.avg(1), data_trl_avgTime.s73.nofoot.avg(1), data_trl_avgTime.s74.nofoot.avg(1), data_trl_avgTime.s76.nofoot.avg(1), data_trl_avgTime.s77.nofoot.avg(1), data_trl_avgTime.s78.nofoot.avg(1), data_trl_avgTime.s80.nofoot.avg(1)];


% ttest_datafoot = [data_trl_avgTime.s51.foot.avg(2), data_trl_avgTime.s52.foot.avg(2), data_trl_avgTime.s53.foot.avg(2), data_trl_avgTime.s55.foot.avg(2), data_trl_avgTime.s56.foot.avg(2), data_trl_avgTime.s57.foot.avg(2), data_trl_avgTime.s60.foot.avg(2), data_trl_avgTime.s61.foot.avg(2), data_trl_avgTime.s62.foot.avg(2), data_trl_avgTime.s63.foot.avg(2), data_trl_avgTime.s65.foot.avg(2), data_trl_avgTime.s66.foot.avg(2), data_trl_avgTime.s67.foot.avg(2), data_trl_avgTime.s68.foot.avg(2), data_trl_avgTime.s69.foot.avg(2), data_trl_avgTime.s70.foot.avg(2), data_trl_avgTime.s71.foot.avg(2), data_trl_avgTime.s72.foot.avg(2), data_trl_avgTime.s73.foot.avg(2), data_trl_avgTime.s74.foot.avg(2), data_trl_avgTime.s76.foot.avg(2), data_trl_avgTime.s77.foot.avg(2), data_trl_avgTime.s78.foot.avg(2), data_trl_avgTime.s80.foot.avg(2)];
% ttest_datanofoot = [data_trl_avgTime.s51.nofoot.avg(2), data_trl_avgTime.s52.nofoot.avg(2), data_trl_avgTime.s53.nofoot.avg(2), data_trl_avgTime.s55.nofoot.avg(2), data_trl_avgTime.s56.nofoot.avg(2), data_trl_avgTime.s57.nofoot.avg(2), data_trl_avgTime.s60.nofoot.avg(2), data_trl_avgTime.s61.nofoot.avg(2), data_trl_avgTime.s62.nofoot.avg(2), data_trl_avgTime.s63.nofoot.avg(2), data_trl_avgTime.s65.nofoot.avg(2), data_trl_avgTime.s66.nofoot.avg(2), data_trl_avgTime.s67.nofoot.avg(2), data_trl_avgTime.s68.nofoot.avg(2), data_trl_avgTime.s69.nofoot.avg(2), data_trl_avgTime.s70.nofoot.avg(2), data_trl_avgTime.s71.nofoot.avg(2), data_trl_avgTime.s72.nofoot.avg(2), data_trl_avgTime.s73.nofoot.avg(2), data_trl_avgTime.s74.nofoot.avg(2), data_trl_avgTime.s76.nofoot.avg(2), data_trl_avgTime.s77.nofoot.avg(2), data_trl_avgTime.s78.nofoot.avg(2), data_trl_avgTime.s80.nofoot.avg(2)];

ttest_datafoot = [data_trl_avgTime.s51.foot.avg(1), data_trl_avgTime.s52.foot.avg(1), data_trl_avgTime.s53.foot.avg(1), data_trl_avgTime.s55.foot.avg(1), data_trl_avgTime.s56.foot.avg(1), data_trl_avgTime.s57.foot.avg(1), data_trl_avgTime.s60.foot.avg(1), data_trl_avgTime.s61.foot.avg(1), data_trl_avgTime.s62.foot.avg(1), data_trl_avgTime.s63.foot.avg(1), data_trl_avgTime.s65.foot.avg(1), data_trl_avgTime.s66.foot.avg(1), data_trl_avgTime.s67.foot.avg(1), data_trl_avgTime.s68.foot.avg(1), data_trl_avgTime.s69.foot.avg(1), data_trl_avgTime.s70.foot.avg(1), data_trl_avgTime.s71.foot.avg(1), data_trl_avgTime.s72.foot.avg(1),  data_trl_avgTime.s74.foot.avg(1), data_trl_avgTime.s76.foot.avg(1), data_trl_avgTime.s77.foot.avg(1), data_trl_avgTime.s78.foot.avg(1), data_trl_avgTime.s80.foot.avg(1)];
ttest_datanofoot = [data_trl_avgTime.s51.nofoot.avg(1), data_trl_avgTime.s52.nofoot.avg(1), data_trl_avgTime.s53.nofoot.avg(1), data_trl_avgTime.s55.nofoot.avg(1), data_trl_avgTime.s56.nofoot.avg(1), data_trl_avgTime.s57.nofoot.avg(1), data_trl_avgTime.s60.nofoot.avg(1), data_trl_avgTime.s61.nofoot.avg(1), data_trl_avgTime.s62.nofoot.avg(1), data_trl_avgTime.s63.nofoot.avg(1), data_trl_avgTime.s65.nofoot.avg(1), data_trl_avgTime.s66.nofoot.avg(1), data_trl_avgTime.s67.nofoot.avg(1), data_trl_avgTime.s68.nofoot.avg(1), data_trl_avgTime.s69.nofoot.avg(1), data_trl_avgTime.s70.nofoot.avg(1), data_trl_avgTime.s71.nofoot.avg(1), data_trl_avgTime.s72.nofoot.avg(1),  data_trl_avgTime.s74.nofoot.avg(1), data_trl_avgTime.s76.nofoot.avg(1), data_trl_avgTime.s77.nofoot.avg(1), data_trl_avgTime.s78.nofoot.avg(1), data_trl_avgTime.s80.nofoot.avg(1)];

% 
ttest_datafoot = [data_trl_avgTime.s51.foot.avg(2), data_trl_avgTime.s52.foot.avg(2), data_trl_avgTime.s53.foot.avg(2), data_trl_avgTime.s55.foot.avg(2), data_trl_avgTime.s56.foot.avg(2), data_trl_avgTime.s57.foot.avg(2), data_trl_avgTime.s60.foot.avg(2), data_trl_avgTime.s61.foot.avg(2), data_trl_avgTime.s62.foot.avg(2), data_trl_avgTime.s63.foot.avg(2), data_trl_avgTime.s65.foot.avg(2), data_trl_avgTime.s66.foot.avg(2), data_trl_avgTime.s67.foot.avg(2), data_trl_avgTime.s68.foot.avg(2), data_trl_avgTime.s69.foot.avg(2), data_trl_avgTime.s70.foot.avg(2), data_trl_avgTime.s71.foot.avg(2), data_trl_avgTime.s72.foot.avg(2), data_trl_avgTime.s74.foot.avg(2), data_trl_avgTime.s76.foot.avg(2), data_trl_avgTime.s77.foot.avg(2), data_trl_avgTime.s78.foot.avg(2), data_trl_avgTime.s80.foot.avg(2)];
ttest_datanofoot = [data_trl_avgTime.s51.nofoot.avg(2), data_trl_avgTime.s52.nofoot.avg(2), data_trl_avgTime.s53.nofoot.avg(2), data_trl_avgTime.s55.nofoot.avg(2), data_trl_avgTime.s56.nofoot.avg(2), data_trl_avgTime.s57.nofoot.avg(2), data_trl_avgTime.s60.nofoot.avg(2), data_trl_avgTime.s61.nofoot.avg(2), data_trl_avgTime.s62.nofoot.avg(2), data_trl_avgTime.s63.nofoot.avg(2), data_trl_avgTime.s65.nofoot.avg(2), data_trl_avgTime.s66.nofoot.avg(2), data_trl_avgTime.s67.nofoot.avg(2), data_trl_avgTime.s68.nofoot.avg(2), data_trl_avgTime.s69.nofoot.avg(2), data_trl_avgTime.s70.nofoot.avg(2), data_trl_avgTime.s71.nofoot.avg(2), data_trl_avgTime.s72.nofoot.avg(2), data_trl_avgTime.s74.nofoot.avg(2), data_trl_avgTime.s76.nofoot.avg(2), data_trl_avgTime.s77.nofoot.avg(2), data_trl_avgTime.s78.nofoot.avg(2), data_trl_avgTime.s80.nofoot.avg(2)];

% Define the window of interest and leg for this t-test
windowOfInterest = '8-16s';  
leg = 'Right';  

% Perform the t-test
[h, p, ci, stats] = ttest(ttest_datafoot, ttest_datanofoot);

% Extract the t-value and degrees of freedom
t_value = stats.tstat;
df = stats.df;

% Prepare the data to write
results = [df, t_value, p];

% Define the file path (adjust the path as necessary)
filename = 'ttest_results_EMG_nos73.csv';

% Check if the file exists to add the header if it's new
if ~isfile(filename)
    fileID = fopen(filename, 'w');  % Create new file and open for writing
    fprintf(fileID, 'Degrees of Freedom,T-Value,P-Value,Window of Interest,Leg\n');  % Print header
else
    fileID = fopen(filename, 'a');  % Open existing file for appending
end

% Write the results to the file, including new columns
fprintf(fileID, '%d,%.4f,%.4f,%s,%s\n', df, t_value, p, windowOfInterest, leg);

% Close the file
fclose(fileID);

% Optionally display the results
fprintf('T-value: %.4f\n', t_value);
fprintf('Degrees of Freedom: %d\n', df);
fprintf('P-value: %.4f\n', p);
fprintf('Window of Interest: %s\n', windowOfInterest);
fprintf('Leg: %s\n', leg);




% % Plot average time course, 4 SDT conditions
% figure('Color', [1 1 1]); hold on;
% for icond = 1:nconds
%     cfg = [];
%     gd_avg.(['cond' num2str(icond)]) = ft_timelockgrandaverage(cfg, data_trl.s2.(['cond' num2str(icond)]), data_trl.s3.(['cond' num2str(icond)]), data_trl.s5.(['cond' num2str(icond)]), data_trl.s6.(['cond' num2str(icond)]), data_trl.s7.(['cond' num2str(icond)]), data_trl.s8.(['cond' num2str(icond)]), data_trl.s9.(['cond' num2str(icond)]), data_trl.s10.(['cond' num2str(icond)]), data_trl.s11.(['cond' num2str(icond)]));
%     cfg = [];
%     cfg.lpfilter = 'yes';
%     cfg.lpfreq = 2;
%     gd_avg.(['cond' num2str(icond)]) = ft_preprocessing(cfg, gd_avg.(['cond' num2str(icond)]));
%     plot(gd_avg.(['cond' num2str(icond)]).time, gd_avg.(['cond' num2str(icond)]).avg(1,:), 'col', col_Act.right.(['cond' num2str(icond)]), 'LineWidth', 2);
% end
% xlim([min(gd_avg.cond1.time) max(gd_avg.cond1.time)]);
% legend('No foot, report no foot', 'Foot, report no foot', 'No foot, report foot', 'Foot, report foot', 'FontSize', 14);
% set(gca,'FontSize',14);
% ylabel('Ongoing activity (microV)');
% xlabel('Time (s)')


a=0;


%% Exploratory & alternative analyses 

%% Trend lines

cfg = [];
% gd_avg.foot = ft_timelockgrandaverage(cfg, data_trl.s51.foot, data_trl.s52.foot, data_trl.s53.foot, data_trl.s54.foot, data_trl.s55.foot, data_trl.s56.foot, data_trl.s57.foot, data_trl.s60.foot, data_trl.s61.foot, data_trl.s62.foot, data_trl.s63.foot, data_trl.s64.foot, data_trl.s65.foot, data_trl.s66.foot, data_trl.s67.foot, data_trl.s68.foot, data_trl.s69.foot, data_trl.s70.foot, data_trl.s71.foot, data_trl.s72.foot, data_trl.s73.foot, data_trl.s74.foot, data_trl.s76.foot, data_trl.s77.foot, data_trl.s78.foot, data_trl.s80.foot);
% gd_avg.nofoot = ft_timelockgrandaverage(cfg, data_trl.s51.nofoot, data_trl.s52.nofoot, data_trl.s53.nofoot, data_trl.s54.nofoot, data_trl.s55.nofoot, data_trl.s56.nofoot, data_trl.s57.nofoot, data_trl.s60.nofoot, data_trl.s61.nofoot, data_trl.s62.nofoot, data_trl.s63.nofoot, data_trl.s64.nofoot, data_trl.s65.nofoot, data_trl.s66.nofoot, data_trl.s67.nofoot, data_trl.s68.nofoot, data_trl.s69.nofoot, data_trl.s70.nofoot, data_trl.s71.nofoot, data_trl.s72.nofoot, data_trl.s73.nofoot, data_trl.s74.nofoot, data_trl.s76.nofoot, data_trl.s77.nofoot, data_trl.s78.nofoot, data_trl.s80.nofoot);
gd_avg.foot = ft_timelockgrandaverage(cfg, data_trl.s51.foot, data_trl.s52.foot, data_trl.s53.foot, data_trl.s54.foot, data_trl.s55.foot, data_trl.s56.foot, data_trl.s57.foot, data_trl.s60.foot, data_trl.s61.foot, data_trl.s62.foot, data_trl.s63.foot, data_trl.s65.foot, data_trl.s66.foot, data_trl.s67.foot, data_trl.s68.foot, data_trl.s69.foot, data_trl.s70.foot, data_trl.s71.foot, data_trl.s72.foot, data_trl.s73.foot, data_trl.s74.foot, data_trl.s76.foot, data_trl.s77.foot, data_trl.s78.foot, data_trl.s80.foot);
gd_avg.nofoot = ft_timelockgrandaverage(cfg, data_trl.s51.nofoot, data_trl.s52.nofoot, data_trl.s53.nofoot, data_trl.s54.nofoot, data_trl.s55.nofoot, data_trl.s56.nofoot, data_trl.s57.nofoot, data_trl.s60.nofoot, data_trl.s61.nofoot, data_trl.s62.nofoot, data_trl.s63.nofoot, data_trl.s65.nofoot, data_trl.s66.nofoot, data_trl.s67.nofoot, data_trl.s68.nofoot, data_trl.s69.nofoot, data_trl.s70.nofoot, data_trl.s71.nofoot, data_trl.s72.nofoot, data_trl.s73.nofoot, data_trl.s74.nofoot, data_trl.s76.nofoot, data_trl.s77.nofoot, data_trl.s78.nofoot, data_trl.s80.nofoot);
cfg = [];
% cfg.lpfilter = 'yes';
% cfg.lpfreq = 2;
data_condFoot = ft_preprocessing(cfg, gd_avg.foot);
data_condNoFoot = ft_preprocessing(cfg, gd_avg.nofoot);


% Calculate the slopes using linear regression for both channels
% Left side (Channel 1)
coeffs_foot_left = polyfit(data_condFoot.time, data_condFoot.avg(1,:), 1);
slope_foot_left = coeffs_foot_left(1);
intercept_foot_left = coeffs_foot_left(2);

coeffs_nofoot_left = polyfit(data_condNoFoot.time, data_condNoFoot.avg(1,:), 1);
slope_nofoot_left = coeffs_nofoot_left(1);
intercept_nofoot_left = coeffs_nofoot_left(2);

% Right side (Channel 2)
coeffs_foot_right = polyfit(data_condFoot.time, data_condFoot.avg(2,:), 1);
slope_foot_right = coeffs_foot_right(1);
intercept_foot_right = coeffs_foot_right(2);

coeffs_nofoot_right = polyfit(data_condNoFoot.time, data_condNoFoot.avg(2,:), 1);
slope_nofoot_right = coeffs_nofoot_right(1);
intercept_nofoot_right = coeffs_nofoot_right(2);

% Generate values for the trend lines
trendLine_foot_left = slope_foot_left * data_condFoot.time + intercept_foot_left;
trendLine_nofoot_left = slope_nofoot_left * data_condNoFoot.time + intercept_nofoot_left;
trendLine_foot_right = slope_foot_right * data_condFoot.time + intercept_foot_right;
trendLine_nofoot_right = slope_nofoot_right * data_condNoFoot.time + intercept_nofoot_right;

% Plot the trend lines with distinct colors and transparency
figure('Color', [1 1 1]); hold on;
plot(data_condFoot.time, trendLine_foot_left, 'Color', [0.9 0.6 0.6, 0.8], 'LineStyle', '-', 'LineWidth', 1.5); % Pastel red for left foot
plot(data_condNoFoot.time, trendLine_nofoot_left, 'Color', [0.6 0.9 0.6, 0.8], 'LineStyle', '-', 'LineWidth', 1.5); % Pastel green for left no foot
plot(data_condFoot.time, trendLine_foot_right, 'Color', [0.6 0.6 0.9, 0.8], 'LineStyle', '-', 'LineWidth', 1.5); % Pastel blue for right foot
plot(data_condNoFoot.time, trendLine_nofoot_right, 'Color', [0.9 0.6 0.9, 0.8], 'LineStyle', '-', 'LineWidth', 1.5); % Pastel magenta for right no foot


% Annotations for slopes
text(14, 1.005, sprintf('Slope (Left Foot): %.4f', slope_foot_left), 'FontSize', 10, 'Color', 'black');
text(14, 1.004, sprintf('Slope (Left No Foot): %.4f', slope_nofoot_left), 'FontSize', 10, 'Color', 'black');
text(14, 1.003, sprintf('Slope (Right Foot): %.4f', slope_foot_right), 'FontSize', 10, 'Color', 'black');
text(14, 1.002, sprintf('Slope (Right No Foot): %.4f', slope_nofoot_right), 'FontSize', 10, 'Color', 'black');

% Set plot parameters
xlim([min(data_condFoot.time) max(data_condFoot.time)]);
ylim([0.99 1.01]);
legend('Left Foot', 'Left No Foot', 'Right Foot', 'Right No Foot', 'FontSize', 14);
set(gca, 'FontSize', 14);
ylabel('Ongoing activity (microV)');
xlabel('Time (s)');

%% all activity + trendlines

cfg = [];
% gd_avg.foot = ft_timelockgrandaverage(cfg, data_trl.s51.foot, data_trl.s52.foot, data_trl.s53.foot, data_trl.s54.foot, data_trl.s55.foot, data_trl.s56.foot, data_trl.s57.foot, data_trl.s60.foot, data_trl.s61.foot, data_trl.s62.foot, data_trl.s63.foot, data_trl.s64.foot, data_trl.s65.foot, data_trl.s66.foot, data_trl.s67.foot, data_trl.s68.foot, data_trl.s69.foot, data_trl.s70.foot, data_trl.s71.foot, data_trl.s72.foot, data_trl.s73.foot, data_trl.s74.foot, data_trl.s76.foot, data_trl.s77.foot, data_trl.s78.foot, data_trl.s80.foot);
% gd_avg.nofoot = ft_timelockgrandaverage(cfg, data_trl.s51.nofoot, data_trl.s52.nofoot, data_trl.s53.nofoot, data_trl.s54.nofoot, data_trl.s55.nofoot, data_trl.s56.nofoot, data_trl.s57.nofoot, data_trl.s60.nofoot, data_trl.s61.nofoot, data_trl.s62.nofoot, data_trl.s63.nofoot, data_trl.s64.nofoot, data_trl.s65.nofoot, data_trl.s66.nofoot, data_trl.s67.nofoot, data_trl.s68.nofoot, data_trl.s69.nofoot, data_trl.s70.nofoot, data_trl.s71.nofoot, data_trl.s72.nofoot, data_trl.s73.nofoot, data_trl.s74.nofoot, data_trl.s76.nofoot, data_trl.s77.nofoot, data_trl.s78.nofoot, data_trl.s80.nofoot);
gd_avg.foot = ft_timelockgrandaverage(cfg, data_trl.s51.foot, data_trl.s52.foot, data_trl.s53.foot, data_trl.s54.foot, data_trl.s55.foot, data_trl.s56.foot, data_trl.s57.foot, data_trl.s60.foot, data_trl.s61.foot, data_trl.s62.foot, data_trl.s63.foot, data_trl.s65.foot, data_trl.s66.foot, data_trl.s67.foot, data_trl.s68.foot, data_trl.s69.foot, data_trl.s70.foot, data_trl.s71.foot, data_trl.s72.foot, data_trl.s73.foot, data_trl.s74.foot, data_trl.s76.foot, data_trl.s77.foot, data_trl.s78.foot, data_trl.s80.foot);
gd_avg.nofoot = ft_timelockgrandaverage(cfg, data_trl.s51.nofoot, data_trl.s52.nofoot, data_trl.s53.nofoot, data_trl.s54.nofoot, data_trl.s55.nofoot, data_trl.s56.nofoot, data_trl.s57.nofoot, data_trl.s60.nofoot, data_trl.s61.nofoot, data_trl.s62.nofoot, data_trl.s63.nofoot, data_trl.s65.nofoot, data_trl.s66.nofoot, data_trl.s67.nofoot, data_trl.s68.nofoot, data_trl.s69.nofoot, data_trl.s70.nofoot, data_trl.s71.nofoot, data_trl.s72.nofoot, data_trl.s73.nofoot, data_trl.s74.nofoot, data_trl.s76.nofoot, data_trl.s77.nofoot, data_trl.s78.nofoot, data_trl.s80.nofoot);
cfg = [];
% cfg.lpfilter = 'yes';
% cfg.lpfreq = 2;
data_condFoot = ft_preprocessing(cfg, gd_avg.foot);
data_condNoFoot = ft_preprocessing(cfg, gd_avg.nofoot);

% Calculate the slopes using linear regression for both channels
% Left side (Channel 1)
coeffs_foot_left = polyfit(data_condFoot.time, data_condFoot.avg(1,:), 1);
slope_foot_left = coeffs_foot_left(1);
intercept_foot_left = coeffs_foot_left(2);

coeffs_nofoot_left = polyfit(data_condNoFoot.time, data_condNoFoot.avg(1,:), 1);
slope_nofoot_left = coeffs_nofoot_left(1);
intercept_nofoot_left = coeffs_nofoot_left(2);

% Right side (Channel 2)
coeffs_foot_right = polyfit(data_condFoot.time, data_condFoot.avg(2,:), 1);
slope_foot_right = coeffs_foot_right(1);
intercept_foot_right = coeffs_foot_right(2);

coeffs_nofoot_right = polyfit(data_condNoFoot.time, data_condNoFoot.avg(2,:), 1);
slope_nofoot_right = coeffs_nofoot_right(1);
intercept_nofoot_right = coeffs_nofoot_right(2);

% Generate values for the trend lines
trendLine_foot_left = slope_foot_left * data_condFoot.time + intercept_foot_left;
trendLine_nofoot_left = slope_nofoot_left * data_condNoFoot.time + intercept_nofoot_left;
trendLine_foot_right = slope_foot_right * data_condFoot.time + intercept_foot_right;
trendLine_nofoot_right = slope_nofoot_right * data_condNoFoot.time + intercept_nofoot_right;

% Plot the trend lines with distinct colors and transparency
figure('Color', [1 1 1]); hold on;
plot(data_condFoot.time, data_condFoot.avg(1,:), 'col', col_Act.right.cond1, 'LineWidth', 2);
plot(data_condNoFoot.time, data_condNoFoot.avg(1,:), 'col', col_Act.right.cond2, 'LineWidth', 2);
plot(data_condFoot.time, trendLine_foot_left, 'Color', [1 0 0, 0.7], 'LineStyle', '-', 'LineWidth', 1); % Red for left foot
plot(data_condNoFoot.time, trendLine_nofoot_left, 'Color', [0 1 0, 0.7], 'LineStyle', '-', 'LineWidth', 1); % Green for left no foot
plot(data_condFoot.time, data_condFoot.avg(2,:), 'col', col_Act.right.cond3, 'LineWidth', 2);
plot(data_condNoFoot.time, data_condNoFoot.avg(2,:), 'col', col_Act.right.cond4, 'LineWidth', 2);
plot(data_condFoot.time, trendLine_foot_right, 'Color', [0 0 1, 0.7], 'LineStyle', '-', 'LineWidth', 1); % Blue for right foot
plot(data_condNoFoot.time, trendLine_nofoot_right, 'Color', [1 0 1, 0.7], 'LineStyle', '-', 'LineWidth', 1); % Magenta for right no foot

% Annotations for slopes
% text(max(data_condFoot.time)*0.8, 1.025, sprintf('Slope (Left Foot): %.4f', slope_foot_left), 'FontSize', 12, 'Color', 'red');
% text(max(data_condNoFoot.time)*0.8, 1.02, sprintf('Slope (Left No Foot): %.4f', slope_nofoot_left), 'FontSize', 12, 'Color', 'green');
% text(max(data_condFoot.time)*0.8, 1.015, sprintf('Slope (Right Foot): %.4f', slope_foot_right), 'FontSize', 12, 'Color', 'blue');
% text(max(data_condNoFoot.time)*0.8, 1.01, sprintf('Slope (Right No Foot): %.4f', slope_nofoot_right), 'FontSize', 12, 'Color', 'magenta');

% Set plot parameters
xlim([min(gd_avg.foot.time) max(gd_avg.foot.time)]);
ylim([0.97 1.03]);
legend('Left Foot', 'Left No Foot', 'Right Foot', 'Right No Foot', 'Left Foot Trend', 'Left No Foot Trend', 'Right Foot Trend', 'Right No Foot Trend', 'FontSize', 14);
set(gca, 'FontSize', 14);
ylabel('Ongoing activity (microV)');
xlabel('Time (s)');





