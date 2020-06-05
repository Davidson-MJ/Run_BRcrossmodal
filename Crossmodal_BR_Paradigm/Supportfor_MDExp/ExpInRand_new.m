function Order = ExpInRand_new(params)
%  Used in every experiment to determine the order of what will
% happen.MD

%Applies certain constraints to avoid consecutive visual only periods.
%% Creating the situations, and just changing the order

%determine how many trials we can git in per block.

t_types =    [1,82,83,92,93];
t_length_secs = [params.Trialdurs.vonly, params.Trialdurs.short*2, ...
    params.Trialdurs.med*2];

%total time for trials, and interval between them:
trialpatt = sum(t_length_secs)+ params.minITI*length(t_types);
%%
%how many times can we repeat this pattern, given block duration.?
patreps = quorem(sym(params.blockduration), round(trialpatt)); 
% patreps = quorem(sym(params.blockduration), sym(round(trialpatt))); 

% 
% params.minITI =  3;              %minimum time (s) between crossmodal input.
% params.Trialdurs.vonly = 2.6;    % seconds duration of visual only 'trials' within a block
% params.Trialdurs.short = 2;      % seconds,
% params.Trialdurs.med = 3.1;      % seconds,
% params.Trialdurs.long = 4; 

%%
Sits = repmat(t_types, 1,patreps);
Order = Sits(:,randperm(length(Sits))); 
%%
iOrderchnk=1;
while 1    
    if iOrderchnk==length(Order)
        break
    end
    %
    numFound = Order(1,iOrderchnk);
    
    if numFound==1 && Order(1,iOrderchnk+1) ==1 %consecutive visual only periods.
        
        %re-randomize
        Order = Order(:,randperm(length(Order)));
                
        iOrderchnk=1; %reset count;
    
    else
        iOrderchnk=iOrderchnk+1;
    end
    %
end


end
    
        
    



