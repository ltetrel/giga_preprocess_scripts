clear
addpath('/files')

opt_grab.batch = '3'

path_out  =  ['ukbb_func_preprocess_output_batch' opt_grab.batch]
path_input = ['/project/rrg-jacquese/All_user_common_folder/RAW_DATA/UKBIOBANK-DATA/UKBIOBANK_IMAGING/UKB_MRI_unzip/UKB_unzip_Oct2018']


%% General
opt.size_output = 'quality_control'; % The amount of outputs that are generated by the pipeline. 'all' will keep intermediate outputs, 'quality_control' will only keep the quality control outputs. 
opt.slice_timing.flag_skip        = 1;% Skip the slice timing (0: don't skip, 1 : skip). Note that only the slice timing corretion portion is skipped, not all other effects such as FLAG_CENTER or FLAG_NU_CORRECT

%% Motion estimation (niak_pipeline_motion)
%opt.motion.session_ref  = 'BL00';

%% resampling in stereotaxic space
opt.resample_vol.interpolation = 'trilinear'; % The resampling scheme. The fastest and most robust method is trilinear. 
opt.resample_vol.voxel_size    = [3 3 3];     % The voxel size to use in the stereotaxic space
opt.resample_vol.flag_skip     = 0;           % Skip resampling (data will stay in native functional space after slice timing/motion correction) (0: don't skip, 1 : skip)

%% Linear and non-linear fit of the anatomical image in the stereotaxic
% space (niak_brick_t1_preprocess)
opt.t1_preprocess.nu_correct.arg = '-distance 75'; % Parameter for non-uniformity correction. 200 is a suggested value for 1.5T images, 75 for 3T images. If you find that this stage did not work well, this parameter is usually critical to improve the results.

%% Temporal filtering (niak_brick_time_filter)
opt.time_filter.hp = 0.01; % Cut-off frequency for high-pass filtering, or removal of low frequencies (in Hz). A cut-off of -Inf will result in no high-pass filtering.
opt.time_filter.lp = Inf;  % Cut-off frequency for low-pass filtering, or removal of high frequencies (in Hz). A cut-off of Inf will result in no low-pass filtering.

%% Regression of confounds and scrubbing (niak_brick_regress_confounds)
opt.regress_confounds.flag_wm = true;            % Turn on/off the regression of the average white matter signal (true: apply / false : don't apply)
opt.regress_confounds.flag_vent = true;          % Turn on/off the regression of the average of the ventricles (true: apply / false : don't apply)
opt.regress_confounds.flag_motion_params = true; % Turn on/off the regression of the motion parameters (true: apply / false : don't apply)
opt.regress_confounds.flag_gsc = false;          % Turn on/off the regression of the PCA-based estimation of the global signal (true: apply / false : don't apply)
opt.regress_confounds.flag_scrubbing = true;     % Turn on/off the scrubbing of time frames with excessive motion (true: apply / false : don't apply)
opt.regress_confounds.thre_fd = 0.5;             % The threshold on frame displacement that is used to determine frames with excessive motion in the scrubbing procedure

%% Spatial smoothing (niak_brick_smooth_vol)
opt.smooth_vol.fwhm      = 6;  % Full-width at maximum (FWHM) of the Gaussian blurring kernel, in mm.
opt.smooth_vol.flag_skip = 0;  % Skip spatial smoothing (0: don't skip, 1 : skip)



files_in = ukbb_grabber(path_input,opt_grab);
%disp(files_in)

failed_three_slice_timing= {'sub3332586','sub3368279','sub3390247','sub3403805','sub3430678','sub3529556','sub3732704'}
tilted_three = {'sub3217315','sub3798980'}



files_in = rmfield(files_in,failed_three_slice_timing)
files_in = rmfield(files_in,tilted_three)

%didnt work
%opt.tune(1).subject = 'sub3217315';
%opt.tune(1).param.t1_preprocess.crop_neck = 0.3;

%tilted
files_in =  rmfield(files_in,'sub3292504')
%tilted
files_in =  rmfield(files_in,'sub3355727')
%tilted
files_in =  rmfield(files_in,'sub3417419')


%didnt work
%opt.tune(2).subject = 'sub3798980';
%opt.tune(2).param.t1_preprocess.crop_neck = 0.3;


%didnt work
opt.tune(1).subject = 'sub3963227';
opt.tune(1).param.t1_preprocess.crop_neck = 0.3;

opt.tune(2).subject = 'sub3975560';
opt.tune(2).param.t1_preprocess.crop_neck = 0.1;


opt.psom.max_queued = 32;
opt.flag_verbose = 0;


opt.psom.qsub_options ='--mem=8000M --account def-pbellec --time=00-48:00  --ntasks=1 --cpus-per-task=2'
opt.folder_out = path_out;
[pipeline,opt_pipe] = niak_pipeline_fmri_preprocess(files_in,opt);

