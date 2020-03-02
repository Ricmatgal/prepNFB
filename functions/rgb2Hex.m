function hexStr = rgb2Hex( rgbColour )
% function used for colorcoding notifications.

hexStr = reshape( dec2hex( rgbColour, 2 )',1, 6);

end