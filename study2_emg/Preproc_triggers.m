%% What does this do?
% Preproc_triggers identifies the triggers used to define the start, end
% and other events within individual trials.
function Preproc_triggers(cfg)
    
    GeneralVariables;
    exp_session = cfg.exp_session;
    subj_list = cfg.subj_list;
    
    
    % Loop on subjects
    for isubj = 1:length(subj_list)
    
        %% for all blocks
        subj = subj_list(isubj);
        disp(['Preprocessing triggers, subject ' num2str(subj)]);
        str_subj = '0'; if subj>9, str_subj = ''; end 
        
        % Define block list to include 'baseline', '1', and '2'
        block_list = {'baseline', '1', '2'};
    
        % Add block exceptions for specific subjects
        if subj == 79 || subj == 80
        block_list = {'baseline', '1'};  
        end
    
    
        %% Loop on blocks
        for iblockIndex = 1:length(block_list)
    
            iblock = block_list{iblockIndex};  % Current block as a string
        
            % Construct the load path dynamically based on the block type
            if strcmp(iblock, 'baseline')
                loadPath = ['../Data_/DataProcessed_/s' str_subj num2str(subj) '/dataft_raw_' exp_session '_block' iblock '.mat'];
            else
                loadPath = ['../Data_/DataProcessed_/s' str_subj num2str(subj) '/dataft_raw_' exp_session '_block' num2str(iblock) '.mat'];
            end
        
            % Load data
            load(loadPath);
            
            % Find triggers
            ichan_trig = find(not(cellfun('isempty',strfind(data_subj.label, 'trigger'))));
            trigger_stayon = find(data_subj.trial{1}(ichan_trig, :) == 1);
            trigger_onoff_find = find(diff(trigger_stayon) ~= 1); % Find the indices where the trigger signal is turned on/off
            trigger_onoff = [0 trigger_onoff_find length(trigger_stayon)];
            trigger_on = {};
            trigger_on_duration = zeros(1, length(trigger_onoff)-1);
            for i = 1:length(trigger_onoff)-1 % Loop through the triggers and extract them
                trigger_on{i} = trigger_stayon(trigger_onoff(i)+1:trigger_onoff(i+1));
                trigger_on_duration(i) = length(trigger_on{i})*(1/data_subj.hdr.Fs*1000); % length in millisecond
            end
    
            
    
            % BLOCK Baseline :
            % Event codes :
            % 1 -> start rest block
            % 2 -> end rest block
            % 3 -> begin imagery
            % 4 -> end imagery
            % 5 -> begin max contraction
            % 6 -> end max right
            % 7 -> end max left
    
    
            if strcmp(iblock, 'baseline')
                trigger_str = {'rest start', 'rest end','beg imagery motor','end imagery motor','begin max','end max droite', 'end max gauche'};
                trigger_info = zeros(length(trigger_on), 3);  % col1=ind start event, col2=ind end event, col3=code event
                trigger_label = cell(length(trigger_on), 1);
    
                if subj ~= 58 && subj ~= 59
                % Your code adjustments for subjects other than 58 and 59
                % For example, removing specific triggers for all but subjects 58 and 59
                trigger_on(9) = [];
                trigger_on_duration(9) = [];
                end
    
    
                for i = 1:length(trigger_on)
                    if trigger_on_duration(i) >= 380 && trigger_on_duration(i) < 420     %% Start rest block
                        trigger_label{i} = trigger_str{1};
                        event_id = 1;
                    % % elseif trigger_on_duration(i) >= 180 && trigger_on_duration(i) < 220  %% End rest block
                    %     trigger_label{i} = trigger_str{2};
                    %     event_id = 2;
                    elseif trigger_on_duration(i) >= 80 && trigger_on_duration(i) < 120 %% Begin imagery
                        trigger_label{i} = trigger_str{3};
                        event_id = 3;
                    % elseif trigger_on_duration(i) >= 280 && trigger_on_duration(i) < 320 %% End imagery
                    %     trigger_label{i} = trigger_str{4};
                    %     event_id = 4;
                    elseif trigger_on_duration(i) >= 480 && trigger_on_duration(i) < 520  %% Begin max contraction
                        trigger_label{i} = trigger_str{5};
                        event_id = 5;
                    % elseif trigger_on_duration(i) >= 680 && trigger_on_duration(i) < 720  %% End max droite
                    %     trigger_label{i} = trigger_str{6};
                    %     event_id = 6;
                    % elseif trigger_on_duration(i) >= 580 && trigger_on_duration(i) < 620  %% End max gauche
                    %     trigger_label{i} = trigger_str{7};
                    %     event_id = 7;
                      
                    else
                        trigger_label{i} = 'not determined';
                        event_id = 0;
                    end
                    if event_id ~= 0
                        trigger_info(i,:) = [trigger_on{1,i}(1) trigger_on{1,i+1}(1) event_id];
                    end
                    trigger_info(9,3) = 6;
                    trigger_info(11,3) = 6;
                
                    savePath = ['../Data_/DataProcessed_/s' str_subj num2str(subj) '/triggers_' exp_session '_block_baseline.mat'];
                    save(savePath, 'trigger_info', 'trigger_label', '-v7.3');
    
                end
            
                % BLOCK 1 and 2 :
                % Event codes :
                % 1 -> word cue
                % 2 -> FR start
                % 3 -> FR end
        
                else
                    trigger_str = {'word cue','end word cue/beg FR','end FR'};
                    trigger_info = zeros(length(trigger_on), 3);  % col1=ind start event, col2=ind end event, col3=code event
                    trigger_label = cell(length(trigger_on), 1);
        
                    % Associate strings with vector values based on a condition
                    for i = 1:length(trigger_on)
                        if trigger_on_duration(i) >= 80 && trigger_on_duration(i) < 120   %% Word cue = 4
                            trigger_label{i} = trigger_str{1};
                            event_id = 1;
                        elseif trigger_on_duration(i) >= 180 && trigger_on_duration(i) < 220  %% Free recall start = 5
                            trigger_label{i} = trigger_str{2};
                            event_id = 2;
                        % elseif trigger_on_duration(i) >= 280 && trigger_on_duration(i) < 320  %% End free recall
                        %     trigger_label{i} = trigger_str{3};
                        %     event_id = 3;
                        else
                            trigger_label{i} = 'not determined';
                            event_id = 0;
                        end
                        if event_id ~= 0
                            trigger_info(i,:) = [trigger_on{1,i}(1) trigger_on{1,i+1}(1) event_id];
                        end
                    end
                    savePath = ['../Data_/DataProcessed_/s' str_subj num2str(subj) '/triggers_' exp_session '_block' iblock '.mat'];
                    save(savePath, 'trigger_info', 'trigger_label', '-v7.3');
            end
        end
    end
    end

