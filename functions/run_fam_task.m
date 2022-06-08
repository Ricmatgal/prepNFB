function run_fam_task(subID, projFolder, Sess)
% 
    usingMRI = 0;
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

    fFullScreen = 1;

    Screen('CloseAll');
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'ConserveVRAM', 64);

    AssertOpenGL();

    myscreens = Screen('Screens');
    screenid = 1; %max(myscreens);

    if ~fFullScreen
        ptb.Screen.wPtr = Screen('OpenWindow', screenid, [125 125 125], ...
            [40 40 720 720]);
    else
        % full screen
        % grey background
%         ptb.Screen.wPtr = Screen('OpenWindow', screenid, [125 125 125]); 
        % black background 
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

    % Setting the coordinates
    ptb.Screen.wRect                            = [0, 0, ptb.Screen.w, ptb.Screen.h];
    [ptb.Screen.xCenter, ptb.Screen.yCenter]    = RectCenter(ptb.Screen.wRect);
    ptb.Screen.xCoords                          = [-ptb.Screen.fixCrossDimPix ptb.Screen.fixCrossDimPix 0 0];
    ptb.Screen.yCoords                          = [0 0 -ptb.Screen.fixCrossDimPix ptb.Screen.fixCrossDimPix];
    ptb.Screen.allCoords                        = [ptb.Screen.xCoords; ptb.Screen.yCoords];

    % presentation parameters
    targetDur       = 1.5;    % presentation dur in sec (500ms)
    targetDur_frms  = round(targetDur / ptb.Screen.ifi);    % in frames
    ISI             = 750/1000;%round(500/ifi);  

    % get some color information
    ptb.Screen.white = WhiteIndex(screenid);
    ptb.Screen.black = BlackIndex(screenid);
    ptb.Screen.grey  = ptb.Screen.white / 2;

    % response option coords on the x and y axis relative to center 
    ptb.Screen.option_lx = -250;    % left option     x
    ptb.Screen.option_rx = 150;     % right option    x
    ptb.Screen.option_ly = 300;     % left option     y
    ptb.Screen.option_ry = 300;     % right option    y

    % accepted response keys
    ptb.Screen.leftKey  = KbName('1!');
    ptb.Screen.rightKey = KbName('2@');

    % show initial fixation dot
    ptb.Screen.fix      = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];
    
    Screen('FillOval', ptb.Screen.wPtr, [255 255 255], ptb.Screen.fix);
    
    ptb.Screen.vbl = Screen('Flip', ptb.Screen.wPtr,ptb.Screen.vbl+ptb.Screen.ifi/2);

    % load task parameters
    load([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder', filesep,...
        'stimParams', filesep, 'FAM_task_param_' subID '_' Sess]);
    
    % rootDir stims
    rootDirStimSet = [projFolder, filesep, subID, filesep, Sess, filesep,...
                      'TaskFolder', filesep, 'StimSets', filesep 'BaseSets', filesep, 'Stimuli'];
         
    imType = '.png';
    
    %% Prepare PTB Sprites
    sz = size(stim_list_final,2); 	% nr of unique images
    Tex = zeros(1,sz);              % initialize pointer matrix
    face_male_c     = 1;
    face_female_c   = 1;
    distr_c         = 1;
    for i = 1:sz
        %select stimulus based on general order and according to class order
        if stim_list_final(1,i) == 1

            target_path                 = [rootDirStimSet, filesep, 'FACES', filesep, 'male'];          
            face_male_c                 = face_male_c+1;
            results.condition_order{i}  = 'faces';
            
        elseif stim_list_final(1,i) == 2
            
            target_path                 = [rootDirStimSet, filesep, 'FACES', filesep, 'female'];
            face_female_c               = face_female_c+1;
            results.condition_order{i}  = 'faces';
            
        elseif stim_list_final(1,i) == 3
            
            target_path                 = [rootDirStimSet, filesep, 'OTHER'];
            distr_c                     = distr_c +1;
            results.condition_order{i}  = 'other';
            
        end

        currimg = char(fullfile([target_path, filesep, num2str(stim_list_final(2,i)), imType]));
        imgArr = imread(currimg);
        imgArr = imresize(imgArr,2); % resize image 
        
        Tex(1,i) = Screen('MakeTexture', ptb.Screen.wPtr, imgArr);
        clear imgArr % to be sure
    end

    % text font, size and style
    Screen('TextFont',ptb.Screen.wPtr, 'Courier New');
    Screen('TextSize', ptb.Screen.wPtr, 32);
    Screen('TextStyle',ptb.Screen.wPtr, 3);
    
    % fixation cross
    Screen('DrawLines', ptb.Screen.wPtr, ptb.Screen.allCoords,...
    4, [], [ptb.Screen.xCenter ptb.Screen.yCenter], 2);
    Screen('Flip', ptb.Screen.wPtr);

    % initialize some matrixes
    trialOns = zeros(size(stim_list_final,2),1);
    respVec  = zeros(size(stim_list_final,2),1);
    
    % wait for MRI trigger
    wait4me = 0;
    while wait4me == 0 
       [keyIsDown, secs, keyCode]=KbCheck;
        rsp=KbName(keyCode);
        if ~(isempty(rsp))
            if strcmp(rsp,'5%')==1 %'rsp=='5%'
                wait4me=1;
                Xstart=GetSecs
            end
        end
    end

    %==========================================================================
    %                            Experiment Start
    %==========================================================================

    % show intro screen: ('press space to start')
    DrawFormattedText(ptb.Screen.wPtr, 'Press the button when the same image repeats twice!', 'center', 'center', [255 255 255]);
    Screen('Flip',ptb.Screen.wPtr);
    WaitSecs(5);
    
    expOns = GetSecs;                                       % mark experiment onset
    for trial = 1:size(stim_list_final,2) 
        trialOns(trial,1) = GetSecs - expOns;       
        
       	% start listening to key input
        KbQueueCreate();    
        KbQueueStart();
        
        waitframes = 1;
        ptb.Screen.vbl = Screen('Flip', ptb.Screen.wPtr);
        for frame = 1:targetDur_frms

            % Draw the image to buffer
            Screen('DrawTexture', ptb.Screen.wPtr,  Tex(1,trial));

            % Flip the screen
            ptb.Screen.vbl = Screen('Flip', ptb.Screen.wPtr, ptb.Screen.vbl + (waitframes - 0.5) * ptb.Screen.ifi);
            
            [pressed, firstPress]=KbQueueCheck();
            if pressed 
                if firstPress(ptb.Screen.leftKey)
                    respVec(trial) = 1;
                    fprintf('\npress!')
                end
            end
        end
        
        % flip to empty buffer
        Screen('Flip', ptb.Screen.wPtr);
        
        resp0 = GetSecs;
        while (GetSecs - resp0) < ISI
            % continue listening
            [pressed, firstPress]=KbQueueCheck();
            if pressed 
                if firstPress(ptb.Screen.leftKey)
                    respVec(trial) = 1;
                    fprintf('\npress!')
                end
            end
        end
       
        % wait inter trial interval
%         WaitSecs(ISI);
    end
    
    % save all to folder
    save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder', filesep,...
        'taskResults', filesep, 'FAM_task_results_' subID '_' Sess])
    
    DrawFormattedText(ptb.Screen.wPtr, 'Thank you!', 'center', 'center', [255 255 255]);
    Screen('Flip',ptb.Screen.wPtr);
    WaitSecs(5);
    sca;
end