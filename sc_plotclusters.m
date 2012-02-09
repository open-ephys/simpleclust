function    plotclusters(features)


plot([-1 1],[-1 -1]+0.01,'color',[1 1 .7],'LineWidth',5);
plot([-1 -1]+0.01,[-1 1],'color',[.8 1 1],'LineWidth',5);


fill([-1 1 1 -1 ],[-1 -1 1 1] ,'b','FaceColor',[0 0 0]);

for i=1:features.Nclusters
    if features.clustervisible(i)
        incluster=find(features.clusters==i .*(features.randperm<features.Ndisplay) .* features.timevisible);
        if numel(incluster)>0
            sc_plotinbox(features.data(features.featureselects(1),incluster),features.data(features.featureselects(2),incluster),features.clusterfstrs{i},features.colors(i,:),features.plotsize);
        end;
        
        % plot cluster traces
        mx=[]; my=[];
        if features.timeselection
            nsteps=100;
            timebins=linspace(features.ts(1),features.ts(end),nsteps);
            for j=2:nsteps
                
                
                incluster_t=find((features.clusters==i  ).*(features.ts > timebins(j-1)).* (features.ts < timebins(j)));
                
                mx(j-1)=median(  features.data(features.featureselects(1),incluster_t)  );
                my(j-1)=median(  features.data(features.featureselects(2),incluster_t)  );
                
                
            end;
            
            f=normpdf([-4:4],0,2); f=f./sum(f);
            
            mx=conv(mx,f,'valid');
            my=conv(my,f,'valid');
            
            plot(mx,my,'r-','color',features.colors(i,:),'LineWidth',4);
            plot(mx,my,'r--','color',[1 1 1],'LineWidth',1);
            
            
        end;
    end;
    
end;

if features.highlight>0
    plot( features.data(features.featureselects(1),features.highlight),features.data(features.featureselects(2),features.highlight),'wo','MarkerSize',8);
    %plot( features.data(features.featureselects(1),features.highlight),features.data(features.featureselects(2),features.highlight),'ko','MarkerSize',9);
    
    
    if features.plotgroup
        plot( features.data(features.featureselects(1),features.highlight_multiple),features.data(features.featureselects(2),features.highlight_multiple),'wo','MarkerSize',6,'color',[.6 .6 .6]);
    end;
end;


