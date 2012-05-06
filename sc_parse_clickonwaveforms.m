function features= parse_clickonwaveforms(x,y,features,mua)


psize=0.65;
%plot(mua.ts_spike+1.5,mua.waveforms./1000);

xpos=[0 0 0 1 1 1 2 2 2];
ypos=[1 2 3 1 2 3 1 2 3];

labelpos=[linspace(0, psize-.3,9),linspace(0, psize-.3,10) ,linspace(0, psize-.3,10) ; zeros(1,9),ones(1,10).*.2,ones(1,10).*.3];

for i=1:features.Nclusters
    xo=(xpos(i)*(psize+.01))+.05;
    yo=-(ypos(i)*(psize+.01))+1;
    
    
    if (x> 1+xo) && (x<1+xo+psize) && (y>yo) && (y<psize+yo) % find waveform display that click is in
        
        %  plot( [1 1.1]+xo , [psize-0.1 psize]+yo,'k');
        %disp(((x-xo)-(y-yo)));
        if ((x-xo)-(y-yo))<0.5 % click on label button

            
            % better: do it in one click
            
            % fill([1+xo+psize 1+xo 1+xo 1+xo+psize],[ yo yo yo+psize yo+psize],'c','facecolor',[.9 .9 .9]); % draw a box
            
            
            % better: draw whitened out spike so user can still see it
            im=-((features.clusterimages(:,:,i)./max(max(features.clusterimages(:,:,i))) ).^(.6));
            
            imagesc( linspace(1,1+psize,features.imagesize)+xo , linspace(0,psize,features.imagesize)+yo , im/2 );
            
            
            text(xo+1.01,yo+0.02,num2str(i),'color',[0 0 0]);
            plot(xo+1.06,yo+0.03,features.clusterfstrs{i},'MarkerSize',22,'color',features.colors(i,:));
            
            for j=1:features.nlabels
                if features.clusterlabels(i)==j
                    text(labelpos(2,j)+xo+1.03,labelpos(1,j)+yo+.15,features.labelcategories{j},'color',[0 0 0],'BackgroundColor',[.7 .9 .7]);
                else
                    text(labelpos(2,j)+xo+1.03,labelpos(1,j)+yo+.15,features.labelcategories{j},'color',[0 0 0]);
                end;
                
                %just click on nearest, not pretty but easy
                lx(j)=labelpos(2,j)+xo+1.06;
                ly(j)=labelpos(1,j)+yo+.15;
                
            end;
            c=features.colors(i,:);
            plot( [1 1]+xo , [0 psize]+yo,'k','color',c);
            plot( [1+psize 1+psize]+xo , [0 psize]+yo,'k','color',c);
            plot( [1 1+psize]+xo , [0 0]+yo,'k','color',c);
            plot( [1 1+psize]+xo , [psize psize]+yo,'k','color',c);
            
            if i==1
                text(xo+1.1 ,yo+0.02,['N: ',num2str(sum(features.clusters==i)),' (MUA/null cluster)'],'color',[0 0 0]);
            else
                text(xo+1.1 ,yo+0.02,['N: ',num2str(sum(features.clusters==i)),' ',features.labelcategories{features.clusterlabels(i)}],'color',[0 0 0]);
            end;
            
            text(labelpos(2,1)+xo+1.03,labelpos(1,1)+yo+.15,'none','color',[.4 .4 .4]);
            
            [ix iy ib]=ginput(1);
            
            d=(ix-lx).^2 +(iy-ly).^2;
            [~,m]=min(d);
            features.clusterlabels(i)=m;
            
            
        else % click on actual waveform
            npoints=numel(mua.ts_spike);
            %xa=  (linspace(0,psize,npoints));
            samples=[-2:2]+((x-(1+xo))/psize)*npoints;
            samples=max(min(round(samples),npoints),1);
            
            % calculate new feature from avg value at that sample
            
            %features.numextrafeaatures=features.numextrafeaatures+1;
            
            features.data(end+1,:)=  mean(mua.waveforms(:,samples)')';
            
            features.name{size(features.data,1)}=['amp@',num2str(round(((x-(1+xo))/psize)*npoints))];
            
            features=sc_scale_features(features);
            
        end;
    end;
    
    
end;