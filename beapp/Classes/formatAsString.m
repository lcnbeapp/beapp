function str = formatAsString(inputArg)

if ischar(inputArg)
    % Wrap character arrays in single quotes
    str = ['''' inputArg ''''];
elseif isstring(inputArg)
    % Handle string arrays element-wise
    elements = arrayfun(@(s) ['''' char(s) ''''], inputArg, 'UniformOutput', false);
    if isscalar(elements)
        str = string(elements{1});
    else
        str = "[" + strjoin(elements, ",") + "]";
    end
elseif isnumeric(inputArg) || islogical(inputArg)
    elements = arrayfun(@num2str, inputArg, 'UniformOutput', false);
    if isscalar(elements)
        str = elements{1};
    else
        str = "[" + strjoin(elements, ",") + "]";
    end
elseif iscell(inputArg)
    formattedCells = cellfun(@(x) char(formatAsString(x)), ...
        inputArg, 'UniformOutput', false);
    if isscalar(formattedCells)
        str = formattedCells{1};
    else
        str = "{" + strjoin(formattedCells, ",") + "}";
    end
elseif isstruct(inputArg)
    fields = fieldnames(inputArg);
    values = struct2cell(inputArg);
    pairs = cellfun(@(f, v) sprintf('%s: %s', f, formatAsString(v)),...
        fields, values, 'UniformOutput', false);
    str = strjoin(pairs, ", ");
elseif isa(inputArg, 'containers.Map')
    keys = inputArg.keys;
    values = inputArg.values;
    pairs = cellfun(@(k, v) sprintf('%s: %s', char(k),...
        formatAsString(v)), keys, values, 'UniformOutput', false);
    str = strjoin(pairs, ", ");
else
    str = "Unsupported input type";
end
end