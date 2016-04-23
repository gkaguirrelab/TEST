function create_functional_script(session_dir,subject_name,outDir,job_name,numRuns,filtType,lowHz,highHz,physio,motion,task,localWM,anat)

% Writes shell script to preprocess functional MRI data 
%
%   Usage:
%   create_functional_script(session_dir,subject_name,outDir,job_name,numRuns,filtType,lowHz,highHz,physio,motion,task,localWM,anat)
%
%   Written by Andrew S Bock Nov 2015

%% Create job script
for rr = 1:numRuns
    if rr < 10
        runtext = ['0' num2str(rr)];
    else
        runtext = num2str(rr);
    end
    fname = fullfile(outDir,[job_name '_functional_' runtext '.sh']);
    fid = fopen(fname,'w');
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,['SESS=' session_dir '\n']);
    fprintf(fid,['SUBJ=' subject_name '\n\n']);
    fprintf(fid,['runNum=' num2str(rr) '\n\n']);
    func = 'rf';
    if ~localWM
        matlab_string = ([...
            '"register_func(''$SESS'',''$SUBJ'',$runNum,1,''' func ''');' ...
            'project_anat2func(''$SESS'',$runNum,''' func ''');' ...
            'create_regressors(''$SESS'',$runNum,''' func ''',''detrend'',' ...
            num2str(lowHz) ',' num2str(highHz) ',' num2str(physio) ',' ...
            num2str(motion) ',' num2str(anat) ');' ...
            'remove_noise(''$SESS'',$runNum,''' func ''',' ...
            num2str(task) ',' num2str(anat) ',' num2str(motion) ',' ...
             num2str(physio) ');' ...
            'temporal_filter(''$SESS'',$runNum,''d' func ''',''' filtType ''',' ...
            num2str(lowHz) ',' num2str(highHz) ');' ...
            'smooth_vol_surf(''$SESS'',$runNum,5,''d' func '.tf'');"']);
    else
        matlab_string = ([...
            '"register_func(''$SESS'',''$SUBJ'',$runNum,1,''' func ''');' ...
            'project_anat2func(''$SESS'',$runNum,''' func ''');' ...
            'create_regressors(''$SESS'',$runNum,''' func ''',''detrend'',' ...
            num2str(lowHz) ',' num2str(highHz) ',' num2str(physio) ',' ...
            num2str(motion) ',' num2str(anat) ');' ...
            'remove_noise(''$SESS'',$runNum,''' func ''',' ...
            num2str(task) ',' num2str(anat) ',' num2str(motion) ',' ...
            num2str(physio) ');' ...
            'remove_localWM(''$SESS'',$runNum,''d' func ''');' ...
            'temporal_filter(''$SESS'',$runNum,''wd' func ''',''' filtType ''',' ...
            num2str(lowHz) ',' num2str(highHz) ');' ...
            'smooth_vol_surf(''$SESS'',$runNum,5,''wd' func '.tf'');"']);
    end
    fprintf(fid,['matlab -nodisplay -nosplash -r ' matlab_string]);
    fclose(fid);
end