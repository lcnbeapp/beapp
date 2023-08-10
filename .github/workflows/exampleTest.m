function tests = exampleTest
% Add my library path
    beapp_main('use_script')
    %test a thing
tests = functiontests(localfunctions);
end

function setup(testCase)
end
function teardown(testCase)
end
function resampTest(testCase)
    test_load = load('reference_data/net_library/Enobio32.mat');
    test_load_2 = load('reference_data/net_library/Enobio32.mat');
    %orig_resamp = load('C:\Users\ch220650\Documents\beapp-testing\rsamp\auditoryEEG01.mat');
    %new_resamp = load('C:\Users\ch220650\Documents\beapp-testing\rsamp_03\auditoryEEG01.mat');
    %verifyEqual(testCase,orig_resamp.eeg,new_resamp.eeg)
    verifyEqual(testCase,test_load,test_load_2)
    %verifyEqual(testCase,orig_resamp.file_proc_info,new_resamp.file_proc_info)
end
function testExampleTwo(testCase)

end
