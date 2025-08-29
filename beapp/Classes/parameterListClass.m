classdef parameterListClass < handle

    properties (SetObservable)

        format = parameterClass("mff");

        filter = parameterClass(["off" "ERP" "Non ERP"],{...
            containers.Map({"Lowpass","Highpass"},{"30 Hz","0.1 Hz"}),...
            containers.Map({"Lowpass","Highpass"},{"100 Hz","1 Hz"})});


    end

end