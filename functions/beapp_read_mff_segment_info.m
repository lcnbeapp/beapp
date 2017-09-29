%% beapp_read_mff_segment_info
% pull pre-created segment information from .mff file
% Inputs:
% full_filepath = file location path
% time_units_exp = exponent on MFF file version timestamps. 
% 6 = microseconds, 9 = nanoseconds
%
% Many of the functions used to read in MFFs are adapted from the EGI
% API written by Colin Davey for FieldTrip in 2006-2014. 
% https://github.com/fieldtrip/fieldtrip/tree/master/external/egi_mff
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C) 2015, 2016, 2017
% Authors: AR Levin, AS Méndez Leal, LJ Gabard-Durnam, HM O'Leary
% 
% This software is being distributed with the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU General
% Public License for more details.
% 
% In no event shall Boston Children’s Hospital (BCH), the BCH Department of
% Neurology, the Laboratories of Cognitive Neuroscience (LCN), or software 
% contributors to BEAPP be liable to any party for direct, indirect, 
% special, incidental, or consequential damages, including lost profits, 
% arising out of the use of this software and its documentation, even if 
% Boston Children’s Hospital,the Laboratories of Cognitive Neuroscience, 
% and software contributors have been advised of the possibility of such 
% damage. Software and documentation is provided “as is.” Boston Children’s 
% Hospital, the Laboratories of Cognitive Neuroscience, and software 
% contributors are under no obligation to provide maintenance, support, 
% updates, enhancements, or modifications.
% 
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License (version 3) as
% published by the Free Software Foundation.
% 
% You should receive a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function file_proc_info = beapp_read_mff_segment_info(full_filepath,file_proc_info,time_units_exp)

categories_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Categories, 'categories.xml', full_filepath);

if ~isempty(categories_obj)
    all_categories = categories_obj.getCategories;
    cat_names = cell(all_categories.size,1);
    clear categories_obj
    
    % count segments across segment type
    segInd = 0;
    
    for curr_cat = 1:(all_categories.size)
        cat = all_categories.get(curr_cat-1);
        cat_names{curr_cat}=char(cat.getName);
        all_segs = cat.getSegments;
           
        for curr_seg = 1:(all_segs.size);
            seg = all_segs.get(curr_seg-1);
            segInd = segInd+1;
            seg_info(segInd).s_start_time = seg.getBeginTime;
            seg_info(segInd).s_end_time= seg.getEndTime;
            seg_info(segInd).s_status = char(seg.getStatus());
            seg_info(segInd).s_evt_start_time = seg.getEventBegin;
            seg_info(segInd).s_evt_end_time = seg.getEventEnd;
            tmp_fault_string = char(seg.getFaults);
            seg_info(segInd).exclusion= seg.getExclusion(); % not working now, but worth trying
            seg_info(segInd).condition_name = cat_names{curr_cat};
            
            % deals with unusual whitespace, assumes no spaces in valid
            % hand editing strings
            remove_non_info_chars = strsplit(tmp_fault_string,{',','[',']',' '});
            remove_non_info_chars2= remove_non_info_chars(find(~cellfun(@isempty,remove_non_info_chars)));
            if ~isempty(remove_non_info_chars2)
                remove_non_info_chars = remove_non_info_chars2(find(~cellfun(@(x) isequal(isspace(x),1), remove_non_info_chars2)));
                seg_info(segInd).s_faults = strjoin(remove_non_info_chars,',');
            else
                seg_info(segInd).s_faults = '';
            end
            seg_info(segInd).s_duration = time2samples(seg_info(segInd).s_end_time(1)- seg_info(segInd).s_start_time(1),file_proc_info.beapp_srate,time_units_exp,'fix');
          
            % compare event index and sample for temporal sorting
            if isempty(seg_info(segInd).s_start_time)
                segs_samps_inds(segInd,1) = nan;
            else
                segs_samps_inds(segInd,1) = seg_info(segInd).s_start_time;
            end
            segs_samps_inds(segInd,2) = segInd;
                
        end
        clear cat all_segs
    end
    
    seg_samps_inds =sortrows(segs_samps_inds);
    sortedSegs = seg_info;
    for p = 1:segInd
        nextSegInd = seg_samps_inds(p,2);
        sortedSegs(p) = seg_info(nextSegInd);
    end
    file_proc_info.seg_info = sortedSegs;
    file_proc_info.seg_tasks=cat_names;
    
    clearvars -except file_proc_info
end