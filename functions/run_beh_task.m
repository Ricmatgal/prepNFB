function [nTrials,nbertask,score] = run_beh_task(trainBlock, ...
    nBlocksRep, ...
    maxNTargets, ...
    fullScreen, ...
    keyboard, ...
    screenid, ...
    subID, ...
    sessionID, ...
    path_output, ...
    version)

arguments % defaults
    trainBlock logical= 1;

    nBlocksRep(1,1) double  = 10;
    maxNTargets(1,1) double  = 10;

    fullScreen logical = false;
    keyboard(1,1) string ='mri';
    screenid(1,1) double  = 0;  %put 0 to have the biggest screen used false

    subID(1,1) string ='sub-test';
    sessionID(1,1) string = string(append('ses-',datestr(now,'dd-mm-yyyy-hh-MM')));
    path_output(1,1) string="C:\";
    version (1,1) string ='EN';

end

sca;


% Visual search task for behavioral measures (RT,accuracy) of covert attention:
% We present N targets in a circle around the fixation point (center of
% the screen)
% Our conditions are:
% the number of items appearing in the display (even or uneven between
% hemifields)
% the hemifield of the target, L or R
% the side missing in the target, L or R
% Input:
%   maxNTargets = maximum number of possible targets in a single display
%   array, even int
%   nBlocksRep = number of experimental blocks repetition, int
%   fullScreen = 0 no - 1 Yes
%   pupilDistance = cm of pupil distance in the subj, int
% Output:
%   pp = participant result struct
%
% Riccardo Galli, 2022
% adapted from VU attention research and Cecilia Mazzetti visual attention
% script
% riccardomgalli@gmail.com



%----------------------------------------------------------------------
%                       PATH
%----------------------------------------------------------------------
% PATH
projFolder=pwd;%pwd current folder
cd(projFolder);


%% PHYSIO 
% Initialize the inpout32.dll I/O driver:
config_io;
parportAddr = hex2dec('2FD8'); % Shadow-BBL hexadecimal
triggers = [128]; % 128 stimuli shown


%%

%----------------------------------------------------------------------
%                       BIDS - Sub infos
%----------------------------------------------------------------------
%% BIDS - standard name
name_bids = string(append(subID,'_',sessionID,'_',datestr(now,'dd-mm-yyyy-hh'),'_task-visualsearch'));
Exp.subnum = name_bids;
% sub_path=string(strcat(path_output,filesep,subID));%format string concatenated
% sub_ses_path=string(strcat(sub_path,filesep,sessionID));
%%%%%%%%%%%%%%path generating
% Path_beh     = string(strcat(sub_ses_path,filesep,'beh')); % where the folder beh is
Path_beh = path_output;
Exp.subdirbeh = Path_beh ;
root = pwd;

disp('##################################################################');
disp(append('RECAP : ', subID, ' & ', sessionID));

file_to_check=string(strcat(Path_beh,filesep,append(name_bids,'_desc-beh.mat')));
if ~exist(Path_beh , 'dir')
%     mkdir(sub_path);
%     mkdir(sub_ses_path);
    mkdir(Exp.subdirbeh);
else
    if isfile(file_to_check) % File exists.
        msg = ['WARNING !!!!!!! \nSubject number already exists and output files was already generated. \n' ...
            'Check to not overwrite results file! \n'];
        cprintf('*red',  msg)
        overwriteCheck = input(['Want to overwrite subject? \n' ...
            '1 = Y - 0 = N \n']);
        if overwriteCheck == 1
            disp('Overwriting... \n')
%             mkdir(sub_path);
%             mkdir(sub_ses_path);
            mkdir(Exp.subdirbeh);
        else
            sca;clc;error('Restart and use another number');
        end
    end
end

%----------------------------------------------------------------------
%                      Main function
%----------------------------------------------------------------------
% % Clear workspace
% clc;

% close all;
%clearvars -except nBlocksRep maxNTargets targetsPair pupilDistance fullScreen trainBlock; clc;
warning('off','all')
% Initialize the random number generator
rng('default')
rng('shuffle')

%to save the window output
diary_name = string(strcat(Path_beh,filesep, append(name_bids,'_desc-matlabdiary.txt')));
diary(diary_name);

%% PTB preparation
disp('Ptb preparation...')

Screen('CloseAll');
Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0);
AssertOpenGL();
myscreens = Screen('Screens');

