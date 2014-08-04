function render_batch_svg(svgfiles, format, num_workers, destination)

% Do some verification here.

% Render SVG as batch job.

if nargin < 1
    error('no SVG files provided.');
end

if nargin < 3
    num_workers = 4;
end

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
    
    if nargin < 4
    destination = directory;
    end
    
    outfiles{i} = fullfile(destination,strcat(filename,newext));
end
renderer = SVGRenderer();
import SVGRendering.SVGRenderer.*;
renderer.SetMaxNumWorkers(num_workers);
renderer.SetOutputFormat(format);
renderer.RenderImages(svgfiles, outfiles);

end

