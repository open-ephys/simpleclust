function features = mua2features_2(mua)

%writes a spike parm file for tetrode data
%
% ONLY DOES ONE CHANNEL RIGHT NOW
%


%D=(squeeze(reshape(tt.waveforms,1,32*size(tt.waveforms,1),size(tt.waveforms,3) )));

D= (squeeze(reshape(mua.waveforms,1,64,size(mua.waveforms,3))));
D=[D(1:2:end,:);D(2:2:end,:)];

%% run PCA
% D=[ D(1:2:end,:) , D(2:2:end,:)];


if size(D,2)<size(D,1)  % pad to square if there are fewer spikes than points per waveform
    D(:,size(D,1))=0;
end;

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
disp('computing pca');

c=princomp(D,'econ');
coeffs=c(:,1:8);

%}

%% get Wavelet coeffs

%{


disp('  computing Wavelet features...')

coeffs=wave_features_wc_mod_8(D)./10;



%}


%plot(coeffs(:,1),coeffs(:,2),'.','MarkerSize',.5)

%% write data
disp('  making features ..')

features=[];


for n = 1:length(mua.ts)
    
    spike = squeeze(mua.waveforms(:,:,n))./20;
    % divide by 20 to get it into the default range for xclust
    % this shouldn't matter for any further processing
    
    
    % interpolate so we get better peaks etc?
    
    %calculate Nonlinear energy (Teager energy operator)
    for d=1:2 %size(spike,1)
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
    
    for d=1:2 %size(spike,1)
        x=spike(d,:);
        mid(d)=round(numel(x)/2)+1;
        
        dd=diff(x);
        y=min(find (( sign(dd(2:end))~=sign(dd(1:end-1)) ) .* x(2:end-1)<0 )+1);
        if numel(y)>0
            mins(d) = y;
        else
            mind(d)=0;
        end;
        
        pretime=0;
        %{
    clf;
    plot(spike); hold on;
    plot(dd,'g');
    plot(dd.*0,'g');
    
    plot(mid,spike(mid),'ro');
    plot(mins,spike(mins),'rx');
        %}
        
        %  min_before(d)=max(mins(mins<=mid));
        %  min_after(d)=min(mins(mins>=mid));
        
    end;
    
    
    features.ts(n)=mua.ts(n);
    features.id(n)=n;
    
    features.data(1,n)=peaks(1);
    
    features.data(2,n)=peaks(2);
    
    features.data(3,n)=neo(1);
    
    features.data(4,n)=neo(2);
    
    for i=1:8
        features.data(4+i,n)=pc(i);
        
    end;
    
    features.data(12,n)=mua.ts(n);
end

features.name{1}='peak a';

features.name{2}='peak b';

features.name{3}='neo a';

features.name{4}='neo b';
for i=1:8
    features.name{4+i}=['PCA ',num2str(i)];
end;

features.name{12}='time';
