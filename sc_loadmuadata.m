function [features,mua]=sc_loadmuadata(muafile, dofeatures)



%load('/home/jvoigts/Documents/moorelab/acute_test_may27_2011/data_2011-05-19_23-52-54_10min_laser_100msisi_1-4sec delay/spikes_from_csc/mua_ch3.mat')

skipsetup=0;


switch muafile(end-2:end)
    case 'mat'
        load(muafile);
        
        if ~ exist('mua') % no mua var in there, try doreas format
            
            if exist('times_all') % marker for doreas mat format
                
                
                if dofeatures
                    prompt = {['source channel nr for file ',muafile]};
                    dlg_title = 'channel nr';
                    num_lines = 1;
                    def = {''};
                    features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
                    features.sourcechannel= str2num(features.chnumstr{1});
                    sourcechannel=features.sourcechannel; % just so we dont overwrite it in  'features=sc_mua2features(mua);'
                end;
                
                % load doreas format
                mua.opt=[];
                mua.fname=muafile;
                
                mua.Nspikes = numel(times_all);
                
                % concatenate all waveforms
                
                mua.ncontacts = size(waveforms,2);
                
                mua.waveforms = (reshape(waveforms,size(waveforms,1)*size(waveforms,2),size(waveforms,3) ))';
                
                mua.ts = times_all;
                
                mua.ts_spike=[1:size( mua.waveforms,2)];
                if dofeatures
                    features=sc_mua2features(mua);
                    features.sourcechannel=sourcechannel;
                end;
                
                
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
                
                if dofeatures
                    features=sc_mua2features(mua);
                    features.sourcechannel=sourcechannel;
                end;
            end;
            
            
        end;
        
    case 'nse'
        
        if dofeatures
            global debugstate
            if debugstate > 0
                features.chnumstr{1} = '3';
            else
                prompt = {['source channel nr for file ',muafile]};
                dlg_title = 'channel nr';
                num_lines = 1;
                def = {''};
                features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
            end;
            features.sourcechannel= str2num(features.chnumstr{1});
            sourcechannel=features.sourcechannel; % just so we dont overwrite it in  'features=sc_mua2features(mua);'
        end;
        
        cdata = read_cheetah_data(muafile);
        %mua = load_neuralynx_mua(muafile);
        
        clear mua;
        mua=[];
        mua.Nspikes = size(cdata.ts,1);
        mua.waveforms=cdata.waveforms;
        mua.ts=cdata.ts;
        
        %identify bits2volt in header
        vstart=strfind(cdata.header,'ADBitVolts');
        mua.val2volt=str2num(cdata.header(vstart+10:vstart+24));
        
        [pathstr, name, ext] = fileparts(muafile);
        mua.fname=[name,ext];
        
        
        mua.opt=[];
        mua.header=cdata.header;
        
        
        
        mua.ncontacts = size(mua.waveforms,1);
        
        % flatten waveforms for display
        
        D= (squeeze(reshape(mua.waveforms,1,32,size(mua.waveforms,3))));
        mua.waveforms=[D(1:end,:)]';
        mua.ts_spike=linspace(-.5,0.5,32);  %  neuralynx saves 32 samples at 30303Hz, so its a 1.056ms window
        
        if dofeatures
            features=sc_mua2features(mua);
            features.sourcechannel=sourcechannel;
        end;
        
    case 'nst'
        
        
        if dofeatures
            prompt = {['source channel nr for file ',muafile]};
            dlg_title = 'channel nr';
            num_lines = 1;
            def = {''};
            features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
            features.sourcechannel= str2num(features.chnumstr{1});
            sourcechannel=features.sourcechannel; % just so we dont overwrite it in  'features=sc_mua2features(mua);'
        end;
        
        cdata = read_cheetah_data(muafile);
        %mua = load_neuralynx_mua(muafile);
        
        clear mua;
        mua=[];
        mua.Nspikes = size(cdata.ts,1);
        mua.waveforms=cdata.waveforms;
        mua.ts=cdata.ts;
        
        [pathstr, name, ext] = fileparts(muafile);
        mua.fname=[name,ext];
        
        
        mua.opt=[];
        mua.header=cdata.header;
        
        %identify bits2volt in header
        vstart=strfind(cdata.header,'ADBitVolts');
        mua.val2volt=str2num(cdata.header(vstart+10:vstart+24));
        
        mua.ncontacts = size(mua.waveforms,1);
        
        % flatten waveforms for display
        
        D= (squeeze(reshape(mua.waveforms,1,64,size(mua.waveforms,3))));
        mua.waveforms=[D(1:2:end,:);D(2:2:end,:)]';
        mua.ts_spike=linspace(-.5,1.5,64); %  neuralynx saves 32 samples at 30303Hz, so its a 1.056ms window
        
        if dofeatures
            features=sc_mua2features(mua);
            features.sourcechannel=sourcechannel;
        end;
        
    case 'ntt'
        
        
        if dofeatures
            prompt = {['source channel nr for file ',muafile]};
            dlg_title = 'channel nr';
            num_lines = 1;
            def = {''};
            features.chnumstr = inputdlg(prompt,dlg_title,num_lines,def);
            features.sourcechannel= str2num(features.chnumstr{1});
            sourcechannel=features.sourcechannel; % just so we dont overwrite it in  'features=sc_mua2features(mua);'
        end;
        
        cdata = read_cheetah_data(muafile);
        %mua = load_neuralynx_mua(muafile);
        
        clear mua;
        mua=[];
        mua.Nspikes = size(cdata.ts,1);
        mua.waveforms=cdata.waveforms;
        mua.ts=cdata.ts;
        
        [pathstr, name, ext] = fileparts(muafile);
        mua.fname=[name,ext];
        
        
        mua.opt=[];
        mua.header=cdata.header;
        
        mua.ncontacts = size(mua.waveforms,1);
        
        
        %identify bits2volt in header
        vstart=strfind(cdata.header,'ADBitVolts');
        mua.val2volt=str2num(cdata.header(vstart+10:vstart+24));
        
        
        % flatten waveforms for display
        
        D= (squeeze(reshape(mua.waveforms,1,128,size(mua.waveforms,3))));
        mua.waveforms=[D(1:4:end,:);D(2:4:end,:);D(3:4:end,:);D(4:4:end,:)]';
 
        
        mua.ts_spike=linspace(-.5,3.5,128); %  neuralynx saves 32 samples at 30303Hz, so its a 1.056ms window
        
        
        if dofeatures
            features=sc_mua2features(mua);
            features.sourcechannel=sourcechannel;
        end;
        
    otherwise
        error('unrecognized file format');
