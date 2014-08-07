function frame_print(fig, varargin)
% Prints a frame to a file. Uses an SVG printing function and a Java-based
% rendering tool to render high quality images.
%
% This is basically a specialized Print command with support for options
% such as TIFF, PNG, JPEG, and SVG rendering.
%
% Note that SVG Rendering doesn't yet render formatting commands to SVG.
%

% Grabs figure window information.
oldunits = get(fig,'units');
set(fig,'units','pixels');
position = get(fig,'position');
set(fig,'units',oldunits);
format = 'SVG';

% sets defaults.

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
            % sets the aspect ratio [w,h]. Normalizes the aspect ratio if
            % it is in formats such as [21,9].
            % Note that currently, it is not cenetered.
            
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

svgFile = strcat(destination,'.svg');

plot2svg(svgFile,fig);

if ~strcmpi(format,'SVG')
    frame_print_setup();
    
    import SVGRendering.SVGRenderer.*;
    
    if ~exist('SVGRendering.SVGRenderer.SVGRenderer','class') && ~strcmpi(format, 'SVG');
        error('SVG Renderer cannot be found. Try running this again.')
    end
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

