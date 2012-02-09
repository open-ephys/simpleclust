function features = parse_feature_selection(x,y,features)

N=numel(features.name);
pos=[linspace(0.8,-1,N),-1.1];

if  (x<-1) && ( y<1) && (x>-1.2)
    
    
    for i=1:N
        
        % plot([-1.2 -1],([1 1].*pos(i))+0.03,'color',[.8 .8 .8]);
        
        if  (y<(pos(i)+0.03)) && (y>(pos(i+1)+0.03))  %abs(pos(i)-y)<0.03
            
            if x<-1.1
                features.featureselects(1)=i;
          %      disp(['set X to feature ',features.name{i}]);
            else
                features.featureselects(2)=i;
           %     disp(['set Y to feature ',features.name{i}]);
            end;
            
        end;
    end;
    
end;

if  (x<-1) && ( y<1) && (x<-1.2) % remove feature
    for i=1:N
        if  (y<(pos(i)+0.03)) && (y>(pos(i+1)+0.03))  %abs(pos(i)-y)<0.03
            
            button = questdlg(['Remove feature ',features.name{i}],'delete feature?','Yes','No','Yes');
            
            if strcmp(button,'Yes')
                % remove feature
                features.data(i,:)=[];
                tmp=features.name;
                features.name={};
                c=0;
                for j=1:N-1
                    c=c+1;
                    if j==i
                        c=c+1;
                    end;
                    features.name{j}=tmp{c};
                end;
                
                % also make sure no removed feature is still selected
                features.featureselects(features.featureselects==i)=1;
                
                if features.featureselects(1)>size(features.data,1)
                    features.featureselects(1)=size(features.data,1);
                end;
                if features.featureselects(2)>size(features.data,1)
                    features.featureselects(2)=size(features.data,1);
                end;
            end;
        end;
    end;
end;