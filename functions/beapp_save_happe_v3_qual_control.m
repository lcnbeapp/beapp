%what I need out from each happe run
function beapp_save_happe_v3_qual_control(grp_proc_info_in,qual_control,params,errorLog)

lnMeans = qual_control.lnMean;
wavMeans = qual_control.wavMean;
dataQC = qual_control.dataQC;
dataQCNames = {qual_control.dataQCnames};
if grp_proc_info_in.HAPPE_v3_reprocessing
    reprocess = 1;
    rerunExt = ['_rerun_' datestr(now, 'dd-mm-yyyy')];
else
    reprocess = 0;
    rerunExt = '';
end
%% GENERATE OUTPUT TABLES
fprintf('Generating quality assessment outputs...\n') ;
srcDir = [grp_proc_info_in.src_dir{1,1} filesep strcat('out_',grp_proc_info_in.beapp_curr_run_tag)];
allDirNames = {'quality_assessment_outputs_HAPPE_V3'} ;
if ~params.paradigm.ERP.on; allDirNames(ismember(allDirNames, 'ERP_filtered')) = []; end
if ~params.muscIL; allDirNames(ismember(allDirNames, 'muscIL')) = []; end
dirNames = cell(1,size(allDirNames,2)) ;
for i=1:length(allDirNames)
    dirNames{i} = [num2str(i) ' - ' allDirNames{i}] ;
    if ~isfolder([srcDir filesep num2str(i) ' - ' allDirNames{i}])
        mkdir([srcDir filesep num2str(i) ' - ' allDirNames{i}]) ;
    end
end
cd([srcDir filesep dirNames{contains(dirNames, ...
    'quality_assessment_outputs_HAPPE_V3')}]) ;
try
    % CREATE AND SAVE PIPELINE QUALITY ASSESSMENT
    if ~reprocess
        % Create line noise reduction names.
        lnNames = {'r all freqs pre/post linenoise reduction'} ;
        for i=2:size(params.lineNoise.neighbors, 2)+1
            lnNames{i} = ['r ' num2str(params.lineNoise.neighbors(i-1)) ...
                ' hz pre/post linenoise reduction'] ;
        end
        for i=1:size(params.lineNoise.harms.freqs, 2)
            lnNames{i+size(params.lineNoise.neighbors, 2)+1} = ['r ' num2str(params.lineNoise.harms.freqs) ...
                ' hz pre/post harmonic reduction'] ;
        end
        
        % Create wavelet thresholding names.
        wavNames = {'RMSE post/pre waveleting', 'MAE post/pre waveleting', ...
            'SNR post/pre waveleting', 'PeakSNR post/pre waveleting', ...
            'r alldata post/pre waveleting'} ;
        for i=1:size(params.QCfreqs,2)
            wavNames{i+5} = ['r ' num2str(params.QCfreqs(i)) ' hz post/pre ' ...
                'waveleting'] ;
        end

        % Concat the Names and QC matrices.
        pipelineQC_names = [(lnNames) (wavNames)] ;
        pipelineQC = [(lnMeans) (wavMeans)] ;
        
        % Save the pipeline QC table.
        pipelineQC_saveName = helpName(['HAPPE_pipelineQC' rerunExt '_' ...
           datestr(now, 'dd-mm-yyyy') '.csv']) ;
        writetable(array2table(pipelineQC, 'VariableNames', pipelineQC_names, ...
            'RowNames', grp_proc_info_in.beapp_fname_all'), pipelineQC_saveName, 'WriteRowNames', ...
            true, 'QuoteStrings', true);
    end

    % CREATE AND SAVE DATA QUALITY ASSESSMENT
    % Concat Names and QC matrices according to the presence or absence of
    % multiple onset tags and conditions.
    
    % Save the data QC table.
    dataQC_saveName = helpName(['HAPPE_dataQC' rerunExt '_' datestr(now, ...
        'dd-mm-yyyy') '.csv']) ;
    dataQCTab = cell2table(dataQC, 'VariableNames', dataQCNames, 'RowNames', ...
        grp_proc_info_in.beapp_fname_all');
    writetable(dataQCTab, dataQC_saveName, 'WriteRowNames', true, 'QuoteStrings', ...
        true) ;

% ERRORS IN WRITING OUTPUTS:
catch ME
    % Add the error to the error log.
    errorLog = [errorLog; {'Outputs', ME.message}] ;

    % Check for a common error, usually caused by the inability to process
    % any files at all or to completion.
    if strcmp(ME.identifier, 'MATLAB:table:IncorrectNumberOfVarNames')
        fprintf(2, ['ERROR: HAPPE was unable to process any of your files.' ...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
            '\nTo troubleshoot, check your command window and error log.\n']) ;
    end
end
%% SAVE ERROR LOG
% If there were any errors while running HAPPE, save an error log so the
% user can troubleshoot.
if ~isempty(errorLog)
    fprintf('Saving error log...\n') ;
    errTabName = helpName(['HAPPE_errorLog_' datestr(now, 'dd-mm-yyyy') ...
        '.csv']) ;
    writetable(cell2table(errorLog, 'VariableNames', {'File', ...
        'Error Message'}), errTabName, 'QuoteStrings', 1) ;
end