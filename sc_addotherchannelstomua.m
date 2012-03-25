function [features,mua]=sc_addotherchannelstomua(features,mua)
% load multiple files and just kepe the spike times to use in a feature
% that counts co-occurrence of spikes across channels

for i=1:numel(features.otherchannelfiles)
    
    
    
    clf; hold on
    fill([-2 -2 5 5],[-2 2 2 -2],'k','FaceColor',[.95 .95 .95]);
    x=linspace(0,2*pi,80);
    plot(sin(x).*.4,cos(x).*.4,'k','LineWidth',22,'color',[1 1 1])
    
    text(0,0,['loading extra channel ',num2str(i),'/',num2str(numel(features.otherchannelfiles))]);
    xlim([-1.3, 3.3]);     ylim([-1.3, 1.2]);
    daspect([1 1 1]);set(gca,'XTick',[]); set(gca,'YTick',[]);
    drawnow;
    
    
    [features_tmp,mua_tmp]=sc_loadmuadata(fullfile(features.muafilepath,features.otherchannelfiles{i}),0);
    mua.otherchannels{i}.ts=mua_tmp.ts;
    
end;

% now compute 'overlap' feature


features.numextrafeaatures=features.numextrafeaatures+1;
features.name{size(features.data,1)+1}=['Nchannel spike overlap'];

tbins=[min(mua.ts):0.5/1000:max(mua.ts)];

[h_this,spikebins]=histc(mua.ts,tbins);
Noverlap=h_this.*0;

for j=1:numel(mua.otherchannels)
    % h_others(:,j)=histc(mua.otherchannels{j}.ts ,tbins);
    Noverlap=Noverlap+histc(mua.otherchannels{j}.ts ,tbins).*h_this;
end;

%point the ones that didnt go into the histc(1st and last?) to 0 just in
%case
Noverlap(end+1)=0;
spikebins(spikebins==0)=numel(Noverlap);

features.data(end+1,:)=Noverlap(spikebins);


%{
% way too slow
mua.diff_to_others=zeros(numel(mua.otherchannels) ,size(features.data,2));
for i=1:size(features.data,2)
    
    if rem(i,100)==0
    fprintf('%d/%d \n',i,size(features.data,2));
    end;
    
    Noverlap=0;
    for j=1:numel(mua.otherchannels)
        mua.diff_to_others(j,i)=  min(abs(mua.otherchannels{j}.ts - mua.ts(i))) ;
    end;
    
    features.data(end+1,i)=Noverlap;
    
end;

%}

features=sc_scale_features(features);
