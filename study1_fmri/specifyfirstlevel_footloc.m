%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First Level of Foot Localizer of MOTORMEM task using SPM12 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron


clear
clc
cfg = project_config();
addpath(cfg.toolboxes_root)


sub_list = cfg.subjects;
TR = cfg.TR;

for i=1:length(sub_list)
    subject_id = sub_list{1,i};

    path_to_sub_folder = fullfile(cfg.preproc_root, subject_id); 
    path_to_func = fullfile(path_to_sub_folder, 'func'); 
    path_to_events = fullfile(cfg.sourcedata_root, subject_id, 'func');
  
    cd (cfg.firstlevel_localiser_root)
    mkdir (subject_id)
    outputdir = fullfile(cfg.firstlevel_localiser_root, subject_id);  
    
    func_files_footloc =  fullfile(path_to_func, ['swu' subject_id '_task-footloc_bold.nii']);
        	  
    % specify first level model
    matlabbatch{1}.spm.stats.fmri_spec.dir = {outputdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = spm_file(cellstr(spm_select('expand', fullfile(func_files_footloc))));
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {fullfile(path_to_events, ['onsetsdurations_footloc_' subject_id '.mat']) };
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg =  {fullfile(path_to_func, ['rp_' subject_id '_task-footloc_bold.txt'])};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = fullfile(cfg.masks_root, 'GreyMatterMask_TPM025.nii');
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    spm_jobman('run', matlabbatch);
    clear matlabbatch

    % estimate model
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {spm_select('FPlist', outputdir, 'SPM.mat')};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    % write contrast
    matlabbatch{2}.spm.stats.con.spmmat = {spm_select('FPlist', outputdir, 'SPM.mat')};
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.name = 'move-rest';
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0 0 0 0];
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{2}.spm.stats.con.delete = 0;
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end
