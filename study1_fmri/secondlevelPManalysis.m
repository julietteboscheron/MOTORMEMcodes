%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify second level analysis of reliving parametric modulator %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron

% This script computes the second-level analysis of the re-experiencing
% parametric modulator. It takes as input the first-level parametric
% modulator contrasts from the Foot and NoFoot conditions and assesses the
% overall PM effect across both conditions using a second-level contrast
% with weights [1 1].

clear
clc
cfg = project_config();
addpath(cfg.toolboxes_root)
sub_list = cfg.subjects;
second_level_folder = cfg.secondlevel_pm_root;

condition = 'FRpm';
contrast1 = 'con_0001.nii';
contrast2 = 'con_0002.nii';


matlabbatch{1}.spm.stats.factorial_design.dir = {fullfile(second_level_folder, '2ndlevel_reliving', condition)]};

for i=1:length(sub_list)
    subject_id = sub_list{1,i};
    path_to_sub_folder = fullfile(cfg.firstlevel_reliving_whole_root, subject_id);
    firstlevel_files1{i}=  spm_select('FPlist', path_to_sub_folder, contrast1); 
    firstlevel_files2{i}=  spm_select('FPlist', path_to_sub_folder, contrast2); 
end

matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = firstlevel_files1';
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = firstlevel_files2';
matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
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


load(spm_select('FPlist', [second_level_folder condition], 'SPM.mat'))

matlabbatch{1}.spm.stats.con.spmmat = {spm_select('FPlist', [second_level_folder '\2ndlevel_reliving' condition], 'SPM.mat')}; 
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Anova_alltrl';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 1];

matlabbatch{1}.spm.stats.con.delete = 1;
spm_jobman('run', matlabbatch);
clear matlabbatch
