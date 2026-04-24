%% What does this do?
% Analyze_OngoingAct performs all analyses on the subthreshold, ongoing EMG activity
% over the window of time of interest and computes a t-test for foot and no foot trials. 

function Analyze_OngoingAct(cfg_input)

GeneralVariables;
exp_session = cfg_input.exp_session;
subj_list = cfg_input.subj_list;
cond = cfg_input.cond;

% Time window of interest
t_WoI = [0 16];  % Free reliving period
%t_WoI = [0 8];  % Free reliving period, 1st half
%t_WoI = [8 16];  % Free reliving period, 2nd half

col_Act.left.cond1 = [0.6 0.6 0.9]; % Left foot: pastel blue, foot condition
col_Act.left.cond2 = [0.9 0.6 0.6];    % Left foot: pastel red, no foot condition
col_Act.right.cond1 = [0 80 239]/255;  % Right foot: dark blue, foot condition
col_Act.right.cond2 = [162 0 37]/255;  % Right foot: red, no foot condition



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
    end

    % Load ongoing activity data
    load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_OngoingAct_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat']);

    % Load behavior data
    load(['../Data_/DataProcessed_/s' num2str(subj) '/databehav_trialcond.mat']);
    nconds = 2;

    % Proceed for each condition
    for icond = 1:nconds

        % Average over trials (nanmean)
        cfg = [];
        cfg.nanmean = 'yes';
        data_trl.(['s' num2str(subj)]).(['cond' num2str(icond)]) = ft_timelockanalysis(cfg, data_OngoingAct.([cond '_' num2str(icond)]));
        
        footTrials = data_OngoingAct.trial_cond_1;
        nofootTrials = data_OngoingAct.trial_cond_2;

        cfg = [];
        cfg.nanmean = 'yes';
        data_trl.(['s' num2str(subj)]).foot = ft_timelockanalysis(cfg, footTrials);
        data_trl.(['s' num2str(subj)]).nofoot = ft_timelockanalysis(cfg, nofootTrials);

        % Average over time window of interest
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


%% T-test 


% Define the window of interest and leg for this t-test
windowOfInterest = '8-16s';  

leg = 'Right';  
ttest_datafoot = [data_trl_avgTime.s51.foot.avg(2), data_trl_avgTime.s52.foot.avg(2), data_trl_avgTime.s53.foot.avg(2), data_trl_avgTime.s55.foot.avg(2), data_trl_avgTime.s56.foot.avg(2), data_trl_avgTime.s57.foot.avg(2), data_trl_avgTime.s60.foot.avg(2), data_trl_avgTime.s61.foot.avg(2), data_trl_avgTime.s62.foot.avg(2), data_trl_avgTime.s63.foot.avg(2), data_trl_avgTime.s65.foot.avg(2), data_trl_avgTime.s66.foot.avg(2), data_trl_avgTime.s67.foot.avg(2), data_trl_avgTime.s68.foot.avg(2), data_trl_avgTime.s69.foot.avg(2), data_trl_avgTime.s70.foot.avg(2), data_trl_avgTime.s71.foot.avg(2), data_trl_avgTime.s72.foot.avg(2), data_trl_avgTime.s74.foot.avg(2), data_trl_avgTime.s76.foot.avg(2), data_trl_avgTime.s77.foot.avg(2), data_trl_avgTime.s78.foot.avg(2), data_trl_avgTime.s80.foot.avg(2)];
ttest_datanofoot = [data_trl_avgTime.s51.nofoot.avg(2), data_trl_avgTime.s52.nofoot.avg(2), data_trl_avgTime.s53.nofoot.avg(2), data_trl_avgTime.s55.nofoot.avg(2), data_trl_avgTime.s56.nofoot.avg(2), data_trl_avgTime.s57.nofoot.avg(2), data_trl_avgTime.s60.nofoot.avg(2), data_trl_avgTime.s61.nofoot.avg(2), data_trl_avgTime.s62.nofoot.avg(2), data_trl_avgTime.s63.nofoot.avg(2), data_trl_avgTime.s65.nofoot.avg(2), data_trl_avgTime.s66.nofoot.avg(2), data_trl_avgTime.s67.nofoot.avg(2), data_trl_avgTime.s68.nofoot.avg(2), data_trl_avgTime.s69.nofoot.avg(2), data_trl_avgTime.s70.nofoot.avg(2), data_trl_avgTime.s71.nofoot.avg(2), data_trl_avgTime.s72.nofoot.avg(2), data_trl_avgTime.s74.nofoot.avg(2), data_trl_avgTime.s76.nofoot.avg(2), data_trl_avgTime.s77.nofoot.avg(2), data_trl_avgTime.s78.nofoot.avg(2), data_trl_avgTime.s80.nofoot.avg(2)];

