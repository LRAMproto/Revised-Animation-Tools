function outfiles = render_batch_svg(svgfiles, varargin)
% Renders a list of SVG images as a batch job.
DEFAULT_WIDTH = 400;
MAX_NUM_WORKERS = 8;
DEFAULT_NUM_WORKERS = 3;
DEFAULT_FORMAT = 'JPEG';

if rem(nargin,2) < 1
    error('Too many input arguments.');
end

width = DEFAULT_WIDTH;
format = DEFAULT_FORMAT;
num_workers = DEFAULT_NUM_WORKERS;
destination = [];

for k=1:2:nargin-2
    opt = varargin{k};
    optarg = varargin{k+1};
    switch lower(opt)
        case 'width'
            width = optarg;
        case 'format'
            format = optarg;
        case 'destination'
            destination = optarg;
        case 'num_workers'
            num_workers = optarg;
    end
end

% This part handles the case in which there are more workers than rendering
% jobs. This will not happen very often with 3>8 workers, but is worth
% doing for future use.

num_workers = min(length(svgfiles),num_workers);

% Verification

switch upper(format)
    case 'PNG'
        newext = '.png';
    case 'JPG'
        newext = '.jpg';
    case 'JPEG'
        newext = '.jpg';
    case 'TIFF'
        newext = '.tiff';
    otherwise
        error('Output format "%s" not recognized.',format);
end

outfiles{length(svgfiles)} = [];

for i=length(svgfiles):-1:1
    [directory, filename, ext] = fileparts(svgfiles{i});
    if ~strcmpi(ext, '.svg')
        warning('File "%s" may not be an SVG file (extension is "%s)".\n',svgfiles{i},ext);
    end
    
    if isempty(destination);
    destination = directory;
    end
    
    outfiles{i} = fullfile(destination,strcat(filename,newext));
end

% Imports the SVG Renderer.
import SVGRendering.SVGRenderer.*;

% Uses a special function to distribute a set of input and output files
% between all workers.

in_divs = divvy(svgfiles,num_workers);
out_divs = divvy(outfiles,num_workers);

% 
if num_workers > MAX_NUM_WORKERS
    error('Maximum number of %d workers exceeded (%d). Tests exceeding %d workers have resulted in MATLAB crashes. Use %d workers for best performance.',MAX_NUM_WORKERS,num_workers,MAX_NUM_WORKERS,DEFAULT_NUM_WORKERS);
end

if num_workers > DEFAULT_NUM_WORKERS
    warning('Note: Testing has revealed no significant improvements in performance using more than %d workers. Set number of workers to %d for the best balance between memory usage and time efficiency.',DEFAULT_NUM_WORKERS,DEFAULT_NUM_WORKERS);
end    

for k=num_workers:-1:1
    % Retrieves the set of input files and output files.
    winfiles = in_divs{k};
    woutfiles = out_divs{k};
    % Creates an SVG Renderer object.
    workers{k} = SVGRenderer();
    workers{k}.SetInputFilenames(winfiles);
    workers{k}.SetOutputFilenames(woutfiles);    
    workers{k}.SetOutputFormat(format);   
    workers{k}.SetWidth(width);
    % starts a seperate thread of execution while allowing MATLAB to go to
    % prepare the next worker.
    workers{k}.start();     
end

for k=num_workers:-1:1
    % prevents the thread from executing until this worker is done.
    workers{k}.join(); 
    
end


% renderer = SVGRenderer();
% renderer.SetMaxNumWorkers(num_workers);
% renderer.SetOutputFormat(format);
% renderer.RenderImages(svgfiles, outfiles);

end

