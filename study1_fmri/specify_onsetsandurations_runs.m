%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract trial-wise onsets and durations for the MOTORMEM fMRI task %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron
%
% This script parses scanner trigger logs and behavioral recall logs to
% determine the onset and duration of each task phase for each trial in
% blocks 1 and 2 of the fMRI experiment.
%
% For each participant, it extracts timing information for fixation cross,
% word cue, free recall, and recognition periods, aligns these events with
% trial metadata from the behavioral logs, and labels trials according to
% encoding condition (Foot vs NoFoot).
%
% The script then saves participant-specific .mat files containing names,
% onsets, and durations formatted for SPM first-level model specification.
% It also saves trial-wise re-experiencing ratings separately for Foot and
% NoFoot trials.


clear
clc 

%% Initialization of variables
cfg = project_config();
cd (cfg.code_root);
sub_list = cfg.subjects;
sub_list_old_names = cfg.subjects_oldnames;
addpath(cfg.code_root)

%% FIND ONSETS AND DURATIONS
for sub=1:length(sub_list)

    
    subject_id_old = sub_list_old_names{1,sub};
    subject_id = sub_list{1,sub};
    path_to_sub_folder = fullfile(cfg.sourcedata_root, subject_id, 'beh');
    path_to_events_folder = fullfile(cfg.sourcedata_root, subject_id, 'func');

    % loop over the two blocks
    for i=1:2
    
        wordcue = zeros(20,8); % will contain the start, end, duration and trial info (i.e. encoding condition) of wordcue presentation for each trial of block 1 and 2
        fixcross = zeros(20,8);% will contain the start, end, duration and trial info (i.e. encoding condition) of fixation cross presentation for each trial of block 1 and 2
        freerecall = zeros(20,8);% will contain the start, end, duration and trial info (i.e. encoding condition) of free recall for each trial of block 1 and 2
        recog = zeros(20,8); % will contain the start, end, duration and trial info (i.e. encoding condition) of recognition task for each trial of block 1 and 2
        
        % load files
        cd(strcat(path_to_sub_folder, '/rand_', subject_id_old, '/'));
        block = num2str(i);
        stim_info = readtable(['/Recall_List_' block '.txt']); % info regarding the stimuli presented at each trial
        cd (strcat(path_to_sub_folder, '/behavioral_logs/recall_logs/block', block));
        folder=dir('*global*');
        triggers = readtable([folder.name '/log_triggers_input.csv']); % triggers log
        file=dir('log*');
        recall_logs = readtable(file.name); % recall log
    
        % only keep the triggers of interest (i.e. 'Alpha Down 5', the scanner triggers) 
        alphadowns = triggers;
        idx=1;
        for itrigg=1:length(triggers.trigger_info)
            if strcmp(triggers.trigger_info(itrigg,1), 'Alpha5 Down')
                alphadowns(idx,:)= triggers(itrigg,:);
                idx=idx+1;
            end
        end
        alphadowns(idx+1:end,:)= [];
        alphadowns.count(1:length(alphadowns.trigger_info)) = 1:length(alphadowns.trigger_info);
        
        % change a routine name for the first 4 participants as it was misleading
        ppt_with_pb_fixcross_name = {'pilot104','sub-01', 'sub-02', 'sub-04'}; 
        
        if any(strcmp(ppt_with_pb_fixcross_name,subject_id))
            for itrigg=1:(length(alphadowns.routine_name)-1)
              if strcmp(alphadowns.routine_name(itrigg,1), 'Conf_recog') && strcmp(alphadowns.routine_name(itrigg+1,1), 'fix cross')
                    alphadowns.routine_name(itrigg+1,1) = {'fix cross3'};
                    if strcmp(alphadowns.routine_name(itrigg+2,1), 'fix cross')
                        alphadowns.routine_name(itrigg+2,1) = {'fix cross3'};
                    end
              elseif strcmp(alphadowns.routine_name(itrigg,1), 'RECOG') && strcmp(alphadowns.routine_name(itrigg+1,1), 'fix cross')
                    alphadowns.routine_name(itrigg+1,1) = {'fix cross3'};
                    if strcmp(alphadowns.routine_name(itrigg+2,1), 'fix cross')
                        alphadowns.routine_name(itrigg+2,1) = {'fix cross3'};
                    end
              elseif strcmp(alphadowns.routine_name(itrigg,1), 'Question') && strcmp(alphadowns.routine_name(itrigg+1,1), 'fix cross')
                    alphadowns.routine_name(itrigg+1,1) = {'fix cross2'};
                    if strcmp(alphadowns.routine_name(itrigg+2,1), 'fix cross')
                        alphadowns.routine_name(itrigg+2,1) = {'fix cross2'};
                        if strcmp(alphadowns.routine_name(itrigg+3,1), 'fix cross')
                            alphadowns.routine_name(itrigg+3,1) = {'fix cross2'};
                        end
                    end
              end
            end
        end
        
        % add stimuli info to our output variables in column 4
        wordcue(:,4) = table2array(stim_info(:,3));
        fixcross(:,4) = table2array(stim_info(:,3));
        freerecall(:,4) = table2array(stim_info(:,3));
        recog(:,4) = table2array(stim_info(:,3));
        for col=5:8
            wordcue(:,col) = table2array(recall_logs(:,col-3));
            fixcross(:,col) = table2array(recall_logs(:,col-3));
            freerecall(:,col) = table2array(recall_logs(:,col-3));
            recog(:,col) = table2array(recall_logs(:,col-3));
        end
        % initialize counters
        idx_wc =1;
        idx_fc =1;
        idx_fr=1;
        idx_recog=1;
    
        % loop over all triggers of interest and catch the 'start' and 'end' of
        % each sub-task of interest (i.e. fixation cross presentation, wordcue
        % presentation, free recall and recognition task)
        for itrigg=1:(length(alphadowns.routine_name)-1)
             if strcmp(alphadowns.routine_name(itrigg,1), 'wait_fix') && strcmp(alphadowns.routine_name(itrigg+1,1), 'fix cross')
                 fixcross(idx_fc,1) = alphadowns.count(itrigg,1);
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'Fixation cross') && strcmp(alphadowns.routine_name(itrigg+1,1), 'fix cross')
                fixcross(idx_fc,1) = alphadowns.count(itrigg,1);
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'fix cross3') && strcmp(alphadowns.routine_name(itrigg+1,1), 'fix cross')
                fixcross(idx_fc,1) = alphadowns.count(itrigg,1);
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'fix cross') && strcmp(alphadowns.routine_name(itrigg+1,1), 'wait_WC')
                fixcross(idx_fc,2) = alphadowns.count(itrigg-1,1); 
                fixcross(idx_fc,3) = fixcross(idx_fc,2)-fixcross(idx_fc,1)+1;
                idx_fc = idx_fc+1;
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'wait_WC') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Word cue')
                wordcue(idx_wc,1) = alphadowns.count(itrigg,1);
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'fix cross') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Word cue')
                wordcue(idx_wc,1) = alphadowns.count(itrigg,1);
                fixcross(idx_fc,2) = alphadowns.count(itrigg-1,1); 
                fixcross(idx_fc,3) = fixcross(idx_fc,2)-fixcross(idx_fc,1)+1;
                idx_fc = idx_fc+1;
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'Word cue') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Free recall')
                wordcue(idx_wc,2) = alphadowns.count(itrigg-1,1); 
                wordcue(idx_wc,3) = wordcue(idx_wc,2)-wordcue(idx_wc,1)+1;
                freerecall(idx_fr,1) = alphadowns.count(itrigg+1,1); 
                idx_wc = idx_wc+1;
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'Free recall') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Wait')
                freerecall(idx_fr,2) = alphadowns.count(itrigg-1,1); 
                freerecall(idx_fr,3) = freerecall(idx_fr,2)-freerecall(idx_fr,1)+1; 
                idx_fr = idx_fr+1;
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'Free recall') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Bip')
                freerecall(idx_fr,2) = alphadowns.count(itrigg-1,1); 
                freerecall(idx_fr,3) = freerecall(idx_fr,2)-freerecall(idx_fr,1)+1; 
                idx_fr = idx_fr+1;            
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'Free recall') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Question')
                freerecall(idx_fr,2) = alphadowns.count(itrigg-1,1); 
                freerecall(idx_fr,3) = freerecall(idx_fr,2)-freerecall(idx_fr,1)+1; 
                idx_fr = idx_fr+1;
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'wait_Recog') && strcmp(alphadowns.routine_name(itrigg+1,1), 'RECOG')
                recog(idx_recog,1) = alphadowns.count(itrigg,1);
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'fix cross2') && strcmp(alphadowns.routine_name(itrigg+1,1), 'RECOG')
                recog(idx_recog,1) = alphadowns.count(itrigg,1);
             elseif strcmp(alphadowns.routine_name(itrigg,1), 'wait_Recog') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Conf_recog')
                recog(idx_recog,1) = alphadowns.count(itrigg,1);
                recog(idx_recog,2) = alphadowns.count(itrigg,1);
                recog(idx_recog,3) = recog(idx_recog,2)-recog(idx_recog,1)+1;
                idx_recog = idx_recog+1;
            elseif strcmp(alphadowns.routine_name(itrigg,1), 'RECOG') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Conf_recog')
                recog(idx_recog,2) = alphadowns.count(itrigg-1,1);
                recog(idx_recog,3) = recog(idx_recog,2)-recog(idx_recog,1)+1;
                idx_recog = idx_recog+1;
             elseif strcmp(alphadowns.routine_name(itrigg,1), 'RECOG') && strcmp(alphadowns.routine_name(itrigg+1,1), 'fix cross3')
                recog(idx_recog,2) = alphadowns.count(itrigg-1,1);
                recog(idx_recog,3) = recog(idx_recog,2)-recog(idx_recog,1)+1;
                idx_recog = idx_recog+1;
             end
        end
        
  
        %supprimer premier trials du sub-13 au premier block
        if i==1 && strcmp(subject_id, 'sub-13')
            wordcue(1,:) = [];
            fixcross(1,:) = [];
            freerecall(1,:) = [];
            recog(1,:) = [];
        end

        %supprimer premier trials du sub-18 au premier block 
        if i==1 && strcmp(subject_id, 'sub-18')
            wordcue(1,:) = [];
            fixcross(1,:) = [];
            freerecall(1,:) = [];
            recog(1,:) = [];
        end

 
        %supprimer trials 19 et 20 du sub-19 au premier block 
        if i==1 && strcmp(subject_id, 'sub-19')
            wordcue([19 20],:) = [];
            fixcross([19 20],:) = [];
            freerecall([19 20],:) = [];
            recog([19 20],:) = [];
        end

        %supprimer trois premier trials du sub-20 au premier block
        if i==1 && strcmp(subject_id, 'sub-20')
            wordcue([1 2 3],:) = [];
            fixcross([1 2 3],:) = [];
            freerecall([1 2 3],:) = [];
            recog([1 2 3],:) = [];
        end

  
        %supprimer last trial du sub-34 au block1 car too slow
        if i==1 && strcmp(subject_id, 'sub-34')
            wordcue(20,:) = [];
            fixcross(20,:) = [];
            freerecall(20,:) = [];
            recog(20,:) = [];
        end

        %supprimer last trial du sub-36 au block1 car too slow
        if i==1 && strcmp(subject_id, 'sub-36')
            wordcue(20,:) = [];
            fixcross(20,:) = [];
            freerecall(20,:) = [];
            recog(20,:) = [];
        end

        %supprimer first trial du sub-38 au block1 car mal compris les
        %instructions
        if i==1 && strcmp(subject_id, 'sub-38')
            wordcue(1,:) = [];
            fixcross(1,:) = [];
            freerecall(1,:) = [];
            recog(1,:) = [];
        end

     

    % COMPUTE .MAT FILE FOR EACH PARTICIPANT
    % with all conditions of interest
    input = {{'fixcross', 'wordcue', 'freerecall', 'recog'},{fixcross, wordcue, freerecall, recog}};
    [names,onsets, durations] = extract_onsetdur_foot_nofoot(input);
    cd(path_to_events_folder);
    save(strcat('onsetsdurations_ALLTRL_block_', block, subject_id, '.mat'), 'names', 'onsets', 'durations', '-mat');

    reliv_score_foot = freerecall(find(freerecall(:,4)==1),5);
    reliv_score_nofoot = freerecall(find(freerecall(:,4)==0),5);

    save(strcat('relivscorefoot_block', block, subject_id, '.mat'), 'reliv_score_foot', '-mat');
    save(strcat('relivscorenofoot_block', block, subject_id, '.mat'), 'reliv_score_nofoot', '-mat');
     end
end



