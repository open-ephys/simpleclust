function features=updateclusterimages(features,mua);

features.clusterimages=zeros(features.imagesize,features.imagesize,12);

usefastmethod =1;
% first, if usefastmethod, interpolate up all waveforms so they look nicer


if usefastmethod
    if ~isfield(features,'waveforms_hi')
        x=size(mua.waveforms,2);
        sfact = features.imagesize/x;
        features.waveforms_hi=zeros(size(mua.waveforms,1),round(x*sfact));
        for i=1:size( mua.waveforms,1)
            features.waveforms_hi(i,:) = interp1(1:x,mua.waveforms(i,:),linspace(1,x,features.imagesize));
        end;
    end;
end;



%npoints=numel(mua.ts_spike);
npoints=size(mua.waveforms,2);

for i=1:features.Nclusters
    
    inthiscluster=find(features.clusters==i);
    
    
    if usefastmethod % fast, not as pretty
        
        ll=(linspace(-.1,.1,features.imagesize).*4.8)./features.waveformscale;
        
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
