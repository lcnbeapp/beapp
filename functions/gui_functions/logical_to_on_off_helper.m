function [on_or_off] = logical_to_on_off_helper (logical_value)
if logical_value
    on_or_off = 'On';
else
    on_or_off = 'Off';
end