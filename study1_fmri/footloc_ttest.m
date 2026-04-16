%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mean activity during reliving in Foot Localizer mask %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron

% This script extracts the mean contrast estimate within 
% a the foot localiser mask for foot and no foot trials 
% for each participant and performs a t-test pm these values.

clear
clc
cfg = project_config();

sub_list = cfg.subjects;
addpath(cfg.code_root);
addpath(cfg.toolboxes_root);

% Choose analysis window:
% 'whole', '1sthalf', or '2ndhalf'
windowOfInterest = 'whole';

%% Define folder and contrasts depending on window of interest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch lower(windowOfInterest)
    case 'whole'
        reliving_root = cfg.firstlevel_reliving_whole_root;
        con_foot_name = 'con_0003.nii';
        con_nofoot_name = 'con_0004.nii';

    case '1sthalf'
        reliving_root = cfg.firstlevel_reliving_half_root;
        con_foot_name = 'con_0001.nii';   % first half foot
        con_nofoot_name = 'con_0003.nii'; % first half nofoot

    case '2ndhalf'
        reliving_root = cfg.firstlevel_reliving_half_root;
        con_foot_name = 'con_0002.nii';   % second half foot
        con_nofoot_name = 'con_0004.nii'; % second half nofoot

    otherwise
        error('Unknown windowOfInterest: %s. Use ''whole'', ''1sthalf'', or ''2ndhalf''.', windowOfInterest);
end

%% Extract mean activity within footlocalizer ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

left_foot_val = nan(length(sub_list),1);
left_nofoot_val = nan(length(sub_list),1);
right_foot_val = nan(length(sub_list),1);
right_nofoot_val = nan(length(sub_list),1);

for i = 1:length(sub_list)
    subject_id = sub_list{1,i};

    % Localizer ROI paths
    path_to_sub_foot_folder = fullfile(cfg.firstlevel_localiser_root, subject_id);
    leftROI  = spm_select('FPlist', path_to_sub_foot_folder, 'left_footloc_fixed_200vox_noverlap.nii');
    rightROI = spm_select('FPlist', path_to_sub_foot_folder, 'right_footloc_fixed_200vox_noverlap.nii');

    % Reliving contrast paths based on selected window
    path_to_sub_FR_folder = fullfile(reliving_root, subject_id);
    Contrast_foot   = spm_select('FPlist', path_to_sub_FR_folder, con_foot_name);
    Contrast_nofoot = spm_select('FPlist', path_to_sub_FR_folder, con_nofoot_name);

    % Extract mean values
    left_foot_val(i)    = Extract_ROI_Data(leftROI, Contrast_foot);
    left_nofoot_val(i)  = Extract_ROI_Data(leftROI, Contrast_nofoot);
    right_foot_val(i)   = Extract_ROI_Data(rightROI, Contrast_foot);
    right_nofoot_val(i) = Extract_ROI_Data(rightROI, Contrast_nofoot);
end

%% T-test
%%%%%%%%%%%%

[ttest_left_fotonofoot, pleft, cileft, statsleft] = ttest(left_foot_val, left_nofoot_val);
[ttest_right_fotonofoot, pright, ciright, statsright] = ttest(right_foot_val, right_nofoot_val);

t_value_left = statsleft.tstat;
df_left = statsleft.df;

t_value_right = statsright.tstat;
df_right = statsright.df;

%% Save results
%%%%%%%%%%%%%%%%

filename = 'ttest_results_loc_test.csv';

if ~isfile(filename)
    fileID = fopen(filename, 'w');
    fprintf(fileID, 'Degrees of Freedom,T-Value,P-Value,Window of Interest,Localizer\n');
else
    fileID = fopen(filename, 'a');
end

fprintf(fileID, '%d,%.4f,%.4f,%s,%s\n', df_left, t_value_left, pleft, windowOfInterest, 'left_hemi');
fprintf(fileID, '%d,%.4f,%.4f,%s,%s\n', df_right, t_value_right, pright, windowOfInterest, 'right_hemi');

fclose(fileID);