if screenid == 0
    % update to the biggest screen
    if length(myscreens) == 3
        disp("Detecting 3 screens, picking the biggest one.")
        screenid = 2;
    elseif length(myscreens) == 2
        disp("Detecting 2 screens, picking the biggest one.")
        screenid=max(myscreens); %take the biggest screen, as the demo one
    elseif length(myscreens) == 1
        disp("Detecting only one screen available.")
        screenid = 0;
    else
        % if different, configure your mode
        screenid = 1;
    end
else
    disp("Picking the screenid argument")
end

disp("Screeen picked "+string(screenid))

% Luminance values
white = WhiteIndex(screenid); %255
black = BlackIndex(screenid); %0
grey  = white/2; % 127
red   = [255 160 70];
green = [0 255 0];

if fullScreen == 0
    % part of the screen, e.g. for test mode
    screen.wPtr = Screen('OpenWindow', screenid, grey, ...
        [40 40 640 520]);
else
    % full screen
    screen.wPtr = Screen('OpenWindow', screenid, grey);
    HideCursor(screenid); %to hide the mouse on the experiment screen
end

%----------------------------------------------------------------------
%                    Psychotoolbox - Settings
%----------------------------------------------------------------------

% Screen parameters
[screen.w, screen.h] = Screen('WindowSize', screen.wPtr);
screen.ifi = Screen('GetFlipInterval', screen.wPtr);
screen.vbl = Screen('Flip', screen.wPtr);

% Drawing text
Screen('TextSize',screen.wPtr,screen.h/20);
Screen('TextFont',screen.wPtr,'Arial');
break_line=50;
v_spacing=1.3;

% Keyboard setup
KbName('UnifyKeyNames');
if strcmp(keyboard,'azerty')==1
    keyChosen = ["w","n"];keySlides = ['w','n'];
elseif strcmp(keyboard,'qwerty')==1
    keyChosen = ["z","m"];keySlides = ['z','m'];
elseif strcmp(keyboard,'qwertz')==1
    keyChosen = ["y","m"];keySlides = ['y','m'];
elseif strcmp(keyboard,'mri')==1
    keyChosen = ["1!","2@"]; keySlides = ['1','2']; % MRI
end
%keyChosen = ["1!","2@"]; keySlides = ['1','2']; % MRI
% keyChosen = ["z","m"];keySlides = ['z','m']; % Keyboard

keyLeft = KbName(convertStringsToChars(keyChosen(1))); keyRight = KbName(convertStringsToChars(keyChosen(2)));
KbCheckList = [KbName('ESCAPE'),keyLeft,keyRight];
RestrictKeysForKbCheck(KbCheckList); % other keys are ignored

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', screen.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Retrieve the maximum priority number
screen.topPriorityLevel = MaxPriority(screen.wPtr);

% fixation cross settings
screen.fixCrossDimPix = 20;
screen.lineWidthPix = 3;

% Setting the coordinates from the screen
screen.wRect = [0, 0, screen.w, screen.h];
[screen.xCenter, screen.yCenter] = RectCenter(screen.wRect);

% Setting the coordinates for the fixation cross
screen.xCoords = [-screen.fixCrossDimPix screen.fixCrossDimPix 0 0];
screen.yCoords = [0 0 screen.fixCrossDimPix -screen.fixCrossDimPix];
screen.allCoords = [screen.xCoords; screen.yCoords];

% get some color information
screen.white = WhiteIndex(screenid);
screen.black = BlackIndex(screenid);
screen.grey  = screen.white / 2;
screen.green = [0,128,0];
screen.red = [255,0,0];

%% Experimental settings

% most experiment settings are produced from create_exp_visual_search
% function, here we add some and make a struct
disp('Experiment settings...')
Exp = struct;
Exp.fixationTime = 1; % time of presentation fixation cross
Exp.searchTime = .8; % time of presentation search display
Exp.responseTime = .7;

% nbertask=nbertask_old+1; %to have the order of this tasks
% Exp.nbertask=nbertask;
Exp.date = string(datestr(now,'dd-mm-yyyy')); % define current date  %datestr(now, 'yyyy-mm-ddThh:MM:SS'); %with time
Exp.time=string(datestr(now,'hh-MM'));
Exp.maxNTargets = maxNTargets;
Exp.nBlocksRep = nBlocksRep;
Exp.targetsSize = 45;
Exp.targetsWidth = 5;

