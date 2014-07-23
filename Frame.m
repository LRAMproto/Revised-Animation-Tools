classdef Frame < hgsetget
    % Records information about each frame individually.
    
    properties
        frameNo = -1
        % relative position of frames relative to the entire animation.
        % Used to verify correct ordering of frames. A frame in position -1
        % has been uninstantiated.
        frameData = [];
        % data that encompasses all changing data variables.
        parentAnimation
        % animation the frame belongs to
        updateFcn = [];
        % external function that modifies the behavior of the frame in a
        % predictable way.
        userData = [];
        % Includes whatever miscellaneous data you need to store for an 
        % animation, such as a set of constants, etc.
    end
    
    methods
    end
    
end

