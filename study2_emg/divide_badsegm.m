function divide_badsegm(cfg_input)

%%


for sub=1:length(cfg.subj_list) 

    clear badsegm data_epoch

    subj = cfg.subj_list(sub);

    if cfg.flag_rectif ~= 0, str_rectif = ['rectif' num2str(cfg.flag_rectif) 'Hz_']; else, str_rectif = ''; end
    if cfg.flag_bsl == 1, str_bsl = 'bsl_'; else, str_bsl = ''; end

    % Load epoch data
    load(['../Data_/DataProcessed_/s'  num2str(subj) '/dataft_epochs_' str_rectif str_bsl cfg.exp_session '_' cfg.epoch_label '.mat']);
    
    % Load badsegm
    load(['../Data_/DataProcessed_/s'  num2str(subj) '/dataft_badsegm_' cfg.leg cfg.exp_session '_' cfg.epoch_label '.mat']);
    
    max_samples = size(data_epoch.sampleinfo, 1);

    % Process bad segments
    for idxseg = 1:length(badsegm)
        sample = 1;
        while ((sample <= max_samples) && (data_epoch.sampleinfo(sample, 1) <= badsegm(idxseg, 1)))
            sample = sample + 1;
        end
        if ((sample < max_samples) && (badsegm(idxseg, 2) > data_epoch.sampleinfo(sample-1, 2)))
            newline = size(badsegm, 1)+1;
            badsegm(newline, 1) = data_epoch.sampleinfo(sample, 1);
            badsegm(newline, 2) = badsegm(idxseg, 2);
            badsegm(idxseg, 2) = data_epoch.sampleinfo(sample-1, 2);
        end
    end

    save(['../Data_/DataProcessed_/s' num2str(subj) '/dataft_badsegm_' cfg.leg '_divided_' cfg.exp_session '_' cfg.epoch_label '.mat'], 'badsegm', '-v7.3');
end
