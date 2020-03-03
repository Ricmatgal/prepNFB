function create_task_param(subID, projFolder, Sess)

%     rng('shuffle')
    
    nrRuns = 5;
    
    % still to implement, dynamically choose stim folder 1 or 2 to
    % counterbalance across subjects! 
    stimSet = 'Stims_1';
    
    % load the faces encoded in memory 
    load([projFolder, filesep, subID, filesep, Sess, filesep, 'TaskFolder', filesep, 'stimParams',...
        filesep, 'encStims_sub' subID '_' Sess])

    % prepare stimulation cock
    % stim folder names
    face_folder = 'Faces';
    contr_folder = 'Animals';

    nr_faces = 39;
    nr_contr = 31;

    % prepare stimulation order
    face_order      = randperm(nr_faces,nr_faces);      % shuffle face stims (we have 35 face stims)
    contr_order     = randperm(nr_contr,nr_contr);      % shuffle animal order

    % here we iniate the two stim classes (general_order): 1 for faces, 2 for
    % animals
    % in addition we create a task order: 1 for detection only, 2 for
    % idenity judment only, 3 for both.
    general_order   = [ones(1,nr_faces) ones(1,nr_contr)+1];   % faces or animals
    % task_order      = [ones(1,13), ones(1,13)+1, ones(1,13)+2,...
    %                     ones(1,12), ones(1,12)+1, ones(1,11)+2];     
    task_order      = [ones(1,10), ones(1,10)+1, ones(1,19)+2,...
                        ones(1,10), ones(1,10)+1, ones(1,15)+2];     

    % this is a shuffle vector that we can use to randomize our conditions and
    % tasks in a controlled manner
    shuf = randperm(numel(general_order));

    % apply the shuffle to both
    general_order = general_order(shuf);
    task_order = task_order(shuf);
    
    % break up in runs: make dynamic!!
    general_order = reshape(general_order,70/5, 5)';
    task_order = reshape(task_order,70/5, 5)';
    
    stimnrs         = 1:numel(dir([projFolder, filesep, 'TaskFolder',...
        filesep, stimSet filesep, face_folder, filesep, '1']))-3;    % how many images per trial?  -3 for ., .., and 0
    stimnames       = num2cell(stimnrs);                            % convert the integers to strings so we can use it
    
    % experiment loop
    face_c = 1;
    obje_c = 1;
    for row = 1:size(general_order,1)
        
        user_fb_update({['Loading images run: ' num2str(row)]},0,1);        
   
        tic
        trial = 1;
        for col = 1:size(general_order, 2)
        %select stimulus based on general order (face or animal) and according
        %to class order (old or new)
        % FACE
        if general_order(row, col) == 1
            target_path = [projFolder, filesep, 'TaskFolder', filesep, stimSet filesep,...
                face_folder, filesep, num2str(face_order(face_c))];

            results.condition_order{row, col} = 'faces';

            if ismember(face_order(face_c),encoded_faces)
                results.key{1,row, col} = 'face';      % stim class = face 
                results.key{2,row, col} = 'old';       % identity match with memorized (old)
            else
                results.key{1,row, col} = 'face';      % stim class = face 
                results.key{2,row, col} = 'new';       % identity mismatch with memorized (new)
            end

            face_c = face_c+1;
        % ANIMAL
        elseif general_order(row, col) == 2
            target_path = [projFolder, filesep, 'TaskFolder', filesep, stimSet filesep,...
                contr_folder, filesep, num2str(contr_order(obje_c))];

            results.condition_order{row, col} = 'animals';

            if ismember(contr_order(obje_c),encoded_contr)
                results.key{1,row, col} = 'animal';    % stim class = animal
                results.key{2,row, col} = 'old';       % identity match with memorized (old)
            else
                results.key{1,row, col} = 'animal';    % face detection
                results.key{2,row, col} = 'new';       % identity mismatch with memorized (new)
            end
            obje_c = obje_c +1;
        end

%         trial_imgs = zeros(200,200,147);
%         trial_imgs = zeros(400,400,147);
        ipaths = [];
        for imgs = 1:numel(stimnrs)
            ipaths = cellstr([ipaths; target_path, filesep, num2str(imgs) '.bmp']);
        end
        I = cellfun(@imread, ipaths,'uni',false);
        I = cellfun(@(x) imresize(x,2), I,'uni',false);
        
        Stims{trial} = I;
        trial = trial +1;
        end
    
        user_fb_update({['took: ' num2str(toc) ' sec']},0,1);
        
        user_fb_update({'Saving...'}, 0, 1)
        tic
        save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder',...
             filesep, 'stimParams', filesep, 'StimsRun_' num2str(row)], 'Stims');
        user_fb_update({['took: ' num2str(toc) ' sec']}, 0, 1);
      
    end
 
    save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder',...
        filesep, 'stimParams', filesep, 'NFB_task_param_' subID '_' Sess]);
    
    % report back to user
    user_fb_update({'NFB task stimuli and parameters: SAVED'},0,4)
end