function run_offa_loc(subID, projFolder)
%% This scripts is a simple picture presentation for FFA localizer
% Subject have to press button when there is two repeted pictures
% That is (see in orderFFA.res) : 
% - fearful face (1,14), (3,15), (4,7), (7,18) and (8,5)
% - neutral face (3,37), (4,30) and (6,46)
% - house (1,33), (2,9), (5,35), (6,19), (7,29) and (8,33)
% - "oval" (control condition) (2,23), (5,2), (6,10) and (8,48)
% - scramble (control condition) (1,49),(2,18),(3,50),(5,42)


% Trigger Acqknowledge: 
% code = 1 (ligne 1) for fearful face
% code = 2 (ligne 2) for neutral face
% code = 4 (ligne 3) for house
% code = 8 (ligne 4) for oval
% code = 16 (ligne 5) for scramble

% Note (Lucas Peek, 25.05.2019): This used to be a cogent script. But in the 
% context of the NFB_prep tool I cleaned it and changed it to a ptb script. 
% Nothing has been changed in terms of presentation paramters. 

usingMRI = 1;
if usingMRI
    parportAddr = hex2dec('2FD8');     
    config_io;
    % Set condition code to zero:
    outp(57392, 0);
    % open shutter A:
    outp(57394, bitset(inp(57394), 1, 0));
    % open shutter B:
    outp(57394, bitset(inp(57394), 2, 0));
    % Set automatic BIOPAC and eye tracker recording to "stop":
    outp(57394, bitset(inp(57394), 3, 0));
    % Close pneumatic valve:
    outp(57394, bitset(inp(57394), 4, 1));
else
    parportAddr = hex2dec('378');
end

rootPath = pwd; % needs to be dir where prep_NFB is run from.. if run as intended this should not be a problem.
imPath = [rootPath, filesep, 'Images_Localizer'];

% Initialize the inpout32.dll low-level I/O driver:
% config_io;
% % Set condition code to zero:
% outp(parportAddr, 0);

% base all random fonction on clock to completly random it
rand('state',sum(100*clock));

rootPathData = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'beh'];

% Configure faces
load([imPath, filesep, 'stimNames.mat']);
load([imPath, filesep, 'orderFFA2.mat']);

% Initialise timing
nb_bloc     = 8;        % number of bloc for one condition
duration    = .5;       % Duration of each picture
interP      = 50/1000;  % Time between each picture /1000 if using ptb func to wait
interB      = 3;        % Time between each bloc

%time between trial, jittered to 3000ms, but sum always equal to 3000*nb_bloc 
interT= random('unif',2000,4000,[1,nb_bloc]); % uniforme
remainder= (3000*nb_bloc) - sum(interT);
division = remainder  / nb_bloc;
interT = round(interT + division);

% order of presentation (1=fearful, 2=neutral, 3=house, 4=oval, 5=scramble)
% (already implement in orderFFA.res, O is useful only for log file)
O=[4,1,2,3,5; 3,5,1,4,2; 4,1,3,2,5; 1,3,2,4,5; 4,1,2,3,5; 4,3,5,1,2; 2,1,3,4,5; 1,5,2,3,4];
% 8 runs de 4 blocs de 10 images (8*4*10 = 320 stim)

% to set the trigger
code=[1,2,4,8,16];

% set ptb paramters
Screen('CloseAll');
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'ConserveVRAM', 64);

AssertOpenGL();

myscreens = Screen('Screens');
screenid = 1;%max(myscreens);

fFullScreen = 1;
if ~fFullScreen
    ptb.Screen.wPtr = Screen('OpenWindow', screenid, [0 0 0], ...
        [40 40 720 720]);
else
    % full screen
    ptb.Screen.wPtr = Screen('OpenWindow', screenid, [0 0 0]);
end

[w, h] = Screen('WindowSize', ptb.Screen.wPtr);
ptb.Screen.ifi = Screen('GetFlipInterval', ptb.Screen.wPtr);

% settings
ptb.Screen.vbl=Screen('Flip', ptb.Screen.wPtr);
ptb.Screen.h = h;
ptb.Screen.w = w;
ptb.Screen.lw = 5;

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', ptb.Screen.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% fixation cross settings
ptb.Screen.fixCrossDimPix = 40;

