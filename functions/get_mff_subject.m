%section copied from mff_importsubject.m
function [subject] = get_mff_subject(SObject)
variables = { 'Fields' 'array' { 'Name' 'char' {}; 'Data' 'char' {}; 'DataType' 'char' {} } };

subject = [];
if ~isempty(SObject)
    try
        if SObject.loadResource()
            subject = mff_getobj(SObject, variables);
        end
    catch
        disp('Failed to load subject ressource');
    end
end
end