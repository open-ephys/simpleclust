%
%   Simple Clust v0.4
%
%   alpha version, not for redistribution
%   email me if there's any issues or features you'd like to see added
%
%
%   Feb 2012, Jakob Voigts (jvoigts@mit.edu)


%{
features 2do:

- fix ISI display
X- loading of simpleclust state with clusters etc intact
X- 'remove features' button (small x) on left
X - add ++ button that puts spikes into cluster from any other cluster even if prev. asigned
X- ISI display
- xcorr feature
X- display multiple waveforms around where user clicke, like 10ish
X- allow rescaling of all visible clusters, pretty much works as zoom
X- time selection at bottom? or just add time feature?
- add merge clusters function
X- add better features for loading stereotrode and tetrode data
X- undo function for the cluster operations
X- make peaks/energy etc work with TTL/ST files
X- make selection polygon same color as the cluster
X - automatically scale waveforms when loading (scaling by 95 quantile of all waveforms)
X - proper zoom function
X - detection of spike overlaps over many channels

%}

run=1;
dataloaded=0;

global debugstate;
debugstate = 0; % 0: do nothing, 1: go trough following states
debuginput = [0 0 0];

%addpath(pwd);
%addpath(fullfile(pwd,'read_cheetah'));

if numel(strfind(path,'read_cheetah')) ==0
    error('make sure the read_cheetah dir is in your matlab path');
end;

%% main loop

