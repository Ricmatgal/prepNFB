function [ifi,waitframes,onsets]=flicker_RightLeft_ce(subID, projFolder)
% Clear the workspace and the screen
rootPath     = pwd; % needs to be dir where prep_NFB is run from.. if run as intended this should not be a problem.
imPath       = [rootPath, filesep, 'Images_Localizer', filesep];
% projFolder   = rootPath; %just to make this run outside prepNF
rootPathData = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'beh', filesep];



PsychDefaultSetup(2)
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests',1);
Screen('Preference', 'VisualDebugLevel',0);
Screen('Preference', 'ScreenToHead', 0, 1, 1);

screens      = Screen('Screens');
screenNumber = 1;%max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

grey = white / 2;

% Open an on screen window using PsychImaging and color it grey. REMOVE
% NUMBERS IF YOU WANT FULL SCREEN
[window, windowRect]           = PsychImaging('OpenWindow', screenNumber, grey, []);



ifi = Screen('GetFlipInterval', window);

maindir    ='C:\Users\mazzetti\Google Drive\Psychtoolbox_scripts\openNFT_SCRIPTS\prepNFB-master\functions\';
[screenXpixels, screenYpixels] = Screen('WindowSize', window);% Get the size of the on screen window
[xCenter, yCenter]             = RectCenter(windowRect);% Get the centre coordinate of the window


fignum = 2;
yPos   = yCenter;
xPos   = linspace(screenXpixels * 0.2, screenXpixels * 0.8, fignum); % create position of figures (depending of how many figures drawn this line divides x coord accordingly into equally spaced parts)

stimuli    = [maindir,filesep, 'stimuli', filesep];
[wheel_image,~, alphawheel]   = imread([imPath ,'wheel_concentric.png']);
wheel_image(:,:,4)            = alphawheel;
our_texture   = Screen('MakeTexture', window, wheel_image);
present_time = 15;%10 secs left and right

baseRect = [0 0 400 400];

%% rectangle for wheel - including scaling of image with proportions kept
[s1, s2, s3]      = size(wheel_image);
aspectratio   = s2/s1; %to preserve aspect ratio and not stretch image when resizing
% We will set the height of each drawn image to a fraction of the screens height
heightScalers = 0.3;
imageHeights  = screenYpixels .* heightScalers;
imageWidths   = imageHeights .* aspectratio;

yPos = yCenter;
xPos = linspace(screenXpixels * 0.15, screenXpixels * 0.85, fignum); % create position of figures (depending of how many figures drawn this line divides x coord accordingly into equally spaced parts)

dstRects1 = nan(4, 2); %4 x number of images
for i = 1:2
    theRect         = [0 0 imageWidths imageHeights]; % dimension of rectangle where to display image
    dstRects1(:, i) = CenterRectOnPointd(theRect, xPos(i), yPos);
end



centeredRect = CenterRectOnPointd(baseRect, xCenter+300, yCenter);
rectColor1 = [0 0 1];
rectColor2 = [0 0 0];

%% Fixation Cross
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 20;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
CROSSCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 4;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

%% Flip duration
% Here we use to a waitframes number greater then 1 to flip at a rate not
% equal to the monitors refreash rate. For this example, once per second,
% to the nearest frame
flipSecs = 0.05;% half of the freq
waitframes = round(flipSecs / ifi);


%% wait for MRI trigger
wait4me = 0;
while wait4me == 0
    [keyIsDown, secs, keyCode]=KbCheck;
    rsp=KbName(keyCode);
    if ~(isempty(rsp))
        if strcmp(rsp,'5%')==1
            wait4me=1;
            startIRM=GetSecs;
        end
    end
end


%% MRI SETTINGS
usingMRI = 1;
if usingMRI
    parportAddr = hex2dec('2FD8');
    config_io;
    % Set condition code to zero:
    outp( parportAddr, 0);
    % Set automatic BIOPAC and eye tracker recording to "stop":
    outp( parportAddr+2, bitset(inp( parportAddr+2), 3, 0));
    
end


%% Actual Printing
pres_sequence = [1 1 2 1 2 2 2 1 2 1 1 2 2 1 2 1 2 1 2 1 2]; %1=left, 2=right
[counterleft, counterright]=deal(0);
for j=pres_sequence
    % Flip outside of the loop to get a time stamp
    vbl = Screen('Flip', window);
    
    t0=clock;
    triggerset =0; %set to zero at the beginning and turns to 1 at the end of the loop otherwise i send trigger at every flicker rate
    while etime(clock, t0) < present_time
        
        
        Screen('DrawLines', window, CROSSCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        tv1 = Screen('AsyncFlipEnd', window);
        Screen('DrawTextures', window, our_texture, [],...
            dstRects1(:, j), [], [], []);
        
        Screen('AsyncFlipBegin', window, tv1 + ifi/2);
        flip_time = GetSecs;
        if triggerset == 0
            switch j %(presentation sequence , 1:left, 2:right)
                case 1 %left
                    counterleft=counterleft+1;
                    ons(j,counterleft)=(flip_time-startIRM);fprintf(['\n FLIP TIME HERE'])
                    % Send a trigger to biopac in line 1 - left cue
                  
                    'CASE 1'
                    outp(parportAddr,1);
                    wait(50);
                    outp(parportAddr,0);
%                     
                case 2%right
                    counterright=counterright+1;
                    ons(j,counterright)=(flip_time-startIRM);fprintf(['\n FLIP TIME HERE'])
                    % Send a trigger to biopac in line 2 - right cue
                     'CASE 2'
                    outp(parportAddr,2); 
                    wait(50);
                    outp(parportAddr,0);
            end
        end
        
        vbl = Screen('Flip', window, vbl + (waitframes - 0.3) * ifi);
        triggerset=1;
    end
    
    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    
    Screen('DrawLines', window, CROSSCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(2)
end

%create onset matrix
names={'Left', 'Right'};
durations = {present_time,present_time}; %presentation time
[onsets]= cell(1,2);
for k=1:2 %1=left, 2=right
    onsets{k}=cell2mat(num2cell(ons(k,:)));
end

filename = 'Onsets_SPM.mat';
save([rootPathData, filesep, filename], 'names', 'durations', 'onsets');
fprintf(['SPM_onset file saved in: ', '%s\n'],rootPathData)
% Flip to the screen
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.6) * ifi);
% Clear the screen.
sca;

end