% Set the line width for fixation cross
ptb.Screen.lineWidthPix = 4;

% Define black, white and grey
black = BlackIndex(screenid);
white = WhiteIndex(screenid);
grey = white / 2;

% Setting the coordinates
ptb.Screen.wRect                            = [0, 0, ptb.Screen.w, ptb.Screen.h];
[ptb.Screen.xCenter, ptb.Screen.yCenter]    = RectCenter(ptb.Screen.wRect);
ptb.Screen.xCoords                          = [-ptb.Screen.fixCrossDimPix ptb.Screen.fixCrossDimPix 0 0];
ptb.Screen.yCoords                          = [0 0 -ptb.Screen.fixCrossDimPix ptb.Screen.fixCrossDimPix];
ptb.Screen.allCoords                        = [ptb.Screen.xCoords; ptb.Screen.yCoords];

% fixation dot coords
ptb.Screen.fix = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];

% accepted response keys
ptb.Screen.respKey = KbName('1!');
    
% Intro screen with instructions
line1 = 'INSTRUCTIONS';
line2 = '\n\n\nPlease, focus on the central point';
line3 = '\n\nPush the button when the image displayed on the screen';
line4 = '\n\nis the same as the previous one';
DrawFormattedText(ptb.Screen.wPtr, [line1 line2 line3 line4], 'center', 'center', white);
Screen('Flip',ptb.Screen.wPtr);

% initiate onset matrix
ons=zeros(5,8);

% wait for MRI trigger
wait4me = 0;
while wait4me == 0 
   [keyIsDown, secs, keyCode]=KbCheck;
    rsp=KbName(keyCode);
    if ~(isempty(rsp))
        if strcmp(rsp,'5%')==1 % rsp=='5%'
            wait4me=1;
            startIRM=GetSecs;
        end
    end
end

% Send trigger to biopac
if usingMRI
    outp(parportAddr, 128);
    wait(200);
    outp(parportAddr, 0);
end
tic;
for i = 1: nb_bloc  % one bloc here, is one "block" of each type, (so it is 4 blocks of 10 picture)
    
    %start the loop for display pictures
    for j = 1:50  %  50 pictures = 10 pictures * 5 types.  There is a break each 10 pictures
        
        k=0;
        t=0;
        n=0;
        
        % get image id, relate to actual image, read it and load in ptb
        % buffer
        local = stimNames(orderFFA2(i,j),1);
        currimg = char(fullfile([imPath, filesep, local{1}(2:end-1)]));    
        imgArr = imread(currimg);
        tex = Screen('MakeTexture', ptb.Screen.wPtr, imgArr);
        clear imgArr 
        
        
        %4 "if" loops to wait between blocs of picture and save timing
        % ten pictures by type, so change of type at 1, 11, 21 and 31, 41
        if j == 1
%             outp(parportAddr, 0);
            Screen('FillOval', ptb.Screen.wPtr, [255 255 255], ptb.Screen.fix);
            ptb.Screen.vbl=Screen('Flip', ptb.Screen.wPtr);    
            WaitSecs(interT(1,i)/1000); 
            type=O(i,1);
%             outp(parportAddr, code(type));
        end
            
        if j == 11
%             outp(parportAddr, 0);
            Screen('FillOval', ptb.Screen.wPtr, [255 255 255], ptb.Screen.fix);
            ptb.Screen.vbl=Screen('Flip', ptb.Screen.wPtr);    
            WaitSecs(interT(1,i)/1000); 
            type=O(i,2);
%             outp(parportAddr, code(type));
        end
        
        if j == 21
%             outp(parportAddr, 0);
            Screen('FillOval', ptb.Screen.wPtr, [255 255 255], ptb.Screen.fix);
            ptb.Screen.vbl=Screen('Flip', ptb.Screen.wPtr);    
            WaitSecs(interT(1,i)/1000); 
            type=O(i,3);
%             outp(parportAddr, code(type));
        end
        
        if j == 31
%             outp(parportAddr, 0);
            Screen('FillOval', ptb.Screen.wPtr, [255 255 255], ptb.Screen.fix);
            ptb.Screen.vbl=Screen('Flip', ptb.Screen.wPtr);    
            WaitSecs(interT(1,i)/1000); 
            type=O(i,4);
