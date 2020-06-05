% function defaults('Variable',Value...)
% really useful function for setting defaults.
% 
% e.g., defaults('sfreq',48000,'dur',1) replaces
% if ~exist('sfreq','var')
%      sfreq = 48000;
% end
% if ~exist('dur','var')
%      dur = 1;
% end
% ... etc.
% INPUT: pairs of ['Variable name',value]

function defaults(varargin)

% iterate through arg lists
for idx = 1:2:length(varargin)
    % check if var exist in parrent workspace
    ifex = evalin('caller',['exist(''' varargin{idx} ''',''var'')']);
    if ~ifex
        % no, assign default value then.
        assignin('caller',varargin{idx},varargin{idx+1});
        % only use to display default arguments.
        %         caller = dbstack; caller = caller(end);
        %         disp(['In ' upper(caller.name) ' default variable ' varargin{idx} ' = ']);
        %         disp(varargin{idx+1});
    else    
        % if exst, but maybe empty []
        ifem = evalin('caller',['isempty(' varargin{idx} ')']);
        if ifem    
            % assign default value then. 
            assignin('caller',varargin{idx},varargin{idx+1});
            %             caller = dbstack; caller = caller(end);
            %             disp(['In ' upper(caller.name) ' default variable ' varargin{idx} ' = ']);
            %             disp(varargin{idx+1});
        end
    end
end
