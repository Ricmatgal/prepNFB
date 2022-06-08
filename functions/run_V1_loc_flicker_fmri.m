function run_V1_loc_flicker_fmri(subID, projFolder)  %[rsp, corr_resp, cues_randorder, ons]=
%% localizer function
%cues randomized 1=right, 2=left

% %% SETTINGS FOR openNFT to initialize the folders right

rootPath     = pwd; % needs to be dir where prep_NFB is run from.. if run as intended this should not be a problem.
imPath       = [rootPath, filesep, 'Images_Localizer', filesep];
% projFolder   = rootPath; %just to make this run outside prepNF
rootPathData = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'beh'];

pilotremote =1; %0, select 1 when sending to pilots, or ready for fmri test

% if pilotremote
%     maindir    = pwd;
%     imPath    = [maindir,filesep, 'imPath', filesep];
%     if ~exist([maindir, filesep, 'Behavioural_data', filesep], 'dir')
%         savefolder = mkdir([maindir, filesep, 'Behavioural_data', filesep])
%     else
%         savefolder = [maindir, filesep, 'Behavioural_data', filesep];
%     end
%     
% else

%% FMRI setup
usingMRI = 1;
if usingMRI
    parportAddr = hex2dec('2FD8');
    config_io;
    % Set condition code to zero:
    outp( parportAddr, 0); 
    % Set automatic BIOPAC and eye tracker recording to "stop":
    outp( parportAddr+2, bitset(inp( parportAddr+2), 3, 0));

end



%%

% info={};
% info.sub  = input('subject number [incl 0]', 's');
% info.age  = input('subject age', 's');
% info.hand = input('handedness [r/l]', 's');
% info.sex  = input('gender [f/m]', 's');

%%  HERE GOES INPUT FOR LATER CALCULATION OF FB TO BE GIVEN




%% define here number of trials and runs

simulated_data = 50;% number of  trials
% %simulate some activity for left and right ROI and scale to use for feedbakc
% a =-100; b=100; % range from -100 to 100;
% rightROI  = a + (b-a)*rand(1,simulated_data);
% leftROI   = a + (b-a)*rand(1,simulated_data);
% normleft  = rescale(leftROI, -2, 2);
% normright = rescale(rightROI, -2, 2);


PsychDefaultSetup(2)
%% Defaults
% Setup defaults and unit color range:
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests',1);
Screen('Preference', 'VisualDebugLevel',0);
Screen('Preference', 'ScreenToHead', 0, 1, 1);

screens      = Screen('Screens');
screenNumber = 1;%max(screens);

% Define colors
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey  = [0.5 0.5 0.5];%white / 2;
red   = [255 0 0];
% darkgrey= [105, 105, 105];
inc   = white - grey;

%% Open an on screen window
% if pilotremote
[window, windowRect]  = PsychImaging('OpenWindow', screenNumber, grey, []);

% else
%     [window, windowRect]           = PsychImaging('OpenWindow', screenNumber, grey, [200 80 1200 860]);

% end

[screenXpixels, screenYpixels] = Screen('WindowSize', window);% Get the size of the on screen window
ifi                            = Screen('GetFlipInterval', window);% Query the frame duration
[xCenter, yCenter]             = RectCenter(windowRect);% Get the centre coordinate of the window


  
ifi        = Screen('GetFlipInterval', window);
flipSecs   = 0.05;% half of the freq
waitframes = round(flipSecs / ifi);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Variables of the tasksca
stim_time     = 0.3; % screen time for the arrows
responsetime  = 3 ;%Response time for button press (if elapsed, trial goes on)
alpha         = 0.7;% initial alpha,  arrows contrast - changes every trial based on performance
fixation_time = 1;
cue_time      = 0.5;
colormod      = [0.3 0.3 0.3]';

%jitter prep interval between 5.5 and 8 secs - preparation interval is
%between cue and stimulus
a=5.5; b=8;
prep_interval= a + (b-a)*rand(1,simulated_data);

% calculate already arrow rotations and correct responses
a1=10; b1=170; % range from -100 to 100;
a2=190; b2=350;
B= 100; %number of generated degrees to be picked from

randomvec = [a1 + (b1-a1)*rand(1,B), a2 + (b2-a2)*rand(1,B)];  % contains all randomly generated rotations in degrees, from range 1 and range 2
randidx            = {};
randidx.leftarrow  = randi([1,B*2],1, simulated_data ); %B*2 because randomvec has 100 for left and 100 for right
randidx.rightarrow = randi([1,B*2],1, simulated_data );

