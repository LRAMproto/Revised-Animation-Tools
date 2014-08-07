function division = divvy(items, numWorkers)
% This function evenly distributes a set of items in a cell array between a
% number of workers. This is useful for multiprocessing applications for
% fair distribution of items.
%
% The output value is a cell array because there is no guarantee that every
% set of items given to it will result in a 100% even distribution
%
% This needs to be modified to handle multi-dimensional arrays.

counts = zeros(1,numWorkers);

for k=numWorkers:-1:1
    division{k} = {};
end

for k=0:length(items)-1
    
    itemIdx = k+1;
    
    if iscell(items) % checks to see if requested item is a cell.
        newEntry = items{itemIdx};
    else
        % This is an array.
        
        newEntry = items(itemIdx);
    end
    
    workerIdx = mod(k,numWorkers)+1;
       
    counts(workerIdx)=counts(workerIdx)+1;
    
    division...
        {workerIdx}...
        {counts(workerIdx)} = ....
        newEntry; 
    
    
end
end

