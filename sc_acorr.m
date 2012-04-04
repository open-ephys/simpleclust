function [l,c] =  sc_acorr(a,lag,N);




l=linspace(0,lag,N);

d=diff(a);
d(d==0)=[];

h=histc(d,l);

c=h./(sum(h)*N);