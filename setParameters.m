% (C) Copyright 2020 CPP visual motion localizer developpers
%adapted by me Iqra 

function [cfg] = setParameters()

    % VISUAL LOCALIZER

    % Initialize the parameters and general configuration variables
    cfg = struct();
    
    cfg.subject.askGrpSess = [false true];% this stops the GUI input for subject group. comment it if you want to ask for subject group
    % by default the data will be stored in an output folder created where the
    % setParamters.m file is
    % change that if you want the data to be saved somewhere else
    cfg.dir.output = fullfile( ...
                              fileparts(mfilename('fullpath')),'output');

    %% Debug mode settings

    cfg.debug.do = false; % To test the script out of the scanner, skip PTB sync
    cfg.debug.smallWin = false; % To test on a part of the screen, change to 1
    cfg.debug.transpWin = false; % To test with trasparent full size screen

    cfg.skipSyncTests = 1;

    cfg.verbose = 1;

    %% Engine parameters

    cfg.testingDevice = 'mri';
    cfg.eyeTracker.do = false;
    cfg.audio.do = false;

    cfg = setMonitor(cfg);

    % Keyboards
    cfg = setKeyboards(cfg);

    % MRI settings
    cfg = setMRI(cfg);
    cfg.suffix.acquisition = '';

    cfg.pacedByTriggers.do = false;

    %% Experiment Design

    % switching this on to MT or MT/MST with use:
    % - MT: translational motion on the whole screen
    %   - alternates static and motion (left or right) blocks
    % - MST: radial motion centered in a circle aperture that is on the opposite
    % side of the screen relative to the fixation
    %   - alternates fixaton left and fixation right
    cfg.design.localizer = 'MT';
    % cfg.design.localizer = 'MT_MST';

    cfg.design.motionType = 'translation';
    cfg.design.motionDirections = [180 90]; %0:right 180:left 90:up 270:down
    cfg.design.names = {'motion'; 'static'};

    cfg.design.nbRepetitions = 6; %12 BLOCKS
    cfg.design.nbEventsPerBlock = 16; % DO NOT CHANGE

    %% Timing

    % FOR 7T: if you want to create localizers on the fly, the following must be
    % multiples of the scanneryour sequence TR
    %
    % IBI
    % block length = (cfg.eventDuration + cfg.ISI) * cfg.design.nbEventsPerBlock

    cfg.timing.eventDuration = 0.5; % second %ACTUALLY RUNS FOR 1SEC (double than this)

    % Time between blocs in secs
    %cfg.timing.IBI = 5;
    cfg.timing.IBI = [5.9008    6.6965    6.0444    6.9093    6.2273    6.0206    5.8399    5.2143    6.2263    5.9364    5.4057    0 ];
    %r = a + (b-a).*rand(N,1); r = 5 + (7-5)*rand(1,11);
    % Time between events in secs
    cfg.timing.ISI = 1;%0.5;
    % Number of seconds before the motion stimuli are presented
    cfg.timing.onsetDelay = 5.25;
    % Number of seconds after the end all the stimuli before ending the run
    cfg.timing.endDelay = 14;

    % reexpress those in terms of repetition time
    if cfg.pacedByTriggers.do

        cfg.pacedByTriggers.quietMode = true;
        cfg.pacedByTriggers.nbTriggers = 5;

        cfg.timing.eventDuration = cfg.mri.repetitionTime / 2 - 0.04; % second

        % Time between blocs in secs
        cfg.timing.IBI = 0;
        % Time between events in secs
        cfg.timing.ISI = 0;
        % Number of seconds before the motion stimuli are presented
        cfg.timing.onsetDelay = 0;
        % Number of seconds after the end all the stimuli before ending the run
        cfg.timing.endDelay = 2;

    end

    %% Visual Stimulation

    % Speed in visual angles / second
    cfg.dot.speed = 15;
    % Coherence Level (0-1)
    cfg.dot.coherence = 1;
    % Number of dots per visual angle square.
    cfg.dot.density = 1;
    % Dot life time in seconds
    cfg.dot.lifeTime = 0.4;
    % proportion of dots killed per frame
    cfg.dot.proportionKilledPerFrame = 0;
    % Dot Size (dot width) in visual angles.
    cfg.dot.size = .25;
    cfg.dot.color = cfg.color.white;

    % Diameter/length of side of aperture in Visual angles
    cfg.aperture.type = 'circle';
    cfg.aperture.width = []; % if left empty it will take the screen height
    cfg.aperture.xPos = 0;

    %% Task(s)

    cfg.task.name = 'visual localizer';

    % Instruction
    cfg.task.instruction = 'Detect the repeated stimulus\n \n\n';

    % Fixation cross (in pixels)
    cfg.fixation.type = 'cross';
    cfg.fixation.colorTarget = cfg.color.white;
    cfg.fixation.color = cfg.color.white;
    cfg.fixation.width = .25;
    cfg.fixation.lineWidthPix = 3;
    cfg.fixation.xDisplacement = 0;
    cfg.fixation.yDisplacement = 0;

    % target
    cfg.target.maxNbPerBlock = 2;
    cfg.target.duration = 0.1; % In secs
    cfg.target.type = 'static_repeat';  
    % 'fixation_cross' : the fixation cross changes color
    % 'static_repeat' : dots are in the same position

    cfg.extraColumns = { ...
                        'direction', ...
                        'speedDegVA', ...
                        'target', ...
                        'event', ...
                        'block', ...
                        'keyName', ...
                        'fixationPosition', ...
                        'aperturePosition'};

    %% orverrireds the relevant fields in case we use the MT / MST localizer
    cfg = setParametersMtMst(cfg);

