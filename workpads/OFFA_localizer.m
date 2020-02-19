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

% + This scripts generate the onsets matrix, to implemente in the 1rst level analyses --> S**_LocalizerOnset.mat

%% Initialise COGENT:

% Try to stop Cogent, in case it was previously terminated improperly:
try
    stop_cogent;
end
% Delete all variables in the workspace:
clear all;

% rootPath = 'D:\1Manip_HoliFace\';
rootPath = pwd;%'D:\LABNIC\EmilieM\';
if exist(rootPath,'file') == 0
    error(['The path ',rootPath,' doesn''t exist']);
end
cd (rootPath);
addpath([rootPath,'\Images_Localizer']);
addpath([rootPath,'Cogent_Script\']);

% Initialize the inpout32.dll low-level I/O driver:
config_io;
% Set condition code to zero:
outp(888, 0);

% base all random fonction on clock to completly random it
rand('state',sum(100*clock));

% Take the ID and Number of the subject
SubjectNumber = input ('Subject number > ','s');
while isempty(SubjectNumber) == 1
    SubjectNumber = input ('Subject number > ','s');
end
SubjectID = input ('Subject ID > ','s');
while isempty(SubjectID) == 1
    SubjectID = input ('Subject ID > ','s');
end
rootPathData = [rootPath,'\S', num2str(SubjectNumber,'%02d'),'\behavior\'];

% rootDirData = ['D:\1Manip_HoliFace\S', num2str(SubjectNumber,'%02d'),'\behavior\'];
if exist(rootPathData,'file') == 0
%     error(['The path ',rootPathData,' doesn''t exist']);
    fprintf('results path: %s not found, we created it for for you\n', rootPathData)
    mkdir(rootPathData)
end
logname = [rootPathData,SubjectID,'_',SubjectNumber,'_faceloc.log'];
resname = [rootPathData,SubjectID,'_',SubjectNumber,'_faceloc.res'];
config_log(logname);
config_results(resname);

% Go to the directory corresponding to the subject
% eval(['cd ',rootDirData]);  % put into the subfolder behavior 
% eval: execute string containing matlab expression
%02d:0 = mettre un zéro devant quand n° sujet<10; 2 = Toujours 2 chiffres
% d = indique que c'est une valeur décimal (pas un string)
% OK si moins de 100 sujets, sinon %03d

% Configure display in full screen mode for use with Cogent:
config_display(0,3,[0 0 0],[1 1 1],'Arial',40,4,0);


% Configure keyboard for use with Cogent:
config_keyboard;

% Configure faces
config_data('FFAlocalizer2.dat');

% Configure timing file
% eval(['config_log S','_',num2str(subject,'%02d'),'_Localizer.log']);     
% % Configure results file
% eval(['config_results S','_',num2str(subject,'%02d'),'_Localizer.res']);     


% Initialise timing
nb_bloc=8; %number of bloc for one condition
duration=500; % Duration of each picture
interP=50; % Time between each picture
interB=3000; % Time between each bloc

%time between trial, jittered to 3000ms, but sum always equal to 3000*nb_bloc 
interT= random('unif',2000,4000,[1,nb_bloc]); % uniforme
remainder= (3000*nb_bloc) - sum(interT);
division = remainder  / nb_bloc;
interT = round(interT + division);

% order of presentation (1=fearful, 2=neutral, 3=house, 4=oval, 5=scramble)
% (already implement in orderFFA.res, O is useful only for log file)
O=[4,1,2,3,5; 3,5,1,4,2; 4,1,3,2,5; 1,3,2,4,5; 4,1,2,3,5; 4,3,5,1,2; 2,1,3,4,5; 1,5,2,3,4];
% 8 runs de 4 blocs de 10 images (8*4*10 = 320 stim)
load orderFFA2.mat

% to set the trigger
code=[1,2,4,8,16];

% Start the Cogent environment:
start_cogent;

% dot between blocs
clearpict(2);
preparestring('.',2);
% blank between picture
clearpict(3);


% Empty the keyboard buffer:
clearkeys;

addresults ('1','fearful face', '(1,14)', '(3,15)', '(4,7)', '(7,18)', '(8,5)';
addresults ('2','neutral face', '(3,37)', '(4,30)', '(6,46)');
addresults ('3','house', '(1,33)', '(2,9)', '(5,35)', '(6,19)', '(7,29)', '(8,33)');
addresults ('4','oval', '(2,23)', '(5,2)', '(6,10)', '(8,48)');
addresults ('5','scramble', '(1,49)','(2,18)','(3,50)','(5,42)');
addresults ();
addresults ('run','trial','type','picture','repetiton','key','time','nb press');


%prepare and display starting
clearpict(4);
% ENGLISH
preparestring('INSTRUCTIONS',4,0,250);
preparestring('Please, focus on the central point',4,0,100);
preparestring('Push the button when the stimuli displayed on the screen',4,0,-50);  
preparestring('is the same as the previous one',4,0,-100);
drawpict(4);

onsets=zeros(5,8);% Generate a matrix 4 lignes (Conditions) * 8 colonnes (Run) de zeros
% la matrice 'Ons' donnera l'onset du début du bloc fearfull/neutral/oval/house dans chacun des 8 runs
% la fin de l'onset est calculé via la durée d'1 bloc qui est défini à 5450ms ligne 321


% dummy_scans = 10;

% Wait for scanner
[press,startIRM]=waitkeydown(inf,32);

% Send trigger to biopac
outp(888, 128);
logstring(sprintf('start'));
wait(200);
outp(888, 0);

for i = 1: nb_bloc  % one bloc here, is one "block" of each type, (so it is 4 blocks of 10 picture)
    
    %start the loop for display pictures
    for j = 1:50  %  50 pictures = 10 pictures * 5 types.  There is a break each 10 pictures
        
        k=0;
        t=0;
        n=0;
        
        clearpict(1);
        local= getdata(orderFFA2(i,j),1);

        try
            loadpict(local, 1);
        end % of try
        
        
        %4 "if" loops to wait between blocs of picture and save timing
        % ten pictures by type, so change of type at 1, 11, 21 and 31, 41
        
        if j == 1
            outp(888, 0);
            logstring('break');
            drawpict(2);
            wait(interT(1,i)); %= interB jiterred
            logstring(O(i,1));
            type=O(i,1);
            outp(888, code(type));
        end
            
        if j == 11
            outp(888, 0);
            logstring('break');
            drawpict(2);
            wait(interB); 
            logstring(O(i,2));
            type=O(i,2);
            outp(888, code(type));
        end
        
        if j == 21
            outp(888, 0);
            logstring('break');
            drawpict(2);
            wait(interB);
            logstring(O(i,3));
            type=O(i,3);
            outp(888, code(type));
        end
        
        if j == 31
            outp(888, 0);
            logstring('break');
            drawpict(2);
            wait(interB);
            logstring(O(i,4));
            type=O(i,4);
            outp(888, code(type));
        end
        
       if j == 41
            outp(888, 0);
            logstring('break');
            drawpict(2);
            wait(interB);
            logstring(O(i,5));
            type=O(i,5);
            outp(888, code(type));
        end

        %display picture
        picture=drawpict(1);
        wait(duration);
        
        % Define Onset of the pictures
        % TR = 0.65; % (en secondes)
        if j == 1 || j == 11 || j == 21 || j == 31 || j== 41
            onsets(type,i)=(picture-startIRM)/1000;
            % type = display content of file
            % onset (en seconde) = (OnsetImage - StartIRM) /1000
            % onset (en nbre de scans) = ((OnsetImage - StartIRM)/1000)/TR
            % enlever le /1000 si on le veux en ms
            % remplit la matrice de 0 "onsets" avec les valeurs des onsets
        end
        
        %blank betweem trial
        drawpict(3);
        
        
        % to add repetition in results file
        if i==1 && (j==14 || j==33)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        elseif i==2 && (j==9 || j==23)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        elseif i==3 && (j==15 || j==37)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        elseif i==4 && (j==7 || j==30)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        elseif i==5 && (j==2 || j==35)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        elseif i==6 && (j==10 || j==19 || j==36)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        elseif i==7 && (j==18 || j==29)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        elseif i==8 && (j==5 || j==23 || j==38)
            repet=1;
            % Send a trigger to biopac in line 6
            etat = inp(888);
            change = bitset(etat,6,1);
            outp(888,change);
        else
            repet=0;
        end
        
                
        % check for key presses
        readkeys;
        logkeys;
        [k, t, n]=getkeydown([28,29,30,31]);
        addresults (i,j,type,(picture-startIRM),repet,k,(t-startIRM),n);
        
        % Read keyboard buffer (ignore all except "52", i.e. <ESC>:
        [ keyout, time, nb ] = getkeydown( 52 ); 
        % If <ESC> has been pressed...
        if keyout == 52
            % ...terminate loop execution:
            break;
        end % of if block
        
        
        
        wait(interP);
        
        % set the 6th bit to 0 in the parallele port (become 1 if repeted picture)
        etat = inp(888);
        change = bitset(etat,6,0);
        outp(888,change);
    
    end; %of for j
        
    if keyout == 52
        % ...terminate loop execution:
        break;
    end % of if block
       
        
end; %of for i

drawpict(2);
wait(interB);

% Send trigger to biopac
outp(888, 128);
logstring(sprintf('stop'));
wait(200);
outp(888, 0);

%prepare and display stoping
clearpict(4);
preparestring('THANKS',4,0,100);
preparestring('You could relax',4,0,-50);  
drawpict(4);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ONSET MANAGER 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create .mat file for SPM analyses, contain onset of each bloc (in each 8 big blog/run)
filename = eval(['''S',num2str(SubjectNumber,'%02d'),'_LocalizerOnset.mat''']);
% Index mat file name according to the subject number
name={'Fearful', 'Neutral', 'House', 'Oval', 'Scramble'};
duree={5.450,5.450,5.450,5.450,5.450}; 
% Onset et dur en secondes sont générés dans la matrice 
% Attention, analyses 1rst level en nbre de scan!
% Convertion dans le script 1rst analyses (/TR)

for i = 1:5
    Onset{i}=onsets(i,:);
end

Ons{1}=Onset;
names{1}=name;
dur{1}=duree;

save(filename, 'names', 'dur', 'Ons');

% Wait for space press
waitkeydown(inf,71);

            
stop_cogent;
    
     
    
    
    
    
    
    