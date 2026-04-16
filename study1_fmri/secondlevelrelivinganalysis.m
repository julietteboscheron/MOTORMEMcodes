%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify second-level within-subject ANOVA of reliving activity %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron

% This script computes the second-level analysis of reliving-related
% activity using a within-subject (repeated-measures) ANOVA. It takes as
% input the first-level contrast images for the Foot and NoFoot conditions
% and models them as repeated measures within each participant.
% The main effect of reliving across both conditions is assessed using a
% second-level contrast averaging across conditions.

clear
clc
cfg = project_config();
addpath(cfg.toolboxes_root);

sub_list = cfg.subjects;
second_level_folder = cfg.secondlevel_reliving_root;

condition = '_ANOVA_FR';
contrast1 = 'con_0003.nii';
contrast2 = 'con_0004.nii';

matlabbatch{1}.spm.stats.factorial_design.dir = {fullfile(second_level_folder, '2ndlevel_reliving', condition)};
for i=1:length(sub_list)
    subject_id = sub_list{1,i};
    path_to_sub_folder =fullfile(cfg.firstlevel_reliving_whole_root, subject_id);
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i).scans = {
           [path_to_sub_folder '\' contrast1 ',1']
           [path_to_sub_folder '\' contrast2 ',1']
          };

    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i).conds = [1 2];

end


matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm_jobman('run', matlabbatch);
clear matlabbatch

matlabbatch{1}.spm.stats.fmri_est.spmmat =  {spm_select('FPlist', [second_level_folder '\2ndlevel_reliving' condition], 'SPM.mat')}; 
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run', matlabbatch);
clear matlabbatch


load(spm_select('FPlist', [second_level_folder '\2ndlevel_reliving' condition], 'SPM.mat'))

contrastFR = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] * pinv(SPM.xX.X)*SPM.xX.X;


matlabbatch{1}.spm.stats.con.spmmat = {spm_select('FPlist', [second_level_folder '\2ndlevel_reliving' condition], 'SPM.mat')}; 
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Anova_alltrl';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = contrastFR;
matlabbatch{1}.spm.stats.con.delete = 1;
spm_jobman('run', matlabbatch);
clear matlabbatch
