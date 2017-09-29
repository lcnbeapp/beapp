% this script calls the path initializing EEGLab code, a subset of
% the primary eeglab script
% this is done to prevent errors caused by adding EEGLab/plugin subfolders
% to the path
% 
% EEGLAB is a Matlab graphic user interface environment for 
%   electrophysiological data analysis incorporating the ICA/EEG toolbox 
%   (Makeig et al.) developed at CNL / The Salk Institute, 1997-2001. 
%   Released 11/2002- as EEGLAB (Delorme, Makeig, et al.) at the Swartz Center 
%   for Computational Neuroscience, Institute for Neural Computation, 
%   University of California San Diego (http://sccn.ucsd.edu/). 
%   User feedback welcome: email eeglab@sccn.ucsd.edu
%
% Authors: Arnaud Delorme and Scott Makeig, with substantial contributions
%   from Colin Humphries, Sigurd Enghoff, Tzyy-Ping Jung, plus
%   contributions 
%   from Tony Bell, Te-Won Lee, Luca Finelli and many other contributors. 
%
function beapp_eeglab_path_adding 

if nargout > 0
    varargout = { [] [] 0 {} [] };
    %[ALLEEG, EEG, CURRENTSET, ALLCOM]
end;

% check Matlab version
% --------------------
vers = version;
tmpv = which('version');
if ~isempty(findstr(lower(tmpv), 'biosig'))
    [tmpp tmp] = fileparts(tmpv);
    rmpath(tmpp);
end;
% remove freemat folder if it exist
tmpPath = fileparts(fileparts(which('sread')));
newPath = fullfile(tmpPath, 'maybe-missing', 'freemat3.5');
if exist(newPath) == 7
    warning('off', 'MATLAB:rmpath:DirNotFound');
    rmpath(newPath)
    warning('on', 'MATLAB:rmpath:DirNotFound');
end;
if str2num(vers(1)) < 7 && str2num(vers(1)) >= 5
    tmpWarning = warning('backtrace');
    warning backtrace off;
    warning('You are using a Matlab version older than 7.0');
    warning('This Matlab version is too old to run the current EEGLAB');
    warning('Download EEGLAB 4.3b at http://sccn.ucsd.edu/eeglab/eeglab4.5b.teaching.zip');
    warning('This version of EEGLAB is compatible with all Matlab version down to Matlab 5.3');
    warning(tmpWarning);
    return;
end;

% check Matlab version
% --------------------
vers = version;
indp = find(vers == '.');
if str2num(vers(indp(1)+1)) > 1, vers = [ vers(1:indp(1)) '0' vers(indp(1)+1:end) ]; end;
indp = find(vers == '.');
vers = str2num(vers(1:indp(2)-1));
if vers < 7.06
    tmpWarning = warning('backtrace');
    warning backtrace off;
    warning('You are using a Matlab version older than 7.6 (2008a)');
    warning('Some of the EEGLAB functions might not be functional');
    warning('Download EEGLAB 4.3b at http://sccn.ucsd.edu/eeglab/eeglab4.5b.teaching.zip');
    warning('This version of EEGLAB is compatible with all Matlab version down to Matlab 5.3');
    warning(tmpWarning);
end; 

% check for duplicate versions of EEGLAB
% --------------------------------------
eeglabpath = mywhich('eeglab.m');
eeglabpath = eeglabpath(1:end-length('eeglab.m'));
if nargin < 1
    eeglabpath2 = '';
    if strcmpi(eeglabpath, pwd) || strcmpi(eeglabpath(1:end-1), pwd) 
        cd('functions');
        warning('off', 'MATLAB:rmpath:DirNotFound');
        rmpath(eeglabpath);
        warning('on', 'MATLAB:rmpath:DirNotFound');
        eeglabpath2 = mywhich('eeglab.m');
        cd('..');
    else
        try, rmpath(eeglabpath); catch, end;
        eeglabpath2 = mywhich('eeglab.m');
    end;
    if ~isempty(eeglabpath2)
        %evalin('base', 'clear classes updater;'); % this clears all the variables
        eeglabpath2 = eeglabpath2(1:end-length('eeglab.m'));
        tmpWarning = warning('backtrace'); 
        warning backtrace off;
        disp('******************************************************');
        warning('There are at least two versions of EEGLAB in your path');
        warning(sprintf('One is at %s', eeglabpath));
        warning(sprintf('The other one is at %s', eeglabpath2));
        warning(tmpWarning); 
    end;
    addpath(eeglabpath);
end;

% add the paths
% -------------
if strcmpi(eeglabpath, './') || strcmpi(eeglabpath, '.\'), eeglabpath = [ pwd filesep ]; end;

% solve BIOSIG problem
% --------------------
pathtmp = mywhich('wilcoxon_test');
if ~isempty(pathtmp)
    try,
        rmpath(pathtmp(1:end-15));
    catch, end;
end;

% test for local SCCN copy
% ------------------------
if ~iseeglabdeployed2
    addpathifnotinlist(eeglabpath);
    if exist( fullfile( eeglabpath, 'functions', 'adminfunc') ) ~= 7
        warning('EEGLAB subfolders not found');
    end;
end;

% determine file format
% ---------------------
fileformat = 'maclinux';
comp = computer;
try
    if strcmpi(comp(1:3), 'GLN') | strcmpi(comp(1:3), 'MAC') | strcmpi(comp(1:3), 'SOL')
        fileformat = 'maclinux';
    elseif strcmpi(comp(1:5), 'pcwin')
        fileformat = 'pcwin';
    end;
end;

% add paths
% ---------
if ~iseeglabdeployed2
    tmp = which('eeglab_data.set');
    if ~isempty(which('eeglab_data.set')) && ~isempty(which('GSN-HydroCel-32.sfp'))
        warning backtrace off;
        warning(sprintf([ '\n\nPath Warning: It appears that you have added the path to all of the\n' ...
            'subfolders to EEGLAB. This may create issues with some EEGLAB extensions\n' ...
            'If EEGLAB cannot start or your experience a large number of warning\n' ...
            'messages, remove all the EEGLAB paths then go to the EEGLAB folder\n' ...
            'and start EEGLAB which will add all the necessary paths.\n\n' ]));
        warning backtrace on;
        foldertorm = fileparts(which('fgetl.m'));
        if ~isempty(strfind(foldertorm, 'eeglab'))
            rmpath(foldertorm);
        end;
        foldertorm = fileparts(which('strjoin.m'));
        if ~isempty(strfind(foldertorm, 'eeglab'))
            rmpath(foldertorm);
        end;
    end;
    myaddpath( eeglabpath, 'eeg_checkset.m',   [ 'functions' filesep 'adminfunc'        ]);
    myaddpath( eeglabpath, 'eeg_checkset.m',   [ 'functions' filesep 'adminfunc'        ]);
    myaddpath( eeglabpath, ['@mmo' filesep 'mmo.m'], 'functions');
    myaddpath( eeglabpath, 'readeetraklocs.m', [ 'functions' filesep 'sigprocfunc'      ]);
    myaddpath( eeglabpath, 'supergui.m',       [ 'functions' filesep 'guifunc'          ]);
    myaddpath( eeglabpath, 'pop_study.m',      [ 'functions' filesep 'studyfunc'        ]);
    myaddpath( eeglabpath, 'pop_loadbci.m',    [ 'functions' filesep 'popfunc'          ]);
    myaddpath( eeglabpath, 'statcond.m',       [ 'functions' filesep 'statistics'       ]);
    myaddpath( eeglabpath, 'timefreq.m',       [ 'functions' filesep 'timefreqfunc'     ]);
    myaddpath( eeglabpath, 'icademo.m',        [ 'functions' filesep 'miscfunc'         ]);
    myaddpath( eeglabpath, 'eeglab1020.ced',   [ 'functions' filesep 'resources'        ]);
    myaddpath( eeglabpath, 'startpane.m',      [ 'functions' filesep 'javachatfunc' ]);
    addpathifnotinlist(fullfile(eeglabpath, 'plugins'));
    eeglab_options;
    
    % remove path to to fmrlab if neceecessary
    path_runica = fileparts(mywhich('runica'));
    if length(path_runica) > 6 && strcmpi(path_runica(end-5:end), 'fmrlab')
        rmpath(path_runica);
    end;

    % add path if toolboxes are missing
    % ---------------------------------
    signalpath = fullfile(eeglabpath, 'functions', 'octavefunc', 'signal');
    optimpath  = fullfile(eeglabpath, 'functions', 'octavefunc', 'optim');
    if option_donotusetoolboxes
        p1 = fileparts(mywhich('ttest'));
        p2 = fileparts(mywhich('filtfilt'));
        p3 = fileparts(mywhich('optimtool'));
        p4 = fileparts(mywhich('gray2ind'));
        if ~isempty(p1), rmpath(p1); end;
        if ~isempty(p2), rmpath(p2); end;
        if ~isempty(p3), rmpath(p3); end;
        if ~isempty(p4), rmpath(p4); end;
    end;
    if ~license('test','signal_toolbox') || exist('pwelch') ~= 2
        warning('off', 'MATLAB:dispatcher:nameConflict');
        addpath( signalpath );
    else
        warning('off', 'MATLAB:rmpath:DirNotFound');
        rmpathifpresent( signalpath );
        rmpathifpresent(optimpath);
        warning('on', 'MATLAB:rmpath:DirNotFound');
    end;
    if ~license('test','optim_toolbox') && ~ismatlab
        addpath( optimpath );
    else
        warning('off', 'MATLAB:rmpath:DirNotFound');
        rmpathifpresent( optimpath );
        warning('on', 'MATLAB:rmpath:DirNotFound');
    end;

    % remove BIOSIG path which are not needed and might cause conflicts
    biosigp{1} = fileparts(which('sopen.m'));
    biosigp{2} = fileparts(which('regress_eog.m'));
    biosigp{3} = fileparts(which('DecimalFactors.txt'));
    removepath(fileparts(fileparts(biosigp{1})), biosigp{:})
else
    eeglab_options;
end;

% for the history function
% ------------------------
comtmp = 'warning off MATLAB:mir_warning_variable_used_as_function';

if nargin < 1 | exist('EEG') ~= 1
	clear global EEG ALLEEG CURRENTSET ALLCOM LASTCOM STUDY;
    CURRENTSTUDY = 0;
	EEG = eeg_emptyset;
	eegh('[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;');
    if ismatlab && get(0, 'screendepth') <= 8
        disp('Warning: screen color depth too low, some colors will be inaccurate in time-frequency plots');
    end;
end;

if nargin == 1
	if strcmp(onearg, 'versions')
        disp( [ 'EEGLAB v' eeg_getversion ] );
	elseif strcmp(onearg, 'nogui')
        if nargout < 1, clear ALLEEG; end; % do not return output var
        return;
	elseif strcmp(onearg, 'redraw')
        if ~ismatlab,return; end;
		W_MAIN = findobj('tag', 'EEGLAB');
		if ~isempty(W_MAIN)
			updatemenu;
            if nargout < 1, clear ALLEEG; end; % do not return output var
			return;
		else
			eegh('eeglab(''redraw'');');
		end;
	elseif strcmp(onearg, 'rebuild')
        if ~ismatlab,return; end;
		W_MAIN = findobj('tag', 'EEGLAB');
        close(W_MAIN);
        eeglab;
        return;
    else
        fprintf(2,['EEGLAB Warning: Invalid argument ''' onearg '''. Restarting EEGLAB interface instead.\n']);
        eegh('[ALLEEG EEG CURRENTSET ALLCOM] = eeglab(''rebuild'');');
	end;
else 
    onearg = 'rebuild';
end;


% default option folder
% ---------------------
if ~iseeglabdeployed2
    eeglab_options;
    %fprintf('eeglab: options file is %s%seeg_options.m\n', homefolder, filesep);
end;

% checking strings
% ----------------
e_try             = 'try,';
e_catch           = 'catch, eeglab_error; LASTCOM= ''''; clear EEGTMP ALLEEGTMP STUDYTMP; end;';
nocheck           = e_try;
ret               = 'if ~isempty(LASTCOM), if LASTCOM(1) == -1, LASTCOM = ''''; return; end; end;';
check             = ['[EEG LASTCOM] = eeg_checkset(EEG, ''data'');' ret ' eegh(LASTCOM);' e_try];
checkcont         = ['[EEG LASTCOM] = eeg_checkset(EEG, ''contdata'');' ret ' eegh(LASTCOM);' e_try];
checkica          = ['[EEG LASTCOM] = eeg_checkset(EEG, ''ica'');' ret ' eegh(LASTCOM);' e_try];
checkepoch        = ['[EEG LASTCOM] = eeg_checkset(EEG, ''epoch'');' ret ' eegh(LASTCOM);' e_try];
checkevent        = ['[EEG LASTCOM] = eeg_checkset(EEG, ''event'');' ret ' eegh(LASTCOM);' e_try];
checkbesa         = ['[EEG LASTCOM] = eeg_checkset(EEG, ''besa'');' ret ' eegh(''% no history yet for BESA dipole localization'');' e_try];
checkepochica     = ['[EEG LASTCOM] = eeg_checkset(EEG, ''epoch'', ''ica'');' ret ' eegh(LASTCOM);' e_try];
checkplot         = ['[EEG LASTCOM] = eeg_checkset(EEG, ''chanloc'');' ret ' eegh(LASTCOM);' e_try];
checkicaplot      = ['[EEG LASTCOM] = eeg_checkset(EEG, ''ica'', ''chanloc'');' ret ' eegh(LASTCOM);' e_try];
checkepochplot    = ['[EEG LASTCOM] = eeg_checkset(EEG, ''epoch'', ''chanloc'');' ret ' eegh(LASTCOM);' e_try];
checkepochicaplot = ['[EEG LASTCOM] = eeg_checkset(EEG, ''epoch'', ''ica'', ''chanloc'');' ret ' eegh(LASTCOM);' e_try];

% check string and backup old dataset
% -----------------------------------
backup =     [ 'if CURRENTSET ~= 0,' ...
               '    [ ALLEEG EEG ] = eeg_store(ALLEEG, EEG, CURRENTSET, ''savegui'');' ...
               '    eegh(''[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET, ''''savedata'''');'');' ...
               'end;' ];

storecall    = '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); eegh(''[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);'');';
storenewcall = '[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, ''study'', ~isempty(STUDY)+0); eegh(LASTCOM);';
storeallcall = [ 'if ~isempty(ALLEEG) & ~isempty(ALLEEG(1).data), ALLEEG = eeg_checkset(ALLEEG);' ...
                 'EEG = eeg_retrieve(ALLEEG, CURRENTSET); eegh(''ALLEEG = eeg_checkset(ALLEEG); EEG = eeg_retrieve(ALLEEG, CURRENTSET);''); end;' ];

testeegtmp   =  'if exist(''EEGTMP'') == 1, EEG = EEGTMP; clear EEGTMP; end;'; % for backward compatibility
ifeeg        =  'if ~isempty(LASTCOM) & ~isempty(EEG),';
ifeegnh      =  'if ~isempty(LASTCOM) & ~isempty(EEG) & ~isempty(findstr(''='',LASTCOM)),';

% nh = no dataset history
% -----------------------
e_storeall_nh   = [e_catch 'eegh(LASTCOM);' ifeeg storeallcall 'disp(''Done.''); end; eeglab(''redraw'');'];
e_hist_nh       = [e_catch 'eegh(LASTCOM);'];

% same as above but also save history in dataset
% ----------------------------------------------
e_newset        = [e_catch 'EEG = eegh(LASTCOM, EEG);' testeegtmp ifeeg   storenewcall 'disp(''Done.''); end; eeglab(''redraw'');'];
e_store         = [e_catch 'EEG = eegh(LASTCOM, EEG);' ifeegnh storecall    'disp(''Done.''); end; eeglab(''redraw'');'];
e_hist          = [e_catch 'EEG = eegh(LASTCOM, EEG);'];
e_histdone      = [e_catch 'EEG = eegh(LASTCOM, EEG); if ~isempty(LASTCOM), disp(''Done.''); end;' ];

% study checking
% --------------
e_load_study = [e_catch 'if ~isempty(LASTCOM), STUDY = STUDYTMP; STUDY = eegh(LASTCOM, STUDY); ALLEEG = ALLEEGTMP; EEG = ALLEEG; CURRENTSET = [1:length(EEG)]; eegh(''CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];''); CURRENTSTUDY = 1; disp(''Done.''); end; clear ALLEEGTMP STUDYTMP; eeglab(''redraw'');'];
e_plot_study = [e_catch 'if ~isempty(LASTCOM), STUDY = STUDYTMP; STUDY = eegh(LASTCOM, STUDY); disp(''Done.''); end; clear ALLEEGTMP STUDYTMP; eeglab(''redraw'');']; % ALLEEG not modified

% build structures for plugins
% ----------------------------
trystrs.no_check                 = e_try;
trystrs.check_data               = check;
trystrs.check_ica                = checkica;
trystrs.check_cont               = checkcont;
trystrs.check_epoch              = checkepoch;
trystrs.check_event              = checkevent;
trystrs.check_epoch_ica          = checkepochica;
trystrs.check_chanlocs           = checkplot;
trystrs.check_epoch_chanlocs     = checkepochplot;
trystrs.check_epoch_ica_chanlocs = checkepochicaplot;
catchstrs.add_to_hist            = e_hist;
catchstrs.store_and_hist         = e_store;
catchstrs.new_and_hist           = e_newset;
catchstrs.new_non_empty          = e_newset;
catchstrs.update_study           = e_plot_study;

% detecting icalab
% ----------------
if exist('icalab')
    disp('ICALAB toolbox detected (algo. added to "run ICA" interface)');
end;

if ~iseeglabdeployed2
    % check for older version of Fieldtrip and presence of topoplot
    % -------------------------------------------------------------
    if ismatlab
        ptopoplot  = fileparts(mywhich('cbar'));
        ptopoplot2 = fileparts(mywhich('topoplot'));
        if ~strcmpi(ptopoplot, ptopoplot2),
            %disp('  Warning: duplicate function topoplot.m in Fieldtrip and EEGLAB');
            %disp('  EEGLAB function will prevail and call the Fieldtrip one when appropriate');
            addpath(ptopoplot);
        end;
    end;
end;

if iseeglabdeployed2
    disp('Adding FIELDTRIP toolbox functions');
    disp('Adding BIOSIG toolbox functions');
    disp('Adding FILE-IO toolbox functions');
    funcname = {  'eegplugin_VisEd' ...
                  'eegplugin_eepimport' ...
                  'eegplugin_bdfimport' ...
                  'eegplugin_brainmovie' ...
                  'eegplugin_bva_io' ...
                  'eegplugin_ctfimport' ...
                  'eegplugin_dipfit' ...
                  'eegplugin_erpssimport' ...
                  'eegplugin_fmrib' ...
                  'eegplugin_iirfilt' ...
                  'eegplugin_ascinstep' ...
                  'eegplugin_loreta' ...
                  'eegplugin_miclust' ...
                  'eegplugin_4dneuroimaging' };
    for indf = 1:length(funcname)
        try 
            vers = feval(funcname{indf}, gcf, trystrs, catchstrs);
            %disp(['EEGLAB: adding "' vers '" plugin' ]);  
        catch
            feval(funcname{indf}, gcf, trystrs, catchstrs);
            %disp(['EEGLAB: adding plugin function "' funcname{indf} '"' ]);   
        end;
    end;
else    
    pluginlist  = [];
    plugincount = 1;
    
    p = mywhich('eeglab.m');
    p = p(1:findstr(p,'eeglab.m')-1);
    if strcmpi(p, './') || strcmpi(p, '.\'), p = [ pwd filesep ]; end;
    
    % scan deactivated plugin folder
    % ------------------------------
    dircontent  = dir(fullfile(p, 'deactivatedplugins'));
    dircontent  = { dircontent.name };
    for index = 1:length(dircontent)
        funcname = '';
        pluginVersion = '';
        if exist([p 'deactivatedplugins' filesep dircontent{index}]) == 7
            if ~strcmpi(dircontent{index}, '.') & ~strcmpi(dircontent{index}, '..')
                tmpdir = dir([ p 'deactivatedplugins' filesep dircontent{index} filesep 'eegplugin*.m' ]);
                [ pluginName pluginVersion ] = parsepluginname(dircontent{index});
                if ~isempty(tmpdir)
                    funcname = tmpdir(1).name(1:end-2);
                end;
            end;
        else 
            if ~isempty(findstr(dircontent{index}, 'eegplugin')) && dircontent{index}(end) == 'm'
                funcname = dircontent{index}(1:end-2); % remove .m
                [ pluginName pluginVersion ] = parsepluginname(dircontent{index}(10:end-2));
            end;
        end;
        if ~isempty(pluginVersion)
            pluginlist(plugincount).plugin     = pluginName;
            pluginlist(plugincount).version    = pluginVersion;
            pluginlist(plugincount).foldername = dircontent{index};
            if ~isempty(funcname)
                 pluginlist(plugincount).funcname   = funcname(10:end);
            else pluginlist(plugincount).funcname   = '';
            end
            if length(pluginlist(plugincount).funcname) > 1 && pluginlist(plugincount).funcname(1) == '_'
                pluginlist(plugincount).funcname(1) = [];
            end; 
            pluginlist(plugincount).status = 'deactivated';
            plugincount = plugincount+1;
        end;
    end;
    
    % scan plugin folder
    % ------------------
    dircontent  = dir(fullfile(p, 'plugins'));
    dircontent  = { dircontent.name };
    for index = 1:length(dircontent)

        % find function
        % -------------
        funcname = '';
        pluginVersion = [];
        if exist([p 'plugins' filesep dircontent{index}]) == 7
            if ~strcmpi(dircontent{index}, '.') & ~strcmpi(dircontent{index}, '..')
                newpath = [ 'plugins' filesep dircontent{index} ];
                tmpdir = dir([ p 'plugins' filesep dircontent{index} filesep 'eegplugin*.m' ]);
                
                addpathifnotinlist(fullfile(eeglabpath, newpath));
                [ pluginName pluginVersion ] = parsepluginname(dircontent{index});
                if ~isempty(tmpdir)
                    %myaddpath(eeglabpath, tmpdir(1).name, newpath);
                    funcname = tmpdir(1).name(1:end-2);
                end;
                
                % special case of subfolder for Fieldtrip
                % ---------------------------------------
                if ~isempty(findstr(lower(dircontent{index}), 'fieldtrip'))
                    addpathifnotexist( fullfile(eeglabpath, newpath, 'compat') , 'electrodenormalize' );
                    addpathifnotexist( fullfile(eeglabpath, newpath, 'forward'), 'ft_sourcedepth.m');
                    addpathifnotexist( fullfile(eeglabpath, newpath, 'utilities'), 'ft_datatype.m');
                    ptopoplot  = fileparts(mywhich('cbar'));
                    ptopoplot2 = fileparts(mywhich('topoplot'));
                    if ~isequal(ptopoplot, ptopoplot2)
                        addpath(ptopoplot);
                    end;
                end;
                    
                % special case of subfolder for BIOSIG
                % ------------------------------------
                if ~isempty(findstr(lower(dircontent{index}), 'biosig')) && isempty(findstr(lower(dircontent{index}), 'biosigplot'))
                    addpathifnotexist( fullfile(eeglabpath, newpath, 'biosig', 't200_FileAccess'), 'sopen.m');
                    addpathifnotexist( fullfile(eeglabpath, newpath, 'biosig', 't250_ArtifactPreProcessingQualityControl'), 'regress_eog.m' );
                    addpathifnotexist( fullfile(eeglabpath, newpath, 'biosig', 'doc'), 'DecimalFactors.txt');
                end;
                    
            end;
        else 
            if ~isempty(findstr(dircontent{index}, 'eegplugin')) && dircontent{index}(end) == 'm'
                funcname = dircontent{index}(1:end-2); % remove .m
                [ pluginName pluginVersion ] = parsepluginname(dircontent{index}(10:end-2));
            end;
        end;

        % execute function
        % ----------------
        if ~isempty(pluginVersion) || ~isempty(funcname)
            if isempty(funcname)
                %disp([ 'EEGLAB: adding "' pluginName '" to the path; subfolders (if any) might be missing from the path' ]);
                pluginlist(plugincount).plugin     = pluginName;
                pluginlist(plugincount).version    = pluginVersion;
                pluginlist(plugincount).foldername = dircontent{index};
                pluginlist(plugincount).status     = 'ok';
                plugincount = plugincount+1;
            else
                pluginlist(plugincount).plugin     = pluginName;
                pluginlist(plugincount).version    = pluginVersion;
                vers   = pluginlist(plugincount).version; % version
                vers2  = '';
                status = 'ok';

                pluginlist(plugincount).funcname   = funcname(10:end);
                pluginlist(plugincount).foldername = dircontent{index};
                [tmp pluginlist(plugincount).versionfunc] = parsepluginname(vers2);
                if length(pluginlist(plugincount).funcname) > 1 && pluginlist(plugincount).funcname(1) == '_'
                    pluginlist(plugincount).funcname(1) = [];
                end; 
                if strcmpi(status, 'ok')
                    if isempty(vers), vers = pluginlist(plugincount).versionfunc; end;
                    if isempty(vers), vers = '?'; end;
                    %fprintf('EEGLAB: adding "%s" v%s (see >> help %s)\n', ...
                        %pluginlist(plugincount).plugin, vers, funcname);
                end;
                pluginlist(plugincount).status       = status;
                plugincount = plugincount+1;
            end;
        end;
    end;
    
end; % iseeglabdeployed2
% Path exception for BIOSIG (sending BIOSIG down into the path)
biosigpathlast; % fix str2double issue
if ~ismatlab, return; end;

function rmpathifpresent(newpath);  
    comp = computer;
    if strcmpi(comp(1:2), 'PC')
        newpath = [ newpath ';' ];
    else
        newpath = [ newpath ':' ];
    end;
    if ismatlab
         p = matlabpath;
    else p = path;
    end;
    ind = strfind(p, newpath);
    if ~isempty(ind)
        rmpath(newpath);
    end;
        
% add path only if it is not already in the list
% ----------------------------------------------
function addpathifnotinlist(newpath);  

    comp = computer;
    if strcmpi(comp(1:2), 'PC')
        newpathtest = [ newpath ';' ];
    else
        newpathtest = [ newpath ':' ];
    end;
    if ismatlab
         p = matlabpath;
    else p = path;
    end;
    ind = strfind(p, newpathtest);
    if isempty(ind)
        if exist(newpath) == 7
            addpath(newpath);
        end;
    end;

function addpathifnotexist(newpath, functionname);
    tmpp = mywhich(functionname);
        
    if isempty(tmpp)
        addpath(newpath);
    end;
    
% find a function path and add path if not present
% ------------------------------------------------
function myaddpath(eeglabpath, functionname, pathtoadd);

    tmpp = mywhich(functionname);
    tmpnewpath = [ eeglabpath pathtoadd ];
    if ~isempty(tmpp)
        tmpp = tmpp(1:end-length(functionname));
        if length(tmpp) > length(tmpnewpath), tmpp = tmpp(1:end-1); end; % remove trailing filesep
        if length(tmpp) > length(tmpnewpath), tmpp = tmpp(1:end-1); end; % remove trailing filesep
        %disp([ tmpp '     |        ' tmpnewpath '(' num2str(~strcmpi(tmpnewpath, tmpp)) ')' ]);
        if ~strcmpi(tmpnewpath, tmpp)
            warning('off', 'MATLAB:dispatcher:nameConflict');
            addpath(tmpnewpath);
            warning('on', 'MATLAB:dispatcher:nameConflict');
        end;
    else
        %disp([ 'Adding new path ' tmpnewpath ]);
        addpathifnotinlist(tmpnewpath);
    end;

function val = iseeglabdeployed2;
%val = 1; return;
if exist('isdeployed')
     val = isdeployed;
else val = 0;
end;

function buildhelpmenu;
    
% parse plugin function name
% --------------------------
function [name, vers] = parsepluginname(dirName);
    ind = find( dirName >= '0' & dirName <= '9' );
    if isempty(ind)
        name = dirName;
        vers = '';
    else
        ind = length(dirName);
        while ind > 0 && ((dirName(ind) >= '0' & dirName(ind) <= '9') || dirName(ind) == '.' || dirName(ind) == '_')
            ind = ind - 1;
        end;
        name = dirName(1:ind);
        vers = dirName(ind+1:end);
        vers(find(vers == '_')) = '.';
    end;

% required here because path not added yet
% to the admin folder
function res = ismatlab;

v = version;
if v(1) > '4'
    res = 1;
else
    res = 0;
end;
    
function res = mywhich(varargin);
try
    res = which(varargin{:});
catch
    fprintf('Warning: permission error accesssing %s\n', varargin{1});
end;