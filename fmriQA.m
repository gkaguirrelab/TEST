

% Required inputs:
%       params.sessionDir       - '/path/to/sessionDir'
%       params.runNum           - scalar value indicating run number

%% Set defaults
preName                 = 'rf.nii.gz';
postName                = 'wdrf.tf.nii.gz';
%% Get bold runs
b                       = find_bold(params.sessionDir);
%% Get the regressors
anat_noise              = load(fullfile(params.sessionDir,b{params.runNum},'anat_params.txt'));
motion_noise            = load(fullfile(params.sessionDir,b{params.runNum},'rf.nii.gz_rel.rms'));
motion_noise            = [0;motion_noise];
physio_noise            = load(fullfile(params.sessionDir,b{params.runNum},'puls.mat'));
for i = 1:length(physio_noise.dicom.AT)
    [~,pulseIdx(i)]     = min(abs(physio_noise.dicom.AT(i) - physio_noise.pulse.AT_ms));
end
physio_noise            = physio_noise.pulse.data(pulseIdx);
%% Load ROI volumes
brain                   = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.brain.nii.gz'));
gm                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.gm.nii.gz'));
%wm                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.wm.nii.gz'));
%lv                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.lh_ventricle.nii.gz'));
%rv                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.rh_ventricle.nii.gz'));
%tv                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.third_ventricle.nii.gz'));
%fv                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.fourth_ventricle.nii.gz'));
%bs                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.brainstem.nii.gz'));
%un                      = load_nifti(fullfile(params.sessionDir,b{params.runNum},'func.aseg.unknown.nii.gz'));
%% Load fMRI volumes
pre                     = load_nifti(fullfile(params.sessionDir,b{params.runNum},preName));
preDims                 = size(pre.vol);
preTC                   = reshape(pre.vol,preDims(1)*preDims(2)*preDims(3),preDims(4));
preTC(brain.vol~=1,:)   = 0;
meanPre                 = mean(preTC,2);
preTC                   = detrend(preTC) + repmat(meanPre,1,size(preTC,2));
preTC                   = convert_to_psc(preTC);
post                    = load_nifti(fullfile(params.sessionDir,b{params.runNum},postName));
postDims                = size(post.vol);
postTC                  = reshape(post.vol,postDims(1)*postDims(2)*postDims(3),postDims(4));
postTC(brain.vol~=1,:)  = 0;
meanPost                = mean(postTC,2);
postTC                  = detrend(postTC) + repmat(meanPost,1,size(postTC,2));
postTC                  = convert_to_psc(postTC);
%% Pull out the time-series data
gmInd                   = gm.vol==1;
nongmInd                = gm.vol~=1 & brain.vol==1;
preGM                   = preTC(gmInd,:);
preWM                   = preTC(nongmInd,:);
postGM                  = postTC(gmInd,:);
postWM                  = postTC(nongmInd,:);
%% Plot the data
fullFigure;
% Relative head motion
subplot(8,1,1);
plot(motion_noise);
xlim([1 size(motion_noise,1)]);
ylabel('Head motion (mm)','FontSize',15);
title(b{params.runNum},'FontSize',20,'interpreter','none');
% Pulse Ox
subplot(8,1,2);
plot(physio_noise);
xlim([1 size(physio_noise,1)]);
ylabel('Pulse Ox','FontSize',15);
% pre-denoised
subplot(8,1,3:5);
imagesc([preGM;preWM],[-5 5]);
% h = colorbar('NorthOutside');
% ylabel(h,'Percent signal change','FontSize',15);
colormap(gray);
hold on;
plot(1:size(preGM,2),size(preGM,1)*ones(1,size(preGM,2)),'g','LineWidth',5);
ylabel('Pre-denoising','FontSize',20);
set(gca,'YTickLabel','');
yyaxis right
ylabel('GM / non-GM','FontSize',20,'Color','k','rot',-90,'Position',[430,0.5]);
set(gca,'YTickLabel','','YTick',[],'ycolor','k');
% post-denoised
subplot(8,1,6:8);
imagesc([postGM;postWM],[-5 5]);
colormap(gray);
hold on;
plot(1:size(postGM,2),size(postGM,1)*ones(1,size(postGM,2)),'g','LineWidth',5);
ylabel('Post-denoising','FontSize',20);
set(gca,'YTickLabel','');
yyaxis right
ylabel('GM / non-GM','FontSize',20,'Color','k','rot',-90,'Position',[430,0.5]);
set(gca,'YTickLabel','','YTick',[],'ycolor','k');
xlabel('TR','FontSize',20);