function animation_setup(FORCE_RESET)
% animation_setup(FORCE_RESET);
% This function sets up necessary paths, etc. for the Animation class to be
% used within a running instance of MATLAB.
%
% This function adds java paths that aren't added by default to the Java 
% Dynamic Path. Without these paths, MATLAB cannot find Java objects used
% for rendering purposes.
% 
% An additional condition, FORCE_RESET, will add java paths whether or not
% it detects them already on the dynamic classpath. Use animation_setup(1);
% if you are re-compiling the SVGRenderer and don't want to restart MATLAB.

if nargin == 0
    FORCE_RESET = false;
end

if (usejava('jvm') == false)
    % Determines whether a JVM is running. No JVM means no option for
    % outputting things.
    
    warning('A Java Virtual Machine (JVM) does not seem to be running. You may not be able to render using the SVGRenderer.');
    
elseif (exist('SVGRenderer','class') == 0)
    
    % Finds full path to this file, animation_setup.    
    thisFileName = mfilename('fullpath');
    
    % Extracts the folder path from the file. Note that we do not care
    % about the name of this file.
    [ThisFolder, ~] = fileparts(thisFileName);
    
    % Finds folders containing Java classes to add to the classpath.
    
    SVGRendererPath = fullfile(ThisFolder,'SVGRendering','SVGRenderer');
    BatikPath = fullfile(ThisFolder,'SVGRendering','batik-1.7');
    SVGRenderingPath = fullfile(ThisFolder,'SVGRendering');
    
    % Adds these folders to the Java Dynamic Classpath if they are not
    % present, or if FORCE_RESET is selected.
    
    paths = {SVGRendererPath, BatikPath, SVGRenderingPath, ThisFolder};
    jpaths = javaclasspath();
    
    % Vector for determining whether a given path has been found.
    pathfound = zeros(1,length(paths));
    
    % Runs through all paths
    for j=1:length(paths)
        for k = 1:length(jpaths)
            % Checks if a path has already been found.
            if strcmp(jpaths{j},jpaths{k}) == true
                % declares path found.
                pathfound(j) = 1;
                break;
            end
        end
    end
    
    for j=1:length(pathfound)
        if pathfound(j) == 0 || FORCE_RESET
            fprintf('Adding java path %s \n',paths{j});
            javaaddpath(paths{j});
        end
    end
end
end


