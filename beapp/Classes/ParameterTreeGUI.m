classdef ParameterTreeGUI < handle
    properties
        TreeObj          % Instance of ParameterTree
        UIFigure         % GUI figure
        TreeComponent    % uitree component
    end

    methods
        function obj = ParameterTreeGUI(treeObj)
            obj.TreeObj = treeObj;
            obj.createUI();
        end

        function createUI(obj)
            obj.UIFigure = uifigure('Name', 'Parameter Tree', 'Position', [100 100 400 600]);
            obj.TreeComponent = uitree(obj.UIFigure, ...
                'Position', [20 20 360 560], ...
                'Multiselect', 'off');
            obj.populateTree(obj.TreeObj.rootParameters, obj.TreeComponent);
        end

        function populateTree(obj, paramNodes, parent)
            for ii = 1:numel(paramNodes)
                param = paramNodes(ii);
                node = uitreenode(parent, 'Text', param.name, 'NodeData', param);

                allowedValues = param.AllowedValues;
                nVals = length(allowedValues);
                value = string(param.value);

                switch nVals
                    case 0
                        valLabel = "Value: " + value;
                        valNode = uitreenode(node, 'Text', valLabel, 'NodeData', param);
                        obj.attachContextMenu(valNode, false);
                    case 1
                        valLabel = "Value: " + value + " in range "+allowedValues;
                        valNode = uitreenode(node, 'Text', valLabel, 'NodeData', param);
                        obj.attachContextMenu(valNode, false);
                    otherwise
                        for j = 1:numel(param.AllowedValues)
                            val = param.AllowedValues(j);
                            label = val;
                            if val == value
                                label = "✔ " + val; % Indicate selected value
                            end
                            child = uitreenode(node, 'Text', label, 'NodeData', struct('param', param, 'value', val));
                            obj.attachContextMenu(child, true);
                        end


                        for jj = 1:nVals
                            itemVal = allowedValues(jj);
                            if value == itemVal
                                itemVal = "✔ "+itemVal;
                            end
                            child = uitreenode(node, 'Text', label, 'NodeData', struct('param', param, 'value', itemVal));
                            obj.attachContextMenu(child, true);
                            
                        end
                end

            end
        end


        function attachContextMenu(obj, node, isEnum)
            cm = uicontextmenu(obj.UIFigure);
            node.ContextMenu = cm;

            if isEnum
                uimenu(cm, 'Text', 'Select this value', ...
                    'MenuSelectedFcn', @(src, evt)obj.selectEnumValue(node));
            else
                uimenu(cm, 'Text', 'Edit numeric value', ...
                    'MenuSelectedFcn', @(src, evt)obj.editNumericValue(node));
            end
        end


        function selectEnumValue(obj, node)
            data = node.NodeData;
            param = data.param;
            newVal = data.value;

            param.Value = newVal;
            obj.refreshTree();
        end

        function editNumericValue(obj, node)
            param = node.NodeData;
            answer = inputdlg(['Enter new value for ', param.Name], ...
                'Edit Value', 1, {num2str(param.Value)});
            if ~isempty(answer)
                newVal = str2double(answer{1});
                if ~isnan(newVal)
                    param.Value = newVal;
                    obj.refreshTree();
                end
            end
        end


        function refreshTree(obj)
            delete(obj.TreeComponent.Children);
            obj.populateTree(obj.TreeObj.RootParameters, obj.TreeComponent);
        end
    end
end