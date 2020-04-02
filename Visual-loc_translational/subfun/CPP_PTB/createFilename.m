function expParameters = createFilename(expParameters, cfg)

zeroPadding = 3;

pattern = ['%0' num2str(zeroPadding) '.0f'];

% sub-<label>[_ses-<label>]_task-<task_label>[_run-<index>]_ieeg.json
% sub-<label>[_ses-<label>]_task-<label>[_run-<index>]_eeg.<manufacturer_specific_extension>

% sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_ce-<label>][_dir-<label>][_rec-<label>][_run-<index>][_echo-<index>]_<contrast_label>.nii[.gz]

% sub-<participant_label>[_ses-<label>][_acq-<label>]_task-<task_label>_eyetrack.<manufacturer_specific_extension>

% MATCHES_events.tsv

subjectNb = expParameters.subjectNb;
sessionNb = expParameters.sessionNb;
runNb = expParameters.runNb;

dateFormat = 'yyyymmdd_HHMM';
expParameters.date = datestr(now, dateFormat);

% output dir
expParameters.outputDir = fullfile (...
    expParameters.dataDir, ...
    'source', ...
    ['sub-' sprintf(pattern, subjectNb)], ...
    ['ses-', sprintf(pattern, sessionNb)]);

% create base filename
expParameters.fileName.base = ...
    ['sub-', sprintf(pattern, subjectNb), ...
    '_ses-', sprintf(pattern, sessionNb) , ...
    '_task-', expParameters.task];

runSuffix = ['_run-' sprintf(pattern, runNb)];


switch cfg.device
    case 'PC'
        modality = 'beh';
    case 'scanner'
        modality = 'func';
    otherwise
        modality = 'beh';
end

expParameters.modality = modality;


% set values for the suffixes for the different fields in the BIDS
% name
fields2Check = { ...
    'ce', ...
    'dir', ...  % For BIDS file naming: phase encoding direction of acquisition for fMRI
    'rec', ...  % For BIDS file naming: reconstruction of fMRI images
    'echo', ... % For BIDS file naming: echo fMRI images
    'acq'       % For BIDS file naming: acquisition of fMRI images
    };

for iField = 1:numel(fields2Check)
    if isempty (getfield(expParameters, fields2Check{iField}) ) %#ok<*GFLD>
        expParameters = setfield(expParameters, [fields2Check{iField} 'Suffix'], ...
            []); %#ok<*SFLD>
    else
        expParameters = setfield(expParameters, [fields2Check{iField} 'Suffix'], ...
            ['_' fields2Check{iField} '-' getfield(expParameters, fields2Check{iField})]);
    end
end


%% create directories
[~, ~, ~] = mkdir(expParameters.dataDir);
[~, ~, ~] = mkdir(fullfile(expParameters.outputDir, modality));

if cfg.eyeTracker
    [~, ~, ~] = mkdir(fullfile(expParameters.outputDir, 'eyetracker'));
end



%% create filenames

switch modality
    
    case 'beh'
        
        expParameters.fileName.events = ...
            [expParameters.fileName.base, runSuffix, '_events_date-' expParameters.date '.tsv'];
        
    case 'func'
        
        expParameters.fileName.events = ...
            [expParameters.fileName.base, ...
            expParameters.acqSuffix, expParameters.ceSuffix, ...
            expParameters.dirSuffix, expParameters.recSuffix, ...
            runSuffix, expParameters.echoSuffix, ...
            '_events_date-' expParameters.date '.tsv'];
        
end

if cfg.eyeTracker
    
    expParameters.fileName.eyetracker = ...
        [expParameters.fileName.base, expParameters.acqSuffix, runSuffix, '_eyetrack_date-' expParameters.date '.edf'];
    
end




end