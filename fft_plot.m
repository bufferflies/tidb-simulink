% plot the picture of the input data 
function y = fft_plot(S,Fs)

% get S din
N=size(S,2);
Y=fft(S);
P2=abs(Y)/N;

% get half freq 
P1=P2(1:N/2+1);
P1(2:end-1)=2*P1(2:end-1);

% to 
f=Fs*(0:(N/2))/N;
bar(f,P1);
y=P1;
end

