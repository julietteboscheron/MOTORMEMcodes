%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify first level  analysis of MOTORMEM task on SPM12 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron

% This script computes the first level SPM analysis of our reliving task
% with the re-experiencing ratings as parametric modulators
% accross the whole reliving period (16 TR)
% once the model is built it estimates it and generate the contrasts of
% interest

clear
clc
cfg = project_config();
cd (cfg.code_root);
addpath(cfg.toolboxes_root);


sub_list = cfg.subjects;

for i=1:length(sub_list)

    %% Setting up variables

    subject_id = sub_list{1,i};
    path_to_sub_folder = fullfile(cfg.preproc_root, subject_id);
    cd (path_to_sub_folder)
    
    path_to_events = fullfile(cfg.sourcedata_root, subject_id, 'func');
    path_to_func = [path_to_sub_folder '\func\'];
    path_to_anat = [path_to_sub_folder '\anat\'];

    cd (cfg.firstlevel_reliving_whole_root)
    mkdir (subject_id)
    outputdir = fullfile(cfg.firstlevel_reliving_whole_root, subject_id);
    
    if strcmp(subject_id, 'sub-43')
        func_files_swu_run2=  spm_select('FPlist', path_to_func, ['^swu' subject_id '_task-reliv_run-03_bold.*\.nii']);
        onsetdur_block2 = load([path_to_events '\onsetsdurations_ALLTRL_block_2' subject_id '.mat']);
    else
        func_files_swu_run1=  spm_select('FPlist', path_to_func, ['^swu' subject_id '_task-reliv_run-01_bold.*\.nii']);
        func_files_swu_run2=  spm_select('FPlist', path_to_func, ['^swu' subject_id '_task-reliv_run-02_bold.*\.nii']);        
        onsetdur_block1 = load(fullfile(path_to_events, 'onsetsdurations_ALLTRL_block_1', subject_id, '.mat'));
        onsetdur_block2 = load(fullfile(path_to_events, 'onsetsdurations_ALLTRL_block_2', subject_id, '.mat'));
    end
    
    relivscorefoot_block1 = load(fullfile(path_to_events, 'relivscorefoot_block1', subject_id, '.mat'));
    relivscorenofoot_block1 = load(fullfile(path_to_events, 'relivscorenofoot_block1', subject_id, '.mat'));
   
    relivscorefoot_block2 = load(fullfile(path_to_events, 'relivscorefoot_block2', subject_id, '.mat'));
    relivscorenofoot_block2 = load(fullfile(path_to_events, 'relivscorenofoot_block2', subject_id, '.mat'));
 
    if strcmp(subject_id, 'sub-17')
        onsetdur_block2.onsets{1,6}(1)=[];
        onsetdur_block2.durations{1,6}(1)=[];
        onsetdur_block2.onsets{1,2}(1)=[];
        onsetdur_block2.durations{1,2}(1)=[];
        relivscorenofoot_block2.reliv_score_nofoot(1)=[];
    end

    
  %%  Specify first level
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = {outputdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = cfg.TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;   

    if strcmp(subject_id, 'sub-16')  || strcmp(subject_id, 'sub-43') || strcmp(subject_id, 'sub-20')
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = spm_file(cellstr(spm_select('expand', fullfile(func_files_swu_run2))));
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name =  onsetdur_block2.names{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset =  onsetdur_block2.onsets{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = onsetdur_block2.durations{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name =  onsetdur_block2.names{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset =  onsetdur_block2.onsets{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = onsetdur_block2.durations{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name =  onsetdur_block2.names{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset =  onsetdur_block2.onsets{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = onsetdur_block2.durations{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod.name = 'relivscorefoot';     
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod.param = relivscorefoot_block2.reliv_score_foot;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).name =  onsetdur_block2.names{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).onset =  onsetdur_block2.onsets{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).duration = onsetdur_block2.durations{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod.name = 'relivscorenofoot';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod.param = relivscorenofoot_block2.reliv_score_nofoot;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
        if strcmp(subject_id, 'sub-16') || strcmp(subject_id, 'sub-20')
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {[path_to_func 'rp_' subject_id '_task-reliv_run-02_bold.txt']};
        elseif strcmp(subject_id, 'sub-43')
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {[path_to_func 'rp_' subject_id '_task-reliv_run-03_bold.txt']};
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
    
     else
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = spm_file(cellstr(spm_select('expand', fullfile(func_files_swu_run1))));
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name =  onsetdur_block1.names{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset =  onsetdur_block1.onsets{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = onsetdur_block1.durations{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name =  onsetdur_block1.names{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset =  onsetdur_block1.onsets{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = onsetdur_block1.durations{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name =  onsetdur_block1.names{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset =  onsetdur_block1.onsets{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = onsetdur_block1.durations{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod.name = 'relivscorefoot';     
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod.param = relivscorefoot_block1.reliv_score_foot;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 1;
    
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).name =  onsetdur_block1.names{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).onset =  onsetdur_block1.onsets{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).duration = onsetdur_block1.durations{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod.name = 'relivscorenofoot';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod.param = relivscorenofoot_block1.reliv_score_nofoot;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {[path_to_func 'rp_' subject_id '_task-reliv_run-01_bold.txt']};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;

        matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = spm_file(cellstr(spm_select('expand', fullfile(func_files_swu_run2))));
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).name =  onsetdur_block2.names{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).onset =  onsetdur_block2.onsets{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).duration = onsetdur_block2.durations{1, 1};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).name =  onsetdur_block2.names{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).onset =  onsetdur_block2.onsets{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).duration = onsetdur_block2.durations{1, 2};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).name =  onsetdur_block2.names{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).onset =  onsetdur_block2.onsets{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).duration = onsetdur_block2.durations{1, 5};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).pmod.name = 'relivscorefoot';
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).pmod.param = relivscorefoot_block2.reliv_score_foot;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).orth = 1;
   
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).name =  onsetdur_block2.names{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).onset =  onsetdur_block2.onsets{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).duration = onsetdur_block2.durations{1, 6};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).pmod.name = 'relivscorenofoot';
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).pmod.param = relivscorenofoot_block2.reliv_score_nofoot;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(4).orth = 1;
    
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {[path_to_func 'rp_' subject_id '_task-reliv_run-02_bold.txt']};
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;
 
     end

         
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = fullfile(cfg.mask_root, 'GreyMatterMask_TPM025.nii');
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
 
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    

     %% Estimate model and create contrasts
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {spm_select('FPlist', outputdir, 'SPM.mat')};   
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
 
    matlabbatch{2}.spm.stats.con.spmmat = {spm_select('FPlist', outputdir, 'SPM.mat')};
    
    
    if strcmp(subject_id,'sub-16') || strcmp(subject_id, 'sub-43') || strcmp(subject_id, 'sub-20')

        matlabbatch{2}.spm.stats.con.consess{1}.tcon.name = 'freerecallfoot_pmreliving';
        matlabbatch{2}.spm.stats.con.consess{1}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

        matlabbatch{2}.spm.stats.con.consess{2}.tcon.name = 'freerecallnofoot_pmreliving';
        matlabbatch{2}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

        matlabbatch{2}.spm.stats.con.consess{3}.tcon.name = 'freerecall_foot';
        matlabbatch{2}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

        matlabbatch{2}.spm.stats.con.consess{4}.tcon.name = 'freerecall_nofoot';
        matlabbatch{2}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

       
        matlabbatch{2}.spm.stats.con.delete = 0;
    else
        matlabbatch{2}.spm.stats.con.consess{1}.tcon.name = 'freerecallfoot_pmreliving';
        matlabbatch{2}.spm.stats.con.consess{1}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

        matlabbatch{2}.spm.stats.con.consess{2}.tcon.name = 'freerecallnofoot_pmreliving';
        matlabbatch{2}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

        matlabbatch{2}.spm.stats.con.consess{3}.tcon.name = 'freerecall_foot';
        matlabbatch{2}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

        matlabbatch{2}.spm.stats.con.consess{4}.tcon.name = 'freerecall_nofoot';
        matlabbatch{2}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0];
        matlabbatch{2}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

        matlabbatch{2}.spm.stats.con.delete = 0;
    end
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end




