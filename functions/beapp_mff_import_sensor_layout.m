function [layout] = beapp_mff_import_sensor_layout(sLayout)

variables = ...
    { ...
    'Name'            'char'  {};
    'OriginalLayout'  'char'  {} ;
    'Sensors'         'array' { 'Name' 'char' {}; 'Number' 'real' {}; 'X' 'real' {}; 'Y' 'real' {}; 'Z' 'real' {}; 'Type' 'real' {}; 'Identifier' 'real' {} };
    'Threads'         'array' { 'First' 'real' {}; 'Second' 'real' {} };
    'TilingSets'      'array' { '' 'array' {} };
    'Neighbors'       'array' { 'ChannelNumber' 'real' {}; 'Neighbors' 'array' {} } };

layout = [];
if ~isempty(sLayout)
    try
        if sLayout.loadResource()
            layout = mff_getobj(sLayout, variables);
        end
    catch
        disp('Failed to load Layout ressource');
    end
end
end