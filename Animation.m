classdef Animation
    % Gathers information on the entire animation.

    properties
        currentFrame = 1;
        % index of current frame used for rendering purposes.
        
        frames = []
        % a list of animation frames used to render everything.
        % this list must support quick, in-order insertion.

        frameUpdateFcn = [];
        % function that accepts a figure and uses an animation's framedata
        % to render the
        
        imgExportFormat = {};
        % format that can be used to export videos.
        % opts = {'avi','mpeg'};
        
        name = [];
        % name of output files for animation.        
        
        videoExportFormat = {};
        % file type of video to export.
        % opts = {'avi','mpeg'};

    end
    
    methods
        
        function renderFrame(obj)
            % renders the next frame.
            obj.renderFrameNo(obj.currentFrame+1);
        end
        
        function renderFrameNo(obj,idx)
            % Renders a frame based on index.
            if numel(obj.frames) > idx
                error('The frame at this position does not exist.');
            end
            
        end
        
    end
    
end

