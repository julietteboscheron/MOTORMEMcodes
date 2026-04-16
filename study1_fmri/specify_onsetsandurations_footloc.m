%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract onsets and durations for the motor localizer task %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron
%
% This script parses scanner trigger logs to determine the onset and
% duration of Move and Rest blocks in the motor localizer task for each
% participant.
%
% It extracts block-wise timing information, formats it for SPM first-level
% model specification, and saves a participant-specific .mat file
% containing condition names, onsets, and durations.

clear
clc
cfg = project_config();
addpath(cfg.toolboxes_root)
addpath(cfg.code_root)


%% Initialization of variables
 sub_list_old_names = cfg.subjects_oldnames;
 sub_list = cfg.subjects;

%% FIND ONSETS AND DURATIONS
for sub=1:length(sub_list)
    
    subject_id_old = sub_list_old_names{1,sub};
    subject_id = sub_list{1,sub};
    path_to_sub_folder = fullfile(cfg.sourcedata_root, subject_id, 'beh');
    path_to_events_folder = fullfile(cfg.sourcedata_root, subject_id, 'func');
   

    rest = zeros(3,3); % will contain the start, end, duration and trial info (i.e. encoding condition) of wordcue presentation for each trial of block 1 and 2
    move = zeros(3,3);% will contain the start, end, duration and trial info (i.e. encoding condition) of fixation cross presentation for each trial of block 1 and 2

    % load files
    cd (strcat(path_to_sub_folder, '/behavioral_logs/recall_logs/footloc'));
    folder=dir('*global*');
    triggers = readtable([folder.name '/log_triggers_input.csv']); % triggers log

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
    
    % initialize counters
    idx_mv =1;
    idx_rst=1;

    % loop over all triggers of interest and catch the 'start' and
    % 'end' of movement localizers
    for itrigg=1:(length(alphadowns.routine_name)-1)
        if strcmp(alphadowns.routine_name(itrigg,1), 'Fixation cross') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Rest')
            rest(idx_rst,1) = alphadowns.count(itrigg+1,1);
        elseif strcmp(alphadowns.routine_name(itrigg,1), 'wait_rest') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Rest')
            rest(idx_rst,1) = alphadowns.count(itrigg+1,1);
        elseif strcmp(alphadowns.routine_name(itrigg,1), 'Rest') && strcmp(alphadowns.routine_name(itrigg+1,1), 'wait_move')
            rest(idx_rst,2) = alphadowns.count(itrigg,1);
            rest(idx_mv,3) = rest(idx_rst,2)-rest(idx_rst,1)+1;
            idx_rst = idx_rst+1;
        elseif strcmp(alphadowns.routine_name(itrigg,1), 'Rest') && strcmp(alphadowns.routine_name(itrigg+1,1), 'move')
            move(idx_mv,1) = alphadowns.count(itrigg+1,1);
            rest(idx_rst,2) = alphadowns.count(itrigg,1);
            rest(idx_mv,3) = rest(idx_rst,2)-rest(idx_rst,1)+1;
            idx_rst = idx_rst+1;
        elseif strcmp(alphadowns.routine_name(itrigg,1), 'wait_move') && strcmp(alphadowns.routine_name(itrigg+1,1), 'move')
            move(idx_mv,1) = alphadowns.count(itrigg+1,1);
        elseif strcmp(alphadowns.routine_name(itrigg,1), 'move') && strcmp(alphadowns.routine_name(itrigg+1,1), 'wait_rest')
            move(idx_mv,2) = alphadowns.count(itrigg,1); 
            move(idx_mv,3) = move(idx_mv,2)-move(idx_mv,1)+1;
            idx_mv = idx_mv+1;
        elseif strcmp(alphadowns.routine_name(itrigg,1), 'move') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Rest')
            rest(idx_rst,1) = alphadowns.count(itrigg+1,1);
            move(idx_mv,2) = alphadowns.count(itrigg,1); 
            move(idx_mv,3) = move(idx_mv,2)-move(idx_mv,1)+1;
            idx_mv = idx_mv+1;
       elseif strcmp(alphadowns.routine_name(itrigg,1), 'move') && strcmp(alphadowns.routine_name(itrigg+1,1), 'Break')
            move(idx_mv,2) = alphadowns.count(itrigg,1); 
            move(idx_mv,3) = move(idx_mv,2)-move(idx_mv,1)+1;
         end
    end

 
    % COMPUTE .MAT FILE FOR EACH PARTICIPANT
    input = {{'move', 'rest'},{move, rest}};
    [names,onsets, durations] = extract_onsetdur_loc(input);
    cd(path_to_events_folder);
    save(strcat('onsetsdurations_footloc_', subject_id, '.mat'), 'names', 'onsets', 'durations', '-mat');
end




