function varargout=extramenu(features,mua,x,y)

pos=[-1  -.8 -.6 -.5 -.4 -.3 -.2 0.0 0.1 0.4 0.5 0.8 1 1.2 1.4];

if nargout==0 % plot
    
    i=1;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,'+wavelet');
    
    
    i=2;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,'+PCA');
    
    
    
    
    
    i=3;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,'wf+');
    
    i=4;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,'wf-');
    
    i=5;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,'isi+');
    
    i=6;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,'isi-');
    
    i=7;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    if features.plotgroup
        plot([0 0.2]+pos(i)+0,[1 1].*-1.05,'color',[.7 .7 .7],'LineWidth',20);
    end;
    text(pos(i)+0.02,-1.05,'plotgroup?');
    
    i=8;
    
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,'.x');
    
    i=9;
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,['Ndisp ',num2str(features.Ndisplay),'(+)']);
    
    i=10;
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,['(-)']);
    
    
    i=11;
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,['new label']);
    
    i=12; % rescaling!
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,['rescale']);
    %sc_scale_features
    
    i=13; % undo
    plot([1 1].*pos(i) ,[-1.1 -1],'color',[.7 .7 .7]);
    plot([1 1].*pos(i+1) ,[-1.1 -1],'color',[.7 .7 .7]);
    
    text(pos(i)+0.02,-1.05,['undo']);
    % features.clusters=features.clusters_undo;
    
else % evaluate x,y
    
    i=1;
    if (x>pos(i)) && (x<pos(i+1))
        
        text(-.5,0,'computing additional wavelet features for visible spikes... ', 'BackgroundColor',[.7 .9 .7]);
        drawnow;
        
        features=sc_compute_extra_wavelet_coeffs(features,mua);
        
    end;
    
    
    i=2;
    if (x>pos(i)) && (x<pos(i+1))
        
        text(-.5,0,'computing additional PCA features for visible spikes... ', 'BackgroundColor',[.7 .9 .7]);
        drawnow;
        
        features=sc_compute_extra_PCA_coeffs(features,mua);
        
    end;
    
    
    i=3; % waveforms +
    if (x>pos(i)) && (x<pos(i+1))
        features.waveformscale=features.waveformscale+0.0001;
        features=sc_updateclusterimages(features,mua);
    end;
    
    i=4; % waveforms -
    if (x>pos(i)) && (x<pos(i+1))
        features.waveformscale=features.waveformscale.*.9;
        features=sc_updateclusterimages(features,mua);
        
    end;
    
    if features.selected>0
        if  features.isioptions(1).tmax>15
            c=5;
        else
            c=1;
        end;
        
        i=5; % ISI +
        if (x>pos(i)) && (x<pos(i+1)) && (features.selected >0)
            features.isioptions(1).tmax=features.isioptions(1).tmax+c;
            
        end;
        
        i=6; % ISI -
        if (x>pos(i)) && (x<pos(i+1)) && (features.selected >0)
            
            
            features.isioptions(1).tmax=max(1,features.isioptions(1).tmax-c);
            
        end;
    end;
    
    i=7; % toggle plotgroup
    if (x>pos(i)) && (x<pos(i+1))
        
        features.plotgroup=1-features.plotgroup;
        disp('toggle');
        sc_plotallclusters(features,mua);
        
    end;
    
    i=8; % toggle point size
    if (x>pos(i)) && (x<pos(i+1))
        
        features.plotsize=1-features.plotsize;
        %disp('toggle');
    end;
    
    i=9; %Ndisplay++
    if (x>pos(i)) && (x<pos(i+1))
        features.Ndisplay=features.Ndisplay+5000;
    end;
    i=10; %Ndisplay--
    if (x>pos(i)) && (x<pos(i+1))
        if features.Ndisplay>5000
            features.Ndisplay=features.Ndisplay-5000;
        end;
    end;
    
    
    
    i=11; %  create new label
    if (x>pos(i)) && (x<pos(i+1))
        
        
        prompt = {'Enter new label:'};
        dlg_title = 'new cluster label';
        num_lines = 1;
        def = {''};
        newlabel = inputdlg(prompt,dlg_title,num_lines,def);
        
        if numel(newlabel)>0
            
            features.labelcategories{numel(   features.labelcategories)+1} = newlabel{1};
            features.nlabels=numel(   features.labelcategories);
            features.clusterlabels(features.nlabels)=1;
            
        end;
        %features.plotsize=1-features.plotsize;
        %disp('toggle');
    end;
    
    
    
    i=12; % rescaling
    
    if (x>pos(i)) && (x<pos(i+1))
        features=sc_scale_features(features);
    end;
    %
    
    i=13; % undo
    if (x>pos(i)) && (x<pos(i+1))
      features.clusters=features.clusters_undo;
    end;
    
    
    
    varargout={features};
    
    
end;