end

function cfg = setKeyboards(cfg)
    cfg.keyboard.escapeKey = 'ESCAPE';
    cfg.keyboard.responseKey = { 'a', 'b', 'c', 'd'};
    cfg.keyboard.keyboard = [];
    cfg.keyboard.responseBox = [];

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.keyboard.keyboard = [];
        cfg.keyboard.responseBox = [];
    end
end

function cfg = setMRI(cfg)
    % letter sent by the trigger to sync stimulation and volume acquisition
    cfg.mri.triggerKey = 's';
    cfg.mri.triggerNb = 1;

    cfg.mri.repetitionTime = 1.75;

    cfg.bids.MRI.Instructions = 'Detect the repeated stimulus';
    cfg.bids.MRI.TaskDescription = [];
    cfg.bids.mri.SliceTiming = [0, 0.9051, 0.0603, 0.9655, 0.1206, 1.0258, 0.181, ...
                              1.0862, 0.2413, 1.1465, 0.3017, 1.2069, 0.362, ...
                              1.2672, 0.4224, 1.3275, 0.4827, 1.3879, 0.5431, ...
                              1.4482, 0.6034, 1.5086, 0.6638, 1.5689, 0.7241, ...
                              1.6293, 0.7844, 1.6896, 0.8448, 0, 0.9051, 0.0603, ...
                              0.9655, 0.1206, 1.0258, 0.181, 1.0862, 0.2413, ...
                              1.1465, 0.3017, 1.2069, 0.362, 1.2672, 0.4224, ...
                              1.3275, 0.4827, 1.3879, 0.5431, 1.4482, 0.6034, ...
                              1.5086, 0.6638, 1.5689, 0.7241, 1.6293, 0.7844, ...
                              1.6896, 0.8448];

end

function cfg = setMonitor(cfg)
    % text size
    cfg.text.size = 48;

    % Monitor parameters for PTB
    cfg.color.white = [255 255 255];
    cfg.color.black = [0 0 0];
    cfg.color.red = [255 0 0];
    cfg.color.grey = mean([cfg.color.black; cfg.color.white]);
    cfg.color.background = cfg.color.black;
    cfg.text.color = cfg.color.white;

    % Monitor parameters
    cfg.screen.monitorWidth = 50; % in cm
    cfg.screen.monitorDistance = 40; % distance from the screen in cm 

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.screen.monitorWidth = 69.8; % 25;
        cfg.screen.monitorDistance = 170; %95;
    end

end

function cfg = setParametersMtMst(cfg)

    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

        cfg.task.name = 'mt mst localizer';

        cfg.design.motionType = 'radial';
        cfg.design.motionDirections = [666 666 -666 -666];
        cfg.design.names = {'fixation_right'; 'fixation_left'};
        cfg.design.xDisplacementFixation = 7;
        cfg.design.xDisplacementAperture = 3;

        cfg.timing.IBI = 3.6;

        % reexpress those in terms of repetition time
        if cfg.pacedByTriggers.do

            cfg.timing.IBI = 2;

        end

        cfg.aperture.type = 'circle';
        cfg.aperture.width = 7; % if left empty it will take the screen height
        cfg.aperture.xPos = cfg.design.xDisplacementAperture;

    end

end
