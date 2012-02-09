function features=sc_scale_features(features);


use=zeros(1,numel(features.ts));


for i=1:features.Nclusters
    if features.clustervisible(i)
        incluster=find(features.clusters==i );
        use(incluster)=1;
    end;
end;

margin=0.1;
for i=1:size(features.data,1)
    x=features.data(i,:);
    x=x-min(x(find(use))); x=x./max(x(find(use))); x=x*(2-margin*2); x=x-(1-margin);
    features.data(i,:)=x;
end;
