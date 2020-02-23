Data(1).name = 'red';
Data(1).Color = [255 0 0];
Data(2).name = 'green';
Data(2).Color = [0 255 0];
Data(3).name = 'blue';
Data(3).Color = [0 0 255];

pre = '<HTML><FONT color="';
post = '</FONT></HTML>';

listboxStr = cell(numel( Data ),1);

for i = 1:numel( Data )
   str = [pre rgb2Hex( Data(i).Color ) '">' Data(i).name post];
   listboxStr{i} = str;
end

figure; hListBox = uicontrol('Style','list', 'Position', [20 20 100 100], 'String', listboxStr );

function hexStr = rgb2Hex( rgbColour )

hexStr = reshape( dec2hex( rgbColour, 2 )',1, 6);

end