function features=add_to_cluster_from_any(features,i,featureselects)


[px,py] =sc_getpolygon(features,features.colors(i,:));




notassigned=find(features.clusters>0); % just select from all
   

dX=features.data(features.featureselects(1),notassigned);
dY=features.data(features.featureselects(2),notassigned);

in = inpolygon(dX,dY,px,py);

features.clusters_undo=features.clusters;
features.clusters(notassigned(in))=i;