% participant data
% get the maximum focus of covert attention
%TO CHECK if same argument
max_distance_cm=15;
distance_onscreen_cm=15;
%[solution_in_cm,solution_in_pixel,Exp.visualDiameter,psychtoolbox_usingmaxdistance] = compute_distance_readable_from_screen_center_overt_EEGonly(distanceChinrest,pupilDistance,max_distance_cm,distance_onscreen_cm);
%[~ , Exp.visualDiameter] = compute_distance_readable_from_screen_center_overt_EEGonly(distanceChinrest,pupilDistance);
% Exp.distanceChinrest=distanceChinrest;
% Exp.pupilDistance=pupilDistance;
%Exp.presentationRadius = Exp.visualDiameter/2; % radius of the search array

% hardcoded from VU experiments (see https://link.springer.com/article/10.3758/s13414-021-02404-z)
Exp.presentationRadius = 255;

%version
Exp.version=version;

%----------------------------------------------------------------------
%                       VERSION GUIDELINES
%----------------------------------------------------------------------


% Get images for instruction slides
%target_12_cropped_answer.png
imageFolder=[projFolder, filesep, 'images_task',filesep,'img_visualsearch'];
addpath(imageFolder);
filenamesImages=dir(fullfile(imageFolder,('*_answer.png'))); % *_inst inst for instruction
%filenamesImages = ["./images/target_1_cropped_answer.png","./images/target_2_cropped_answer.png"];
filenamesImages={filenamesImages(:).name}

%init
slideTexture = cell(0);
slideImage = cell(0);

for fImage = filenamesImages
    %slideImage(end+1) = {imread(fImage)};
    slideim=imread(string(fullfile(imageFolder,fImage)));
    slideImage(end+1)={slideim};
    slideTexture(end+1) = {Screen('MakeTexture', screen.wPtr, slideim)};
end


% Text "Welcome" - also to check that PTB-3 function 'DrawText' is working
%clc;
disp('Beginning of the experiment.');
disp('##################################################################');
ListenChar(-1);

blockCounter = 1;

%% *************************    Version - language  *************************************
%Get the version
if contains(Exp.version,'EN') %info.version=='EN'
    %instructions
    indic0=char("Welcome to the experiment !\n\n Make yourself comfortable.\n\n Press 1 or 2 to continue. \n\n");
    
    indic1=char("'During this experiment, you will see a serie of stimuli "+ ...
    "appearing around the fixation cross."+ ...
    "You should : \n\n"+...
    "Press: "+ keySlides(1)+ "\nif the target is missing its left side."+ ...
    "\nPress: "+keySlides(2)+"\nif target is missing its right side. "+...
    "\n\nPress 1 or 2 to continue.");

    indic2=char(['We will now show you one example of a trial. \n' ...
    'Here, the target appears on the right side.\n\n' ...
    'Remember to reply whether the right or left part of the target is missing and '...
    'IGNORE the missing part on top or bottom of the target.\n\n'...
    ' \n\nPress 1 or 2 to see the first example.']);
    
    indic3=char(['We will now show you another example of a trial. \n' ...
    'In this second example, the target appears on the left side. \n\n' ...
    'Remember to reply whether the right or left part of the target is missing and '...
    'IGNORE the missing part on top or bottom of the target. \n\n'...
    ' \n\nPress 1 or 2 to continue.']);
    
    indic4=char(['The target and distractors will change position ' ...
    'around a circle with the fixation cross as its center.' ...
    '\n\nYou must keep your eyes always fixating on the fixation cross.' ...
    ' \n\nPress the 1 or 2 to continue.']);

    %training
    indic5=char(['If you have any other question, contact the experimenter.' ...
    '\n\n\nExperiment will start IMMEDIATELY with a first train block. \n\n\nPress 1 or 2 to continue. ']);

    %if score training too low 
    indic_failed_check = char("You did not perform well enough in the training.\n\n" + ...
    "We will restart the experiment with another training block.\n\n" + ...
    "If you have issues contact the experimenter.\n\n" + ...
    "Press 1 or 2 to continue.");
      
    %real experiment
    indic6=char("END of the practice block. \n\n\n If you have any other question, contact us." +...
            "\n\n\nPress 1 or 2 to continue. " );
    indic61=char("Real experiment will start IMMEDIATELY. \n\n\n Press 1 or 2 to continue. ");


    indic71=char('End of block : ');
    indic72=char(['\n\n\nWell done ! \n\nNow, you have a break. You can rest your eyes. ' ...
            '\n\n\nPress 1 or 2 when you want to end the break and are ready to continue with this experiment.']);

    %fin expe
    indic_endexpe=char('Done! Thank you for your time!');

  
else %if FR, by default
    %instructions
    indic0=char("Bienvenue dans cette expérience !\n\n Mettez-vous à l'aise.\n\nAppuyez sur 1 ou 2 pour continuer. \n\n");
    
    indic1=char("Pendant cette expérience, vous verrez une série de stimuli"+ ...
    " apparaître autour de la croix de fixation."+ ...
    "Vous devez : \n\n"+...
    "Appuyer sur : "+keySlides(1)+"\ns'il manque le côté gauche de la cible." +...
    "\nAppuyer sur : "+keySlides(2)+"\ns'il manque le côté droit de la cible. "+...
    "\n\nAppuyez sur 1 ou 2 pour continuer.");
    
    indic2=char("Nous allons maintenant vous montrer un exemple. \n" +...
    "Ici, la cible apparaît sur le côté droit de l'écran.\n\n" +...
    "N'oubliez pas de répondre si la partie droite ou gauche de la cible est manquante et "+...
    "IGNOREZ la partie manquante en haut ou en bas de la cible.\n\n"+...
    "\n\nAppuyez sur 1 ou 2 pour voir le premier exemple.");
    
    indic3=char("Nous allons maintenant vous montrer un autre exemple. \n" +...
    "Dans ce deuxième exemple, la cible apparaît sur le côté gauche de l'écran. \n\n" +...
    "N'oubliez pas de répondre si la partie droite ou gauche de la cible est manquante et "+...
    "IGNOREZ la partie manquante en haut ou en bas de la cible. \n\n"+...
    "\n\nAppuyez sur 1 ou 2 pour continuer.");    
    
    indic4=char("La cible et les distracteurs vont changer de position "+...
    "autour d'un cercle dont le centre est la croix." +...
    "\n\nVous devez toujours garder vos yeux fixés sur la croix." +...
    "\n\nAppuyez sur 1 ou 2 pour continuer.");  
    
    %training
    indic5=char("Si vous avez d'autres questions, posez-les maintenant."+ ...
    "\n\n\nL'expérience va commencer IMMÉDIATEMENT avec un premier bloc d'entrainement.\n\n\nAppuyez sur 1 ou 2 pour continuer. "); 

    %if score training too low
    indic_failed_check = char("Vous n'avez pas été assez performant lors de l'entrainement.\n\n" + ...
        "Nous recommencons l'expérience avec un autre bloc d'entraînement.\n\n" + ...
        "Si vous avez des problèmes, contactez-nous.\n\n" + ...
        "Appuyez sur 1 ou 2 pour continuer.");
    
    %real experiment
    indic6=char("FIN du bloc d'entrainement. \n\n\n Si vous avez d'autres questions, posez-les maintenant." + ...
            "\n\n\nAppuyez sur 1 ou 2 pour continuer. " );
    indic61=char("La vraie expérience va commencer IMMÉDIATEMENT. \n\n\n Appuyez sur 1 ou 2 pour continuer. ");  
  

    indic71=char('Fin du bloc : ');
    indic72=char(['\n\n\nBien joué ! \n\nMaintenant, vous avez une pause. Vous pouvez reposer vos yeux. ' ...
        '\n\n\nAppuyez sur 1 ou 2 lorsque vous voulez mettre fin à la pause et que vous êtes prêt à poursuivre cette expérience.']);

    %fin expe
    indic_endexpe=char("C'est la fin de cette partie de l'expérience ! Merci pour votre temps !");

end


Screen('TextSize', screen.wPtr , screen.h/20);
DrawFormattedText(screen.wPtr, indic0, 'center', 'center', screen.white);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
KbStrokeWait;


%----------------------------------------------------------------------
%                       EXPE SETTINGS
%----------------------------------------------------------------------

%% Create the experimental conditions and assign to Exp struct the info

if trainBlock
    matrix_practice = create_exp_visual_search(Exp.maxNTargets,1);
    nPracticeTrials = size(matrix_practice,2);
    matrix_experiment = [matrix_practice,create_exp_visual_search(Exp.maxNTargets,Exp.nBlocksRep)];
else
    matrix_experiment = create_exp_visual_search(Exp.maxNTargets,Exp.nBlocksRep);

end

Exp.nTrials = 1:size(matrix_experiment,2);
nTrials = size(matrix_experiment,2);
Exp.nTargets = matrix_experiment(1,:);
Exp.hemifield = matrix_experiment(2,:);
Exp.hemiObject = matrix_experiment(3,:);


Exp.pauseTrials = maxNTargets*2:maxNTargets*2:length(Exp.nTrials);
Exp.pauseTrials = Exp.pauseTrials(1:end-1);


if trainBlock
    nTrialsPauses = nTrials-size(matrix_practice,2); % for computing the right number of pauses between blocks
    freq_pause=int16(nTrialsPauses/4); %pause every freq_pause trials % freq_pause=50; %pause every freq_pause trials
    mat_pause=(0:freq_pause:nTrialsPauses)+24;
    Exp.pauseTrials = mat_pause(2:end-1); %do not take first elt which is 0
    total_blocks = size(Exp.pauseTrials,2)+1;

else
    nTrialsPauses = nTrials;
    freq_pause=int16(nTrialsPauses/4); %pause every freq_pause trials % freq_pause=50; %pause every freq_pause trials
    mat_pause=(0:freq_pause:nTrialsPauses);
    Exp.pauseTrials = mat_pause(2:end-1); %do not take first elt which is 0
    total_blocks = size(Exp.pauseTrials,2)+1;
end

%% Experiment routine
% create participant struct for experimental data
rsp = struct;

% Draw instructions
DrawFormattedText(screen.wPtr, indic1, 'center', 'center', screen.white,break_line,0,0,v_spacing);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
KbStrokeWait;
display_time=8;
DrawFormattedText(screen.wPtr,indic2, 'center', 'center', screen.white,break_line,0,0,v_spacing);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
KbStrokeWait;
Screen('DrawTexture', screen.wPtr, cell2mat(slideTexture(1)), [], []);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
WaitSecs(display_time);
DrawFormattedText(screen.wPtr,indic3, 'center', 'center', screen.white,break_line,0,0,v_spacing);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
KbStrokeWait;
Screen('DrawTexture', screen.wPtr, cell2mat(slideTexture(2)), [], []);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
WaitSecs(display_time);

DrawFormattedText(screen.wPtr, indic4,'center', 'center', screen.white,break_line,0,0,v_spacing);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
KbStrokeWait;

DrawFormattedText(screen.wPtr, indic5, 'center', 'center', screen.white,break_line,0,0,v_spacing);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
KbStrokeWait;
WaitSecs(2);

%----------------------------------------------------------------------
%                       EXPERIMENT - LOOP
%----------------------------------------------------------------------
list_rsp=[];
trial = 0;
%for trial = Exp.nTrials % for each trial
while trial < length(Exp.nTrials)

    trial = trial + 1;

    if trainBlock && trial == nPracticeTrials+1
        DrawFormattedText(screen.wPtr, indic6, 'center', 'center', screen.white,break_line,0,0,v_spacing);
        screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
        disp(append('#####END OF TRAIN BLOCK'));
        KbStrokeWait;
        WaitSecs(2);
        [outcome] = check_training(list_rsp,nPracticeTrials);
        if outcome == 0
            % reset
            rsp = struct;
            trial = 1;
            Screen('TextSize', screen.wPtr , screen.h/20);
            DrawFormattedText(screen.wPtr, indic_failed_check, 'center', 'center', screen.white,break_line,0,0,v_spacing);
            screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
            disp(append('#####PRACTICE FAILED'));
            KbStrokeWait;
            WaitSecs(2);
        else
            % all good and continue
            Screen('TextSize', screen.wPtr , screen.h/20);
            DrawFormattedText(screen.wPtr, indic61, 'center', 'center', screen.white,break_line,0,0,v_spacing);
            screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
            KbStrokeWait;
            disp(append('#####PRACTICE SUCCEDED'));
        end

        
    end

    disp(append('#####Trial :',num2str(trial)));


    % draw initial white fixation cross
    colorCross = screen.white;
    drawFixCross(screen.wPtr, screen.allCoords, colorCross, screen.xCenter, screen.yCenter)
    screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
    WaitSecs(Exp.fixationTime);

    % Prepare targets
    [targetsPositionsX,targetsPositionsY] = calcTargetsPositions(Exp.nTargets(trial),Exp.presentationRadius,screen.xCenter, ...
        screen.yCenter,Exp.hemifield(trial));

    if Exp.hemifield(trial) == 1 % pick items list from left hemifield
        tmpTargetsPositionsX = targetsPositionsX(targetsPositionsX < screen.xCenter);
        tmpTargetsPositionsY = targetsPositionsY(targetsPositionsX < screen.xCenter);

    else % pick items list from right hemifield
        tmpTargetsPositionsX = targetsPositionsX(targetsPositionsX > screen.xCenter);
        tmpTargetsPositionsY = targetsPositionsY(targetsPositionsX > screen.xCenter);
    end

    % shuffle and pick one item as target for the trial, then retrieve the
    % coordinates
    tmpTargetsPositionsXYPicked = randperm(length(tmpTargetsPositionsX),1);
    pickedTargetX = tmpTargetsPositionsX(tmpTargetsPositionsXYPicked);
    pickedTargetY = tmpTargetsPositionsY(tmpTargetsPositionsXYPicked);

    timedout = 1;
    rsp(trial).response = 'null'; % initialize the response as none
    distractorFeature = randi([1,2],length(targetsPositionsX)); % shared feature condition between target and distractor (50 % chances)

    tStart = GetSecs; % RT initialization

    while (GetSecs-tStart) < Exp.searchTime
        
        outp(parportAddr,triggers(1));
        WaitSecs(0.05);
        outp(parportAddr,0);
        drawFixCross(screen.wPtr, screen.allCoords, screen.white, screen.xCenter, screen.yCenter)
        drawTargets(screen.wPtr,targetsPositionsX,targetsPositionsY,screen.white,Exp.targetsSize,Exp.targetsWidth) %drawTargets(screen,x,y,color,size,width)

        % draw the confounder feature according to the distractorFeature
        % matrix
        for item = 1:length(targetsPositionsX)
            drawBlackLineConfounder(screen.wPtr,targetsPositionsX(item),targetsPositionsY(item),grey,Exp.targetsSize,Exp.targetsWidth*2,distractorFeature(item))
        end

        % draw the target (i.e. a black line that covers portion of the
        % white rectangle creating the emptiness left or right)
        drawBlackLineTarget(screen.wPtr,pickedTargetX,pickedTargetY,grey,Exp.targetsSize,Exp.targetsWidth*2,Exp.hemiObject(trial))
        screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);

        % check for keyboard press during stimuli presentation
        [keyIsDown, secs, keyCode, ~] = KbCheck;

        if keyIsDown % if a response is given
            rsp(trial).RT = secs - tStart; % get RT
            rsp(trial).response = KbName(keyCode); % get response and overwrite
            timedout = 0; % no timedout
            break ; % close the while loop
        end
    end

    if timedout == 1 % give more time to answer, but without showing the visual search array
        while (GetSecs-tStart) < Exp.responseTime
            drawFixCross(screen.wPtr, screen.allCoords, screen.white, screen.xCenter, screen.yCenter)
            screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
            [keyIsDown, secs, keyCode, ~] = KbCheck;

            if(keyIsDown)
                rsp(trial).response = KbName(keyCode);
                rsp(trial).RT = secs - tStart;
                timedout = 0;

                break
            end
        end
    end


    % update matrix
    rsp(trial ).timedout= timedout;
    rsp(trial).nTargets = Exp.nTargets(trial);
    rsp(trial).pickedTargetX = pickedTargetX;
    rsp(trial).pickedTargetY = pickedTargetY;
    rsp(trial).hemiField = Exp.hemifield(trial);
    rsp(trial).hemiObject = Exp.hemiObject(trial);

    if or(rsp(trial).response == keyChosen(1) & rsp(trial).hemiObject == 1, rsp(trial).response == keyChosen(2) & rsp(trial).hemiObject == 2)
        rsp(trial).outcome = 'valid';
    %elseif ~or(rsp(trial).response == keyChosen(1) & rsp(trial).hemiObject == 1, rsp(trial).response == keyChosen(2) & rsp(trial).hemiObject == 2)
    else
        rsp(trial).outcome = 'invalid';
    end

    %display(append('=================Number targets ',num2char(pp(trial).nTargets)))
    %     display(append('-----------------Hemifield : ',pp(trial).hemiField))
    display(append('-----------------Response given : ',rsp(trial).response))
    disp(append('----------------------Outcome : ',rsp(trial).outcome))


    % adjust fixation cross color to give feedback about trial outcome
    if rsp(trial).outcome == "valid"
        colorCross = screen.green;
        rsp(trial).iscorrect=1;
    elseif rsp(trial).outcome == "invalid"
        colorCross = screen.red;
        rsp(trial).iscorrect=-1;
    end

    if rsp(trial).response == "null"
        rsp(trial).iscorrect=0; %overwriting if no answer
    end


    % add in the results whether it was training or not
    if trainBlock && trial <=nPracticeTrials
        rsp(trial).training0_or_expe1 = 0;
    else
        rsp(trial).training0_or_expe1 = 1;
    end


    drawFixCross(screen.wPtr, screen.allCoords, colorCross, screen.xCenter, screen.yCenter)
    screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
    WaitSecs(1);

    if ismember(trial, Exp.pauseTrials)== 1
        % show an encouragement slide
        indic7=strcat(indic71,num2str(blockCounter),'/',num2str(total_blocks),indic72);
        DrawFormattedText(screen.wPtr, indic7,...
            'center', 'center', screen.white,break_line,0,0,v_spacing);
        screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
        blockCounter = blockCounter + 1;
        KbStrokeWait;
    end

    %% Computing score if ()
    list_rsp(end+1)=(rsp(trial).iscorrect);
    Exp.score=sum(list_rsp== 1);
    Exp.maximum_score_achievable=size(rsp,2);
    Exp.relative_score=(Exp.score/Exp.maximum_score_achievable)*100;
    disp(append("--------------------Score is ",num2str(Exp.score)))

    score=Exp.score;

    fprintf('Saving responses ... \n');
    filename_resp_mat = string(strcat(Path_beh,filesep, append(name_bids,'_desc-beh.mat')));
    save(filename_resp_mat,'rsp');
    %csv rsp
    file_csv=string(strcat(Path_beh, filesep,append(name_bids,'_desc-beh.csv')));
    writetable(struct2table(rsp),file_csv);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------
