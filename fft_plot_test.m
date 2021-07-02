%  采样频率为1K 持续1.5s
% Fs=1000;
% T=1/Fs;
% ts=1.5;
% % 测试函数
% t=(0:T:ts);
% w1=50;
% w2=120;
% w4=400;
% S=0.7*sin(2*pi*w1*t)+sin(2*pi*w2*t)+2*sin(2*pi*w4*t);
% fft_plot(S,Fs)
Fs=1e2;
S=simData.signals(1).values;
fft_plot(transpose(S),Fs);

% S=simData.signals(1).values;
% fft_plot(transpose(S),Fs);
