function dev= openASIOatMBI(output_channels, input_channels, sfreq, reallyneedlowlatency)
%%
%prep for low latency, multi-channel playback.
InitializePsychSound(reallyneedlowlatency)

%assume no devices available
dev_num=-1;
devs=PsychPortAudio('GetDevices');
n_devs=length(devs);
if n_devs<1
    erro('No available audio devices')
end
%% cycle through and see what we have.
ASIOdevs=[];
for d=1:n_devs
if strcmp(devs(d).DeviceName, 'ASIO4ALL v2')
    hasASIO=1;
    ASIOdevs= [ASIOdevs, d];
elseif strcmp(devs(d).DeviceName, 'Creative ASIO') 
    hasASIO=1;
    ASIOdevs= [ASIOdevs, d];
elseif strcmp(devs(d).DeviceName, 'SBAudigy5/Rx ASIO 24/96[C000]')
    hasASIO=1;
    ASIOdevs= [ASIOdevs, d];
elseif strcmp(devs(d).DeviceName, 'SBAudigy5/Rx ASIO[C000]')
    hasASIO=1;
    ASIOdevs= [ASIOdevs, d];
end
end
%%
if hasASIO %preference opening this sound device
    for iASIO=1:length(ASIOdevs)
       asiod = ASIOdevs(iASIO);
       Dev_Index=devs(asiod).DeviceIndex;
        try PsychPortAudio('Open', Dev_Index)







end