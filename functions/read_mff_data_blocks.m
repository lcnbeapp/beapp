% Original function written by Colin Davey for EGI API
% date 3/2/2012, 4/15/2014
% Copyright 2012, 2014 EGI. All rights reserved.

function data = read_mff_data_blocks(binObj, blocks, beginBlock, endBlock)
for blockInd = beginBlock-1:endBlock-1
    tmpdata = read_mff_data_block(binObj, blocks, blockInd);
    if blockInd == beginBlock-1
        data = tmpdata;
    else
        if size(data,1) == size(tmpdata,1)
            data = [data tmpdata];
        else
            % Error: blocks disagree on number of channels
        end
    end
end
end