end;


if ~dofeatures
    skipsetup=1;
    features=[]; % in this case just return the mua
end;


if ~skipsetup
    
    %% config and setup
    features.clusters=ones(size(features.id));
    features.clusters_undo=features.clusters;
    features.clustervisible=ones(1,12);
    
    
    %features.clusters(1:100)=2;
    features.labelcategories = {' ','noise','unit','big','wide','thin','small','unit_{fs}','unit_{rs}','negative'};
    
    features.clusterfstrs={'k.','b.','r.','g.','c.','r.','k.','r.','b.'};
    features.colors=[.7 .7 .7; 1 0 0; 0 1 0; 0 0 1; 1 .7 0; 1 .2 1; 0 1 1; 1 .5 0; .5 1 0; 1 0 .5];
    features.Nclusters=2;
    features.imagesize=100;
    
    features.waveformscale=0.0001;
    
    % find appropriate scale for plotting waveforms
    features.waveformscale=0.1 ./ quantile(mua.waveforms(:)-mean(mua.waveforms(:)),.95);
    
    features.range=zeros(size(features.data,1),2); % for x/y range display
    features.zoomrange=zeros(size(features.data,1),2); % where do we display right now
    
    
    
    features.numextrafeaatures=0;
    features.highlight = 0;
    features.clusterimages=ones(features.imagesize,features.imagesize,12);
    features.selected=0;
    features.plotsize=0;
    
    features.timeselectwidth=200;
    features.timeselection=0;
    
    features.Ndisplay=25000;
    
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