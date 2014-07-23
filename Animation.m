classdef Animation < hgsetget
    % Gathers information on the entire animation.
    
    properties
        
        autoPreallocateMode = 'none';
        % automatically pre-allocates to make rendering faster.
        % opts = {'none','exponential','linear'};
        
        autoPreallocateExponent = 2;
        
        autoPreallocateSize = 1;
        
        currentFrame = 0;
        % index of current frame used for rendering purposes.
        
        displayFigure = [];
        % figure that displays the animation
        
        frames = []
        % a list of animation frames used to render everything.
        % this list must support quick, in-order insertion.
        
        frameRate = 60;
        
        frameUpdateFcn = [];
        % function that accepts a figure and uses an animation's framedata
        % to render the function.
        
        imgExportFormat = {};
        % format that can be used to export videos.
        % opts = {'avi','mpeg'};
        
        name = [];
        % name of output files for animation.
        
        numFrames = 0;
        % number of currently used frames.
        
        numFramesMax = 0;
        % maximum number of frames.
        
        updateFcn = [];
        % function which updates the frame.
        
        videoExportFormat = {'avi'};
        % file type of video to export.
        % opts = {'avi','mpeg'};
        
    end
    
    methods
        
        % hg set get operations
        function obj = set.autoPreallocateMode(obj,val)
            opts = {'none','linear','exponential',};
            val = lower(val);
            if ismember(val,opts)
                obj.autoPreallocateMode = val;
            else
                error('This is not a valid option.');
            end
            
        end
        
        
        function PreAllocateFrames(obj, num)
            % Pre-allocates a given number of frames to speed up addition
            % of frames when the size of the animation is known.
            % this does not erase old frames.
            newFrames = repmat(Frame(),1,num);
            obj.frames = [obj.frames, newFrames];
            obj.numFramesMax = obj.numFramesMax + num;
        end
        
        function frame = MakeFrame(obj,framedata)
            % Makes a frame.
            if obj.numFrames >= obj.numFramesMax
                switch(obj.autoPreallocateMode)
                    case 'linear'
                        obj.PreAllocateFrames(obj.autoPreallocateSize);
                    case 'none'
                        obj.PreAllocateFrames(1);
                    case 'exponential'
                        obj.PreAllocateFrames(obj.autoPreallocateSize);
                        obj.autoPreallocateSize = ...
                            obj.autoPreallocateSize * ...
                            obj.autoPreallocateExponent;
                end
                
            end
            obj.numFrames = obj.numFrames + 1;
            obj.currentFrame = obj.currentFrame+1;
            newFrame = Frame();
            set(newFrame,...
                'frameNo',obj.currentFrame,...
                'frameData',framedata);
            obj.frames(obj.currentFrame) = newFrame;
            frame = newFrame;
        end
        
        function frame = GetFrameNo(obj,idx)
            if obj.numFrames<idx
                error('Not enough frames.');
            else
                frame = obj.frames(idx);
            end
        end
        
        function RenderFrame(obj)
            % renders the next frame.
            obj.renderFrameNo(obj.currentFrame+1);
        end
        
        function RenderFrameNo(obj,idx)
            % Renders a frame based on index.
            if numel(obj.frames) > idx
                error('The frame at this position does not exist.');
            end
            
        end
        
        function RunAnimation(obj)
            for i=1:obj.numFrames
                pause(1/obj.frameRate);
                obj.updateFcn(obj,obj.frames(i));
            end
        end
        
        
    end
    
end

