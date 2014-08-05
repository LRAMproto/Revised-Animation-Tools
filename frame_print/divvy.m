function division = divvy(items, numWorkers)
counts = zeros(1,numWorkers);
for k=numWorkers:-1:1
    division{k} = {};
end
for k=0:length(items)-1
    
    itemIdx = k+1;
    
    if iscell(items) % checks to see if requested item is a cell.
        newEntry = items{itemIdx};
    else % this is an array.
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

