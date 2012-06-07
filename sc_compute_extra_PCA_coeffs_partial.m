function features=sc_compute_extra_PCA_coeffs_partial(features,mua,from,to)


a=min([from,to]);
b=max([from,to]);

features.numextrafeaatures=features.numextrafeaatures+1;


visible = find(ismember(features.clusters, find(features.clustervisible)));


if a==b
    coeffs= mua.waveforms(visible,a); % if the user just wants one point, use that amplitude
    
D=zeros(1,size(features.data,2));
    D(:,visible)=coeffs';
    for i=1
        features.name{size(features.data,1)+i}=['amp@',num2str(a)];
    end;
    features.data(end+1,:)=D;
    
else
    [coeffs,score]= princomp(mua.waveforms(visible,a:b)','econ');
    
    if size(coeffs,2)>4 % cut to 4
        coeffs=coeffs(:,1:4);
    end;
    
    D=zeros(size(coeffs,2),size(features.data,2));
    D(:,visible)=coeffs';
    
    
    for i=1:size(coeffs,2)
        features.name{size(features.data,1)+i}=['pca@',num2str(a),'-',num2str(b)];
    end;
    features.data(end+1:end+size(coeffs,2),:)=D;
    
end;



features=sc_scale_features(features);