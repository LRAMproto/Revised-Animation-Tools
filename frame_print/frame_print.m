function frame_print(fig, destination, format, width)

% Wrapper function for a specialized PRINT command.

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
            extension = 'png';
        case 'TIFF'
            renderer.SetOutputFormat('TIFF');
            extension = '.tiff';
        otherwise
            error('Unknown format "%s" specified.',format);
    end
    renderer.SetWidth(width);
    
    outFile = strcat(destination,extension);
    
    renderer.RenderImage(svgFile,outFile);
    delete(svgFile);
end
end

