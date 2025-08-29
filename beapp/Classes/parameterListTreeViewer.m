classdef parameterListTreeViewer < handle
    properties
        ParamListObj   % Instance of parameterList
        UIFigure       % GUI figure
        Tree           % Tree UI component
    end

    methods
        function obj = parameterListTreeViewer(paramListObj)
            obj.ParamListObj = paramListObj;
            obj.createUI();
        end

        function createUI(obj)
            % Create the figure
            obj.UIFigure = uifigure('Name', 'Parameter Tree Viewer', 'Position', [100 100 400 500]);

            % Create the tree
            obj.Tree = uitree(obj.UIFigure, ...
                'Position', [50 50 300 400]);

            % Populate the tree
            obj.populateTree();
        end

        function populateTree(obj)
            metaProps = metaclass(obj.ParamListObj).PropertyList;

            for k = 1:length(metaProps)
                prop = metaProps(k);
                if prop.SetObservable
                    paramObj = obj.ParamListObj.(prop.Name);
                    if isprop(paramObj, 'allowedValues') && isprop(paramObj, 'value')
                        % Create parent node
                        parentNode = uitreenode(obj.Tree, 'Text', prop.Name);

                        % Add child nodes for allowedValues
                        for i = 1:length(paramObj.allowedValues)
                            val = paramObj.allowedValues(i);
                            childNode = uitreenode(parentNode, 'Text', val);

                            % Make the node bold if it matches the current value
                            if val == paramObj.value
                                childNode.FontWeight = 'bold';
                            end
                        end
                    end
                end
            end
        end
    end
end