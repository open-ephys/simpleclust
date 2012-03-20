function  [px,py] =getpolygon(plotcolor);

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
