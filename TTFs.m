function TTFs(folder)

TTFsDir = fileparts(mfilename('fullpath')); % path to this script
tpmsPath = [TTFsDir filesep 'tpms']; % path to tissue TPMs
elecSeeds = [tpmsPath filesep 'TTF.nii']; % TTField transducer seed coordinates

% Use built in SPM navigator to find the target files
if ~exist('folder','var') || isempty(folder)
    % Use built in SPM navigator to find the target files
    folder = uigetdir('', 'Select DICOM directory');
    disp(folder);
end
cd(folder);

all_files = dir(folder);
selected_images = {all_files.name};
selected_images = selected_images(:);
selected_images = selected_images(~strcmp(selected_images, '.'));
selected_images = selected_images(~strcmp(selected_images, '..'));
selected_images = char(selected_images);

% Converts the DICOM images to img/hdr format
img_Path = DICOMConvert(selected_images);

% Coregister the padded image to a template
img_Info = spmCoregistration(img_Path);

disp(tpmsPath);
% Segments the image using nii_for_seg.img in last step
spmSegment(tpmsPath, 'nii_for_seg.img');

% Applies a modified binary mask generation workflow 
postSegment(img_Loc);

% Generates and places electrodes on the surface of the scalp
electrodeGeneration('mask_scalp.img', elecSeeds, 'iy_nii_for_seg.nii');

% Generates a python script for ScanIP import and smoothing
% if uncommented, this would generate a python script that will
% automated mask import and postprocessing in ScanIP

pyScanIPScript(img_Info, img_Loc);


% Optional step for bat script generation/automated ScanIP import
% useful for Windows if using ScanIP. Generates a batch script for
% and calls it to initiate ScanIP and the import script in the last
% step

ScanIP_Loc = 'E:\Program Files\Simpleware\ScanIP';
batScript(img_Loc, ScanIP_Loc);

end