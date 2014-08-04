function render_batch_test(num_workers)
%RENDER_BATCH_TEST Summary of this function goes here
%   Detailed explanation goes here

if nargin == 0;
    num_workers = 4;
end
    thisFileName = mfilename('fullpath');
    
    % Extracts the folder path from the file. Note that we do not care
    % about the name of this file.
    [ThisFolder, ~] = fileparts(thisFileName);      
    
svgfiles = {'this.svg','this2.svg','this3.svg','this4.svg','this5.svg','this6.svg'};

for i=length(svgfiles):-1:1
    svgfiles{i} = fullfile(ThisFolder,'threadtestframes',svgfiles{i});
end
render_batch_svg(svgfiles, 'PNG',num_workers);

end

