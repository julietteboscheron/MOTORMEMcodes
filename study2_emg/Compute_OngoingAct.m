%% What does this do?
% Compute_OngoingAct does several things. It applies baseline correction to individual trials,
% does trial exclusion using the tagged segments from Preproc_BadSegmDetect, 
% computes the average ongoing activity for individual trials and stores it for R analysis.
function Compute_OngoingAct(cfg_input)

GeneralVariables;
exp_session = cfg_input.exp_session;
subj_list = cfg_input.subj_list;
cond = cfg_input.cond;

% Initialize exclusion information array
num_conditions = 2; % Assuming max of 4 conditions as per your SDT setup
exclusion_info = zeros(length(subj_list), num_conditions);


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

% Time window for the baseline correction and for analysis
if strcmp(cfg_input.epoch_label, 'Reliving')  % Baseline taken on Memory cue period
    t_baseline = [-2 -0.5];  % Memory cue period
    t_WoI_phases = [];
elseif strcmp(cfg_input.epoch_label, 'WholeTrial')  % Baseline taken on Fixation period
    t_baseline = [-9.5 -5.5];    % Fixation cross period
    t_WoI_phases = [-4 0; 0 5; 5 10; 10 15; 0 8; 8 16; 0 16];  % All phases to look at (for mixed models analysis)
end

% Open csv file to store data for R analysis
outp_file = fopen(['../Data_/Group_/dataEMG_ongoing_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.csv'], 'w');
str_header = 'participant\tencod_cond\trecalled_cond\t';
for i_WoI = 1:length(t_WoI_phases)
    i_str_R = ['EMG_' num2str(abs(t_WoI_phases(i_WoI,1))) 'to' num2str(abs(t_WoI_phases(i_WoI,2))) '_R\t'];
    i_str_L = ['EMG_' num2str(abs(t_WoI_phases(i_WoI,1))) 'to' num2str(abs(t_WoI_phases(i_WoI,2))) '_L\t'];
    str_header = [str_header i_str_R i_str_L];
end
str_header = [str_header 'bsl_R\tbsl_L\tq1\tq2\tq3\tq4\tindex_encod\tindex_recall\tword\ttrlNb\n'];
fprintf(outp_file, str_header);

    % - subject number
    % - encoded condition
    % - recalled condition
    % - EMG data, one column for each phase and channel
    % - baseline activity before bsl correction
    % - reliving score
    % - time reliving %%%%%% <-- NOT INCLUDED FOR NOW, ADD LATER!
    % - index encoding
    % - index recall
    % - obstacle name
    % - trial number at recall

