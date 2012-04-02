function  [px,py] =getpolygon(features,plotcolor);



px=[];
py=[];

[x,y,b] = ginput(1);

px(end+1)=x;
py(end+1)=y;

while b~=3
    
    [x,y,b] = ginput(1);
    plot( [px(end),x],[py(end),y] ,'color',plotcolor);
    
    px(end+1)=x;
    py(end+1)=y;
end;


% remap from screen space to feature space


px=sc_remap(px,-.9, .9, features.zoomrange(features.featureselects(1),1),features.zoomrange(features.featureselects(1),2) );
py=sc_remap(py,-.9, .9, features.zoomrange(features.featureselects(2),1),features.zoomrange(features.featureselects(2),2) );