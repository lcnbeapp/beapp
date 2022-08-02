%copied from section of mff_importinfon.m to just pull out calibrations
function [calibValues] = get_mff_calibration(calibAll)
calibValues = [];
if ~isempty(calibAll)
            for iCalType = 1:calibAll.size

                calibList = calibAll.get(iCalType-1); % first on the list is Gain
                if strcmpi(char(calibList.getType()), 'GCAL');


                    if ~isempty(calibList)
                        calibValues = [];
                        channels    = calibList.getChannels;

                        for iCalib = 1:channels.size
                            chan = channels.get(iCalib-1);
                            calibValues(iCalib) = str2num(chan.getChannelData());
                        end

                        infoN.calibration = calibValues;

                    end
                end
            end
            
end

end