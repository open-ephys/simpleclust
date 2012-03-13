function [features,mua]=sc_loadmuadata(muafile)



%load('/home/jvoigts/Documents/moorelab/acute_test_may27_2011/data_2011-05-19_23-52-54_10min_laser_100msisi_1-4sec delay/spikes_from_csc/mua_ch3.mat')
skipsetup=0;

switch muafile(end-2:end)
    case 'mat'
        load(muafile);
        
        if ~ exist('mua') % no mua var in there, try doreas format
            
            if exist('times_all') % marker for doreas mat format
                
                
                prompt = {['source channel nr for file ',muafile]};
                dlg_title = 'channel nr';
                num_lines = 1;
                def = {''};
                features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
                features.sourcechannel= str2num(features.chnumstr{1});
                
                % load doreas format
                mua.opt=[];
                mua.fname=muafile;
                
                mua.Nspikes = numel(times_all);
                
                % concatenate all waveforms
                
                mua.ncontacts = size(waveforms,2);
                
                mua.waveforms = (reshape(waveforms,size(waveforms,1)*size(waveforms,2),size(waveforms,3) ))';
                
                mua.ts = times_all;
                
                mua.ts_spike=[1:size( mua.waveforms,2)];
                
                features=sc_mua2features(mua);
                
                
                
            end;
            
        else % file has a variable mua in it, probably jakobs own format
            
            if  exist('features') %marker for simple_clust output format
                
                % we just loaded previous simple_clust data
                % in theory there should be nothing left to do here?
                skipsetup=1;
                
            else
                
                % parse jakobs ad hoc format here
                % for now we only deal with simple electrodes
                
                mua.ncontacts = 1;
                features=sc_mua2features(mua);
            end;
            
            
        end;
        
    case 'nse'
        
        
        prompt = {['source channel nr for file ',muafile]};
        dlg_title = 'channel nr';
        num_lines = 1;
        def = {''};
        features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
        features.sourcechannel= str2num(features.chnumstr{1});
        
        cdata = read_cheetah_data(muafile);
        %mua = load_neuralynx_mua(muafile);
        
        clear mua;
        mua=[];
        mua.Nspikes = size(cdata.ts,1);
        mua.waveforms=cdata.waveforms;
        mua.ts=cdata.ts;
        
        [pathstr, name, ext] = fileparts(muafile);
        mua.fname=[name,ext];
        
        mua.ts_spike=linspace(-.5,.5,32); %  neuralynx saves 32 samples at 30303Hz, so its a 1.056ms window
        
        mua.opt=[];
        mua.header=cdata.header;
        
        
        
        mua.ncontacts = size(mua.waveforms,1);
        
        % flatten waveforms for display
        
        D= (squeeze(reshape(mua.waveforms,1,32,size(mua.waveforms,3))));
        mua.waveforms=[D(1:end,:)]';
        mua.ts_spike=linspace(-.5,1.5,32);
        
        features=sc_mua2features(mua);
        
    case 'nst'
        
        
        prompt = {['source channel nr for file ',muafile]};
        dlg_title = 'channel nr';
        num_lines = 1;
        def = {''};
        features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
        features.sourcechannel= str2num(features.chnumstr{1});
        
        cdata = read_cheetah_data(muafile);
        %mua = load_neuralynx_mua(muafile);
        
        clear mua;
        mua=[];
        mua.Nspikes = size(cdata.ts,1);
        mua.waveforms=cdata.waveforms;
        mua.ts=cdata.ts;
        
        [pathstr, name, ext] = fileparts(muafile);
        mua.fname=[name,ext];
        
        mua.ts_spike=linspace(-.5,.5,32); %  neuralynx saves 32 samples at 30303Hz, so its a 1.056ms window
        
        mua.opt=[];
        mua.header=cdata.header;
        
        
        
        mua.ncontacts = size(mua.waveforms,1);
        
        % flatten waveforms for display
        
        D= (squeeze(reshape(mua.waveforms,1,64,size(mua.waveforms,3))));
        mua.waveforms=[D(1:2:end,:);D(2:2:end,:)]';
        mua.ts_spike=linspace(-.5,1.5,64);
        
        features=sc_mua2features(mua);
    case 'ntt'
        
        prompt = {['source channel nr for file ',muafile]};
        dlg_title = 'channel nr';
        num_lines = 1;
        def = {''};
        features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
        features.sourcechannel= str2num(features.chnumstr{1});
        
        
        cdata = read_cheetah_data(muafile);
        %mua = load_neuralynx_mua(muafile);
        
        clear mua;
        mua=[];
        mua.Nspikes = size(cdata.ts,1);
        mua.waveforms=cdata.waveforms;
        mua.ts=cdata.ts;
        
        [pathstr, name, ext] = fileparts(muafile);
        mua.fname=[name,ext];
        
        mua.ts_spike=linspace(-.5,.5,128); %  neuralynx saves 32 samples at 30303Hz, so its a 1.056ms window
        
        mua.opt=[];
        mua.header=cdata.header;
        
        mua.ncontacts = size(mua.waveforms,1);
        
        
        % flatten waveforms for display
        
        D= (squeeze(reshape(mua.waveforms,1,128,size(mua.waveforms,3))));
        mua.waveforms=[D(1:4:end,:);D(2:4:end,:);D(3:4:end,:);D(4:4:end,:)]';
        mua.ts_spike=linspace(-.5,1.5,64);
        
        features=sc_mua2features(mua);
    otherwise
        error('unrecognized file format');
end;


if ~skipsetup
    
    %% config and setup
    features.clusters=ones(size(features.id));
    features.clusters_undo=features.clusters;
    features.clustervisible=ones(1,12);
    
    
    %features.clusters(1:100)=2;
    features.labelcategories = {' ','noise','negative','unit','big','wide','thin'};
    
    features.clusterfstrs={'k.','b.','r.','g.','c.','r.','k.','r.','b.'};
    features.colors=[.7 .7 .7; 1 0 0; 0 1 0; 0 0 1; 1 .7 0; 1 .2 1; 0 1 1; 1 .5 0; .5 1 0; 1 0 .5];
    features.Nclusters=2;
    features.imagesize=100;
    features.waveformscale=0.0001;
    features.numextrafeaatures=0;
    features.highlight = 0;
    features.clusterimages=ones(features.imagesize,features.imagesize,12);
    features.selected=0;
    features.plotsize=1;
    
    features.timeselectwidth=200;
    features.timeselection=0;
    
    features.Ndisplay=15000;
    
    for i=1:1
        features.isioptions(1).tmax=10;
        features.isioptions(1).nbins=50;
    end;
    
    features.plotgroup=1;
    
    features.highlight_multiple(1:10)=1;
    features.clusterlabels(1:10)=1;
    features.nlabels=numel(features.labelcategories );
    
    % preprocess features to fit 1 1 -1 -1 box
    features=sc_scale_features(features);
    
    features=sc_addnoisetoquantiledfeatures(features);
    % laod icons
    %features.eye_icon_o=imread('eye.png');
    %features.eye_icon_x=imread('eye_closed.png');
    
    
    
    features.timevisible=ones(1,numel(features.ts));
    features.randperm = randperm(numel(features.ts));
    
    
    features.featureselects=[3 4];
    
    features=sc_updateclusterimages(features,mua);
end;

run=1;