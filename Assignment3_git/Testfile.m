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
y = rmmissing(y,1,'MinNumMissing',5);
y= fillmissing (table2array(y),'pchip',1);
y_main = array2table(y);
rows = size(y_main,1);
columns = size(y_main,2);

%%%%%%%%%%%%%%%%_____AverageCGM(Pre and Post Lunch)______%%%%%%%%%%%%%%%%%%%%%

y_c = flip(table2array(y_main),2); 
for i=1:size(y_c,1)
    feat_test(i,1) = mean(y_c(i,7:columns))-mean(y_c(i,1:6));
    feat_test(i,2) = mean(y_c(i,7:columns));
    feat_test(i,3) = mean(y_c(i,1:6));  
end
dbfeat_test = feat_test;

%%%%%%%%%%%%%%%%_______ROOTMEAN________%%%%%%%%%%%%%%%%%%%%%

%RMS average glucose for one person's one meal is calculated
y_c = flip(y_main,2);
v1 = [];
for i = 1:size(y_c,1)
    y_c{i,:}= y_c{i,:}.^2;
    temp = sum(y_c{i,:});
    v1(i,:) = (sqrt(temp/columns));
end
feat_test = horzcat(feat_test,v1);


%%%%%%%%%%%%%%%%_______DWT________%%%%%%%%%%%%%%%%%%%%%

y_c= flip(y_main,2);
v = [];
for i = 1:rows
    y = y_c{i,:};
    [c,l] = wavedec(y,3,'bior1.1');
    approx = appcoef(c,l,'bior1.1',3);
    v(i,:) = approx;
end 
feat_test = horzcat(feat_test,v);
dbfeat_test = horzcat(dbfeat_test,v);

feat_t = bsxfun(@minus,feat_test,mean(feat_test,1));
feat_t = bsxfun(@rdivide,feat_t,std(feat_test,1));

[U, Z1]=pca(feat_t, 'NumComponents', 2);

Test_Kmeans_prediction = mypredict_kmeans(feat_t);
Test_DBscan_prediction = mypredict_DBscan(Z1);
OutputMatrix = horzcat(Test_Kmeans_prediction,Test_DBscan_prediction);