clear all;
close all;
prompt = 'Select only the *.csv folder to be inputed';
[file,path] = uigetfile('*.csv');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end
selectedfile = fullfile(path,file);
y = readtable(selectedfile);
y = rmmissing(y,2,'MinNumMissing',10);
y = rmmissing(y,1,'MinNumMissing',6);
y_temp= fillmissing (table2array(y),'pchip',1);
y_main = array2table(y_temp);
rows = size(y_main,1);
columns = size(y_main,2);
feat = [];
figure;
for i=1:20
    subplot(4,5,i)
        plot(flip(y_main{i,:}));
end
figure;
for i=1:20
    subplot(4,5,i)
    i=i+20;
        plot(flip(y_main{i,:}));
        i = i-20;
end
figure;
for i=1:20
    subplot(4,5,i)
    i=i+40;
        plot(flip(y_main{i,:}));
        i=i-40;
end
figure;
for i=1:20
    subplot(4,5,i)
    i=i+60;
        plot(flip(y_main{i,:}));
        i=i-60;
end
%%%%%%%%%%%%%%%%_____FFT______%%%%%%%%%%%%%%%%%%%%%
for i = 1:rows
xfft = fft(y_main{i,:});
n=length('enter the length of fft');
DT = 3000;
% sampling frequency
Fs = 1/DT;
DF = Fs/31;
freq = 0:DF:Fs/2;
xdft = xfft(1:length(xfft)/2+1);
[pks,locs] = findpeaks(abs(xdft),'npeaks',3);
for k = length(pks)+1:3
    pks(k) = 0;
    locs(k) = 0;
end
feat (i,:) = [pks];
ylim([0 500])
end
xlabel ('Frequency');
ylabel ('Amplitued of Glucose levels');

%%%%%%%%%%%%%%%%_____AverageCGM(Pre and Post Lunch)______%%%%%%%%%%%%%%%%%%%%%

y_c = flip(y_main,2); 
rows = size(y_c,1);
columns = size(y_c,2);
m = [];
m = table2array(y_c);

k=size(feat,2);
for i=1:size(m,1)
    j=1;
    while j <= 24
        if(j<6)
          feat(i,k+1) = (m(i,j)+m(i,j+1)+m(i,j+2)+m(i,j+3)+m(i,j+4)+m(i,j+5))/6;
          j = j+6;
        end
          if(j>6)
              if(j<=24)
                    temp = sum(m(i,j:30));
                    temp = temp/24;
                    feat(i,k+2) = temp;
%                     feat(i,k+3) = feat(i,k+2)-feat(i,k+1);
                    j=30;
              end
          end
    end
end
feat = feat(:,any(feat));

%%%%%%%%%%%%%%%%_______ROOTMEAN________%%%%%%%%%%%%%%%%%%%%%

%RMS average glucose for one person's one meal is calculated
y_c = flip(y_main,2);
rows = size(y_c,1);
columns = size(y_c,2);
v1 = [];
for i = 1:rows
    y_c{i,:}= y_c{i,:}.^2;
    temp = sum(y_c{i,:});
    v1(i,:) = sqrt(temp/columns);
end 
feat = horzcat(feat,v1);

%%%%%%%%%%%%%%%%_____Max_CGM_Velocity______%%%%%%%%%%%%%%%%%%%%%

y_cgm = flip(y_main,2);
rows = size(y_cgm,1);
columns = size(y_cgm,2);
v = [];
% CGM Velcoity for a window of 30mins
for i = 1:rows
    for j=1:columns-6
      v(i,j)= (y_cgm{i,j+5}-y_cgm{i,j})/30; 
    end
end
v = v(:,any(v));
%Average CGM
k=size(feat,2);
for i=1:size(v,1)
    j=1;
    sumdummy = 0;
    max = 0;
    while j <= 19
          sumdummy = (v(i,j)+v(i,j+1)+v(i,j+2)+v(i,j+3)+v(i,j+4)+v(i,j+5))/6;
          if(max>sumdummy)
              feat(i,k+1) = max;
          else
              max = sumdummy;
              feat(i,k+1) = sumdummy;
          end
          j = j+6;
    end
end
feat = feat(:,any(feat));

%%%%%%%%%%%%%%%%_______POLYFIT________%%%%%%%%%%%%%%%%%%%%%

y_cgm = flip(y_main,2);
rows = size(y_cgm,1);
columns = size(y_cgm,2);
v = [];
for i = 1:rows
    y = y_cgm{i,:};
    x = 1:columns;
    poco = polyfit(x,y,2);
    v(i,:) = polyval(poco,x);
end 
feat = horzcat(feat,v);
feat_t = bsxfun(@rdivide,feat,std(feat));

temp_feat=[];
co_eff = table2array(readtable('coeff.csv'));
temp_feat = feat_t*co_eff;
temp_feat = temp_feat(:,1:5);
hold on;
% %Scatter Plot of PCAs
scatter(temp_feat(:,1),temp_feat(:,3),'filled');
scatter(temp_feat(:,1),temp_feat(:,4),'filled');
scatter(temp_feat(:,1),temp_feat(:,4),'filled');
scatter(temp_feat(:,1),temp_feat(:,5),'filled');
title('PCA components 2, 3, 4, 5 plotted against PCA component 1');
xlabel('PCA Component 1');
colormap(jet);
colorbar;

ypredicted = mypredict(temp_feat);
