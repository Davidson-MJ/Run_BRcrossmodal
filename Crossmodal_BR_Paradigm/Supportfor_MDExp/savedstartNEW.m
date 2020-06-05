
%% This was only added in to add robustness, if the user had to restart
% the program due to problems with EEG (OR THE PROGRAM DYING)

% collect user input in matlab command window.
params.inEEGroom=0;              % used to define path

SaveOrNot = upper(input('Do you want to use the previous experiment order? (Y/N): ', 's'));

if SaveOrNot == 'N'
    clc;
    % Getting their name
    params.Initials = upper(input('Subject Initials: ', 's'));
    params.Day1_2 = '1'; %upper(input('Day of experimentation: ', 's'));
    % initializing the random seed
    Date = clock;
    seed = round(sum(Date));
    rng(seed, 'v4');
    
    
    %% Creating the random permutations
    % we have different blocks in this design. 
    % originally: 2 practice
    % and 6 each of Auditory and Tactile (simultaneous), Auditory, Tactile,
    % also in phase or out of phase with the visual stimulus.
    
%     nblocktypes = 6; % Crossmodal x Phase combinations
    nblocktypes = 1; 
    nreps       = params.nreps;       % reps per block
    nprac       = params.nprac;
    
    nblocks = nblocktypes*nreps + nprac;
    
    Exps = zeros(nblocks, 2);
    
    %% now define the block order for this experiment.
    Blocksets=repmat([1:nblocktypes]',1,nreps);
    
    % Defining each situation
    ExpsNEW=[]; 
for irow = 1:size(Blocksets,1)
    %%
    newpair =Blocksets(irow,:)'; 
    tmp=randperm(nreps);
    newpair(:,2)=tmp; %select first 3 from randomized 1:4, 
    
    %% add for storage. 
    ExpsNEW=[ExpsNEW;newpair]; %concatenate (in order).
end
%%
%add extra column to randomize.
tmp = randperm(size(ExpsNEW,1))';
ExpsNEW(:,3)=tmp;
%sort according to this new column
tmp = sortrows(ExpsNEW,3);
ExpsNEW=tmp(:,1:2);

%% Save experiment order
Exps(3:nblocks,:) = ExpsNEW; % save experimental order.

% Define practice trials as : Auditory and tactile (Inphase; Low freq left), and 
% Auditory and tactile (out of phase; High Freq left).

Exps(1:2,:) = [3,1; 5,3]; 

%%
params.ExpOrder=Exps;
    
    cd(params.savedatadir)
    switch params.AttendEXP
        case 1 %attention on
            pattn = 'On';
        case 0
            pattn = 'Off';
    end
    
    % Names the subject's folder
    params.namedir = [params.Initials '_On_' num2str(Date(3)) '-' num2str(Date(2)) '_Day' num2str(params.Day1_2) '_Attn_' num2str(pattn)];
    
    %since this is a new ppant,
    mkdir(num2str(params.namedir))
    
    cd(params.namedir); % Saving the Seed and Date
    save('Seed_Data', 'seed', 'Date', 'params', 'Exps');
    cd ../
end

%% Checks whether the user wants to start from another position
StartPos = 1; % Default starting position is from the first block.

if SaveOrNot == 'Y' % Checks if we need to start from a different position
    params.Initials = upper(input('Subject Initials: ', 's'));
    params.Day1_2 = upper(input('Day of experimentation: ', 's'));
    % initializing the random seed
    Date = clock;
    prevAttending = upper(input('Was this an Attend condition? Y/N:', 's'));
    
    switch prevAttending
        case 'Y'
            pattn = 'On';
            params.AttendEXP=1;
        case 'N'
            pattn = 'Off';
             params.AttendEXP=1;
    end
    
    cd(params.savedatadir)
    params.namedir = [params.Initials '_On_' num2str(Date(3)) '-' num2str(Date(2)) '_Day' num2str(params.Day1_2) '_Attn_' num2str(pattn)];
    cd(params.namedir)
    load('Seed_Data', 'params', 'Exps');
    disp(Exps);
    StartPos = input('From which block position do you wish to start from?: ');
    % Hopefully, you can read which position you were on before it died.
    
   
    
end
%% EEG ports
 %reinitialize mex command, won't work based on previously saved. 
if params.EEG
    params.ioObj = io64; % initialise the mex command
    status = io64(params.ioObj); % Status of the driver
    params.port = hex2dec('0378'); % Portcode to send to EEG machine,
else
    params.ioObj=nan;
end


%% reset these variables each day/Experiment.
if StartPos==1
    Trainingperformance = []; 
    AttnperBlock=zeros(2,4);
end