function [nums,dens]=hma(n)
a=2/(n*(n+1));
dens=[1,zeros(1,n-1)];
nums=zeros(1,n);
for i=1:n
    nums(i)=n-i+1;
end
nums=nums*a;

    