while run
    figure(1); clf;hold on; grid off;
    
    
    
    
    fill([-2 -2 5 5],[-2 2 2 -2],'k','FaceColor',[.93 .93 .93]);
    
    set(gca, 'position', [0 0 1 1]);
    
    title('simple clust v0.4');
    
    if ~dataloaded
        
        x=linspace(0,2*pi,80);

        for i=2:12
        plot(sin(x).*i.*.3,cos(x).*i.*.3,'k','LineWidth',28,'color',[.9 .9 .9])
        end;
             plot(sin(x).*1.*.3,cos(x).*1.*.3,'k','LineWidth',28,'color',[1 1 1])
             
        text(0,0,'Simple Clust v0.4')
        xlim([-1.3, 3.3]);     ylim([-1.3, 1.2]);
        daspect([1 1 1]);set(gca,'XTick',[]); set(gca,'YTick',[]);
        
        
    end;
    
    if dataloaded
        
        features=sc_plotclusters(features);
        
        sc_plotfeatureselection(features);
        
        sc_plotclusterselection(features);
        
        sc_plotallclusters(features,mua);
        
        sc_extramenu(features);
        
        sc_timeline(features,mua,x,y,b);
        
        if features.selected>0
            sc_plot_cluster_info(features,features.selected);
        end;
        
        features.highlight = 0; % remove highlight on each click
    end;
    fill([-1.2 -1 -1 -1.2],[1 1 1.2 1.2],'b','FaceColor',[.9 .9 .9]);
    
    text(-1.18,1.05,'save/exit');
    plot([-1.2 -1],[1.1 1.1],'color',[0 0 0]);
    text(-1.18,1.15,'open');
    
    plot([-1.2 -1],[1 1],'color',[.7 .7 .7]);
    
    xlim([-1.3, 3.3]);     ylim([-1.3, 1.2]);
    daspect([1 1 1]);set(gca,'XTick',[]); set(gca,'YTick',[]);
    
    
    
    [x,y,b] = sc_ginput(1);
    
    %   debuginput(end+1,1:3)=[x y b]; % for recording debug input sequence
    %disp(b);
    
    
    if dataloaded
        features=sc_parse_feature_selection(x,y,features);
        
        features=sc_parse_custerselection(features,x,y,mua);
        
        features=sc_parse_clickonwaveforms(x,y,features,mua);
        
        features=sc_parse_zoom(b,x,y,features);
        
        features=sc_timeline(features,mua,x,y,b);
        
        if y<-1 && y>-1.1
            features=  sc_extramenu(features,mua,x,y);
        end;
        
        if (b==3) && (abs(x)<1) && (abs(y)<1)
            features=sc_parse_highlight_wave(x,y,features);
        end;
    end;
    
    if (x<-1)&& (y>1)
        
        if y > 1.1
            disp('open');
            if dataloaded
                button = questdlg('Open new MUA dataset?','open?','Yes','No','Yes');
            else
                button='Yes';
            end;
            if strcmp(button,'Yes')
                
                % load MUa data
                global debugstate
                if debugstate > 0
                    
                    PathName = '/home/jvoigts/Dropbox/em003/good/';
                    FileName =  'ST11.nse';
                else
                    [FileName,PathName,FilterIndex] = uigetfile({'*.mat', 'matlab file';'*.nse',  'neuralynx single electrode file'; '*.nst',  'neuralynx stereotrode file'; '*.ntt',  'neuralynx tetrode file'},'choose input file');
                    
                end;
                
                features.muafile =[PathName,FileName];
                % ask user for channel number this file comes from
                % could parse filename here but the small time saving is
                % not worth the loss of flexibility
                %
                
                
                
                %   features.muafile='/home/jvoigts/Documents/moorelab/acute_test_may27_2011/data_2011-05-20_00-12-09_oddball/spikes_from_csc/mua_ch5.mat';
                [features,mua]=sc_loadmuadata(features.muafile,1);
                
                
                
                features.muafilepath =[PathName];
                features.muafile =[PathName,FileName];
                % cd(PathName); % for faster selection of later input files
                features.muafile_justfile =FileName;
                
                % ask to load other files
                % this can be used to make a feature that counts how many
                % channels a spike occurs in simultaneously
                if debugstate >0
                    button='no';
                else
                    
                    button = questdlg('Open other channnels from same recording?','open?','Yes','No','Yes');
                end;
                
                if strcmp(button,'Yes')
                    features.loadmultiple=1;
                    [FileName,PathName,FilterIndex] = uigetfile({'*.mat', 'matlab file';'*.nse',  'neuralynx single electrode file'; '*.nst',  'neuralynx stereotrode file'; '*.ntt',  'neuralynx tetrode file'},'choose files for other channels','MultiSelect','on');
                    features.otherchannelfiles=FileName;
                    
                    [features,mua]=sc_addotherchannelstomua(features,mua);
                    
                else
                    features.loadmultiple=0;
                end;
                
                
                
                dataloaded=1;
                
            else
                run=0;
                return;
            end;
            
        else
            disp('save/exit');
            % ask for saving here
            if dataloaded
                button = questdlg('Save clusters?','save?','Save','Continue editing','Save');
                
                if strcmp(button,'Save')
                    
                    
                    % save result to simplified spikes objects
                    spikes=[];
                    %  if numel(mua.opt.projectpath)>0
                    %  spikes.projectpath=mua.opt.projectpath;
                    %  end;
                    spikes.sourcefile = features.muafile;
                    spikes.ts=features.ts;
                    spikes.cluster_is=features.clusters;
                    spikes.labelcategories=features.labelcategories;
                    spikes.clusterlabels=features.clusterlabels;
                    spikes.sourcechannel=features.sourcechannel;
                    
                    spikes.Nspikes=mua.Nspikes;
                    
                    spikes.waveforms=mua.waveforms;
                    spikes.waveforms_ts=mua.ts_spike;
                    
                    %outfilename=[spikes.sourcefile(1:end-4),'_clustered.mat'];
                    outfilename=[features.muafilepath,'ch',num2str(spikes.sourcechannel),'_clustered.mat'];
                    save(outfilename,'spikes');
                    
                    % save simpleclust state so we can just load it again
                    % if needed
                    outfilename_sc=[features.muafilepath,'ch',num2str(spikes.sourcechannel),'_simpleclust.mat'];
                    save(outfilename_sc,'features','mua');
                    
                    disp(['saved to ',outfilename,' output for using in science']);
                    disp(['saved to ',outfilename_sc,' can be loaded with simpleclust']);
                    
                    run=0;
                end;
            else
                clf; drawnow;
                run=0;
            end;
        end;
        
    end;
    
end; % while run