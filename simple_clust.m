%
%   Simple Clust v0.4
%
%   alpha version, not for redistribution
%   email me if there's any issues or features you'd like to see added
%
%
%   apr 2012, Jakob Voigts (jvoigts@mit.edu)


%{
features 2do:

X - fix ISI display
X- loading of simpleclust state with clusters etc intact
X- 'remove features' button (small x) on left
X - add ++ button that puts spikes into cluster from any other cluster even if prev. asigned
X- ISI display
X- xcorr feature
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
X - ma keeoverlap faster by doing histogram method by default
X - do overlap as percent of channels
X - improve label selection
X - fix spike.waveform_ts lenght in tetrodes (is sized for st)
X - dsplay ch in overlap selection
X - add progress bar for initial waveform supersampling,
X - try to improve waveform supersampling speed (do linear?)
X - do . display by default, not x, increase default displynum to 30000
- add batch process functions, sorte work in progress
- figure out saving as ch_simpleclust with no channel nnr bug
- add warning if ch is not just a number
X- add isi feature
X - make add function take spikes only from visible clusters
 - allow to change color
 - save selected color for plotting in later analysis?
 - add template matching to selected cluster?

%}

run=1;
dataloaded=0;

global debugstate;
debugstate = 0; % 0: do nothing, 1: go trough following states
debuginput = [0 0 0];

%addpath(pwd);
%addpath(fullfile(pwd,'read_cheetah'));

s_opt=[];

s_opt.batch=0;

s_opt.auto_overlap = 1; % automatically loads other channels from same recording and computes spike overlap
s_opt.auto_overlap_max = 6; %if >0, limits how many other channels are loaded

s_opt.auto_noise = 1; % automatically assign channels with high overlap into noise cluster
s_opt.auto_noise_trs = .5; %proportion of channels a spike must co-occur in within .2ms in order to be classified noise

s_opt.auto_number =1; % if set to 1, simpleclust will assume that there is ONLY ONE number in the MUA filenames and use is to designate the source channel for the resulting data


if numel(strfind(path,'read_cheetah')) ==0
    error('make sure the read_cheetah dir is in your matlab path');
end;

%% main loop

while run
    figure(1); clf;hold on; grid off;
    
    
    
    
    fill([-2 -2 5 5],[-2 2 2 -2],'k','FaceColor',[.92 .92 .92]);
    
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
        
        
        fill([-1.2 -1 -1 -1.2],[1 1 1.2 1.2]-0.2,'b','FaceColor',[.9 .9 .9]);
        
        text(-1.18,1.05-0.2,'batch run');
        plot([-1.2 -1],[1.1 1.1]-0.2,'color',[0 0 0]);
        text(-1.18,1.15-0.2,'batch prep');
        
        plot([-1.2 -1],[1 1],'color',[.0 .0 .0]);
        
        
        
    end;
    
    fill([-1.2 -1 -1 -1.2],[1 1 1.2 1.2],'b','FaceColor',[.9 .9 .9]);
    
    text(-1.18,1.05,'save/exit');
    plot([-1.2 -1],[1.1 1.1],'color',[0 0 0]);
    if s_opt.batch
        text(-1.18,1.17,'next file');
        text(-1.18,1.13,[num2str(multi_N),'/',num2str(numel(multifiles))]);
        
        
    else
        text(-1.18,1.15,'open');
    end;
    
    plot([-1.2 -1],[1 1],'color',[.7 .7 .7]);
    
    xlim([-1.3, 3.3]);     ylim([-1.3, 1.2]);
    daspect([1 1 1]);set(gca,'XTick',[]); set(gca,'YTick',[]);
    
    
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
    
    
    
    
    [x,y,b] = sc_ginput(1);
    
    
    if (x<-1)&& (y>0.9) && (y<1) % batch (pre)process
        
        [FileName,PathName,FilterIndex] = uigetfile({'*.nse;*.nst;*.ntt;','all base electrode file types';'*.mat', 'matlab file';'*.nse' ,'neuralynx single electrode file'; '*.nst',  'neuralynx stereotrode file'; '*.ntt',  'neuralynx tetrode file'},['choose files to preprocess'],'MultiSelect','on');
        
        
        for b=1:numel(FileName)
            
            features.muafile =[PathName,FileName{b}];
            
            fprintf('processing file %d of %d \n',b,numel(FileName));
            
            sc_load_mua_dialog;
            sc_save_dialog;
            
        end;
        
        dataloaded=0;
        
    end;
    
    if (x<-1)&& (y>0.8) && (y<0.9) % batch run - open folder of simpleclust files and loop trough sorting them one at a time
        
        
        [multifiles,PathName,FilterIndex] = uigetfile({'*_simpleclust.mat', 'simpleclust file';'*.nse;*.nst;*.ntt;','all base electrode file types';'*.mat', 'matlab file';'*.nse' ,'neuralynx single electrode file'; '*.nst',  'neuralynx stereotrode file'; '*.ntt',  'neuralynx tetrode file'},['choose files to cluster'],'MultiSelect','on');
        
        s_opt.batch=1; % indicate we're doing a batch
        multi_N=1; % cycle trough many files
        
        
        features.muafile =[PathName,multifiles{multi_N}];
        sc_load_mua_dialog;
        
        
    end;
    
    
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
            
            if s_opt.batch % open next file in batch
                if dataloaded
                    button = questdlg('Save and open next file?','open?','Yes','No','Yes');
                else
                    button='Yes';
                end;
                
                sc_save_dialog;
                
                multi_N=multi_N+1;
                
                
                features.muafile =[PathName,multifiles{multi_N}];
                sc_load_mua_dialog;
                
                
                
                
            else % open one file
                
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
                        [FileName,PathName,FilterIndex] = uigetfile({'*.nse;*.nst;*.ntt;','all base electrode file types';'*_simpleclust.mat', 'simpleclust file';'*.mat', 'matlab file';'*.nse' ,'neuralynx single electrode file'; '*.nst',  'neuralynx stereotrode file'; '*.ntt',  'neuralynx tetrode file'},'choose input file');
                        
                    end;
                    
                    features.muafile =[PathName,FileName];
                    % ask user for channel number this file comes from
                    % could parse filename here but the small time saving is
                    % not worth the loss of flexibility
                    %
                    
                    
                    
                    %   features.muafile='/home/jvoigts/Documents/moorelab/acute_test_may27_2011/data_2011-05-20_00-12-09_oddball/spikes_from_csc/mua_ch5.mat';
                    sc_load_mua_dialog;
                    
                else
                    run=0;
                    return;
                end;
            end;
            
            % exit/save
        else
            disp('save/exit');
            % ask for saving here
            if dataloaded
                button = questdlg('Save clusters?','save?','Save','Continue editing','Save');
                
                if strcmp(button,'Save')
                    
                    
                    sc_save_dialog;
                    
                    run=0;
                end;
            else
                clf; drawnow;
                run=0;
            end;
        end;
        
        
    end;
    
end; % while run