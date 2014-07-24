function animation_test_cases(varargin)
%ANIMATION_TEST_CASES Summary of this function goes here
%   Detailed explanation goes here

NUM_TESTS = 4;

if nargin == 0
    testops = 1:NUM_TESTS;
else
    testops = varargin{1};
end

tests = {@test1,@test2,@test3,@test4,@test5,@test6,@test7,@test8};
for i=1:length(testops)
    tests{testops(i)}();
end


end

%% TESTS

function test1()
% Simple instatiation of base classes.
fprintf('Test 1: Simple Instantiation of all objects.\n');
an = Animation();
disp(an);
fr = Frame();
disp(fr);
end

function test2()
% Tests preallocation of frames.
fprintf('Test 2: Preallocation of frames.\n');
an = Animation();
an.PreAllocateFrames(100);
disp(an);
disp(an.frames);
assert(numel(an.frames) == 100)
% Makes sure that 100 frames are instantiated.
end



function test3()
% tests auto-preallocation of frames and times it versus the regular
% allocation of frames
fprintf('***** Test 3: Preallocation of frames. *****\n\n');

wb = waitbar(0,'Test3: Preallocation of frames...');
POWER = 12;
timeData = zeros(POWER,5);

frameTests = {...
    @fullAllocFrameTest,...% Pre-Allocating All Frames
    @expAllocFrameTest,... % Exponential Allocation
    @linAllocFrameTest,...% Linear Allocation
    @noAllocFrameTest,... % No Allocation
    @linkedListFrameTest...% Linked List
    };

IT_VECT = 2.^(1:POWER);
itCount = 1;
for k=IT_VECT
    NUM_FRAMES = k;
    RAND_FRAME = double(int32(rand(1)*NUM_FRAMES));
    
    fprintf('*** Rendering %f frames. ***\n',NUM_FRAMES);
    
    BEST_EFF.tdata.efficiency = -1;
    BEST_FPS.tdata.fps = -1;
    BEST_RANK.tdata.rank = -1;
    
    for i=1:length(frameTests)
        tdata = frameTests{i}(NUM_FRAMES, RAND_FRAME, wb);
        
        if tdata.efficiency > BEST_EFF.tdata.efficiency
            BEST_EFF.tdata = tdata;
        end
        if tdata.fps > BEST_EFF.tdata.fps
            BEST_FPS.tdata = tdata;
        end
        
        if tdata.rank > BEST_RANK.tdata.rank
            BEST_RANK.tdata = tdata;
        end
        timeData(itCount,i) = tdata.rank;
    end
    fprintf('<< RESULTS >>\n\n');
    fprintf('\t Best efficiency: %s\n',BEST_EFF.tdata.name);
    fprintf('\t Best frames ber second: %s\n',BEST_FPS.tdata.name);
    fprintf('\t Best rank: %s\n',BEST_RANK.tdata.name);
    itCount = itCount + 1;
end
axis;
disp(IT_VECT);
disp(timeData);
delete(wb);
line(IT_VECT,timeData(:,1),'linestyle','-','linewidth',1,'color','red');
% Pre-Allocating All Frames
line(IT_VECT,timeData(:,2),'linestyle','-','linewidth',1,'color','green');
% Exponential Allocation
line(IT_VECT,timeData(:,3),'linestyle','-','linewidth',1,'color','blue');
% Linear Allocation
line(IT_VECT,timeData(:,4),'linestyle','-','linewidth',1,'color','magenta');
% No Allocation
line(IT_VECT,timeData(:,5),'linestyle','-','linewidth',1,'color','black');
% Linked List
end


function test4
% Simple instatiation of base classes.
fprintf('Test 1: Simple Instantiation of all objects.\n');
an = Animation();
fr = an.MakeFrame('Hi');
disp(an);
disp(fr);
end

function test5()
fprintf('*** Test 5: Linking vs Exponential');

wb = waitbar(0,'Test 5: Preallocation of frames...');

NUM_FRAMES = double(int32(rand(1)*10000));
RAND_FRAME = double(int31(rand(1)*NUM_FRAMES));
if RAND_FRAME < 1
    RAND_FRAME = 1;
end

fprintf('Rendering %f frames\n',NUM_FRAMES);

tdata = linkedListFrameTest(NUM_FRAMES,RAND_FRAME, wb);
tdata = expAllocFrameTest(NUM_FRAMES, RAND_FRAME, wb);


end

function test6()
fprintf('*** Test 6: Preallocation vs Linking');

wb = waitbar(0,'Test 6: Preallocation of frames...');

