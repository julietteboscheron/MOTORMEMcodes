%% What does this do?
% Preproc_dataRaw2ft converts the raw EMG data to fieldtrip format for
% further analyses. 

function Preproc_dataRaw2ft(cfg)

GeneralVariables;
exp_session = cfg.exp_session;
subj_list = cfg.subj_list;

% Loop on subjects
for isubj = 1:length(subj_list)
    subj = subj_list(isubj);
    disp(['Preprocessing data Raw to Fieldtrip format, subject ' num2str(subj)]);
    str_subj = '0';
    if subj > 9, str_subj = ''; end

    % Ensure block_list is a cell array with appropriate blocks and 'baseline'
    block_list = {'1', '2'};
    if subj == 79 || subj == 80
        block_list = {'1'};
    end
    block_list = [{'baseline'}, block_list];

    % Loop on blocks
    for i = 1:length(block_list)
        iblock = block_list{i}; % This should now work without error

        % Adjust the file path for baseline differently
        if strcmp(iblock, 'baseline')
            filepath = [path2rawdata '/sub-' num2str(subj) '/' exp_session '/baseline' '/sub-' num2str(subj)  '_EMG_' exp_session '_baseline.mat'];
        else
            filepath = [path2rawdata '/sub-' num2str(subj) '/' exp_session '/block' iblock '/sub-' num2str(subj)  '_EMG_recall_block' iblock '.mat'];
        end 
            
             data_raw = load(filepath)

            %% CHECK WITH JULIETTE %%
    
            % filename = sprintf('%s/%s/%s/block%d/%s_EMG_%s_block%d.mat', path2rawdata, str_subj, exp_session, iblock, str_subj, exp_session, iblock);
            % data_raw = load(filename);
    
    
            %invert channel order for subjects 79 and 80
            if (subj ==79||subj==80)
                right= data_raw.Data{1,1};
                left= data_raw.Data{1,2};
                data_raw.Data{1,1} = left;
                data_raw.Data{1,2} = right;
            end

            % Adjust channel names
            data_raw.channelNames{1} = 'left_tibialis_anterior';
            data_raw.channelNames{2} = 'right_tibialis_anterior';
            data_raw.channelNames{3} = 'trigger';
       
            % Build data structure in fieldtrip format
            data_subj = [];
            data_subj.hdr = [];
            data_subj.hdr.Fs =  data_raw.samplingRate;
            data_subj.hdr.nChans = data_raw.noChans;
            data_subj.hdr.nSamples = size(data_raw.Data{1},1);
            data_subj.hdr.nSamplesPre = 0;
            data_subj.hdr.nTrials = 1;
            data_subj.hdr.label = data_raw.channelNames';
            data_subj.hdr.chantype{1} = 'EMG';
            data_subj.hdr.chantype{2} = 'EMG';
            data_subj.hdr.chanunit{1} = 'microVolts';
            data_subj.hdr.chanunit{2} = 'microVolts';
    
            data_subj.hdr.chantype{3} = 'trigger';
            data_subj.hdr.chanunit{3} = 'Volts';
            data_subj.trial{1} = [data_raw.Data{1,1},data_raw.Data{1,2},data_raw.Data{1,3}]';
              
            data_subj.hdr.chantype = data_subj.hdr.chantype';
            data_subj.hdr.chanunit= data_subj.hdr.chanunit';
            data_subj.fsample = data_subj.hdr.Fs;
            data_subj.label = data_raw.channelNames';
            data_subj.sampleinfo = [1 size(data_raw.Data{1},1)];
            data_subj.time{1} =linspace(0,1/data_subj.hdr.Fs*data_subj.hdr.nSamples,data_subj.hdr.nSamples);
            data_subj.cfg = [];
    
    
            mkdir(['../Data_/DataProcessed_/s' str_subj num2str(subj)])
             % Save processed data - Note: Using iblock directly for filename to handle 'baseline'
            savepath = ['../Data_/DataProcessed_/s' str_subj num2str(subj) '/dataft_raw_' exp_session '_block' iblock '.mat'];
            save(savepath, 'data_subj', '-v7.3');         

        end
    end 
end





