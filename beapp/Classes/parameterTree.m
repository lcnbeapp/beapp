classdef parameterTree < handle
    properties
        rootParameters paramNode % Array of top-level parameters
    end

    methods
        function obj = parameterTree(rootParams)
            obj.rootParameters = rootParams;
        end
    end
end