%
%   cross-platform sound device initialisation using PsychPortAudio
%
%   attempts to initialise devices in this order:
%
%   1. ASIOsound- for ASIO4all high perfomance sound
%   2. MOTU Ultralite - for Mac
%   3. Fireface ASIO
%   4. built-in output (mac)
%   5. Built-in output (windows)
%

%   NOTES:
%
%   to use the built-in input & output simultaneously on a Mac with
%   PsychPortAudio, it best to create an aggregate device using
%   Audio MIDI Setup (you would then need to add the new aggregate
%   device to this code).
%
%
%   ella wufong - March 2012 - microfish@fishmonkey.com.au
%   updated MD - June 2016 - mjd070@gmail.com


function  dev = audio_device_init( output_channels, input_channels, sfreq, reallyneedlowlatency)

defaults('output_channels', [1 2], 'input_channels', [], 'sfreq', 44100, 'reallyneedlowlatency', true);

dbstop if error

n_output_channels = length(output_channels);
n_input_channels = length(input_channels);

%
%   more settings...
%

% latency_class = 0;  % don't care about latency
% latency_class = 1;  % low latency, but play nice
latency_class = 2;  % low latency, hog device


%
%   load PsychPortAudio driver...
%
InitializePsychSound(reallyneedlowlatency);



%
%   search flags for various external audio interfaces
%  %note that this list is not comprehensive, and a new driver may need to
%  be selected for your local machine.
Fireface_ASIO = false; 
Fireface = false;
Ultralite = false;
ASIOsound =false;
Primarysound=false;
Realtek1=false;
Realtek2=false;
Builtin=false;
%
%   to begin with assume we don't have any devices...
%
dev_num = -1;


%
%   get available audio devices
%
devs = PsychPortAudio('GetDevices');

n_devs = length(devs);

if n_devs < 1
    error('No audio devices found!');
end



%
%   scan through all available devices...
%
%   we don't know what the order might be, so we iterate through all
%   devices and store information for later
%
%%
for d = 1:n_devs
    
   if strncmp(devs(d).DeviceName, 'Primary Sound Driver', length('Realtek HD Audio output'))
        
        Fireface_ASIO = true;
        Fireface_ASIO_dev_num = d;
        
    elseif strncmp(devs(d).DeviceName, 'Fireface', length('Fireface'))
        
        Fireface = true;
        Fireface_dev_num = d;
        
    elseif strncmp(devs(d).DeviceName, 'MOTU UltraLite', length('MOTU UltraLite'))
        
        Ultralite = true;
        Ultralite_dev_num = d;
        
    elseif strcmp(devs(d).DeviceName, 'Primary Sound Driver') % changed from 'Built-in Output', MD
        
        Primarysound = true;
        Primarysound_dev_num = d;
        
     elseif strcmp(devs(d).DeviceName, 'ASIO4ALL v2')
         ASIOsound = true;
         ASIO_dev_num=d;
    elseif strcmp(devs(d).DeviceName, 'Speakers/Headphones (Realtek(R) Audio)')
        Realtek1 = true;
        Realtek1_dev_num=d;
    elseif strcmp(devs(d).DeviceName, 'Speakers (Realtek HD Audio output)')
        
        Realtek2=true;
        Realtek2_dev_num=d;
        
   elseif strcmp(devs(d).DeviceName, 'Built-in Output');
       Builtin = true;
       Builtin_dev_num= d;
       
   end 
end

% now cycle through these devices in our order of preference:
if ASIOsound
    dev_num = ASIO_dev_num;
elseif Ultralite
dev_num = Ultralite_dev_num;
elseif Fireface_ASIO
    dev_num = Fireface_ASIO_dev_num;
elseif Realtek1
    dev_num=Realtek1_dev_num;
    
elseif Builtin
    dev_num = Builtin_dev_num;
    
end
    
%
%   check that we have actually found an output device...
%
if dev_num == -1
    %%
    error(['Initialisation not complete, as no valid output device was found...' ...
        ' type: "open devs" in the command window and set dev_num to best available sound driver. ',...
        'Search for Audrate = 44100, output channels = 2, lowest latency possible'])
    
end

%%
%
%   make sure the device we are about to initialise actually has the
%   requested input/output channels available...

dev_index = devs(dev_num).DeviceIndex;
%%
if n_input_channels == 0    % output only

    mode = 1;   % ask for playback only, even if device can do duplex
    
    channels = n_output_channels;
    select_channels = output_channels - 1;  % physical channels are numbered from zero...

else
    
    channels = [n_output_channels n_input_channels];
    select_channels = [output_channels - 1; input_channels - 1];  % physical channels are numbered from zero...
    
end


%
%   open a handle to the device...

dev.handle = PsychPortAudio('Open', dev_index, mode, latency_class, sfreq, channels, [], [], select_channels);

PsychPortAudio('RunMode', dev.handle, 1);   % keep device in "hot standby" state...

%%
%
%   return the details of the initialised device handle...
%
dev.name = devs(dev_num).DeviceName;
dev.input_channels = input_channels;
dev.output_channels = output_channels;




end









