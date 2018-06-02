function disp_str_colon_note_arr = beapp_arr_to_colon_note_string (input_arr)
% represent existing array as a string in matlab colon notation (for gui)
inds_gaps_between_freqs = find(diff(input_arr)>1);
if ~isempty(inds_gaps_between_freqs)
    disp_str_colon_note_arr = '[';
    for curr_freq_gap = 1:length(inds_gaps_between_freqs)
        if curr_freq_gap ==1
            disp_str_colon_note_arr = [disp_str_colon_note_arr num2str(input_arr(1)),...
                ':' num2str(input_arr(inds_gaps_between_freqs(curr_freq_gap)))];
        else
            disp_str_colon_note_arr = [disp_str_colon_note_arr num2str(input_arr(inds_gaps_between_freqs(curr_freq_gap-1)+1)),...
                ':' num2str(input_arr(inds_gaps_between_freqs(curr_freq_gap)))];
        end
        
        if curr_freq_gap < length(inds_gaps_between_freqs)
            disp_str_colon_note_arr = [disp_str_colon_note_arr ','];
        elseif curr_freq_gap == length(inds_gaps_between_freqs)
            if length(input_arr)> inds_gaps_between_freqs(curr_freq_gap)
                disp_str_colon_note_arr = [disp_str_colon_note_arr ',' num2str(input_arr(inds_gaps_between_freqs(curr_freq_gap)+1)),...
                    ':', num2str(input_arr(end)) ']' ];
            else
                disp_str_colon_note_arr = [disp_str_colon_note_arr ']'];
            end
        end
    end
else
    disp_str_colon_note_arr = ['[' num2str(input_arr(1)) ':' num2str(input_arr(end)) ']'];
end