%loadprevBRcalibration

%reorient and load this participants contrast values for each eye and Hz
%combination, established during calibration on day 1.


cd(params.savedatadir)
fols=dir([pwd filesep num2str(params.Initials) '*Day1' '*']);
cd(fols.name)
p2=load('Seed_Data', 'params');


%load previous gratings.
params.downContrRed_condLG = p2.params.downContrRed_condLG; %multiply outgoing colour and audio by what contrast mod? (1 = full contrast colour, need GG correction?).
params.downContrGreen_condLG = p2.params.downContrGreen_condLG ; %
params.downContrRed_condHG = p2.params.downContrRed_condHG; %%high green conditon, so differnece not as strong.
params.downContrGreen_condHG = p2.params.downContrGreen_condHG; %
params.downContrRed_condLR=p2.params.downContrRed_condLR; %high green conditon, so differnece not as strong.
params.downContrGreen_condLR=p2.params.downContrGreen_condLR;
params.downContrRed_condHR=p2.params.downContrRed_condHR;
params.downContrGreen_condHR=p2.params.downContrGreen_condHR;