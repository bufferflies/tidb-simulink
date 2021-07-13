% cal operator rank
%
function rank = calcProgressiveRank(srcLd,dstLd,peer)
great_dec_ratio=0.95;
minor_dec_ratio=0.99;

[keyHot,keyDecRatio]=checkHot(srcLd,dstLd,1,peer);
[byteHot,byteDecRatio]=checkHot(srcLd,dstLd,2,peer);

if byteHot&&byteDecRatio<=great_dec_ratio&&keyHot&&keyDecRatio<=great_dec_ratio
    rank=-3;
    return;
end
if byteHot<=minor_dec_ratio&&keyHot&&keyDecRatio<=great_dec_ratio
    rank=-2;
    return;
end
if byteHot&&byteDecRatio<=great_dec_ratio
    rank=-1;
    return
end
rank=0;
end

function [isHot,decRatio]=checkHot(srcLd,dstLd,dim,peer)
min_hot_byte_rate=100;
min_hot_key_rate=10;

srcRate=srcLd(dim,1);
dstRate=dstLd(dim,1);
peerRate=peer(dim);

%  target < src
decRatio=(dstRate+peerRate)/getSrcDecRate(srcRate,peerRate);

if dim==1
    isHot=peerRate>min_hot_byte_rate;
end
if dim==2
    isHot=peerRate>min_hot_key_rate;
end
end


function out=getSrcDecRate(a,b)
if a-b<=0
    out=1;
else
    out=a-b;
end

end
