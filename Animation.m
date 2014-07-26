classdef Animation < hgsetget
    % Gathers information on the entire animation.
    
    properties
        
        autoPreallocateMode = 'none';
        % automatically pre-allocates to make rendering faster.
        % opts = {'none','exponential','linear'};
        
        autoPreallocateExponent = 2;
        
        autoPreallocateSize = 1;
        
        currentFrame = [];
        
        currentFrameNo = -1;
        % index of current frame used for rendering purposes.
        
        displayFigure = [];
        % figure that displays the animation
        
        firstFrame = [];
        
        frames = []
        % a list of animation frames used to render everything.
        % this list must support quick, in-order insertion.
        
        frameRate = 60;
        
        frameUpdateFcn = [];
        % function that accepts a figure and uses an animation's framedata
        % to render the function.
        
        frameWidth = 1024;
        
        imgExportFormat = {};
        % format that can be used to export videos.
        % opts = {'avi','mpeg'};
        
        lastFrame = [];
        % last frame in the animation
        
        name = [];
        % name of output files for animation.
        
        numFrames = 0;
        % number of currently used frames.
        
        numFramesMax = 0;
        % maximum number of frames.
        
        saveDirectory = pwd;
        
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
        
        function frame = MakeLinkedFrame(obj,framedata)
            obj.currentFrameNo = obj.currentFrameNo+1;
            obj.numFrames = obj.numFrames+1;
            
            newFrame = Frame();
            set(newFrame,...
                'frameNo',obj.currentFrameNo,...
                'frameData',framedata);
            if isempty(obj.firstFrame)
                obj.firstFrame = newFrame;
                obj.lastFrame = obj.firstFrame;
            else
                obj.lastFrame.nextFrame = newFrame;
                newFrame.previousFrame = obj.lastFrame;
                obj.lastFrame = newFrame;
            end
            
            frame = newFrame;
            
        end
        
        function MakeFrameContainer(obj)
            obj.PreAllocateFrames(obj.numFrames);
            curFrame = obj.firstFrame;
            count = 0;
            while ~isempty(curFrame)
                count = count + 1;
                obj.frames(count) = curFrame;
                curFrame = curFrame.nextFrame;
            end
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
                        obj.autoPreallocateSize = ...
                            obj.autoPreallocateSize * ...
                            obj.autoPreallocateExponent;
                        obj.PreAllocateFrames(obj.autoPreallocateSize-obj.numFramesMax);
                        
                end
                
            end
            obj.numFrames = obj.numFrames + 1;
            obj.currentFrameNo = obj.currentFrameNo+1;
            newFrame = Frame();
            set(newFrame,...
                'frameNo',obj.currentFrameNo,...
                'frameData',framedata);
            obj.frames(obj.currentFrameNo+1) = newFrame;
            frame = newFrame;
        end
        
        function frame = GetFrameNo(obj,idx)
            if obj.numFrames<idx
                error('Not enough frames.');
            else
                frame = obj.frames(idx);
            end
        end
        
        function RenderFrame(obj, directory)
            % renders the next frame.
            obj.renderFrameNo(obj.currentFrameNo+1, directory);
        end
        
        function RenderFrameNo(obj,idx, directory)
            % Renders a frame based on index.
            savedir = fullfile(directory,'frames');
            if ~exist(savedir)
                mkdir(savedir);
            end
            tempSVGFilename = fullfile(savedir,'temp.svg');
            
            if numel(obj.frames) < idx
                disp(numel(obj.frames));
                error('The frame at this position does not exist.');
            end
            obj.updateFcn(obj,obj.frames(idx));
            plot2svg(tempSVGFilename,obj.displayFigure);
            framename = sprintf('frameno%d.jpg',obj.frames(idx).frameNo);
            frameOutputName = fullfile(savedir,framename);
            svg2jpg(tempSVGFilename,frameOutputName);
            obj.frames(idx).outputFile = frameOutputName;
        end
        
        function RenderAllFramesTo(obj,directory)
            tic;
            for i=1:obj.numFrames
                
                obj.RenderFrameNo(i, directory);
            end
            toc;
        end
        
        function RenderAllFramesToo(obj, directory)
            tic;
            import SVGRendering.SVGRenderer.*;
            
            renderer = SVGRenderer();
            renderer.SetOutputFormat('PNG');
            renderer.SetWidth(obj.frameWidth);
            
            savedir = fullfile(directory,'frames');
            if ~exist(savedir)
                mkdir(savedir);
            end
            
            tempSVGFilename = fullfile(savedir,'temp.svg');
            
            for idx=1:obj.numFrames
                if numel(obj.frames) < idx
                    disp(numel(obj.frames));
                    error('The frame at this position does not exist.');
                end
                obj.updateFcn(obj,obj.frames(idx));
                plot2svg(tempSVGFilename,obj.displayFigure);
                framename = sprintf('frameno%d.png',obj.frames(idx).frameNo);
                frameOutputName = fullfile(savedir,framename);
                renderer.RenderImage(tempSVGFilename,frameOutputName);
                obj.frames(idx).outputFile = frameOutputName;
            end
            toc;
        end
        
        function RunAnimation(obj)
            for i=1:obj.numFrames
                pause(1/obj.frameRate);
                obj.updateFcn(obj,obj.frames(i));
            end
        end
        
        function MakeVideoFile(obj, directory)
            for i=1:obj.numFrames
                if isempty(obj.frames(i).outputFile);
                    error('Frame %d has not been rendered. You must render all frames first.',obj.frames(i).frameNo);
                end
            end
            filepath = fullfile(directory,strcat(obj.name,'.avi'));
            vidObj = VideoWriter(filepath);
            set(vidObj,'FrameRate',obj.frameRate);
            open(vidObj);
            
            for i = 1:obj.numFrames
                
                for k = 1:length(obj.frames)
                    tempFrame = obj.frames(k).outputFile;
                    curFrame = imread(tempFrame);
                    writeVideo(vidObj,curFrame);
                end
            end
            close(vidObj);
            
        end
        
    end
end

