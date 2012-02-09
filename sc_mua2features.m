function features = mua2features(mua)

%writes a spike parm file for tetrode data
%
% ONLY DOES ONE CHANNEL RIGHT NOW
%


%D=(squeeze(reshape(tt.waveforms,1,32*size(tt.waveforms,1),size(tt.waveforms,3) )));

D=mua.waveforms;

%% run PCA via nipals
% D=[ D(1:2:end,:) , D(2:2:end,:)];

%{
if size(D,2)<size(D,1)  % pad to square if there are fewer spikes than points per waveform
    D(:,size(D,1))=0;
end;
%}
%{
for i=1:size(D,1)
    
    
    %  possibly get rid of outliers for the pca
    
%{
    level=0.001;
    q=quantile(D(i,:),[level,1-level]);
    D(i,D(i,:)>q(2))=q(2);
    D(i,D(i,:)<q(1))=q(1);
%}
    
    %   center/rescale
    D(i,:)=D(i,:)-mean(D(i,:));
    s=std(D(i,:));
    if s>0
        D(i,:)=D(i,:)./s;
    else
        D(i,:)=D(i,:).*0;
    end;
    
    
end;
%}
%{
[Tprinc,Lprinc,pc]=nipals2(D,4);
coeffs=Lprinc';
%}

%% get Wavelet coeffs


if 0 % disabled because this takes up too much time and users can justcompute these manually
    
    disp('  computing Wavelet features...')
    
    coeffs=sc_wave_features_wc_mod_8(D')./10;
    
    
    %clf; hold on;
    
    D=coeffs;
end;

%% do PCA features


disp('  computing PCA ...')
[coeffs,score]= princomp(mua.waveforms','econ');

D=coeffs(:,1:8)';

%plot(coeffs(:,1),coeffs(:,2),'.','MarkerSize',.5)


disp('  making features ..')

features=[];

%% write data

trodeboundaries = max(1,round(linspace(0,size(mua.waveforms,2),mua.ncontacts+1)));


for n = 1:length(mua.ts)
    c=0;
    spike = squeeze(mua.waveforms(n,:))./20;
    
    features.ts(n)=mua.ts(n);
    features.id(n)=n;
    
    
    % spike time
    c=c+1;
    features.data(c,n)=mua.ts(n);
    
    if n==1; features.name{c}=['time']; end;
    
    %peak height
    for d=1:mua.ncontacts %size(spike,1)
        x=spike(trodeboundaries(d):trodeboundaries(d+1));
        neo(d) =max(x);
        
        c=c+1;
        features.data(c,n)= neo(d);
        
        if n==1; features.name{c}=['peak ',num2str(d)]; end;
        
    end;
    
    
    %calculate Nonlinear energy (Teager energy operator)
    for d=1:mua.ncontacts %size(spike,1)
        x=spike(trodeboundaries(d):trodeboundaries(d+1));
        neo(d) = mean(x(2:end-1).^2 - ( x(1:end-2) .* x(3:end) ))*10;
        
        c=c+1;
        features.data(c,n)= neo(d);
        
        if n==1; features.name{c}=['energy ',num2str(d)]; end;
        
    end;
    
    % put in PCA features
    if size(coeffs,2)>2
        pc = coeffs(n,1:8).*100;
    else
        pc = [0 0 0 0 0 0 0 0 0];
    end;
    
    for i=1:8
        c=c+1;
        features.data(c,n)= pc(i);
        if n==1; features.name{c}=['PCA ',num2str(i)]; end;
    end;
    
    
    
       % max. derivative
    c=c+1;
    features.data(c,n)=max(abs(diff(spike)));
    
    if n==1; features.name{c}=['maxD']; end;
    
    
end





%% old code
%{
for n = 1:length(mua.ts)
    
    spike = squeeze(mua.waveforms(n,:))./20;
    % divide by 20 to get it into the default range for xclust
    % this shouldn't matter for any further processing
    
    
    % interpolate so we get better peaks etc?
    
    %calculate Nonlinear energy (Teager energy operator)
    for d=1 %size(spike,1)
        x=spike(d,:);
        neo(d) = mean(x(2:end-1).^2 - ( x(1:end-2) .* x(3:end) ))*10;
    end;
    
    
    [closest_time] = 0;
    ind =0 ;
    
    %   nearest_pos_x = pos.xval(ind);
    %   nearest_pos_y = pos.yval(ind);
    
    [peaks,peak_inds] = max(spike');
    [troughs,trough_inds] = min(spike');
    
    max_height = max(peaks+abs(troughs));
    
    widths = trough_inds - peak_inds;
    f = find(widths > 0);
    
    if numel(f) > 0
        max_width = max(widths(f));
    else
        max_width = 0;
    end
    
    %disp(n-1)
    
    if size(coeffs,2)>2
        pc = coeffs(n,1:8).*100;
        %   tt.Pcomps(i,3:4) = 0;
    else
        pc = [0 0 0 0 0 0 0 0 0];
    end;
    %   pc = [0 0 0 0];
    
    
    mid=round(numel(spike)/2)+1;
    
    dd=diff(spike);
    mins = find (( sign(dd(2:end))~=sign(dd(1:end-1)) ) .* spike(2:end-1)<0 )+1;
    
    pretime=0;
%{
    clf;
    plot(spike); hold on;
    plot(dd,'g');
    plot(dd.*0,'g');
    
    plot(mid,spike(mid),'ro');
    plot(mins,spike(mins),'rx');
%}
    
    min_before=max(mins(mins<=mid));
    min_after=min(mins(mins>=mid));
    
    
    features.ts(n)=mua.ts(n);
    features.id(n)=n;
    
    features.data(1,n)=peaks;
    
    features.data(2,n)=neo;
    
    
    if numel(min_before)>0
        features.data(3,n)=abs(mid - min_before);
        
        features.data(5,n)=spike(mid)-spike(min_before);
    end;
    
    if numel(min_after)>0
        features.data(4,n)=abs(mid - min_after);
        
        
        features.data(6,n)=spike(mid)-spike(min_after);
    end;
    
    for i=1:8
        features.data(6+i,n)=pc(i);
        
    end;
    
    features.data(15,n)=mua.ts(n);
end


features.name{1}='peak';
features.name{2}='neo';
features.name{3}='pre_width';
features.name{4}='post_width';
features.name{5}='pre_height';
features.name{6}='post_height';
features.name{15}='time';

for i=1:8
    features.name{6+i}=['PCA',num2str(i)];
end;
%}