%             outp(parportAddr, code(type));
        end
        
       if j == 41
%             outp(parportAddr, 0);
            Screen('FillOval', ptb.Screen.wPtr, [255 255 255], ptb.Screen.fix);
            ptb.Screen.vbl=Screen('Flip', ptb.Screen.wPtr);    
            WaitSecs(interT(1,i)/1000); 
            type=O(i,5);
%             outp(parportAddr, code(type));
        end

        %display picture
        % Draw the image to buffer
        Screen('DrawTexture', ptb.Screen.wPtr,  tex);
        % Flip the screen
        picture = Screen('Flip', ptb.Screen.wPtr);
        
        % start listening to key input
        KbQueueCreate();
        KbQueueStart();
        
        % during wait no key press evaluation is delayed. It's fine.
        WaitSecs(duration);
        
        % Define Onset of the pictures
        % TR = 0.65; % (en secondes)
        if j == 1 || j == 11 || j == 21 || j == 31 || j== 41
            ons(type,i)=(picture-startIRM);
            % type = display content of file
            % onset (en seconde) = (OnsetImage - StartIRM) /1000
            % onset (en nbre de scans) = ((OnsetImage - StartIRM)/1000)/TR
            % enlever le /1000 si on le veux en ms
            % remplit la matrice de 0 "onsets" avec les valeurs des onsets
        end
        
        %blank between trial
        Screen('Flip', ptb.Screen.wPtr);
        
        if usingMRI
            % to add repetition in results file
            if i==1 && (j==14 || j==33)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            elseif i==2 && (j==9 || j==23)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            elseif i==3 && (j==15 || j==37)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            elseif i==4 && (j==7 || j==30)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            elseif i==5 && (j==2 || j==35)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            elseif i==6 && (j==10 || j==19 || j==36)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            elseif i==7 && (j==18 || j==29)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            elseif i==8 && (j==5 || j==23 || j==38)
                repet=1;
                % Send a trigger to biopac in line 6
                etat = inp(parportAddr);
                change = bitset(etat,6,1);
                outp(parportAddr,change);
            else
                repet=0;
            end
        end
                

        % wait ISI and check for key presses
%         resp0 = time;
        resp0 = GetSecs;
        while (GetSecs - resp0) < interP % time
            [pressed, firstPress]=KbQueueCheck();
            if pressed 
                if firstPress(ptb.Screen.respKey)
    %                 respVec(trial) = 1;
                    fprintf('\npress!\n')
                end
            end
        end
        
%         WaitSecs(interP);
        
        if usingMRI
            % set the 6th bit to 0 in the parallele port (become 1 if repeted picture)
            etat = inp(parportAddr);
            change = bitset(etat,6,0);
            outp(parportAddr,change);
        end
    
    end %of for j
    
end %of for i
toc
Screen('Flip',ptb.Screen.wPtr);
WaitSecs(interB);

if usingMRI
    % Send trigger to biopac
    outp(parportAddr, 128); 
    wait(200);
    outp(parportAddr, 0);
end

%prepare and display stopping
line5 = 'Thank you!';
line6 = '\n\nEnd of Experiment';
DrawFormattedText(ptb.Screen.wPtr, [line5 line6], 'center', 'center', white);
Screen('Flip',ptb.Screen.wPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ONSET MANAGER 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create .mat file for SPM analyses, contain onset of each bloc (in each 8 big blog/run)
name={'Fearful', 'Neutral', 'House', 'Oval', 'Scramble'};
duree={5.450,5.450,5.450,5.450,5.450}; 

for i = 1:5
    onsets{i}=ons(i,:);
end

% on{1}=Onset;
names=name;
durations=duree;

filename = 'Onsets_SPM.mat';
save([rootPathData, filesep, filename], 'names', 'durations', 'onsets');
fprintf(['SPM_onset file saved in: ', '%s\n'],rootPathData)

% Wait for any press after 3 sec time out.
WaitSecs(3);
KbStrokeWait;
            
sca;

fprintf(['SPM_onset file saved in: ', '%s\n'],rootPathData)

end
    
     
    
    
    
    
    
    