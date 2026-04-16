%% What does this do?
% Preproc_processRaw applies the first preprocessing steps to the raw,
% fieldtrip-formatted data, i.e. low-pass filters and rectification.
function Preproc_processRaw(cfg)
    GeneralVariables;
    exp_session = cfg.exp_session;
    subj_list = cfg.subj_list;
    
    % Loop on subjects
    for isubj = 1:length(subj_list)
    
        subj = subj_list(isubj);
        disp(['Preprocessing raw data, subject ' num2str(subj)]);
    
        str_subj = '0'; if subj > 9, str_subj = ''; end
    
        % Initialize block list and include baseline for all subjects
        block_list = [{'baseline'}, {'1', '2'}]; 
    
        % Adjust block list for specific subjects if necessary
        if subj == 79 || subj == 80
            block_list = [{'baseline'}, {'1'}]; % Include only 'baseline' and '1' for subjects 79 and 80
        end
    
    
        % Loop on blocks
         for i = 1:length(block_list)
            iblock = block_list{i};
    
            % Construct file paths
            loadPath = ['../Data_/DataProcessed_/s' str_subj num2str(subj) '/dataft_raw_' exp_session '_block' iblock '.mat'];
            
            %% Load data from previous savepath
            load(loadPath);
    
            % Apply preprocessing steps defined in the cfg entered as input of the function
            data = ft_preprocessing(cfg, data_subj);
    
            % Apply rectification (and low-pass filter to smooth discontinuities induced by the rectification)
            % Appliquer rectification (et, éventuellement, un LPF pour lisser les discontinuités induites par la rectification)
            if cfg.flag_rectif ~= 0
                % Rectification : prendre la valeur absolue du signal
                data.trial{1} = abs(data.trial{1});
                
                if cfg.flag_rectif > 0
                    % Si la valeur est positive, appliquer également un filtrage passe-bas
                    cfg_filt = [];
                    cfg_filt.lpfilter = 'yes';
                    cfg_filt.lpfreq = cfg.flag_rectif;
                    data = ft_preprocessing(cfg_filt, data);
                    str_rectif = ['rectif' num2str(cfg.flag_rectif) 'Hz_'];
                else
                    % Si la valeur est négative, appliquer uniquement la rectification (sans filtrage)
                    str_rectif = 'rectifOnly_';
                end
            else
                str_rectif = '';
            end
            
            %% Save data ADJUST FOR MAC %%
            save(['../Data_/DataProcessed_/s' str_subj num2str(subj)  '/dataft_process_' str_rectif exp_session '_block' num2str(iblock) '.mat'], 'data', '-v7.3');
        end
    end


end

