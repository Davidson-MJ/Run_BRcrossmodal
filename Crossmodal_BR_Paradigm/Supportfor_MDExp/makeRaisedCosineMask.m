function raisedCosMask = makeRaisedCosineMask(imSize, nCosSteps , apHeight ,apWidth  );

% function to make a raised cosine mask to make a soft aperture mask for a
% 2D visual stimulus. 
% * If 2 arguments passed, it assumes the aperture has same diameter as Image.
% * if 3 arguments passed, it assumes aperture is smaller than Image and round.
% * Use 4 arguments to specify an elliptical aperture.

if nargin == 2
    apHeight = imSize;
    apWidth = apHeight;
elseif nargin == 3
    apWidth = apHeight;
end
HWratio = apHeight/apWidth;

if mod(imSize,2) == 1 % odd number
    imSize = imSize + 1;
    imTrim = 1;
end

[ X Y ] = meshgrid((-imSize/2+1:imSize/2),(-imSize/2+1:imSize/2));
radii = sqrt(X.^2 + (Y/HWratio).^2);

% Use a linear transformation to scale the radii values so that the 
% value corresponding to the inner edge of the ramp is equal to 
% (zero x pi) and the value for the outer edge is equal to (1 x pi). 
% The cosine of these values will be 1.0 and zero, respectively.
 
% set inner edge to zero
radii = radii - radii(floor(end/2),floor(end/2)+floor(apWidth/2)-nCosSteps); 

% Do linear transform to set outer edge to pi
outerVal = radii(floor(end)/2,floor(end)/2+(floor(apWidth/2)-1));
radii = radii * pi/outerVal ;

% set values more central than the soft aperture to 0 (ie, cos(0) = 1)
radii( find(radii<=0) ) = 0;

% set values more beyond soft aperture to pi (ie, cos(pi) = 0)
radii( find(radii>=pi) ) = pi;

% Finally, take cos of all the transformed radial values.
raisedCosMask = .5 + .5 * cos(radii);

size(raisedCosMask );

if mod(imSize,2) == 1% odd number
    raisedCosMask = raisedCosMask(1:end-1,1:end-1);
end

% imshow(raisedCosMask)
