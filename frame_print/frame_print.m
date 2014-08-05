function frame_print(fig, varargin)

% Wrapper function for a specialized PRINT command.
oldunits = get(fig,'units');
set(fig,'units','pixels');
position = get(fig,'position');
set(fig,'units',oldunits);
format = 'SVG';

width = [];
height = [];

aspectRatio = [position(3),position(4)]/position(4);

destination = pwd;

set(fig,'units',oldunits);

scaling = 1;
interval = 1:2:length(varargin);
for k=interval
    switch varargin{k}
        case 'aspect ratio'
            aspectRatio = varargin{k+1};
            if aspectRatio(2) ~= 1
                aspectRatio = aspectRatio/aspectRatio(2);
            end
            
        case 'format'
            format = varargin{k+1};
        case 'width'
            width = varargin{k+1};
        case 'height'
            height = varargin{k+1};
        case 'scaling'
            scaling = varargin{k+1};
        case 'destination'
            destination = varargin{k+1};
    end
end
if isempty(width)
    if isempty(height)
        wh = position(4)*aspectRatio;
        width = wh(1);
        height = position(4);
    else
        width = height*apsectRatio(1);
    end
else
    if isempty(height)
        height = width/aspectRatio(1);     
    end
end

    
frameWidth = width*scaling;
frameHeight = height*scaling;

% fprintf('Creating %s | %s | %d\n',destination,format,width);
frame_print_setup();
frame_print_setup();
import SVGRendering.SVGRenderer.*;

if ~exist('SVGRenderer','class') && ~strcmpi(format, 'SVG');
    error('SVG Renderer cannot be found. Try running this again.')
end

svgFile = strcat(destination,'.svg');

plot2svg(svgFile,fig);


if ~strcmpi(format,'SVG')
    
    if strcmpi(format,'JPG')
        format = 'JPEG';
    end
    renderer = SVGRenderer();
    switch upper(format)
        case 'JPEG'
            renderer.SetOutputFormat('JPEG');
            extension = '.jpg';
        case 'PNG'
            renderer.SetOutputFormat('PNG');
            extension = '.png';
        case 'TIFF'
            renderer.SetOutputFormat('TIFF');
            extension = '.tiff';
        otherwise
            error('Unknown format "%s" specified.',format);
    end
    renderer.SetWidth(frameWidth);
    renderer.SetHeight(frameHeight);
    
    outFile = strcat(destination,extension);
    
    renderer.RenderImage(svgFile,outFile);
    delete(svgFile);
end
end

