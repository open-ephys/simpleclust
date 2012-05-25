function [l,c] =  sc_sxcorr(a,b,lag,N);

l=linspace(-lag,lag,N*2);
h=zeros(size(l));
%h_null=zeros(size(l));


for i=1:numel(a)
    h=h+histc(b-a(i),l);
end;
c=h./(sum(h)*N);