%% Loop on subjects
for isubj = 1:length(subj_list)

    subj = subj_list(isubj);

    % Load epoch data
    load(['../Data_/DataProcessed_/s'  num2str(subj) '/dataft_epochs_' str_rectif exp_session '_' cfg_input.epoch_label '.mat']);
    %load(['../Data_/DataProcessed_/s'  num2str(subj) '/dataft_epochs_' str_rectif str_bsl exp_session '_' 'WholeTrial' '.mat']);

    % Load behavior data
    if strcmp(cond, 'trial_cond')
        load(['../Data_/DataProcessed_/s'  num2str(subj) '/databehav_trialcond.mat']);
        nconds = 2;
    elseif strcmp(cond, 'SDT')
        load(['../Data_/DataProcessed_/s'  num2str(subj) '/databehav_SDTcond.mat']);
        load(['../Data_/DataProcessed_/s'  num2str(subj) '/databehav_trialcond.mat']);
        load(['../Data_/DataProcessed_/s'  num2str(subj) '/databehav_otherVars.mat']);
        nconds = 4;
    end


    % Proceed for each condition
    for icond = 1:nconds

        % Find trials of current condition
        if strcmp(cond, 'trial_cond') & icond == 1
            epoch_cond = find(trial_cond == 1)';  % Foot condition
        elseif strcmp(cond, 'trial_cond') & icond == 2
            epoch_cond = find(trial_cond == 0)';  % No foot condition
        elseif strcmp(cond, 'SDT') 
            epoch_cond = find(SDT_cond == icond);
        end

        % Special handling for Subject 80 or 79 with fewer trials
        if subj == 80 || subj== 79
            % Ensure no indices exceed the number of available trials
            epoch_cond = epoch_cond(epoch_cond <= length(data_epoch.sampleinfo));
            if isempty(epoch_cond)
                warning('No valid trials for condition %d in subject 80.', icond);
            end
        end



        % Check if enough trials to be considered in current condition
        if isempty(epoch_cond)
            error(['No entries for current condition ' num2str(icond) ' in subject ' num2str(subj) '!']);
        elseif length(epoch_cond) == 1
            error(['Only one entry for current condition ' num2str(icond) ' in subject ' num2str(subj) '! May create a problem when averaging epochs!'])
        end

        % Extract epochs of current condition
        cfg = [];
        cfg.trials = epoch_cond;
        data_epoch_cond = ft_selectdata(cfg, data_epoch);

        % Remove bad segments of data for the left leg
        load(['../Data_/DataProcessed_old/s'  num2str(subj) '/dataft_badsegm_left_divided_' exp_session '_' cfg_input.epoch_label '.mat']);
        if length(badsegm)>0
            % Remove badsegm (i.e. replace data with NaNs)
            for ibad = 1:size(badsegm,1)
                % Find start and end samples of the current artefact
                spl_start = badsegm(ibad, 1);
                spl_end   = badsegm(ibad, 2);
                % Find trial corresponding to current artefact
                trl_artf = find(data_epoch_cond.sampleinfo(:,1)<=spl_start & data_epoch_cond.sampleinfo(:,2)>=spl_end);
                % Proceed if artefact found (if not found: trial of alternative condition)
                if ~isempty(trl_artf)
                    % Find samples of the artefact, samples relative to start of the trial
                    spl_trl_start = spl_start - data_epoch_cond.sampleinfo(trl_artf,1) + 1;
                    spl_trl_end   = spl_end   - data_epoch_cond.sampleinfo(trl_artf,1) + 1;
                    % Replace artefact with NaNs
                    data_epoch_cond.trial{trl_artf}(:, spl_trl_start:spl_trl_end) = NaN;
                end
            end
        end

        % Remove bad segments of data for the right leg
        load(['../Data_/DataProcessed_old/s'  num2str(subj) '/dataft_badsegm_right_divided_' exp_session '_' cfg_input.epoch_label '.mat']);
        if length(badsegm)>0
            % Remove badsegm (i.e. replace data with NaNs)
            for ibad = 1:size(badsegm,1)
                % Find start and end samples of the current artefact
                spl_start = badsegm(ibad, 1);
                spl_end   = badsegm(ibad, 2);
                % Find trial corresponding to current artefact
                trl_artf = find(data_epoch_cond.sampleinfo(:,1)<=spl_start & data_epoch_cond.sampleinfo(:,2)>=spl_end);
                % Proceed if artefact found (if not found: trial of alternative condition)
                if ~isempty(trl_artf)
                    % Find samples of the artefact, samples relative to start of the trial
                    spl_trl_start = spl_start - data_epoch_cond.sampleinfo(trl_artf,1) + 1;
                    spl_trl_end   = spl_end   - data_epoch_cond.sampleinfo(trl_artf,1) + 1;
                    % Replace artefact with NaNs
                    data_epoch_cond.trial{trl_artf}(:, spl_trl_start:spl_trl_end) = NaN;
                end
            end
        end
           
        % Remove trials with too much noise or with no baseline left
        ntrials = length(data_epoch_cond.sampleinfo);
        trl_keep = 1:ntrials;
        for itrl = 1:ntrials
            % Init flag to exclude trial or not
            flag_excl = 0;
            % Check number of samples with NaNs (we take the first channel for example)
            nb_NaN_trl = sum(isnan(data_epoch_cond.trial{itrl}(1, :)));
            % Check if number of NaNs is more than half the length of the trial
            if nb_NaN_trl > length(data_epoch_cond.time{itrl})/2
                flag_excl = 1;
            end
            % Check if nb of samples with NaNs in the baseline
            spl_bsl_start = nearest(data_epoch_cond.time{itrl}, t_baseline(1));
            spl_bsl_end   = nearest(data_epoch_cond.time{itrl}, t_baseline(2));
            nb_spl_bsl = spl_bsl_end - spl_bsl_start + 1;
            nb_NaN_bsl = sum(isnan(data_epoch_cond.trial{itrl}(1, spl_bsl_start:spl_bsl_end)));
            % Check if we have enough baseline left (at least half)
            if nb_NaN_bsl > nb_spl_bsl/2
                flag_excl = 1;
            end
            % Exclude current trial if it was flagged as bad
            if flag_excl == 1
                epoch_cond(trl_keep==itrl) = [];
                trl_keep(trl_keep==itrl) = [];
            end
        end

        % Find index for the subject in subj_list
        subj_index = find(subj_list == subj);

        % Exclude bad trials
        if length(trl_keep) ~= ntrials
            cfg = [];
            cfg.trials = trl_keep;
            data_epoch_cond = ft_selectdata(cfg, data_epoch_cond);
            num_excluded = ntrials - length(trl_keep);
            disp(['>>> Subj ' num2str(subj) ', cond' num2str(icond) ': ' num2str(num_excluded) ' trials excluded.']);
            
        % Store the number of excluded trials
            exclusion_info(subj_index, icond) = num_excluded;
        else
        % If no trials are excluded, ensure the entry is zero (which it should already be)
            exclusion_info(subj_index, icond) = 0;
        end

        % Baseline-correct data
        if cfg_input.flag_bsl ~= 0
            bsl_activity = zeros(2, length(data_epoch_cond.sampleinfo));
            for itrl = 1:length(data_epoch_cond.sampleinfo)
                % Beginning and end samples of baseline
                spl_bsl_start = nearest(data_epoch_cond.time{itrl}, t_baseline(1));
                spl_bsl_end   = nearest(data_epoch_cond.time{itrl}, t_baseline(2));
                % Compute mean activity over baseline period
                bsl_act = mean(data_epoch_cond.trial{itrl}(:, spl_bsl_start:spl_bsl_end), 2, 'omitnan');
                bsl_activity(:,itrl) = bsl_act;
                if cfg_input.flag_bsl == 1 % baseline subsrtaction
                    data_epoch_cond.trial{itrl}(1,:) = data_epoch_cond.trial{itrl}(1,:) - bsl_act(1);
                    data_epoch_cond.trial{itrl}(2,:) = data_epoch_cond.trial{itrl}(2,:) - bsl_act(2); 
                elseif cfg_input.flag_bsl == 2 % baseline normalization
                    data_epoch_cond.trial{itrl}(1,:) = data_epoch_cond.trial{itrl}(1,:)/bsl_act(1);
                    data_epoch_cond.trial{itrl}(2,:) = data_epoch_cond.trial{itrl}(2,:)/bsl_act(2); 
                end
            end
        end
        

        % Smooth data: we are only interested in "slow" changes of EMG, matching with slow dynamics of memory retrieval
        %%% No because NaNs (bad segments) are spread, so did it only for plotting averages