% leg = 'Left';  
% ttest_datafoot = [data_trl_avgTime.s51.foot.avg(1), data_trl_avgTime.s52.foot.avg(1), data_trl_avgTime.s53.foot.avg(1), data_trl_avgTime.s55.foot.avg(1), data_trl_avgTime.s56.foot.avg(1), data_trl_avgTime.s57.foot.avg(1), data_trl_avgTime.s60.foot.avg(1), data_trl_avgTime.s61.foot.avg(1), data_trl_avgTime.s62.foot.avg(1), data_trl_avgTime.s63.foot.avg(1), data_trl_avgTime.s65.foot.avg(1), data_trl_avgTime.s66.foot.avg(1), data_trl_avgTime.s67.foot.avg(1), data_trl_avgTime.s68.foot.avg(1), data_trl_avgTime.s69.foot.avg(1), data_trl_avgTime.s70.foot.avg(1), data_trl_avgTime.s71.foot.avg(1), data_trl_avgTime.s72.foot.avg(1),  data_trl_avgTime.s74.foot.avg(1), data_trl_avgTime.s76.foot.avg(1), data_trl_avgTime.s77.foot.avg(1), data_trl_avgTime.s78.foot.avg(1), data_trl_avgTime.s80.foot.avg(1)];
% ttest_datanofoot = [data_trl_avgTime.s51.nofoot.avg(1), data_trl_avgTime.s52.nofoot.avg(1), data_trl_avgTime.s53.nofoot.avg(1), data_trl_avgTime.s55.nofoot.avg(1), data_trl_avgTime.s56.nofoot.avg(1), data_trl_avgTime.s57.nofoot.avg(1), data_trl_avgTime.s60.nofoot.avg(1), data_trl_avgTime.s61.nofoot.avg(1), data_trl_avgTime.s62.nofoot.avg(1), data_trl_avgTime.s63.nofoot.avg(1), data_trl_avgTime.s65.nofoot.avg(1), data_trl_avgTime.s66.nofoot.avg(1), data_trl_avgTime.s67.nofoot.avg(1), data_trl_avgTime.s68.nofoot.avg(1), data_trl_avgTime.s69.nofoot.avg(1), data_trl_avgTime.s70.nofoot.avg(1), data_trl_avgTime.s71.nofoot.avg(1), data_trl_avgTime.s72.nofoot.avg(1),  data_trl_avgTime.s74.nofoot.avg(1), data_trl_avgTime.s76.nofoot.avg(1), data_trl_avgTime.s77.nofoot.avg(1), data_trl_avgTime.s78.nofoot.avg(1), data_trl_avgTime.s80.nofoot.avg(1)];

% Perform the t-test
[h, p, ci, stats] = ttest(ttest_datafoot, ttest_datanofoot);

% Extract the t-value and degrees of freedom
t_value = stats.tstat;
df = stats.df;

% Prepare the data to write
results = [df, t_value, p];

% Define the file path (adjust the path as necessary)
filename = 'ttest_results_EMG.csv';

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

% Display the results
fprintf('T-value: %.4f\n', t_value);
fprintf('Degrees of Freedom: %d\n', df);
fprintf('P-value: %.4f\n', p);
fprintf('Window of Interest: %s\n', windowOfInterest);
fprintf('Leg: %s\n', leg);




