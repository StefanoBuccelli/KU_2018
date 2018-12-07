%% goal: understand how much are signals within the same probe correlated
clear
clc
close all
cd('/Volumes/Processed_Data/Rat/ComplexBoxHealthyPilotStudy/R17-11/R17-11_2017_02_24_1/R17-11_2017_02_24_1_RawData')

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
    curr_low(curr_ch,:)=bandpass(curr_raw(curr_ch,:),[70 95],20e3,'Steepness',0.85,'StopbandAttenuation',60);
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