%         cfg = [];
%         cfg.lpfilter = 'yes';
%         cfg.lpfreq = 2;
%         data_epoch_cond = ft_preprocessing(cfg, data_epoch_cond);

        % Store data
        data_epoch_cond.cfg = [];
        data_OngoingAct.([cond '_' num2str(icond)]) = data_epoch_cond;

        % Average over time window of interest (for R analysis)
        for i_WoI = 1:length(t_WoI_phases)
            cfg = [];
            cfg.avgovertime = 'yes';
            cfg.latency = t_WoI_phases(i_WoI, :);
            cfg.nanmean = 'yes';
            data_trl_avgTime.(['WoI_' num2str(abs(t_WoI_phases(i_WoI, 1))) 'to' num2str(abs(t_WoI_phases(i_WoI, 2)))]) = ft_selectdata(cfg, data_epoch_cond);
        end

        % Store data for csv file
        for itrl = 1:length(epoch_cond)
            if icond==1, encod_cond='1'; recall_cond='-';
            elseif icond==2, encod_cond='0'; recall_cond='-';
            end
            str_WoI = [];
            for i_WoI = 1:length(t_WoI_phases)
                str_WoI = [str_WoI num2str(data_trl_avgTime.(['WoI_' num2str(abs(t_WoI_phases(i_WoI, 1))) 'to' num2str(abs(t_WoI_phases(i_WoI, 2)))]).trial{itrl}(1)) '\t' num2str(data_trl_avgTime.(['WoI_' num2str(abs(t_WoI_phases(i_WoI, 1))) 'to' num2str(abs(t_WoI_phases(i_WoI, 2)))]).trial{itrl}(2)) '\t'];
            end
            i_str = ['s' num2str(subj) '\t' encod_cond '\t' recall_cond '\t' str_WoI];
            i_bsl_R = num2str(bsl_activity(1,itrl));
            i_bsl_L = num2str(bsl_activity(2,itrl));
            i_q1 = num2str(q1(epoch_cond(itrl)));
            i_q2 = num2str(q2(epoch_cond(itrl)));
            i_q3 = num2str(q3(epoch_cond(itrl)));
            i_q4 = num2str(q4(epoch_cond(itrl)));


            i_index_encod = num2str(index_encod(epoch_cond(itrl)));
            i_index_recall = num2str(index_recall(epoch_cond(itrl)));
            i_word = word{epoch_cond(itrl)};
            i_str = [i_str i_bsl_R '\t' i_bsl_L '\t' i_q1 '\t' i_q2 '\t' i_q3 '\t' i_q4 '\t' i_index_encod '\t' i_index_recall '\t' i_word '\t' num2str(epoch_cond(itrl)) '\n'];
            fprintf(outp_file, i_str);
        end
    end
         % Save data
    save(['../Data_/DataProcessed_/s'  num2str(subj) '/dataft_OngoingAct_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat'], 'data_OngoingAct', '-v7.3');
end


% Save exclusion information to a CSV file
filename = ['../Data_/Group_/exclusion_info_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.csv'];
fileID = fopen(filename, 'w');
fprintf(fileID, 'Subject,Condition1,Condition2\n'); 
for i = 1:size(exclusion_info, 1)
    fprintf(fileID, '%d', subj_list(i));
    for j = 1:size(exclusion_info, 2)
        fprintf(fileID, ',%d', exclusion_info(i, j));
    end
    fprintf(fileID, '\n');
end
fclose(fileID);

    % % Save data
    % save(['../Data_/DataProcessed_/s'  num2str(subj) '/dataft_OngoingAct_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat'], 'data_OngoingAct', '-v7.3');


    % Make table for analysis in R, rows=trials, and columns:
    % - subject number
    % - encoded condition
    % - recalled condition
    % - EMG data, one column for each phase and channel
    % - reliving score
    % - time reliving
    % - index encoding
    % - index recall
    % - obstacle name
    % - recall trial number


fclose(outp_file);






