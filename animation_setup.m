function animation_setup
% The following adds relevant Java paths that aren't added by default to
% the Java Dynamic Path.
% Without these paths, MATLAB cannot find Java objects.

if (usejava('jvm') == false)
	warning('A Java Virtual Machine (JVM) does not seem to be running. You may not be able to render using the SVGRenderer.');
else
% Finds the name of this file.

thisFileName = mfilename('fullpath');
% Extracts the folder path from the file.
[ThisFolder, file] = fileparts(thisFileName);

% Finds key Java paths to add to the java path.

SVGRendererPath = fullfile(ThisFolder,'SVGRendering','SVGRenderer');
BatikPath = fullfile(ThisFolder,'SVGRendering','batik-1.7');
SVGRenderingPath = fullfile(ThisFolder,'SVGRendering');

% adds these folders to the Java Path.
javaaddpath(SVGRendererPath);
javaaddpath(BatikPath);
javaaddpath(SVGRenderingPath);
javaaddpath(ThisFolder);
end


