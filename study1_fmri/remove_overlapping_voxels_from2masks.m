%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove overlapping voxels between two ROI masks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron
%
% This function removes overlapping voxels between two binary ROI masks
% (typically left and right hemisphere masks) for a given participant.
%
% Using SPM's imcalc, it creates two new masks in which any voxel present
% in both input masks is removed, ensuring non-overlapping ROIs.
%
function remove_overlapping_voxels_from2masks(output_dir, leftROI, rightROI)

    % Check existence
    if ~exist(leftROI, 'file')
        return;
    end
    if ~exist(rightROI, 'file')
        return;
    end
    % Derive output filenames by appending “_noverlap”
    [~, leftBase, leftExt] = fileparts(leftROI);
    leftNoOverlapName = [leftBase, '_noverlap', leftExt];
    [~, rightBase, rightExt] = fileparts(rightROI);
    rightNoOverlapName = [rightBase, '_noverlap', rightExt];

    % 1) Create the left no-overlap mask: i1 .* (i2==0)
    matlabbatch = [];
    matlabbatch{1}.spm.util.imcalc.input = {leftROI; rightROI};
    matlabbatch{1}.spm.util.imcalc.output = leftNoOverlapName;
    matlabbatch{1}.spm.util.imcalc.outdir = {output_dir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1.*(i2==0)';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;  % int16
    spm_jobman('run', matlabbatch);

    % 2) Create the right no-overlap mask: i1 .* (i2==0)
    matlabbatch = [];
    matlabbatch{1}.spm.util.imcalc.input = {rightROI; leftROI};
    matlabbatch{1}.spm.util.imcalc.output = rightNoOverlapName;
    matlabbatch{1}.spm.util.imcalc.outdir = {output_dir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1.*(i2==0)';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    spm_jobman('run', matlabbatch);
end