% Code that just makes everything in the directory accessible

if ~exist('basefol', 'var')
    basefol=pwd;
    addpath(basefol)
end

%%
%add path for saved data
cd(basefol);
try cd('OutputData_MDEXP')
catch
    cd(basefol);
    mkdir('OutputData_MDEXP')
    cd('OutputData_MDEXP')
end

params.savedatadir = pwd;
%%

%add support folders
addpath([basefol  filesep 'Supportfor_MDExp']); 
% addpath([basefol  filesep 'Supportfor_Exp']);
addpath([basefol filesep 'Supportfor_Lunghi']);



%% key responses.
KbName('UnifyKeyNames')
    params.keyLeft = KbName('LeftArrow'); % windows OS
    params.keyRight= KbName('RightArrow');

    
%% check for previous participant information.
savedstartNEW           %checks for participant info, incase we crashed.


