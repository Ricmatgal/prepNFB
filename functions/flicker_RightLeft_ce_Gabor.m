function [onsets]=flicker_RightLeft_ce_Gabor(subID, projFolder, fullScreen,usingMRI)

% function for localizer task via prepNFB.

arguments

    subID = '01';
    projFolder = 'C:\Users\gallir\Documents\OpenNFT\projects\NFB_EDEA_MRI';
    fullScreen = 1;
    usingMRI = 0;

end

sca;

% directories
rootPath     = pwd; % needs to be dir where prep_NFB is run from.. if run as intended this should not be a problem.
imPath       = [rootPath, filesep, 'Images_Localizer', filesep, 'gabor_wheels', filesep]; % images path
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
grey = white / 2;

% only for debugging
if ~ usingMRI
    screenNumber = 2;
end

% fullscreen or not
if fullScreen 
    [window, windowRect]           = Screen('OpenWindow', screenNumber, black, []);
else
    [window, windowRect]           = Screen('OpenWindow', screenNumber, black, [40 40 640 520]);
end


ifi = Screen('GetFlipInterval', window);

[screenXpixels, screenYpixels] = Screen('WindowSize', window); % Get the size of the on screen window
[xCenter, yCenter]             = RectCenter(windowRect); % Get the centre coordinate of the window

% get the gabor images filenames and N
filenames = dir(imPath);
filenames = {filenames([filenames.isdir] == 0).name};
filenamesN = length(filenames);

% read the images and prepare textures
gabor_images = cell(0);
alpha_gabor_images = cell(0);
our_textures = cell(0);

for filename = filenames
    [gabor_images{end+1},~, alpha_gabor_images{end+1}]   = imread([imPath,filename{1,1}]);
end

for gabor = gabor_images
    our_textures{end+1}   = Screen('MakeTexture', window, gabor{1,1});
end

% experimental randomization (take into account 0.5 sec of pause between trials)
present_time = 10; % secs left and right
nRepetition = 15;
pres_sequence = [repelem(1,nRepetition) repelem(2,nRepetition)]; % presentation sequence 1:left 2:right unrandomized 
pres_sequence = pres_sequence(randperm(length(pres_sequence))); % presentation sequence randomized



% rectangle for wheel - including scaling of image with proportions kept
[s1, s2, ~]  = size(gabor_images{1,1});
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


% adjusted using Soraya function for distance 
[solution_in_cm_mirror,solution_in_cm_stimuliscreen,solution_in_pixel_stimuliscreen] = compute_distance_readable_from_screen_center_overt_fmri(50,60, 6.45, 3);
distanceStimuli = solution_in_pixel_stimuliscreen;

dstRects(:,1) = CenterRectOnPointd(theRect, xCenter -  distanceStimuli , yPos);
dstRects(:,2) = CenterRectOnPointd(theRect, xCenter +  distanceStimuli , yPos);



% Fixation Cross
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
CROSSCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);



% wait for MRI trigger
Screen('DrawLines', window, CROSSCoords,...
    lineWidthPix, [255 255 255], [xCenter yCenter], 2); % for some reason white is not taken..
Screen('Flip', window);
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


%% MRI settings

if usingMRI
    parportAddr = hex2dec('2FD8');
    config_io;
    % Set condition code to zero:
    outp( parportAddr, 0);
    % Set automatic BIOPAC and eye tracker recording to "stop":
    outp( parportAddr+2, bitset(inp( parportAddr+2), 3, 0));  
end


%% Experimental routine

[counterleft, counterright]=deal(0); % initialize counters

for j = pres_sequence

    triggerset  = 0; % set to zero at the beginning and turns to 1 at the end of the loop 
    timeToPresent = present_time/filenamesN; % presentation_time/number of images

        for texture = our_textures

            Screen('DrawTextures', window, texture{1,1}, [],...
                dstRects(:, j), [], [], []);
            Screen('DrawLines', window, CROSSCoords,...
             lineWidthPix, [255 255 255], [xCenter yCenter], 2);
            Screen('Flip', window);
            flip_time = GetSecs;
            WaitSecs(timeToPresent); % secs/nStim

        if triggerset == 0

            switch j % (presentation sequence , 1:left, 2:right)

                case 1 %left

                    counterleft = counterleft + 1;
                    timestamp = flip_time-startIRM;
                    ons(j,counterleft) = timestamp; 
                    fprintf('ONSET RECORDED: %f \n',timestamp)

                    % Send a trigger to biopac in line 1 - left cue              
%                     'CASE 1'
%                     outp(parportAddr,1);
%                     wait(50);
%                     outp(parportAddr,0);    

                case 2 %right
                    counterright=counterright+1;
                    timestamp = flip_time-startIRM;
                    ons(j,counterright) = timestamp; 
                    fprintf('ONSET RECORDED: %f \n',timestamp)

                    % Send a trigger to biopac in line 2 - right cue
%                      'CASE 2'
%                     outp(parportAddr,2); 
%                     wait(50);
%                     outp(parportAddr,0);
            end

        end
  
        triggerset = 1; % after first image is presented no more timestamps needed

        end
    
    % Keep the fixation cross between repetitions
    
    Screen('DrawLines', window, CROSSCoords,...
        lineWidthPix, [255 255 255], [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(0.5);

end

fprintf('TOTAL TIME: %f secs \n', GetSecs - startIRM);


%% Saving

%create onset matrix

names={'Left', 'Right'};

durations = {present_time,present_time}; %presentation time

[onsets]= cell(1,2);

for k = 1:2 %1=left, 2=right

    onsets{k} = cell2mat(num2cell(ons(k,:)));

end

filename = fullfile(rootPathData,'Onsets_SPM.mat');
save(filename, 'names', 'durations', 'onsets');
fprintf(['\n SPM_onset file saved in: ', '%s \n'],rootPathData);
sca;

end