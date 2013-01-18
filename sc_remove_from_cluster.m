function features=sc_remove_from_cluster(features,i,featureselects)


[px,py] =sc_getpolygon(features,features.colors(i,:));



if i>1
    inthiscluster=find(features.clusters==i);
else    % if we're removing the null cluster, do nothing obvs
    
    inthiscluster=[];
    
end;
dX=features.data(features.featureselects(1),inthiscluster);
dY=features.data(features.featureselects(2),inthiscluster);

in = inpolygon(dX,dY,px,py);

features.clusters_undo=features.clusters;
features.clusters(inthiscluster(in))=1;