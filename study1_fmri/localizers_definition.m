%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define M1 foot masks, based on localizer run %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron

% This script defines the foot localizer ROI masks.
% It first defines the left M1 foot mask based on the localizer 
% runs, during which participans were alternating between right 
% foot movement and rest. From the move-rest contrast it selects 
% the 200 most active voxels within left M1 and creates a mask.
% It then projects that mask onto the contralateral hemisphere 
% and remove overlapping voxels.

clear
clc
cfg = project_config();

sub_list = cfg.subjects;
data_dir = cfg.firstlevel_localiser_root;
mask_path = fullfile(cfg.masks_root, 'leftM1.nii');  % Anatomical M1 mask

voxelskept=200;
leftROIname = 'left_footloc_fixed_200vox.nii';
rightROIname = 'right_footloc_fixed_200vox.nii';


%% Define left M1 foot localiser mask
for iSubj = 1:length(sub_list)
    subject = sub_list{iSubj};
    disp([">>>>>> Processing Subject  " subject])
    tmap = fullfile(data_dir, subject, 'spmT_0001.nii');  % move-rest contrast of right foot movement : left M1 foot region
    output_dir = fullfile(data_dir, subject, leftROIname);  

    create_fixed_size_footloc_mask(tmap, mask_path, voxelskept, output_dir);
end

%% Project that mask onto right hemisphere
for iSubj = 1:length(sub_list)
    subject = sub_list{iSubj};
    disp([">>>>>> Processing Subject  " subject])
    input_mask = fullfile(data_dir, subject, leftROIname);  % take left M1 mask as input
    output_dir = fullfile(data_dir, subject);  

    flip_mask(input_mask, output_dir, rightROIname); % project onto right hemi
end


%% Remove overlapping voxels between right and left M1 masks
for iSubj = 1:length(sub_list)
    subject = sub_list{iSubj};
    disp([">>>>>> Processing Subject  " subject])
    leftROI = fullfile(data_dir, subject, leftROIname);
    rightROI = fullfile(data_dir, subject, rightROIname);
    output_dir = fullfile(data_dir, subject);  

    remove_overlapping_voxels_from2masks(output_dir, leftROI, rightROI); 
end
