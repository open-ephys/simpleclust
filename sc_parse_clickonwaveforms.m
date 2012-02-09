function features= parse_clickonwaveforms(x,y,features,mua)


psize=0.65;
%plot(mua.ts_spike+1.5,mua.waveforms./1000);

xpos=[0 0 0 1 1 1 2 2 2];
ypos=[1 2 3 1 2 3 1 2 3];


for i=1:features.Nclusters
    xo=(xpos(i)*(psize+.01))+.05;
    yo=-(ypos(i)*(psize+.01))+1;
    
    
    if (x> 1+xo) && (x<1+xo+psize) && (y>yo) && (y<psize+yo) % find waveform display that click is in
        
        %  plot( [1 1.1]+xo , [psize-0.1 psize]+yo,'k');
        %disp(((x-xo)-(y-yo)));
        if ((x-xo)-(y-yo))<0.5
            %disp('lala');
            if features.clusterlabels(i) >= features.nlabels
                features.clusterlabels(i)=1;
            else
                features.clusterlabels(i)=features.clusterlabels(i)+1;
            end;
            
            
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