arrow_rotations= zeros(2,simulated_data); %prealloc
arrow_rotations(1,:)= randomvec(randidx.leftarrow); %left arrow
arrow_rotations(2,:)= randomvec(randidx.rightarrow); %right arrow
arrow_array  = [20 8 20 5];
%cues randomized 1=right, 2=left

cues_ordered   = [repmat(1,1, simulated_data/2), repmat(2,1, simulated_data/2)]; %because i want 50-50 left and right
randorder      = randperm(simulated_data, simulated_data);
cues_randorder = cues_ordered(randorder); % 2=right, 1=left

validity = [repmat(1,1,(B/100*80)), repmat(0,1,(B/100*20))]; %80% validity
randval = validity(randperm(length(validity)));

% compute correct responses for each trial before task goes on
corr_resp = {};
for j=1:simulated_data
    switch cues_randorder(j)
        case 1 %cue left, look at second row of arrow rotations matrix
            if arrow_rotations(2,j) >10 && arrow_rotations(2,j) < 170 %if oriented right
                corr_resp{j}='2@'; %right
            elseif arrow_rotations(2,j)>190 && arrow_rotations(2,j)< 350 %if oriented left
                corr_resp{j}='1!'; %left
            end
        case 2
            if arrow_rotations(1,j) >10 && arrow_rotations(1,j) < 170  %if oriented right
                corr_resp{j}='2@'; %right
            elseif arrow_rotations(1,j)>190 && arrow_rotations(1,j)< 350 %if oriented left
                corr_resp{j}='1!'; %left
            end
    end
end


%%
%number of textures (items) on screen (equally spaced horizontally)
fignum = 2;
yPos   = yCenter;
xPos   = linspace(screenXpixels * 0.2, screenXpixels * 0.8, fignum); % create position of figures (depending of how many figures drawn this line divides x coord accordingly into equally spaced parts)


%% Load pngs of circles (rings)

[wheel_image,~, alphawheel]   = imread([imPath,'Wheel_transp.png']);
wheel_image(:,:,4)            = alphawheel;
[arrow_image, ~, alphaarrow]  = imread([imPath ,'myarrow.png']);
arrow_image(:,:,4)            = alphaarrow;

%convert this image into a texture

% Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
our_texture   = Screen('MakeTexture', window, wheel_image);
arrow_texture = Screen('MakeTexture', window, arrow_image);



%% rectangles for wheel
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

%% rectangles for arrow
[s1, s2, s3]  = size(arrow_image);
aspectratio   = s2/s1; %to preserve aspect ratio and not stretch image when resizing

heightScalers = 0.1;
imageHeights  = screenYpixels .* heightScalers;
imageWidths   = imageHeights .* aspectratio;

fignum    = 2;
dstRects2 = nan(4, 2); %4 x number of images
for i = 1:2
    theRect         = [0 0 imageWidths imageHeights]; % dimension of rectangle where to display image
    dstRects2(:, i) = CenterRectOnPointd(theRect, xPos(i), yPos);
    
end


%% Make fixation cross
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Setup the text type for the window
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 50);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 10;

xCoords     = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords     = [0 0 -fixCrossDimPix fixCrossDimPix];
CROSSCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 2;

%% triggers and buttons
% for some reason it doesn't woek on OSX so for now work only with left and
% right arrows and set up and test with windows the other buttons

KbName('KeyNamesWindows')
% KbName('UnifyKeyNames');
continueKey   = 'space'; %doesn't work on mACOSX
respleftKey   = '1!';
resprightKey  = '2@';

interruptKey  = 'q';
interruptCode = KbName(interruptKey);
continueCode  = KbName(continueKey);
respRightCode = KbName(resprightKey);
respLeftCode  = KbName(respleftKey);
% activeKeys    = [KbName('LeftArrow') KbName('RightArrow')];

%% Instructions

topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
Screen('TextFont', window, 'Ubuntu');
Screen('TextSize', window, 22);
DrawFormattedText(window, 'Keep fixating the cross in the middle of the screen\npay attention to the instructed cued side and, when the arrows appear\n indicate as fast as possible the perceived tilt direction (left vs right)\n of the arrow in the attended side\nPress a button to start',...
    'center', 'center', white);

Screen('Flip', window);
KbPressWait([],[]);



%% codes triggers
% to set the trigger
code=[1,2,4,8,16];
%% START MRI set timing - based on trigger from scanner
% set MRI ports
%  if pilotremote



% wait for MRI trigger
wait4me = 0;
while wait4me == 0 
   [keyIsDown, secs, keyCode]=KbCheck;
    rsp=KbName(keyCode);
    if ~(isempty(rsp))
        if rsp=='5%'
            wait4me=1;
            startIRM=GetSecs;
        end
    end
