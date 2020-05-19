y0= readtable('CGMSeriesLunchPat1.csv');
y1= readtable('CGMSeriesLunchPat2.csv');
y2= readtable('CGMSeriesLunchPat3.csv');
y3= readtable('CGMSeriesLunchPat4_1.csv');
y4= readtable('CGMSeriesLunchPat5.csv');
y = [];
y = vertcat(y0,y1,y2,y3,y4);
y = rmmissing(y,2,'MinNumMissing',50);
y = rmmissing(y,1,'MinNumMissing',4);
y_temp= fillmissing (table2array(y),'pchip',1);
y_main = array2table(y_temp);
rows = size(y_main,1);
columns = size(y_main,2);
feat = [];
for i = 1:rows
xfft = fft(y_main{i,:});
n=length('enter the length of fft');
DT = 3000;
% sampling frequency
Fs = 1/DT;
DF = Fs/31;
freq = 0:DF:Fs/2;
xdft = xfft(1:length(xfft)/2+1);
subplot(rows,columns,i);
[pks,locs] = findpeaks(abs(xdft),'npeaks',5);
for k = length(pks)+1:5
    pks(k) = 0;
    locs(k) = 0;
end
feat (i,:) = [pks];
%plot(freq,abs(xdft));
ylim([0 500])
end
xlabel ('Frequency');
ylabel ('Amplitued of Glucose levels');