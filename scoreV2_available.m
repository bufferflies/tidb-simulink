%  available: disk used size 
%  hma_available: notional used size is filterred by hma  
%  delta: tolerate size 
%  deviation: the deviation value 
function  y = scoreV2_available(available,hma_available,deviation,lows_space_ratio,amp,capacity,delta)
k=1;
m=256;
b=1e7;
f=50; 
if f<capacity*(1-lows_space_ratio)
    f=capacity*(1-lows_space_ratio);
end

r=(capacity-available)*amp*1024+delta;
used=capacity-hma_available;
if delta~=0
    used=used+used*delta/r;
    if used<capacity&&used>0
        hma_available=capacity-used;
    end
end
hma_available=hma_available-deviation-delta/(amp*1024);
if hma_available>f
    b=hma_available-f+1;
    y=(k*r+m*(log(capacity)-log(b))/(capacity-b)*r);
else
    y=(k+m*log(capacity)/capacity)*r+b*(f-hma_available)/f;
end


