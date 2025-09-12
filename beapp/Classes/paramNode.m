classdef paramNode < handle
    % Hierarchical class to define a parameter
    % Optional allowedValues can be used to restrict the value to a
    % prefined set

    properties
        name
    end

    properties (SetObservable,Dependent)
        value
        AllowedValues
    end

    properties (Constant)
        restrictionTypes = ["None" "ValueSet" "DataRange"];
    end

    properties (SetAccess=protected)
        valueRestrictionType string % ValueSet, DataRange, None
    end

    properties (SetObservable)
        children paramNode 
    end

     properties (Access=private)
        value_
        valueRestrictions_ % empty if unrestricted
    end

    methods

        function obj = paramNode(name,value,varargin)
            % Name-value pairs for ValueSet, ValueRange and Children
            % eg. a = paramNode("Test","Opt1","AllowedValues",["Opt1"
            % "Opt2"]
           
            % Argument checks
            if nargin < 2
                error('paramNode must have a name and value');
            end

            % Parse inputs, enforce argument types
            p = inputParser;
            p.FunctionName = class(obj);
            addRequired(p, 'name', @(x) isstring(x));
            addRequired(p, 'value');
            addParameter(p, 'ValueSet', [], ...
                @(x)isa(x,class(value)) || isempty(x));
            addParameter(p, 'ValueRange', [], ...
                @(x)isa(x,class(value)) || isempty(x));
            addParameter(p, 'children', paramNode.empty, ...
                @(x) isa(x, 'paramNode') || isempty(x));
            parse(p, name, value, varargin{:});

            % Set data restrictions
            vs = ~isempty(p.Results.ValueSet);
            vr = ~isempty(p.Results.ValueRange);
            if vs&&vr
                error('You can set either ''ValueSet'' or ''ValueRange''');
            elseif vs
                obj.valueRestrictions_ = p.Results.ValueSet;
                obj.valueRestrictionType = "ValueSet";
            elseif vr
                obj.valueRestrictions_ = p.Results.ValueRange;
                obj.valueRestrictionType = "DataRange";
            else
                obj.valueRestrictionType = "none";
            end

            % Assign parsed values to object
            obj.name = p.Results.name;
            obj.value = p.Results.value;
            obj.children = p.Results.children;

        end

        % Value is a SetObservable dependent property - this code will
        % value check when needed before allowing it to be set and will
        % return the underlying stored value_ when it is needed externally
        function set.value(obj,newValue)
            if ~isempty(obj.value_) && ~strcmp(class(newValue),class(obj.value_))
                error("New value type '%s' does not match existing value type '%s'",...
                    class(newValue),class(obj.value_));
            end
            switch obj.valueRestrictionType
                case "ValueSet"
                    if ~any(obj.valueRestrictions_==newValue)
                        error("Value is not a member of specified value set");
                    end
                case "DataRange"
                    if newValue < obj.valueRestrictions_(1) || ...
                            newValue > obj.valueRestrictions_(2)
                        error("Value %1.2f is outside specified range [%1.2f %1.2f]",...
                            newValue,obj.valueRestrictions_(1),...
                            obj.valueRestrictions_(2));
                    end
                case "None"
                    
                otherwise
                    error('Unknown restrictionType %s',...
                        obj.valueRestrictionType);
            end
            obj.value_ = newValue;
        end

        function value = get.value(obj)
            value = obj.value_;
        end

        function values = get.AllowedValues(obj)
            % Return AllowedValues based on RestrictionType
            % Always returns a string array with length 0 ("none")
            % 1 ("DataRange") or >1 ("ValueSet")
            switch obj.valueRestrictionType
                case "ValueSet"
                    values = string(obj.valueRestrictions_);
                case "DataRange"
                    values = "["+obj.valueRestrictions_(1)+" "+...
                        obj.valueRestrictions_(2)+"]";
                case "none"
                    values = strings(0);
                otherwise
                    error('Unknown restrictionType %s',...
                        obj.valueRestrictionType);
            end
        end

    end

end