end


fprintf(['\n', num2str(startIRM), '\n'])
% % Send trigger to biopac
% if usingMRI
%     outp(parportAddr, 128);
%     wait(200);
%     outp(parportAddr, 0);
% end
% % else 
% % end

% initiate onset matrix
%%
[rsp]=deal({});
%create random vector for direction of rotations in each run

tmp = randi(2, 1, simulated_data);
direction=[];
for k=1:numel(tmp)
    switch tmp(k)
        case 1
            direction(k)=-0.3;
        case 2
            direction(k)= 0.3;
    end
end
clear tmp;

type = cues_randorder;
[duration_mat, ons] = deal(zeros(2,simulated_data/2));
[counterleft, counterright]=deal([0]);
vbl = Screen('Flip', window);
% initialize response str
rsp ={};
rsp.RT = zeros(1,simulated_data)
rsp.keyName = cell(1, simulated_data)
for run = 1:simulated_data
        
   % save type of trial, i.e., left vs right (1=right, 2=left)

    % FIXATION CROSS
    rotation_angle=0;
    Screen('DrawLines', window, CROSSCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(fixation_time);
    
    % CUE
    fprintf('\ncue\n')
    Screen('TextFont', window, 'Arial');Screen('TextSize', window, 25);
    switch cues_randorder(run)
        case 2 %right
            counterright = counterright+1;
            DrawFormattedText(window, '>','center', 'center', white);
            duration_mat(cues_randorder(run), counterright)=prep_interval(run);
        case 1 %left
            counterleft = counterleft+1;
            DrawFormattedText(window, '<','center', 'center', white);
            duration_mat(cues_randorder(run), counterleft)=prep_interval(run);
    end
    
    cue_flip=Screen('Flip', window);
    fprintf(['\n cue flip time ', num2str(cue_flip), '\n']);
    %send trigger related to cue type (trial type)
    if pilotremote
        
        switch cues_randorder(run)
            case 2 %right
                % Send a trigger to biopac in line 6 - right cue
                            
                    'CASE 2'
                outp(parportAddr,2);
%            
                wait(50);
                outp(parportAddr,0);
            case 1 %left
                % Send a trigger to biopac in line 8 - left cue
                         
                'CASE 1'
                outp(parportAddr,1);
               
                wait(50);
                outp(parportAddr,0);
        end
        
    end
    
    WaitSecs(cue_time);
       
        
    %     % ROTATION OF WHEELS FOR X SECONDS based on clock
    fprintf('\nrotate wheels\n')
    t0 = clock;
    
    vbl = Screen('Flip', window);
    while etime(clock, t0) < prep_interval(run) %(preparation interval jittered)
         Screen('DrawLines', window, CROSSCoords,...
                lineWidthPix, red, [xCenter yCenter], 2);
        tv1 = Screen('AsyncFlipEnd', window);
        Screen('DrawTextures', window, our_texture, [],...
            dstRects1(:, 1:2), [], [], []);
        %   Screen('Flip', window);
        Screen('AsyncFlipBegin', window, tv1 + ifi/2);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
    end
    
    
    
    %% %%%%%%%%%%% ARROWS APPEAR FOR X ms
    fprintf('\narrows appear\n');
%     if run>3
%                 try
%         switch sum(rsp.iscorrect([end-2:end]))
%             case 3 %all past 3 responses correct
%                 if alpha>= 0.2 %do not decrease alpha too much
%                     alpha = alpha-0.1;
%                 end
%             case  {0, -3}
%                 if alpha < 1
%                     alpha = alpha+0.1;
%                 end
%         end
%     end
    
    
    t0 = clock;
    vbl=Screen('Flip', window);
    while etime(clock, t0) < stim_time %(stimulus time - arrow stay on screen)
        %Wheels + fixation
        Screen('DrawLines', window, CROSSCoords,...
            lineWidthPix, red, [xCenter yCenter], 2);
        Screen('Flip', window);
        tv1 = Screen('AsyncFlipEnd', window);
        Screen('DrawTextures', window, our_texture, [],...
            dstRects1(:, 1:2), [], [], []);
        switch cues_randorder(run)
            case 2 %right
                if randval(run)==1
                    Screen('DrawTexture', window, arrow_texture, [],...
                        dstRects2(:, 2), arrow_rotations(2, run), [], alpha, colormod);%RIGHT ARROW
                elseif randval(run)==0
                    Screen('DrawTexture', window, arrow_texture, [],... %LEFT ARROW
                        dstRects2(:, 1), arrow_rotations(1, run), [], alpha,colormod);
                end
                                
            case 1 %left cue
                if randval(run)==1
                    
                    Screen('DrawTexture', window, arrow_texture, [],... %LEFT ARROW
                        dstRects2(:, 1), arrow_rotations(1, run), [], alpha,colormod); % adaptive alpha based on performance
                elseif randval(run)==0
                    Screen('DrawTexture', window, arrow_texture, [],...
                        dstRects2(:, 2), arrow_rotations(2, run), [], alpha, colormod);%RIGHT ARROW
                end
        end
        
        
        Screen('AsyncFlipBegin', window, tv1 + ifi/2);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
    end
    
    
    
    
    %% %%%%%%%%% RESPONSE PERIOD loop with keyboard press %%%%%%%%%%%%%%
    
    fprintf(['\nresponse time\n'])
    
    %% INSERT CONFIGURATION FOR RESPONSE TRIGGERS
    
    % if the wait for presses is in a loop,
    % then the following two commands should come before the loop starts
    % restrict the keys for keyboard input to the keys we want

    % suppress echo to the command line for keypresses
    %     ListenChar(2);
    timedout = false;   % repeat until a valid key is pressed or we time out
    tStart = GetSecs;

    fprintf(['\n\n', mat2str(corr_resp{run}), '\n']);
    
    vbl=Screen('Flip', window);
    while ~timedout
        Screen('DrawLines', window, CROSSCoords,...
            lineWidthPix, red, [xCenter yCenter], 2);
        tv1 = Screen('AsyncFlipEnd', window);
 % redraw wheels in response interval       
        Screen('DrawTextures', window, our_texture, [],...
            dstRects1(:, 1:2), [], [], []);
%         Screen('DrawLines', window, CROSSCoords,...
%             lineWidthPix, red, [xCenter yCenter], 2);
        
        Screen('AsyncFlipBegin', window, tv1 + ifi/2);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        if(keyIsDown)
            break;
        end
        if( (secs - tStart) > responsetime)
            timedout = true;
        end
        
    end
    
    
    if ~timedout % if key pressed
        rsp.RT(run)      = secs - tStart;
        rsp.keyName{run} = KbName(keyCode)
        fprintf('\n RESPONSE GIVEN \n')
        
        if strcmp( rsp.keyName{run},corr_resp{run})==1
            rsp.keyName{run}
            corr_resp{run}
            %             Corr_sound(1, imPath)
            fprintf('\n correct \n')
            rsp.iscorrect(run)=1;
        elseif  strcmp( rsp.keyName{run},corr_resp{run})==0
            %             Wrong_sound(1,imPath)
            fprintf('\n incorrect \n')
            rsp.iscorrect(run)=-1;
            
        end
    else %if no response given
        fprintf('\n no resp \n')
        %             Wrong_sound(1,imPath)
        rsp.iscorrect(run)=2
    end

        fprintf(['\n cue flip onset saved ', num2str(cue_flip-startIRM), '\n']);

    
  %% save onset matrix
   switch cues_randorder(run)
        case 1 %left
           ons(type(run),counterleft)=(cue_flip-startIRM); %type corresponds to cues_randorder(run), so it's 1 if left trial and 2 for right trial
        case 2 %right
          ons(type(run),counterright)=(cue_flip-startIRM);
   end
%        ons
end


clear keyIsDown keyTime keyCode
% type again if you want to restore keys

 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ONSET MANAGER 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FOR MULTIPLE CONDITIONS (~= block design)
%This  *.mat file must include the following cell arrays (each 1 x n):
%where n is nr conditions
%names, onsets and durations. eg. names=cell(1,5), onsets=cell(1,5),


names={'Left', 'Right'};

[onsets, durations]= deal(cell(1,2));
for k=1:2 %1=left, 2=right
durations{k}=num2cell(duration_mat(k,:)); 
onsets{k}=num2cell(ons(k,:)); 
end

% 
filename = 'Onsets_SPM.mat';
save([rootPathData, filesep, filename], 'names', 'durations', 'onsets');
fprintf(['SPM_onset file saved in: ', '%s\n'],rootPathData)

data = {};
data.rsp  = rsp;
data.arrowrotations   = arrow_rotations;
data.cueorder         =  cues_randorder ;
data.corr_resp_matrix = corr_resp;
% define current date to add to the name path
% currentDate = datestr(now,'ddmmyy_HH:MM');
save([rootPathData, filesep, 'beh_info_localizer.mat'], 'data');


% Clear the screen
sca;
exptime = GetSecs - startIRM;
fprintf(['\nExperiment duration total ', num2str(exptime) , '\n' ]);
end