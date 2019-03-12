

%% load raw data

set(0,'DefaultFigureWindowStyle','docked'); % fix matlab's figure positioning bug

% raw data available on
% https://drive.google.com/drive/folders/1CwFcErgp3F3D6I2TB_hTtW1JAQB21TAC?usp=sharing
%
datapath='/home/jvoigts/Desktop/TT13_continuous_3/'

out_dir='/home/jvoigts/Desktop/TT13_continuous_3/';
out_name = 'marie_rsc_test.mat';

source_channels=[40 40 38 36];

data_raw=[];
for ch=source_cahnnels % grab 4 channels of raw data from one tetrode
    fname=sprintf('100_CH%d.continuous',ch)
    [data, timestamps, info]=load_open_ephys_data_faster(fullfile(datapath,fname));
    data_raw(:,end+1) = data;
end;

data_raw=data_raw.*info.header.bitVolts;
fs = info.header.sampleRate;

%data_raw=data_raw(1:30000,:); % cut away some data for faster testing

%% plot

plotlim=50000;
figure(1);
clf;
hold on;
plot(data_raw(1:plotlim,:));


%% filter

clf; hold on;
[b,a] = butter(3, [300 3000]/(fs/2)); % choose filter (normalize bp freq. to nyquist freq.)

data_bp=filtfilt(b,a,data_raw); %use zero phase filter

%% plot filtered
offset=plotlim*0;
clf;
plot(data_bp([1:plotlim]+offset,:));
hold on;

%% find treshold crossings
treshold=-6;
crossed= min(data_bp,[],2)<-treshold; % trigger if _any_ channel crosses in neg. direction

spike_onsets=find(diff(crossed)==1);

length_sec=size(data,1)/fs;
fprintf('got %d candidate events in %dmin of data, ~%.2f Hz\n',numel(spike_onsets),round(length_sec/60),numel(spike_onsets)/length_sec);

%% plot some spike onsets 
for i=1:100%numel(spike_onsets)
    if(spike_onsets(i)<plotlim)
        plot([1 1].*spike_onsets(i),[-1 1].*treshold*2,'k--')
    end;
end;


%% extract spike waveforms and make some features

spike_window=[1:32]-5; % grab some pre-treshold crossign samples

spikes=[];
spikes.waveforms=zeros(numel(spike_onsets),4*numel(spike_window)); % pre-allocate memory
spikes.peakamps=zeros(numel(spike_onsets),4);
spikes.times = spike_onsets/(fs/1000);

for i=1:numel(spike_onsets)
    this_spike=(data_bp(spike_onsets(i)+spike_window,:));
    
    spikes.waveforms(i,:)= this_spike(:);% grab entire waveform
    spikes.peakamps(i,:)=min(this_spike); % grab 4 peak amplitudes
end;

%% make into and save as simpleclust compatible file
mua=[];
mua.waveforms=spikes.waveforms;
mua.sourcechannel = source_channels;
mua.ts = spike_onsets/info.header.sampleRate;
mua.ts_spike=([1:size(spikes.waveforms,2)]-1)./info.header.sampleRate;
mua.ncontacts=4;

save(fullfile(out_dir,[out_name,'.mat']),'mua');


%% BELOW HERE IS A VERY MINIMAL SPIKE SORTER

%% plot peak to peak amplitudes
clf; hold on;
plot(spikes.peakamps(:,2),spikes.peakamps(:,4),'.');
daspect([1 1 1]);

%% initialize all cluster assignments to 1
spikes.cluster=ones(numel(spike_onsets),1);

%% manual spike sorter
% cluster 0 shall be the noise cluster (dont plot this one)
run =1;

projections=[1 2; 1 3; 1 4; 2 3; 2 4; 3 4]; % possible feature projections
use_projection=1;

cluster_selected=2; spike_selected=1;

while run
    dat_x=spikes.peakamps(:,projections(use_projection,1));
    dat_y=spikes.peakamps(:,projections(use_projection,2));
    
    clf; 
    subplot(2,3,1); hold on;% plot median waveform
    plot(quantile(spikes.waveforms(spikes.cluster==cluster_selected,:),.2),'g');
    plot(quantile(spikes.waveforms(spikes.cluster==cluster_selected,:),.5),'k');
    plot(quantile(spikes.waveforms(spikes.cluster==cluster_selected,:),.8),'g');
    plot(spikes.waveforms(spike_selected,:),'r'); % also plot currently selected spike waveform
    
    title('waveforms from cluster');
    
    subplot(2,3,4); hold on;% plot isi distribution
    isi = diff(spikes.times(spikes.cluster==cluster_selected));
    bins=linspace(0.5,15,20); 
    h= hist(isi,bins); h(end)=0;
    stairs(bins,h);
    title('ISI histogram'); xlabel('isi(ms)');
    
    ax=subplot(2,3,[2 3 5 6]); hold on; % plot main feature display
    ii=spikes.cluster>0; % dont plot noise cluster
    scatter(dat_x(ii),dat_y(ii),(0.5+(spikes.cluster(ii)==cluster_selected))*20,spikes.cluster(ii)*2,'filled');
    plot(dat_x(spike_selected),dat_y(spike_selected),'ro','markerSize',10);
    title(sprintf('current cluster %d, projection %d, %d spikes in cluster',cluster_selected,use_projection,sum(spikes.cluster==cluster_selected)));
    
    [x,y,b]=ginput(1);
    
    if b>47 & b <58 % number keys, cluster select
        cluster_selected=b-48;
    end;
    
    if b==30; use_projection=mod(use_projection,6)+1; end; % up/down: cycle trough projections
    if b==31; use_projection=mod(use_projection-2,6)+1; end; % up/down: cycle trough projections
    if b==27; disp('exited'); run=0; end; % esc: exit
    
    if b==43 | b==42; % +, add to cluster
        t= imfreehand(ax,'Closed' ,1);
        t.setClosed(1);
        r=t.getPosition;
        px=r(:,1);py=r(:,2);
        in = inpolygon(dat_x,dat_y,px,py);
        if b==43 % +, add
            spikes.cluster(in)=cluster_selected;
        else % *. intersect cluster (move all non selected to null cluster)
            spikes.cluster(~in & spikes.cluster==cluster_selected)=1;
        end;
    end;
    
    if b==1 % left click - select individual waveform to plot
        [~,spike_selected]=min((dat_x-x).^2 +(dat_y-y).^2);
    end;
    
end;
