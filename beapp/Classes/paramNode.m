classdef paramNode < handle
    % Hierarchical class to define a parameter
    % Optional allowedValues can be used to restrict the value to a
    % prefined set

    properties
        name
        value
    end

    properties (SetObservable)
        allowedValues % string array or empty
        children paramNode % list of parameters 
    end

    methods

        function obj = paramNode(name,value,allowedValues,children)
            
            if nargin < 2
                error('paramNode must have a name and value');
            end
            if nargin < 3
                allowedValues = [];
            end
            if nargin < 4
                children = paramNode.empty;
            end

            % Parse inputs, enforce argument types
            p = inputParser;
            p.FunctionName = 'paramNode';
            addRequired(p,'name',@(x)isstring(name));
            addRequired(p,'value')
            addOptional(p,'allowedValues', @(x)isa(x,class(value)));
            addOptional(p,'children',"",@(x)isa(x,class(obj)));
            parse(p, name, value, allowedValues, children);

            obj.name = p.Results.name;
            obj.value = p.Results.value;
            
            % obj.allowedValues = p.Results.allowedValues;
            % obj.value =  defaultValue;
            % if ~isempty(keys)
            %     obj.params = containers.Map(keys, values);
            % end

        end

        function set.value(obj,value)
            if isempty(obj.allowedValues)
                obj.value = value;
            elseif ~any(obj.allowedValues==value)
                error("Value %s is not in allowedValues",value);
            end
        end


        function value = get.value(obj)
            value = obj.allowedValues(obj.valueIndex);
        end

    end

end