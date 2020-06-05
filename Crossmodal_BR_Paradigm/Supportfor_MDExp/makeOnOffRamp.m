% written by D Alais 2001.function [ rampMat  rampLength  ] = makeOnOffRamp(rampTime,sampleLength,sampRate);% Function makes on/off ramps using a cumulative Gaussian profile.% rampTime is duration of ramp portion only ( in seconds).% sampleLength is number of bits to be played (sampleLength/sampRate = duration)% sampRate is in Hz.rampMat = ones(1,sampleLength);  % the full matrix.rampLength = rampTime * sampRate;rampVals = (1:rampLength ); % just the ramp portionrampVals = rampVals - mean(rampVals);onRamp = 0.5 + 0.5*erf(rampVals/(sqrt(2)*(length(rampVals)/5)));offRamp = 0.5 + 0.5*erf(rampVals/-(sqrt(2)*(length(rampVals)/5)));rampMat(1:length(onRamp)) = onRamp;rampMat(length(rampMat)-length(onRamp)+1:length(rampMat)) = offRamp;