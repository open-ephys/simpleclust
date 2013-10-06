function features=sc_updateclusterimages(features,mua);



% first, update the ISI plots
for i=1:features.Nclusters
    
    % precompute ISI hist.
    
    features.isioptions(1).tmax = max(.5,features.isioptions(1).tmax);
    
    l=linspace(0,features.isioptions(1).tmax,features.isioptions(1).nbins);
    
    thisclust=find(features.clusters==i);
    if numel(thisclust)>1
        
        dt= diff(features.ts(thisclust).*1000);
        dt(dt==0)=[];
        psize=0.65;
        
        h=histc(dt,l);
        h=(h./max(h)).*psize.*.95;
        
        features.isiplots{i}=h;
    else
        features.isiplots{i}=zeros(0,features.isioptions(1).nbins);
    end;
    
end;



% now update actual cluster images

%features.clusterimages=zeros(features.imagesize,features.imagesize,12);

usefastmethod =1;

% first, if usefastmethod, interpolate up all waveforms so they look nicer
if usefastmethod
    if ~isfield(features,'waveforms_hi') % this takes up time in the first pass
        x=size(mua.waveforms,2);
        L_im=linspace(1,x,features.imagesize);
        sfact = features.imagesize/x;
        features.waveforms_hi=zeros(size(mua.waveforms,1),round(x*sfact));
        
        
        for i=1:size( mua.waveforms,1)
            
            if mod(i,4000)==0
                clf; hold on;
                fill([-2 -2 5 5],[-2 2 2 -2],'k','FaceColor',[.95 .95 .95]);
                
                plot(linspace(1,3,numel(features.waveforms_hi(i-1,:))) , 0.9*features.waveforms_hi(i-1,:)/max(features.waveforms_hi(i-1,:)) ,'k','LineWidth',22,'color',.93.*[1 1 1])
                
                
                xx=linspace(0,2*pi*(i/size( mua.waveforms,1)),100);
                plot(sin(xx).*.4,cos(xx).*.4,'k','LineWidth',22,'color',[.85 .85 .85])
                text(0,0,['interpolating waveforms']);
                
                xlim([-1.3, 3.3]);     ylim([-1.3, 1.2]);
                daspect([1 1 1]);set(gca,'XTick',[]); set(gca,'YTick',[]);
                
                
                drawnow;
            end;
            
            
            
            features.waveforms_hi(i,:) = interp1(1:x,mua.waveforms(i,:),L_im, 'linear'); % use 'linear' for speed or even 'nearest'
        end;
    end;
    
    
end;



%npoints=numel(mua.ts_spike);
npoints=size(mua.waveforms,2);

ll=(linspace(-.1,.1,features.imagesize).*4.8)./features.waveformscale;

% if the last manipulation was a +,-,or *, then the only clusters that are
% affected are NULl and the slected cluster, so we can restrict the image
% upates to these two clusters and save a LOT of time:
if features.last_op_was_from_any
    clusters_to_update = 1:features.Nclusters;
else
    clusters_to_update =[1 features.editedcluster];
end;


for i=clusters_to_update
    
    
    features.clusterimages(:,:,i)=zeros(features.imagesize,features.imagesize);
    
    inthiscluster=find(features.clusters==i);
    
    
    if usefastmethod % fast, not as pretty
        
        grid=zeros(size(ll)); grid(round(end/2))=1;
        
        for k=1:features.imagesize % go trough image instead of waveform points, for speed and image quality
            x = k;
            %features.clusterimages(:,x,i) = histc( features.waveforms_hi(inthiscluster, round(sc_remap(k,1,features.imagesize,1,size(mua.waveforms,2)))  ) , ll*6 );
            
            if mod(k,6)<3
                g=grid;
            else
                g=grid.*0;
            end;
            
            if numel(inthiscluster)==1
                g=g';
            end;
            if numel(inthiscluster) >0
                features.clusterimages(:,x,i) = histc( features.waveforms_hi(inthiscluster(1:2:end), k ) , ll ) + g';
            else
                features.clusterimages(:,x,i) =  g;
            end;
            
        end;
        
    else % old, slow method
        
        for j=1:numel(inthiscluster)
            
            lastx=0; % avoid drawing the same line twice
            
            for k=2:npoints
                
                
                xa=  (((k-1)/npoints)*features.imagesize);
                ya=  ( mua.waveforms(inthiscluster(j),k-1) );
                
                xb=  ((k/npoints)*features.imagesize);
                yb=  ( mua.waveforms(inthiscluster(j),k) );
                
                
                steps=3;
                for ii=1:steps
                    
                    m=(ii-1)./steps;
                    x=floor((1-m)*xa + m*xb);
                    y=floor(( (1-m)*ya + m*yb) *features.imagesize *features.waveformscale) +round(features.imagesize/2);
                    
                    
                    if (x>0) && (y>0) && (x<=features.imagesize) && (y<=features.imagesize)&& (x~=lastx)
                        
                        features.clusterimages(y,x,i)=features.clusterimages(y,x,i)+1;
                        lastx=x;
                    end;
                    
                end;
                
                
            end;
        end;
        
    end;
end;
