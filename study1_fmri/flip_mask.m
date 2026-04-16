function flip_mask(roiPath, outputDir, outputFileName)
% FLIP_MASK  Flips a NIfTI image along the x-axis and saves the result.

    % Load the binary mask (or any NIfTI image)
    V = spm_vol(roiPath);
    roiMaskData = spm_read_vols(V);

    % Flip the image data along the x-axis
    flipped_mask_data = flip(roiMaskData, 1);

    % Set the output file path for the flipped mask
    V.fname = fullfile(outputDir, outputFileName);

    % Write the flipped mask data to a new file
    spm_write_vol(V, flipped_mask_data);

    disp(['Flipped mask saved as ', V.fname]);
end
