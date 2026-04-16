function create_fixed_size_footloc_mask(spmT_path, m1_mask_path, num_voxels_to_keep, output_path)
% create_fixed_size_footloc_mask
% 
% This function picks the top N active voxels (by T-value) within an M1 mask
% from a movement-rest T-map, ensuring a fixed ROI size. 
%
% Inputs:
%   spmT_path          - path to the subject's T-map (e.g. 'spmT_0001.nii')
%   m1_mask_path       - path to the M1 mask (e.g. 'M1_mask.nii')
%   num_voxels_to_keep - number of voxels to keep in the final ROI
%   output_path        - where to save the final binary mask (e.g. 'fixed_mask.nii')
%
% Example usage:
%   create_fixed_size_footloc_mask('locT_0001.nii','M1_mask.nii',100,'footloc_fixed_100vox.nii')

    % Load T-map
    Vt = spm_vol(spmT_path);
    Tmap = spm_read_vols(Vt);

    % Load M1 mask
    Vm = spm_vol(m1_mask_path);
    Mask = spm_read_vols(Vm);

    % Ensure Tmap and Mask are same dimensions
    if any(Vt.dim ~= Vm.dim)
        error('T-map and M1 mask must have the same dimensions. Consider reslicing.');
    end

    % Extract T-values only within the M1 mask
    mask_idx = find(Mask > 0);
    T_in_mask = Tmap(mask_idx);

    % Sort T-values in descending order
    [sorted_vals, sorted_idx] = sort(T_in_mask, 'descend');

    % How many voxels are available?
    total_vox = numel(sorted_vals);

    % If we have fewer voxels than num_voxels_to_keep, keep them all
    if total_vox < num_voxels_to_keep
        warning('M1 mask has only %d voxels, less than %d. Keeping all available voxels.', ...
                 total_vox, num_voxels_to_keep);
        num_voxels_to_keep = total_vox;
    end

    % Select the top N voxels
    top_voxel_indices = sorted_idx(1:num_voxels_to_keep);

    % Create a new binary mask (same dimensions as Tmap)
    fixed_mask = zeros(Vt.dim);

    % Fill the chosen voxel locations with 1
    fixed_mask(mask_idx(top_voxel_indices)) = 1;

    % Write out the new mask
    Vout = Vm;  % copy header from the M1 mask
    Vout.fname = output_path;
    spm_write_vol(Vout, fixed_mask);

    fprintf('Fixed-size footloc mask saved as: %s\n', output_path);
end