NUM_FRAMES = double(int32(rand(1)*10000));
RAND_FRAME = double(int32(rand(1)*NUM_FRAMES));

fprintf('Rendering %f frames\n',NUM_FRAMES);

linkedListFrameTest(NUM_FRAMES,RAND_FRAME, wb);
fullAllocFrameTest(NUM_FRAMES, RAND_FRAME, wb);


end

function test7
% Testing animation on a figure window.
handles.fig = figure('units','pixels','position',[0 0 500 500]);
%handles.msg = uicontrol('parent',handles.fig,'style','text','string','testnum','fontsize',45,'position',[0 0 500 100]);
handles.ax = axes(...
    'units','pixels',...
    'xlim',[-2 2],...
    'ylim',[-2 2],...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'parent',handles.fig,...
    'position',[25 25 450 450]...
    );
handles.pat.xdata = [-.25 .25 .25 -.25];
handles.pat.ydata = [-.25 -.25 .25 .25];

handles.pat2.xdata = [-.5 .5 .5 -.5];
handles.pat2.ydata = [-.5 -.5 .5 .5];

handles.pat2.visual = patch(...
    'parent',handles.ax,...
    'xdata',handles.pat2.xdata,...
    'ydata',handles.pat2.ydata,...
    'facecolor','red');

handles.pat.visual = patch(...
    'parent',handles.ax,...
    'xdata',handles.pat.xdata,...
    'ydata',handles.pat.ydata,...
    'facecolor',[.2 .4 .6]);

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

framedata = zeros(1,6);

for  i=1:NUM_FRAMES
    t = i/60;

    [framedata(1),framedata(2)] = pol2cart(degtorad(t*360),.5);
    
    an.MakeFrame(framedata);
    waitbar(i/NUM_FRAMES,wb,sprintf('Rendering Frames\n (%f %%)',i/NUM_FRAMES*100));
end
close(wb);
toc
disp(an.name);

an.displayFigure = handles.fig;
an.updateFcn = @UpdateTest;
an.RunAnimation();

end

function test8()

% Testing animation on a figure window.
handles.fig = figure('units','pixels','position',[0 0 500 500]);
%handles.msg = uicontrol('parent',handles.fig,'style','text','string','testnum','fontsize',45,'position',[0 0 500 100]);
handles.ax = axes(...
    'units','pixels',...
    'xlim',[-2 2],...
    'ylim',[-2 2],...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'parent',handles.fig,...
    'position',[25 25 450 450]...
    );
handles.pat.xdata = [-.25 .25 .25 -.25];
handles.pat.ydata = [-.25 -.25 .25 .25];

handles.pat2.xdata = [-.5 .5 .5 -.5];
handles.pat2.ydata = [-.5 -.5 .5 .5];

handles.pat2.visual = patch(...
    'parent',handles.ax,...
    'xdata',handles.pat2.xdata,...
    'ydata',handles.pat2.ydata,...
    'facecolor','red');

handles.pat.visual = patch(...
    'parent',handles.ax,...
    'xdata',handles.pat.xdata,...
    'ydata',handles.pat.ydata,...
    'facecolor',[.2 .4 .6]);

guidata(handles.fig, handles);
fprintf('*** Test 5: Animation Replay. ***\n\n');


wb = waitbar(0,'Test3: Preallocation of frames...');

NUM_FRAMES = 360;

fprintf('Rendering %f frames\n',NUM_FRAMES);

% Pre-Allocating All Frames

tic
an = Animation();
numFrameStr = sprintf('%d frame PreAlloc',NUM_FRAMES);
an.name = numFrameStr;
an.PreAllocateFrames(NUM_FRAMES);

framedata = zeros(1,6);

for  i=1:NUM_FRAMES
    t = i/60;

    [framedata(1),framedata(2)] = pol2cart(degtorad(t*360),.5);
    
    an.MakeFrame(framedata);
    waitbar(i/NUM_FRAMES,wb,sprintf('Rendering Frames\n (%f %%)',i/NUM_FRAMES*100));
end
close(wb);
toc
disp(an.name);

an.displayFigure = handles.fig;
an.updateFcn = @UpdateTest;
an.RunAnimation();

end


%% ALLOCATION TESTS

function tdata = fullAllocFrameTest(NUM_FRAMES, RAND_FRAME, wb)
tic
an = Animation();
numFrameStr = sprintf('%d frame PreAlloc',NUM_FRAMES);
an.name = numFrameStr;
an.PreAllocateFrames(NUM_FRAMES);
for  i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Full Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));
end

