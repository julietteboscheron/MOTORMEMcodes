%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing of fMRI Data of MOTORMEM task %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron
%
% This script performs preprocessing of the MOTORMEM fMRI dataset in SPM12.
% It is designed for multi-run functional data and processes each participant
% from raw BIDS-like inputs to normalized and smoothed functional images.
%
% The preprocessing workflow includes:
%   1. Defacing of the anatomical T1 image
%   2. Resetting image origins
%   3. Fieldmap-based VDM calculation
%   4. Realignment and unwarping of functional runs
%   5. Coregistration of functional to anatomical images
%   6. Segmentation of the anatomical image
%   7. Normalization of anatomical and functional images to MNI space
%   8. Smoothing of normalized functional images
%
% The script assumes that, for each participant, anatomical, functional, and
% fieldmap files are organized in BIDS-like subfolders ('anat', 'func', 'fmap'),
% and that functional runs are named according to the entries listed in 'bolds'.
%
% Some preprocessing steps depend on outputs from earlier steps and therefore
% must be run in chronological order.


clear
clc
cfg = project_config();

addpath(cfg.toolboxes_root);

sub_list = cfg.subjects;

% Acquisition parameters used for preprocessing.
TR = cfg.TR;
nb_slices = 65;

for i=1:length(sub_list)

    subject_id = sub_list{1,i};
   
    blipdir  = -1;
    % some participants had missing runs are missing the localisers runs
     if strcmp(subject_id, 'sub-28')
        bolds = {'reliv_run-01', 'reliv_run-02', 'rest'};
    elseif strcmp(subject_id, 'sub-35')
        bolds = {'reliv_run-01', 'reliv_run-02', 'rest'};
    elseif strcmp(subject_id, 'sub-36')
        bolds = {'reliv_run-01', 'reliv_run-02', 'rest'};
    else
        bolds = {'reliv_run-01', 'reliv_run-02', 'pedalmem', 'footloc', 'thumbloc', 'rest'};
     end
  
	    
    %% Set up subject-specific paths and preprocessing folders %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    path_of_sub_raw = fullfile(cfg.data_root, subject_id);
    path_of_sub_derivatives = fullfile(cfg.preproc_root, subject_id);
    path_to_fmap = fullfile(path_of_sub_derivatives, 'fmap');
    path_to_func = fullfile(path_of_sub_derivatives, 'func');
    path_to_anat = fullfile(path_of_sub_derivatives, 'anat');

    % Uncompress raw NIfTI files before copying them to the derivatives folder.
    cd (fullfile(path_to_raw, 'func'))
    gunzip('*.gz')
    cd (fullfile(path_to_raw, 'anat'))
    gunzip('*.gz')
    cd (fullfile(path_to_raw, 'fmap'))
    gunzip('*.gz')

    cd(cfg.preproc_root)
    mkdir (subject_id)
    cd (subject_id)
    mkdir func
    mkdir anat
    mkdir fmap

   
    %% DEFACE T1 %%
    % Deface the anatomical scan before copying it to the derivatives folder

    matlabbatch{1}.spm.util.deface.images = cellstr(spm_select('FPList',fullfile(path_of_sub_raw, 'anat'),'^sub.*.nii$'));
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
    % file management
    % delete original file with the face still intact
    delete (spm_select('FPList',fullfile(path_of_sub_raw, 'anat'),'^sub.*.nii$'));
    % rename anonimized file
    fname=spm_select('FPList',fullfile(path_of_sub_raw, 'anat'),'^anon.*.nii$');
    newname= regexprep(fname,'anon_','');
    movefile (fname,newname);

    copyfile(fullfile(path_of_sub_raw, 'func'), path_to_func)
    copyfile(fullfile(path_of_sub_raw, 'anat'), path_to_anat)
    copyfile(fullfile(path_of_sub_raw, 'fmap'), path_to_fmap)
    
    cd func
    delete *.gz


    %% RESET ORIGIN %%
    % Reset image origins to the center before spatial preprocessing to facilitate alignment steps
    
   
    cd(path_to_func);  
      
    for task=1:length(bolds)
    
        [P,sts] = spm_select('List',path_to_func,[subject_id '_task-' bolds{task} '.*\.nii$']);
        if ~sts, return; else P = cellstr(P); end
        spm_progress_bar('Init',numel(P),'Resetting orientations',...
            'Images Complete');
        for i=1:numel(P)
            V    = spm_vol(P{i});
            M    = V.mat;
            vox  = sqrt(sum(M(1:3,1:3).^2));
            if det(M(1:3,1:3))<0, vox(1) = -vox(1); end
            dim = V.dim;
            orig = (dim(1:3)+1)/2;
            off  = -vox.*orig;
            M    = [vox(1) 0      0      off(1)
                0      vox(2) 0      off(2)
                0      0      vox(3) off(3)
                0      0      0      1];
            spm_get_space(P{i},M);
            spm_progress_bar('Set',i);
        end
        spm_progress_bar('Clear');
    
    end


    %% Calculate VDM %%
    % Compute voxel displacement maps (VDMs) from the fieldmap images for each
    % functional run. These VDMs are then used during realign-and-unwarp.    

    clear matlabbatch 
    
    if strcmp(subject_id, 'sub-20')
         fieldmap_phase = fullfile(path_to_fmap, subject_id, '_run-01_phasediff.nii');
        fieldmap_mag = fullfile(path_to_fmap, subject_id, '_run-01_magnitude1.nii');
    else
        fieldmap_phase = fullfile(path_to_fmap, subject_id, '_phasediff.nii');
        fieldmap_mag = fullfile(path_to_fmap, subject_id, '_magnitude1.nii');
    end
    for task=1:length(bolds)
        func_files_raw{task}=  spm_select('FPlist', path_to_func, [subject_id '_task-' bolds{task} '.*\.nii$']);
    end

    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = {[fieldmap_phase ',1']};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {[fieldmap_mag ',1']};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = [4.92 7.38];
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 1;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = blipdir;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 68.8196;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = fullfile(cfg.toolboxes_root, 'spm1/toolbox/FieldMap/T1.nii');
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;
    for task=1:length(bolds)
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session(task).epi = {[func_files_raw{task} ',1']};
    end
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
    
    spm_jobman('run', matlabbatch);
    
    clear fieldmap_mag fieldmap_phase func_files_raw matlabbatch


    %% Segment anatomical scans in different tissue types %%
    % Segment the T1-weighted anatomical scan into tissue classes and estimate
    % the deformation field used for normalization to MNI space.    
 
    clear matlabbatch 
    
    anat_vol_raw = spm_select('FPlist', path_to_anat, ['^' subject_id '.*\.nii$']);
    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = {[anat_vol_raw ',1']};
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = fullfile(cfg.toolboxes_root, 'spm12/tpm/enhanced_TPM.nii,1');
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = fullfile(cfg.toolboxes_root, 'spm12/tpm/enhanced_TPM.nii,2');
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = fullfile(cfg.toolboxes_root, 'spm12/tpm/enhanced_TPM.nii,3');
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = fullfile(cfg.toolboxes_root, '/spm12/tpm/enhanced_TPM.nii,4');
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = fullfile(cfg.toolboxes_root, 'spm12/tpm/enhanced_TPM.nii,5');
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = fullfile(cfg.toolboxes_root, 'spm12/tpm/enhanced_TPM.nii,6');
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
    
    spm_jobman('run', matlabbatch);
    
    clear anat_vol_raw matlabbatch

    %% Normalise to standard space %%
    % Normalize anatomical image and tissue type masks to standard space
    
    clear matlabbatch 
    
    def_field = spm_select('FPlist', path_to_anat, '^y_sub.*\.nii$');
    c1_mask = spm_select('FPlist', path_to_anat, '^c1s.*\.nii$');
    c2_mask = spm_select('FPlist', path_to_anat, '^c2s.*\.nii$');
    c3_mask = spm_select('FPlist', path_to_anat, '^c3s.*\.nii$');
    c4_mask = spm_select('FPlist', path_to_anat, '^c4s.*\.nii$');
    c5_mask = spm_select('FPlist', path_to_anat, '^c5s.*\.nii$');
    anat_vol_raw = spm_select('FPlist', path_to_anat, ['^' subject_id '_T1w.*\.nii$']);
    
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = {def_field};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {[c1_mask ',1']; [c2_mask ',1']; [c3_mask ',1']; [c4_mask ',1']; [c5_mask ',1']; [anat_vol_raw ',1']};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    spm_jobman('run', matlabbatch);
    
    clear def_field c1_rmask matlabbatch


    %% For each run %
    %%%%%%%%%%%%%%%%%
        
    for task=1:length(bolds)

        % Realign & Unwarp %
        %%%%%%%%%%%%%%%%%%%%
        
        clear matlabbatch 
    
        func_files_raw=  spm_select('FPlist', path_to_func, ['^' subject_id '_task-' bolds{task} '.*\.nii']);
        func_files_vdm=  spm_select('FPlist', path_to_fmap, strcat(sprintf('^vdm.*session%d', task)), '.*\.nii$');    
        
        matlabbatch{1}.spm.spatial.realignunwarp.data.scans = spm_file(cellstr(spm_select('expand', fullfile(func_files_raw))));
        matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan = {func_files_vdm};
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = '';
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = [];
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        
        spm_jobman('run', matlabbatch);
        
        clear func_files_vdm func_files_raw  matlabbatch 
       
    
        % Coregister functional to anatomical volumes %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Coregister mean functional image to the anatomical scan and apply the same
        % transformation to all unwarped functional volumes from the run.    
       
        clear matlabbatch 
        
        mean_bold = spm_select('FPlist', path_to_func, ['^meanu' subject_id '_task-' bolds{task} '.*\.nii']);
        anat_vol_raw = spm_select('FPlist', path_to_anat, ['^' subject_id '_T1w.*\.nii$']);
        func_files_u=  spm_select('FPlist', path_to_func,['^u' subject_id '_task-' bolds{task} '.*\.nii']);
        
        matlabbatch{1}.spm.spatial.coreg.estimate.ref = {[anat_vol_raw ',1']};
        matlabbatch{1}.spm.spatial.coreg.estimate.source = {mean_bold};
        matlabbatch{1}.spm.spatial.coreg.estimate.other = spm_file(cellstr(spm_select('expand', fullfile(func_files_u))));
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
     
        spm_jobman('run', matlabbatch);
        
        clear mean_bold anat_vol_raw matlabbatch
    
    
        % Normalise functional volumes to standard space %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
        % Apply the anatomical deformation field to the unwarped functional images
        % to bring them into MNI space.

        clear matlabbatch 
        
        def_field = spm_select('FPlist', path_to_anat, '^y_sub.*\.nii$');
        func_files_u=  spm_select('FPlist', path_to_func, ['^u' subject_id '_task-' bolds{task} '.*\.nii']);
    
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = {def_field};
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = spm_file(cellstr(spm_select('expand', fullfile(func_files_u)))); 
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                                  78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        spm_jobman('run', matlabbatch);
    
        clear def_field func_files_au volumes all_in_one_func_files_u matlabbatch
    
    
        % Smooth functional volumes %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
        clear matlabbatch
        
        func_files_wu=  spm_select('FPlist', path_to_func, ['^wu' subject_id '_task-' bolds{task} '.*\.nii']);
        
        matlabbatch{1}.spm.spatial.smooth.data = spm_file(cellstr(spm_select('expand', fullfile(func_files_wu))));
        matlabbatch{1}.spm.spatial.smooth.fwhm = [4 4 4];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        
        spm_jobman('run', matlabbatch);
        
        clear all_in_one_func_files_wu matlabbatch
    end 


end