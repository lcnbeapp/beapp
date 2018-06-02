% version of the REST_Reference_Callback function taken from the REST
% toolbox to correspond with BEAPP format.
% calls REST toolbox Lead_Field software to create lead field matrix
% The REST Toolbox:
%  Li Dong*, Fali Li, Qiang Liu, Xin Wen, Yongxiu Lai, Peng Xu and Dezhong Yao*.
% MATLAB Toolboxes for Reference Electrode Standardization Technique (REST) of Scalp EEG.
% Frontiers in Neuroscience, 2017:11(601).

function beapp_create_REST_lead_matrix(net_library_location, sensor_layout, sensor_layout_short_name,sensor_layout_long_name)

make_lead_matrix_prompt = questdlg(sprintf(['Would you like to create a REST Lead Matrix for this layout (' sensor_layout_long_name ')? \n',...
    'Note: only an option for Windows']), 'Create REST Lead Matrix', 'No', 'Yes', 'Yes');

if strcmp( make_lead_matrix_prompt,'Yes')
    if ~ispc
        warndlg('REST Lead Matrices can only be created on a PC');
        return;
    else
        % create ascii file
        cd([net_library_location, filesep, 'REST_lead_field_library']);
        
        cart_double = horzcat([sensor_layout(:).X]',[sensor_layout(:).Y]',[sensor_layout(:).Z]');
        save([sensor_layout_short_name '_REST_ascii_coords.txt'], 'cart_double','-ascii');
        
        waitfor(msgbox(sprintf(['The REST Lead Field calculation program will now open.\n',...
            'From the LeadField GUI, load the .txt file in the REST matrix library folder ',...
            'with the same layout variable name as the current net, and then calculate matrix'])));
        
        % create lead matrix
        uiopen('LeadField.exe',1)
        
        waitfor(msgbox('Click OK when LeadField matrix calculation is completely done for this sensor layout'));
        movefile('Lead_Field.dat',[sensor_layout_short_name '_REST_lead_field.dat']);
    end
else 
    return;
end