tdata.name = an.name;
tdata.time = toc;
tdata.numFrames = an.numFrames;
tdata.numFramesMax = an.numFramesMax;
tdata.efficiency = an.numFrames / an.numFramesMax;
tdata.fps = an.numFrames/tdata.time;
tdata.rank = tdata.efficiency * tdata.fps;
DisplayStats(tdata);

rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in full prealloc');
end

end


function tdata = expAllocFrameTest(NUM_FRAMES, RAND_FRAME, wb)

tic
an = Animation();
an.name = 'Exponential Pre-Allocation';
an.autoPreallocateMode = 'exponential';

for i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Exponential Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));
end
tdata.name = an.name;
tdata.time = toc;
tdata.numFrames = an.numFrames;
tdata.numFramesMax = an.numFramesMax;
tdata.efficiency = an.numFrames / an.numFramesMax;
tdata.fps = an.numFrames/tdata.time;
tdata.rank = tdata.efficiency * tdata.fps;
DisplayStats(tdata);

rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in exponential prealloc');
end

end

function tdata = linAllocFrameTest(NUM_FRAMES, RAND_FRAME, wb)

tic
an = Animation();
an.name = 'Linear Pre-Allocation';
an.autoPreallocateMode = 'linear';
an.autoPreallocateSize= 100;
for i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Linear Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));
end
tdata.name = an.name;
tdata.time = toc;
tdata.numFrames = an.numFrames;
tdata.numFramesMax = an.numFramesMax;
tdata.efficiency = an.numFrames / an.numFramesMax;
tdata.fps = an.numFrames/tdata.time;
tdata.rank = tdata.efficiency * tdata.fps;

DisplayStats(tdata);

rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in linear prealloc');
end

end

function tdata = noAllocFrameTest(NUM_FRAMES,RAND_FRAME, wb)
tic
an = Animation();
an.name = 'No Pre-Allocation';

for  i=1:NUM_FRAMES
    an.MakeFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('No Pre-Allocation Test\n (%f %%)',i/NUM_FRAMES*100));
end
tdata.name = an.name;
tdata.time = toc;
tdata.numFrames = an.numFrames;
tdata.numFramesMax = an.numFramesMax;
tdata.efficiency = an.numFrames / an.numFramesMax;
tdata.fps = an.numFrames/tdata.time;
tdata.rank = tdata.efficiency * tdata.fps;

DisplayStats(tdata);

rframe = an.GetFrameNo(RAND_FRAME);
if (rframe.frameNo ~= RAND_FRAME)
    error('inconsistent frame number in no prealloc');
end

end

function tdata = linkedListFrameTest(NUM_FRAMES, RAND_FRAME, wb)
tic
an = Animation();
an.name = 'Linked List Addition';

for i=1:NUM_FRAMES
    an.MakeLinkedFrame(i);
    waitbar(i/NUM_FRAMES,wb,sprintf('Linked Test\n (%f %%)',i/NUM_FRAMES*100));
end
an.MakeFrameContainer();

tdata.name = an.name;
tdata.time = toc;
tdata.numFrames = an.numFrames;
tdata.numFramesMax = an.numFramesMax;
tdata.efficiency = an.numFrames / an.numFramesMax;
tdata.fps = an.numFrames/tdata.time;
tdata.rank = tdata.efficiency * tdata.fps;

DisplayStats(tdata);

rframe = an.GetFrameNo(RAND_FRAME);
if rframe.frameNo ~= RAND_FRAME
    disp(an);
    disp(rframe);
    error('frame %d has frameNo %d in Linked Addition Test\n',RAND_FRAME,rframe.frameNo);
end
end

%Test 3 Display Function

function DisplayStats(tdata)
fprintf('\n');
fprintf('Name: %s\n',tdata.name);
fprintf('\tTime: %f Seconds\n',tdata.time);
fprintf('\tNumber of Frames Rendered: %f\n',tdata.numFrames);
fprintf('\tNumber of Frames Total: %f\n',tdata.numFramesMax);
fprintf('\tEfficiency: %f %%\n',tdata.efficiency);
fprintf('\tFrames/Second: %f \n',tdata.fps);
fprintf('\tRank: %f \n',tdata.rank);

end

% Test 7 Update Function
function UpdateTest(animation, frame)
fig = animation.displayFigure;
handles = guidata(fig);
set(handles.pat.visual,...
    'xdata',handles.pat.xdata+frame.frameData(1),...
    'ydata',handles.pat.ydata+frame.frameData(2));
    
end
