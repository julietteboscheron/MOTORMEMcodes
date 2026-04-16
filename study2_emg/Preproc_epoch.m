%% What does this do?
% Preproc_epoch uses the triggers from Preproc_triggers as well as the data
% from Preproc_processRaw to extract the epochs of individual trials.
function Preproc_epoch(cfg_input)
    
    GeneralVariables;
    exp_session = cfg_input.exp_session;
    subj_list = cfg_input.subj_list;
    
    % Loop on subjects
    for isubj = 1:length(subj_list)
    
        subj = subj_list(isubj);
        disp(['Preprocessing epochs, subject ' num2str(subj)]);
        if cfg_input.flag_rectif < 0
            str_rectif = 'rectifOnly_';
        elseif cfg_input.flag_rectif > 0
            str_rectif = ['rectif' num2str(cfg_input.flag_rectif) 'Hz_'];
        else
            str_rectif = '';
        end
    
        block_list = cfg_input.iblock;
        if subj==1 & find(cfg_input.iblock==1), block_list(block_list==1) = []; end
    
        %  % Adding exceptions for subjects 79 and 80 to only include block 1
        if subj == 79 || subj == 80
            block_list = 1;
        end
    
    
        for i=1:length(block_list)
    
            iblock = block_list(i);
    
            % Load data and triggers
            load(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_process_' str_rectif exp_session '_block' num2str(iblock) '.mat']);
            load(['../Data_/DataProcessed_/s' num2str(subj) '/triggers_' exp_session '_block' num2str(iblock) '.mat']);
    
            % Test if current subject has required triggers
            ind_trigg = find(trigger_info(:,3)==cfg_input.event_code);
    
            if ~isempty(ind_trigg)
    
                % Create matrix with definition of epochs
                start_epoch = trigger_info(ind_trigg, 1) + cfg_input.t_pretrigger*data.fsample;
                end_epoch   = trigger_info(ind_trigg, 1) + cfg_input.t_posttrigger*data.fsample;
                offset_epoch = ones(length(start_epoch), 1)*cfg_input.t_pretrigger*data.fsample;
                trl = round([start_epoch end_epoch offset_epoch]);
    
                % Epoch data
                cfg = [];
                cfg.trl = trl;
                data_epoch_block = ft_redefinetrial(cfg, data);
    
                % Apply baseline correction
                if cfg_input.flag_bsl == 1
                    error('Baseline correction is not coded in this function.')
                else
                    str_bsl = '';
                end
    
                if i == 1
                    data_epoch = data_epoch_block;
                else
                    % Append data from different runs
                    cfg = [];
                    cfg.keepsampleinfo='no';
                    data_epoch = ft_appenddata(cfg, data_epoch, data_epoch_block);
                    % Fix sample info
                    data_epoch = fixsampleinfo(data_epoch);
                end
    
            else
                disp(['  Subject ' num2str(subj) ' does not have required trigger.']);
            end
        end
    
        % Save data
        if exist('data_epoch', 'var')
            save(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_epochs_' str_rectif str_bsl exp_session '_' cfg_input.epoch_label '.mat'], 'data_epoch', '-v7.3');
        end
         % Clear only the variables that are no longer needed
        clear data_epoch_block data_epoch trigger_info ind_trigg;
    
    end

end
