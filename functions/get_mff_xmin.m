%taken from mff_importcategories and streamlined for beapp purposes
function [xmin] = get_mff_xmin(catsResource,version)
if nargin < 2
    version = 3;
end
if version == 0
    divider = 1000;
else
    divider = 1;
end

if ~isempty(catsResource)
    if catsResource.loadResource()
        categories = catsResource.getCategories();
        fprintf('Importing categories.xml ressource: %d categories\n', categories.size);
        
       % for iCat = 1:categories.size
            category = categories.get(iCat-1);
            % cat(iCat).name = char(category.getName());
            
            % Get the list of segments for this category.
            segments = category.getSegments();
           % fprintf('Category %s, %d trials\n', char(category.getName()), segments.size);
            
            if ~isempty(segments)
                
               % for iSeg = 1:segments.size
                    
                    segment = segments.get(1-1);
                    %cat(iCat).trials(iSeg).name = char(segment.getName());
                    % cat(iCat).trials(iSeg).status = char(segment.getStatus());
                    cat(1).trials(1).begintime = segment.getBeginTime()/divider;
                    % cat(iCat).trials(iSeg).endtime = segment.getEndTime()/divider;
                    cat(1).trials(1).eventbegin = segment.getEventBegin()/divider;
                    % cat(iCat).trials(iSeg).eventend = segment.getEventEnd()/divider;
                    
                    keylist  = segment.getKeys();
                    cat(iCat).trials = mff_importkeys(cat(iCat).trials, iSeg, keylist, true);
                    
                    if segment.getClockStartTimePresent()
                        cat(iCat).trials(iSeg).clockstarttime = char(segment.getClockStartTime());
                    end
                %end
            end
       % end
    end
    xmin = -(cat(1).trials(1).eventbegin-cat(1).trials(1).begintime)/1000000;
end
end
