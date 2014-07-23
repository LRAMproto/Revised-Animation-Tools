function animation_test_cases(varargin)
%ANIMATION_TEST_CASES Summary of this function goes here
%   Detailed explanation goes here

NUM_TESTS = 4;

if nargin == 0
    testops = 1:NUM_TESTS;
else
    testops = varargin{1};
end

tests = {@test1,@test2,@test3,@test4,@test5};
for i=1:length(testops)
    tests{testops(i)}();
end


end

function test1
% Simple instatiation of base classes.
fprintf('Test 1: Simple Instantiation of all objects.\n');
an = Animation();
disp(an);
fr = Frame();
disp(fr);
end

function test2
% Tests preallocation of frames.
fprintf('Test 2: Preallocation of frames.\n');
an = Animation();
an.PreAllocateFrames(100);
disp(an);
disp(an.frames);
assert(numel(an.frames) == 100)
% Makes sure that 100 frames are instantiated.
end

function test3
% tests auto-preallocation of frames and times it versus the regular
% allocation of frames
fprintf('*** Test 3: Preallocation of frames. ***\n\n');

wb = waitbar(0,'Test3: Preallocation of frames...');

NUM_FRAMES = double(int32(rand(1)*10000));
RAND_FRAME = double(int32(rand(1)*NUM_FRAMES));

fprintf('Rendering %f frames\n',NUM_FRAMES);

% Pre-Allocating All Frames

tic
an = Animation();
numFrameStr = sprintf('%d frame PreAlloc',NUM_FRAMES);
an.name = numFrameStr;
an.PreAllocateFrames(NUM_FRAMES);
for  i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Full Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));
end
toc
disp(an.name);
fprintf('\t Efficiency: %f %%\n',an.numFrames / an.numFramesMax);
rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in full prealloc');
end
clear('an');


% Exponential Allocation

tic
an = Animation();
an.name = 'Exponential Pre-Allocation';
an.autoPreallocateMode = 'exponential';

for i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Exponential Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));        
end
toc
disp(an.name);
fprintf('\t Efficiency: %f %%\n',an.numFrames / an.numFramesMax);
rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in exponential prealloc');
end
clear('an');


% Linear Allocation

tic
an = Animation();
an.name = 'Linear Pre-Allocation';
an.autoPreallocateMode = 'linear';
an.autoPreallocateSize= 100;
for i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Linear Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));
end
toc
disp(an.name);
fprintf('\t Efficiency: %f %%\n',an.numFrames / an.numFramesMax);
rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in linear prealloc');
end

clear('an');


% No Allocation

tic
an = Animation();
an.name = 'No Pre-Allocation';

for  i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('No Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));
end
toc

disp(an.name);

fprintf('\t Efficiency: %f %%\n',an.numFrames / an.numFramesMax);
rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in no prealloc');
end

clear('an');

end


function test4
% Simple instatiation of base classes.
fprintf('Test 1: Simple Instantiation of all objects.\n');
an = Animation();
fr = an.MakeFrame('Hi');
disp(an);
disp(fr);
end

function test5
% Testing animation on a figure window.
handles.fig = figure;
handles.msg = uicontrol('parent',figure','style','text','string','testnum','fontsize',45,'position',[0 0 500 100]);
guidata(handles.fig, handles);

fprintf('*** Test 5: Animation Replay. ***\n\n');

wb = waitbar(0,'Test3: Preallocation of frames...');

NUM_FRAMES = double(int32(rand(1)*10000));

fprintf('Rendering %f frames\n',NUM_FRAMES);

% Pre-Allocating All Frames

tic
an = Animation();
numFrameStr = sprintf('%d frame PreAlloc',NUM_FRAMES);
an.name = numFrameStr;
an.PreAllocateFrames(NUM_FRAMES);
for  i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Rendering Frames\n (%f %%)',i/NUM_FRAMES*100));
end
close(wb);
toc
disp(an.name);

an.displayFigure = handles.fig;
an.updateFcn = @UpdateTest;
an.RunAnimation();

clear('an');


end

function UpdateTest(animation, frame)
    fig = animation.displayFigure;
    handles = guidata(fig);
    set(handles.msg,'String',frame.frameData(1));
end
