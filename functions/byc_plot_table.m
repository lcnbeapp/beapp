%% this script plots some of the features reported in the table
function byc_plot_table(signal,signal_low_mat,result_table,time_s,byc_dir,filename,chan,seg,save_reports)
% clear
% close all
% clc

% Change the current folder to the folder of this m-file.
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end
cd ..

%data_result_folder='C:\Users\ch203202\Downloads\bycycle_matlab-master\Results\Results_mat\';
%fig_folder='C:\Users\ch203202\Downloads\bycycle_matlab-master\Results\Results_fig\';
%load([data_result_folder 'results'])

%% plot signal and BP signal
% figure
% plot(time_s,signal)
% hold on
% plot(time_s,signal_low_mat)
% legend({'signal','BP signal'})
% title(['signal and BP signal [' num2str(frequency_limits) '] Hz'])
% xlabel('Time [s]')
% savefig([fig_folder 'signal_band_pass'])

%% showing peaks and other cycle markers
figure
h(1)=subplot(5,1,1);
plot(time_s , signal_low_mat)
hold on
plot( time_s(result_table.sample_peak+1) , signal_low_mat(result_table.sample_peak+1),'bx')
plot( time_s(result_table.sample_last_trough+1) , signal_low_mat(result_table.sample_last_trough+1),'rx')
plot( time_s(result_table.sample_zerox_decay+1) , signal_low_mat(result_table.sample_zerox_decay+1),'mx')
plot( time_s(result_table.sample_zerox_rise+1) , signal_low_mat(result_table.sample_zerox_rise+1),'gx')
legend({'BP signal','sample peak','sample through','mid decay','mid rise'})
title('BP signal and peaks, valleys, decays and rise')
xlabel('Time [s]')

h(2)=subplot(5,1,2);
plot( time_s(result_table.sample_peak+1) , result_table.amp_consistency,'b')
title('amp consistency')

h(3)=subplot(5,1,3);
plot( time_s(result_table.sample_peak+1) , result_table.amp_fraction,'b')
title('amp fraction')

h(4)=subplot(5,1,4);
plot( time_s(result_table.sample_peak+1) , result_table.period_consistency,'b')
title('period consistency')

h(5)=subplot(5,1,5);
plot( time_s(result_table.sample_peak+1) , result_table.monotonicity,'b')
title('monotonicity')

linkaxes(h,'x')
pause(.5)
if save_reports
    src_dir{1} = pwd;
    cd(byc_dir);
    mkdir(strcat(filename,'_Image_outputs'));
    cd(strcat(filename,'_Image_outputs'));
    savefig([filename '_Channel' chan '_Segment',seg,'TimeSeries.fig'])
    cd(src_dir{1});
end
% savefig([fig_folder 'band_pass_peaks'])

%% showing comparison between times
% figure
% subplot(3,1,1);
% plot(result_table.time_trough./fs_mat,result_table.time_peak./fs_mat,'b.')
% max_x_y=max(max(result_table.time_trough,result_table.time_peak))./fs_mat;
% hold on
% plot([0 max_x_y],[0 max_x_y],'r')
% xlim([0 max_x_y*1.1])
% ylim([0 max_x_y*1.1])
% % axis square
% ylabel('time peak [s]')
% xlabel('time through [s]')
% title('time through vs peak')
% 
% subplot(3,1,2)
% plot(result_table.time_trough./fs_mat,result_table.time_rise./fs_mat,'b.')
% max_x_y=max(max(result_table.time_trough,result_table.time_rise))./fs_mat;
% hold on
% plot([0 max_x_y],[0 max_x_y],'r')
% xlim([0 max_x_y*1.1])
% ylim([0 max_x_y*1.1])
% % axis square
% ylabel('time rise [s]')
% xlabel('time through [s]')
% title('time through vs rise')
% 
% subplot(3,1,3)
% plot(result_table.time_ptsym,result_table.time_rdsym,'b.')
% max_x_y=max(max(result_table.time_ptsym,result_table.time_rdsym));
% hold on
% plot([0 max_x_y],[0 max_x_y],'r')
% xlim([0 max_x_y*1.1])
% ylim([0 max_x_y*1.1])
% % axis square
% ylabel('time ptsym ')
% xlabel('time rdsym')
% title('time ptsym vs rdsym')
% savefig([fig_folder 'time_peaks'])

%% showing burst-related parameters
figure
h_hist(1)=subplot(2,2,1);
histogram(result_table.amp_consistency,'normalization','probability')
title('amp consistency')
h_hist(2)=subplot(2,2,2);
histogram(result_table.amp_fraction,'normalization','probability')
title('amp fraction')
h_hist(3)=subplot(2,2,3);
histogram(result_table.period_consistency,'normalization','probability')
title('period consistency')
h_hist(4)=subplot(2,2,4);
histogram(result_table.monotonicity,'normalization','probability')
title('monotonicity')
pause(.5)
if save_reports
    cd(byc_dir);
    cd(strcat(filename,'_Image_outputs'));
    savefig([filename '_Channel' chan '_Segment',seg,'Histograms.fig'])
    cd(src_dir{1});
end