%                       Store results
%----------------------------------------------------------------------
%% Clean and save
% Clearing textures
fprintf('Saving experimental settings ... \n');
filename_info_mat = string(strcat(Path_beh,filesep, append(name_bids,'_desc-settings-exp.mat')));
save(filename_info_mat,'Exp'); %save all info
disp(append('Reading the saved ',name_bids,'-settings-exp.mat'));
%csv Exp
file_csv=string(strcat(Path_beh, filesep,append(name_bids,'_desc-settings-exp.csv')));
writetable(struct2table(Exp),file_csv);



DrawFormattedText(screen.wPtr,indic_endexpe,...
    'center','center',screen.white);
screen.vbl = Screen('Flip', screen.wPtr, screen.vbl + screen.ifi/2);
WaitSecs(3);

%% Ending the Experiment
diary off;
% Screen('Close',screen.wPtr);
sca;
% close all;
ListenChar(1);
ShowCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------
%                       FUNCTIONS
%----------------------------------------------------------------------


    function drawFixCross(screen,crossCoords,crossColor,xCenter,yCenter)
        % Draw a simple fixation cross

        Screen('DrawLines', screen, crossCoords, 4, crossColor, [xCenter yCenter], 2);

    end


    function drawTargets(screen,x,y,color,size,width)
        % Draw the item for the display array (rectangles)

        for i = 1:length(x)

            Screen('FrameRect',screen,color,[x(i) - size, y(i) - size, x(i) + size, y(i) + size],width)

        end

    end

    function drawBlackLineConfounder(screen,x,y,color,length,width,up_bottom)
        % draw the confounding feature shared between distractors and target
        % (missing line top bottom)

        if up_bottom == 1

            Screen('DrawLine',screen,color, x - length/2, y + length , x + length/2, y + length, width)

        else

            Screen('DrawLine',screen,color, x - length/2, y - length, x + length/2, y - length, width)

        end

    end


    function drawBlackLineTarget(screen,x,y,color,length,width,missing_side)
        % draw the target specific feature, left or right missing part

        if missing_side == 2 % right part missing

            Screen('DrawLine',screen,color, x + length, y + length/2, x + length, y - length/2, width)

        elseif missing_side == 1

            Screen('DrawLine',screen,color, x - length, y + length/2, x - length, y - length/2, width)

        else

        end

    end

    function [xPoints, yPoints] = calcTargetsPositions(nTargets,radius,xCenter,yCenter,hemifield)

        % Function for calculating the coordinates for all the item displayed in a
        % trial, given a n of targets and a radius for our circle, we calculate the
        % coordinates for each target position

        % calculate list of angles
        angles = linspace(0,2*pi,nTargets+1);
        % calculate half angle for tilt
        angles_gap = angles(2) - angles(1);
        % since first and last position are the same, we calculate 1 more and
        % eliminate the last one
        angles(end)=[];

        if hemifield == 1 % to control when we have only one item, start calculating the position from left
            xPoints = xCenter - radius*cos(angles);
            yPoints = radius*sin(angles) + yCenter;

        elseif hemifield == 2 % opposite
            xPoints = radius*cos(angles) + xCenter;
            yPoints = radius*sin(angles) + yCenter;
        end

        % tilt if on items appeares in the middle of the display
        if any(xPoints == xCenter)

            if hemifield == 1 % balance for the tilt, sometimes clockwise, sometimes counterclockwise

                xPoints = radius*cos(angles + angles_gap/2) + xCenter;
                yPoints = radius*sin(angles + angles_gap/2) + yCenter;

            else

                xPoints = radius*cos(angles - angles_gap/2) + xCenter;
                yPoints = radius*sin(angles - angles_gap/2) + yCenter;
            end

        end

    end


    function [matrix_exp_random] = create_exp_visual_search(maxNTargets,nBlocksRep)

        % Creates the experimental matrix for the visual search experiment:
        %
        % Input:
        %   maxnTargets = maximum number of targets possible in a sigle display
        %   array, even int
        %   nBlocksRep = number of experimental blocks repetition, int
        %   targetsPair = flag for even or odd n of stimuli displayed between the
        %   two hemifields, bool 0 = odd, 1 = even
        %
        % Return:
        %   matrix_exp_random = matrix of experimental conditions, where row 1:3
        %   are randomized N of targets (int) - condition for hemifield or target
        %   (0 or 1) - condition for target location ( missing target side, 0 or 1)


        minimumRep = 4; % 2 hemifield x 2 hemiobject

        nTargets = repmat(2:2:maxNTargets,1,minimumRep);
        hemifield = [];
        hemiobject = [];

        for rep = 1:minimumRep % we need a minimum of 4 reps for complete randomization

            switch rep

                case 1

                    hf = repmat(1:2,1,maxNTargets/2);hf = hf(1:maxNTargets/2);
                    ho = repmat(1:2,1,maxNTargets/2);ho = ho(1:maxNTargets/2);

                case 2

                    hf = flip(repmat(1:2,1,maxNTargets/2));hf = hf(1:maxNTargets/2);
                    ho = flip(repmat(1:2,1,maxNTargets/2));ho = ho(1:maxNTargets/2);

                case 3

                    hf = ones(1,maxNTargets/2);
                    ho = repmat(2,1,maxNTargets/2);

                case 4

                    hf = repmat(2,1,maxNTargets/2);
                    ho = ones(1,maxNTargets/2);

            end

            hemifield = [hemifield,hf];
            hemiobject = [hemiobject,ho];

        end

        matrix_exp = [nTargets;hemifield;hemiobject];

        % repeat depending on the n of blocks
        matrix_exp = repmat(matrix_exp,1,nBlocksRep);

        % randomize
        ind = randperm(size(matrix_exp,2));
        matrix_exp_random = matrix_exp(:,ind);

    end



    function [outcome] = check_training(responses,nTrial)
        % this function computes a rapid score for the practice block and
        % if performance is quite low it then restart the trial routine
        
        % responses : the response or answer struct for pp
        % nTrial : number of trial to compute the accuracy on
        % rsp : the pp responses and/or answers struct
        % trial : the trial index in the experiment logic

       if sum(responses == 1) < floor(nTrial*(2/3))
           % send an outcome (0 check not passed)
           outcome = 0; 

       else
           % send an outcome (1 check passed)
           outcome = 1; 
       end
    
   end

end




