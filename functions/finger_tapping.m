function [onsets] = finger_tapping(subID,projFolder,fullScreen,usingMRI)

%% FINGER TAPPING LOCALIZER TASK
% Simple localizer task for sensorimotor regions identification
% pp is asked to tap either left or right index finger for N seconds N
% times

% inputs:
% .....
% outputs:
% onsets: ....

% default arguments for debugging ...

arguments
    subID = '01';
    projFolder = 'D:\motor_NFB_demo';
    fullScreen = 1;
    usingMRI = 0;
end

% directories
rootPath     = pwd; % needs to be dir where prep_NFB is run from.. if run as intended this should not be a problem.
imPath       = [rootPath, filesep, 'Images_Localizer', filesep, 'finger_tapping', filesep]; % images path
rootPathData = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'beh', filesep]; % where the onsets will be saved

% Psychtoolbox settings
PsychDefaultSetup(2)
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests',1);
Screen('Preference', 'VisualDebugLevel',0);
Screen('Preference', 'ScreenToHead', 0, 1, 1);

% screen and colors
screens      = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% only for debugging
if ~ usingMRI
    screenNumber = 2;
end

% fullscreen or not
if fullScreen
    [window, windowRect]           = Screen('OpenWindow', screenNumber, grey, []);
else
    [window, windowRect]           = Screen('OpenWindow', screenNumber, grey, [40 40 640 520]);
end

% screen parameters
[screenXpixels, screenYpixels] = Screen('WindowSize', window); % Get the size of the on screen window
[xCenter, yCenter]             = RectCenter(windowRect); % Get the centre coordinate of the window
ifi = Screen('GetFlipInterval', window);
vbl = Screen('Flip', window);


% get the fingers images filenames and N
filenames = dir(imPath);
filenames = {filenames([filenames.isdir] == 0).name};
filenamesN = length(filenames);

% read the images and prepare textures
finger_images = cell(0);
alpha_gabor_images = cell(0);
our_textures = cell(0);

% order is both,left,right(1,2,3 index for textures)

for filename = filenames
    [finger_images{end+1},~, alpha_gabor_images{end+1}]   = imread([imPath,filename{1,1}]);
end

for gabor = finger_images
    our_textures{end+1}   = Screen('MakeTexture', window, gabor{1,1});
end

% experimental randomization (take into account 0.5 sec of pause between trials)
present_time = 10; % secs left and right
nRepetition = 10;
pres_sequence = [repelem(1,nRepetition) repelem(2,nRepetition)]; % presentation sequence 1:left 2:right unrandomized
pres_sequence = pres_sequence(randperm(length(pres_sequence))); % presentation sequence randomized

% rectangle for left/right picture - including scaling of image with proportions kept
[s1, s2, ~]  = size(finger_images{1,2});
aspectratio   = s2/s1; %to preserve aspect ratio and not stretch image when resizing

% We will set the height of each drawn image to a fraction of the screens height
heightScalers = 0.35;
imageHeights  = screenYpixels .* heightScalers;
imageWidths   = imageHeights .* aspectratio;

% images positioning
fignum = 2;
yPos = yCenter;
xPos = linspace(screenXpixels * 0.15, screenXpixels * 0.85, fignum); % create position of figures (depending of how many figures drawn this line divides x coord accordingly into equally spaced parts)

dstRects = nan(4, fignum); % 4 x number of images
for i = 1:fignum
    theRect         = [0 0 imageWidths imageHeights]; % dimension of rectangle where to display image
    dstRects(:, i) = CenterRectOnPointd(theRect, xPos(i), yPos);
end

% welcome

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

message=char("Bienvenue dans cette expérience!");
Screen('TextSize', window , screenYpixels/20);
Screen('TextFont',window,'Arial');
DrawFormattedText(window, message, 'center', 'center', white);
vbl = Screen('Flip', window, vbl + ifi/2);
disp('flipped the text')
KbStrokeWait;

% show the fingers

Screen('DrawTexture', window, our_textures{1,1}, [], []);
Screen('Flip', window);
disp('show the images')
KbStrokeWait;


% wait for MRI trigger
disp('Waiting for MRI trigger')

wait4me = 0;
while wait4me == 0

    [~, ~, keyCode]=KbCheck;
    rsp=KbName(keyCode);

    if ~(isempty(rsp))

        if strcmp(rsp,'5%')==1

            wait4me=1;
            startIRM=GetSecs;
        end
    end
end


if usingMRI
    parportAddr = hex2dec('2FD8');
    config_io;
    % Set condition code to zero:
    outp( parportAddr, 0);
    % Set automatic BIOPAC and eye tracker recording to "stop":
    outp( parportAddr+2, bitset(inp( parportAddr+2), 3, 0));
end

[counterleft, counterright]=deal(0); % initialize counters

for j = pres_sequence

    switch j % (presentation sequence , 1:left, 2:right)

        case 1 %left

            % display the finger and record onset
            Screen('DrawTextures', window, our_textures{1,2}, [],...
                dstRects(:, j), [], [], []);
            Screen('Flip', window);
            flip_time = GetSecs;
            WaitSecs(present_time);
            counterleft = counterleft + 1;
            timestamp = flip_time - startIRM;
            ons(j,counterleft) = timestamp;
            fprintf('PRESENTATION: %f ONSET RECORDED: %f \n',j,timestamp)

        case 2 %right

            % display the finger and record onset
            Screen('DrawTextures', window, our_textures{1,3}, [],...
                dstRects(:, j), [], [], []);
            Screen('Flip', window);
            flip_time = GetSecs;
            WaitSecs(present_time);
            counterright=counterright+1;
            timestamp = flip_time-startIRM;
            ons(j,counterright) = timestamp;
            fprintf('PRESENTATION: %f ONSET RECORDED: %f \n',j,timestamp)

    end
    WaitSecs(0.5); % half a second pause between subsequent images
end

fprintf('TOTAL TIME: %f secs \n', GetSecs - startIRM);


%% Saving

% create onset matrix

names = {'Left', 'Right'};

durations = {present_time,present_time}; % presentation time

[onsets]= cell(1,2);

for k = 1:2 % 1=left, 2=right

    onsets{k} = cell2mat(num2cell(ons(k,:)));

end

if ~exist(rootPathData,'dir')
    mkdir(rootPathData)
end

filename = fullfile(rootPathData,'Onsets_SPM.mat');
save(filename, 'names', 'durations', 'onsets');
fprintf(['\n SPM_onset file saved in: ', '%s \n'],rootPathData);
sca;

end



