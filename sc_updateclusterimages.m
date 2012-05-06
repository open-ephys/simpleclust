function features=sc_updateclusterimages(features,mua);

features.clusterimages=zeros(features.imagesize,features.imagesize,12);

usefastmethod =1;
% first, if usefastmethod, interpolate up all waveforms so they look nicer


if usefastmethod
    if ~isfield(features,'waveforms_hi') % this takes up time in the first pass
        x=size(mua.waveforms,2);
        sfact = features.imagesize/x;
        features.waveforms_hi=zeros(size(mua.waveforms,1),round(x*sfact));
        
        
        for i=1:size( mua.waveforms,1)
            
            if mod(i,2000)==0
            clf; hold on;
            fill([-2 -2 5 5],[-2 2 2 -2],'k','FaceColor',[.95 .95 .95]);
            
            plot(linspace(1,3,numel(features.waveforms_hi(i-1,:))) , 1.0*features.waveforms_hi(i-1,:)/max(features.waveforms_hi(i-1,:)) ,'k','LineWidth',22,'color',[.9 .9 .9])
            
            
            xx=linspace(0,2*pi*(i/size( mua.waveforms,1)),100);
            plot(sin(xx).*.4,cos(xx).*.4,'k','LineWidth',22,'color',[.85 .85 .85])
            text(0,0,['interpolating waveforms']);
            
            xlim([-1.3, 3.3]);     ylim([-1.3, 1.2]);
            daspect([1 1 1]);set(gca,'XTick',[]); set(gca,'YTick',[]);
            
            
            drawnow;
            end;
            
            
            
            features.waveforms_hi(i,:) = interp1(1:x,mua.waveforms(i,:),linspace(1,x,features.imagesize), 'linear'); % use linear for speed
        end;
    end;
    
    features.clusterimages=zeros(features.imagesize,features.imagesize,features.Nclusters);
    
end;



%npoints=numel(mua.ts_spike);
npoints=size(mua.waveforms,2);

ll=(linspace(-.1,.1,features.imagesize).*4.8)./features.waveformscale;

for i=1:features.Nclusters
    
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
                features.clusterimages(:,x,i) = histc( features.waveforms_hi(inthiscluster, k ) , ll ) + g';
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
