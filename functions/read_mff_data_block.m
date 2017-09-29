% Original function written by Colin Davey for EGI API
% date 3/2/2012, 4/15/2014
% Copyright 2012, 2014 EGI. All rights reserved.

function data = read_mff_data_block(binObj, blocks, blockInd)
blockObj = blocks.get(blockInd);
% to access the data for a block, it must be loaded first
blockObj = binObj.loadSignalBlockData(blockObj);
numChannels = blockObj.numberOfSignals;

% number of 4 byte floats is 1/4 the data block size
% That is divided by channel count to get data for each channel:
samplesTimesChannels = blockObj.dataBlockSize/4;
numSamples = samplesTimesChannels / numChannels;

% get first block, returned as bytes.
data = blockObj.data;
% convert bytes to equivalent floating point values
data = typecast(data,'single');
data = reshape(data, numSamples, numChannels)';
end