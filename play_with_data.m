%% goal: understand how much are signals within the same probe correlated
clear
clc
close all
cd('P:\Rat\ComplexBoxHealthyPilotStudy\R17-13\R17-13_2017_02_18_1\R17-13_2017_02_18_1_RawData')
d = designfilt('bandpassiir', ...       % Response type
    'StopbandFrequency1',65, ...    % Frequency constraints
    'PassbandFrequency1',70, ...
    'PassbandFrequency2',95, ...
    'StopbandFrequency2',100, ...
    'StopbandAttenuation1',40, ...   % Magnitude constraints
    'PassbandRipple',1, ...
    'StopbandAttenuation2',50, ...
    'DesignMethod','ellip', ...      % Design method
    'MatchExactly','passband', ...   % Design method options
    'SampleRate',20000);               % Sample rate
% fvtool(d)
%% retrive data
all_chs=dir('*Ch*');

%% cycle over them to create matfiles
for curr_ch=1:length(all_chs)
    m{curr_ch}=matfile(all_chs(curr_ch).name);
end
fs=m{1}.fs;
tot_samples=length(m{1}.data);

stop_sample=floor(tot_samples/3);
start_sample=stop_sample-fs*60; % one minute before half the recording length
time_samples=start_sample:stop_sample;
time_sec=time_samples/fs;
curr_raw=zeros(length(all_chs),length(time_sec));
for curr_ch=1:length(all_chs)
    disp(curr_ch)
    curr_raw(curr_ch,:)=m{curr_ch}.data(1,start_sample:stop_sample);
end
%% remove DC, lowpass, downsample
for curr_ch=1:length(all_chs)
    disp([num2str(1e2*curr_ch/length(all_chs)) ' %'])
    curr_raw_DC(curr_ch,:)=curr_raw(curr_ch,:)-mean(curr_raw(curr_ch,:));
    curr_low(curr_ch,:)=filtfilt(d,curr_raw(curr_ch,:));
    %     curr_low(curr_ch,:)=bandpass(curr_raw(curr_ch,:),[70 95],20e3,'Steepness',0.85,'StopbandAttenuation',60);
    curr_low_dec(curr_ch,:)=downsample(curr_low(curr_ch,:),20);
    curr_hilb=hilbert(curr_low_dec(curr_ch,:));
    curr_angle(curr_ch,:)=angle(curr_hilb);
end
time_sec_dec=downsample(time_sec,20);
%% plot
figure
hold on
for curr_ch=1:length(all_chs)
    if curr_ch<17
        h_f(1)=subplot(2,1,1);
        plot(time_sec_dec,curr_low_dec(curr_ch,:),'b')
        hold on
        plot(time_sec_dec,curr_angle(curr_ch,:),'b-')
    else
        h_f(2)=subplot(2,1,2);
        plot(time_sec_dec,curr_low_dec(curr_ch,:),'r')
        hold on
    end
end
linkaxes(h_f,'x')

%% pick 2 channels
figure
subplot(2,1,1)
plot(time_sec_dec,curr_low_dec(1,:),'b')
hold on
plot(time_sec_dec,curr_low_dec(18,:),'r')
%%
subplot(2,1,2)
phase_lag=curr_angle(1,:)-curr_angle(18,:);
[x,y]=pol2cart(phase_lag,1);
compass(x,y)
hold on
[x,y]=pol2cart(curr_angle(1,2),1);

%%
figure
for curr_window=1:100:length(x)
    start=curr_window;
    stop=curr_window+100;
    subplot(2,1,1)
    hold off
    plot(1:101,curr_low_dec(1,start:stop),'b')
    hold on
    plot(1:101,curr_low_dec(18,start:stop),'r')
    xlim([0 101])
    xlabel('Time [ms]')
    title(['Abs Start Win Time: ' num2str((start_sample+curr_window*20)/fs) ' s'])
    subplot(2,1,2)
    compass(x(start:stop),y(start:stop))
    title('Phase Lag')
    pause(1)
end


