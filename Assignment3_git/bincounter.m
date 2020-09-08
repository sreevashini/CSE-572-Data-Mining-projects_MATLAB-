clear all;
close all;
b=[];
a = readtable("mealAmountData1.csv");
y_concat = readtable("mealData1.csv");
rows_i = size(y_concat,1);
columns_i = size(y_concat,2);
b = vertcat(b,a{1:rows_i,:});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = readtable("mealAmountData2.csv");
y = readtable("mealData2.csv");
rows_i = size(y,1);
columns_i = size(y,2);
b = vertcat(b,a{1:rows_i,:});
y_concat = vertcat(y_concat,y);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = readtable("mealAmountData3.csv");
y = readtable("mealData3.csv");
rows_i = size(y,1);
columns_i = size(y,2);
b = vertcat(b,a{1:rows_i,:});
y_concat = vertcat(y_concat,y);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = readtable("mealAmountData4.csv");
y = readtable("mealData4.csv");
rows_i = size(y,1);
columns_i = size(y,2);
b = vertcat(b,a{1:rows_i,:});
y_concat = vertcat(y_concat,y);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = readtable("mealAmountData5.csv");
y = readtable("mealData5.csv");
rows_i = size(y,1);
columns_i = size(y,2);
b = vertcat(b,a{1:rows_i,:});
y_concat = vertcat(y_concat,y);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newy = [];
newb = [];
k = 1;
for i=1:size(y_concat,1)
        TF = ismissing(y_concat{i,:}); 
        TF = sum(TF);
    if(TF<5)
        newy(k,:) = table2array(y_concat(i,:));
        newb(k,:) = b(i,:);
        k = k+1;
    end 
end
newy= fillmissing (newy,'pchip',1);
y_main = array2table(newy);
rows = size(y_main,1);
columns = size(y_main,2);

val = 1:rows;
sub = [];
for i =1: rows;
    if(newb(i,:)==0)
        sub = vertcat (sub, 1);
    else
        quo = newb(i,:)/10;
        if((quo > 0) && (quo<=2))
            sub = vertcat (sub,2);
        end
        if((quo > 2) && (quo<=4))
            sub = vertcat (sub,3);
        end
        if((quo >4) && (quo<=6))
            sub = vertcat (sub,4);
        end
        if((quo >6) && (quo<=8))
            sub = vertcat (sub,5);
        end
        if((quo > 8) && (quo<=10))
            sub = vertcat (sub,6);
        end
    end 
end
Bins = [];
catnames = {'<0';'0<=20';'20<=40';'40<=60';'60<=80';'80<=100'};
Bins = horzcat(Bins,catnames);
Bins = horzcat(Bins,accumarray(sub,val,[],@(x) {x}));
feat = [];

%%%%%%%%%%%%%%%%_____AverageCGM(Pre and Post Lunch)______%%%%%%%%%%%%%%%%%%%%%

y_c = flip(table2array(y_main),2); 
k=size(feat,2);

for i=1:size(y_c,1)
    feat(i,k+1) = mean(y_c(i,7:30))-mean(y_c(i,1:6));
    feat(i,k+2) = mean(y_c(i,7:30));
    feat(i,k+3) = mean(y_c(i,1:6));  
end

%%%%%%%%%%%%%%%%_______ROOTMEAN________%%%%%%%%%%%%%%%%%%%%%

%RMS average glucose for one person's one meal is calculated
y_c = flip(y_main,2);
v1 = [];
for i = 1:size(y_c,1)
    y_c{i,:}= y_c{i,:}.^2;
    temp = sum(y_c{i,:});
    v1(i,:) = (sqrt(temp/columns));
end
feat = horzcat(feat,v1);


%%%%%%%%%%%%%%%%_______DWT________%%%%%%%%%%%%%%%%%%%%%

y_cgm = flip(y_main,2);
rows = size(y_cgm,1);
columns = size(y_cgm,2);
v = [];
for i = 1:rows
    y = y_cgm{i,:};
    [c,l] = wavedec(y,3,'bior1.1');
    approx = appcoef(c,l,'bior1.1',3);
    v(i,:) = approx;
end 
feat = horzcat(feat,v);

feat_t = bsxfun(@minus,feat,mean(feat,1));
feat_t = bsxfun(@rdivide,feat_t,std(feat,1));

[coeff,score,latent,~,variance]=pca(feat_t);
[U, Z1]=pca(feat_t, 'NumComponents', 2);

opts = statset('Display','final');
[idx,C] = kmeans(feat_t,6,'Distance','sqEuclidean',...
    'Replicates',10,'Options',opts);
kbins = accumarray(idx,val,[],@(x) {x});


figure;
for x = 1:6
    if(x==1)
        color = 'r.';
    end
    if(x==2)
        color = 'b.';
    end
    if(x==3)
        color = 'g.';
    end
    if(x==4)
        color = 'y.';
    end
    if(x==5)
        color = 'c.';
    end
    if(x==6)
        color = 'm.';
    end
    for y = 2:2:size(feat_t,2)
        plot(feat_t(idx==x,1),feat_t(idx==x,y),color,'MarkerSize',12);
        hold on;
        plot(C(:,1),C(:,2),'kx','MarkerSize',15);
    end
    legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6','Centroids',...
       'Location','NW');
end
title 'Cluster Assignments and Centroids';
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%________DBSCAN________%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minpts = 4;
epsilon = 0.435;
[labels, corepts] = dbscan(Z1,epsilon,minpts,'Distance','euclidean');

[dbclustercenters,dbclus1m,dbclus2m,dbclus3m,dbclus4m,dbclus5m,dbclus6m,...
    dbclus1l,dbclus2l,dbclus3l,dbclus4l,dbclus5l,dbclus6l] = distance_calculation(labels,Z1);
        
dbnoise = find(labels == -1);
if(~isempty(dbnoise))
    for i=1:size(dbnoise,1)
        rowid = dbnoise(i);
        dbnoise(i,2)= Z1(rowid,1);
        dbnoise(i,3)= Z1(rowid,2);
    end
    dbnoise1 = dbnoise(:, 2:3);
    [cIdx,~] = knnsearch(dbclustercenters,dbnoise1);
    cIdx = horzcat (cIdx,dbnoise(:,1));
end

for i=1:size(cIdx,1)
    labels(cIdx(i,2),1) = cIdx(i,1);
end
dbbins = accumarray(labels,val,[],@(x) {x});

%%%%%%%%%%%%________CLUSTERSIZE_CHANGE__________%%%%%%%%%%%% 
%%%%%%%%%%%%______(6 iterations on max)_________%%%%%%%%%%%%
for i = 1:10 
    maxclus = maxclusout(dbbins);
    if(maxclus(1,1) > 60)
        largeclus = mode(labels);
        if(largeclus == 1)
            [cIdxlarge,~] = knnsearch(dbclustercenters,dbclus1m);
            cIdxlarge = horzcat(cIdxlarge,dbclus1l(:,1));
        end
        for j=1:size(cIdxlarge,1)
            labels(cIdxlarge(j,2),1) = cIdxlarge(j,1);
        end
        [dbclustercenters,dbclus1m,dbclus2m,dbclus3m,dbclus4m,dbclus5m,dbclus6m,...
            dbclus1l,dbclus2l,dbclus3l,dbclus4l,dbclus5l,dbclus6l] = distance_calculation(labels,Z1);
        dbbins = accumarray(labels,val,[],@(x) {x});
    end
end

figure;
gscatter(Z1(:,1),Z1(:,2),labels);
hold on;
for i=1:6
    plot (dbclustercenters(i,1),dbclustercenters(i,2),'kx','MarkerSize',15);
end
hold off;

kweights = weightcal(Bins,kbins);
DBweights = weightcal(Bins,dbbins);

maximum = max(max(cell2mat(kweights)));
[x ,y]= find(cell2mat(kweights)==maximum);
knew = kweights;
knew(x,:) = [];
knew(:,y) = [];
assignment1 = [];
assignment1(1,:) = x;
[assignment,cost,~,~,~] = lapjv(cell2mat(knew));
for i=1:size(assignment,2)
    if(assignment(:,i)>=x)
        assignment1(i+1,:) = 1+assignment(:,i);
    else
        assignment1(i+1,:) = assignment(:,i);
    end
end
assignment1 = assignment1(:,any(assignment1));
[assignment2,cost1,~,~,~] = lapjv(cell2mat(DBweights));
assignment2(:,4)=5;
assignment2(:,5)=4;
assignment2(:,6)=2;

for k = 1:6
    newlab = assignment1(k,:);
    rownumbers = find(idx == newlab);
    for j=1:size(rownumbers,1)
        rownew = rownumbers(:,1);
        idx_new(rownew,:) = k;
    end
end
   
for l = 1:6
    newlab1 = assignment2(:,l);
    rownumbers1 = find(labels == newlab1);
    for j=1:size(rownumbers1,1)
        rownew1 = rownumbers1(:,1);
        labels_new(rownew1,:) = l;
    end
end

kmeanfeat = horzcat(feat_t,idx_new);
% kmeanfeat = array2table(kmeanfeat);

dbscanfeat = horzcat(Z1,labels_new);
% dbscanfeat = array2table(dbscanfeat);

function [dbcluscenter,dbclus1m,dbclus2m,dbclus3m,dbclus4m,dbclus5m,dbclus6m,...
    dbclus1l,dbclus2l,dbclus3l,dbclus4l,dbclus5l,dbclus6l] = distance_calculation (func_labels,Z1)
   
    dbclus1 = find(func_labels == 1);
    for i=1:size(dbclus1,1)
        rowid = dbclus1(i);
        dbclus1(i,2)= Z1(rowid,1);
        dbclus1(i,3)= Z1(rowid,2);
    end

    dbclus2 = find(func_labels == 2);
    for i=1:size(dbclus2,1)
        rowid = dbclus2(i);
        dbclus2(i,2)= Z1(rowid,1);
        dbclus2(i,3)= Z1(rowid,2);
    end

    dbclus3 = find(func_labels == 3);
    for i=1:size(dbclus3,1)
        rowid = dbclus3(i);
        dbclus3(i,2)= Z1(rowid,1);
        dbclus3(i,3)= Z1(rowid,2);
    end

    dbclus4 = find(func_labels == 4);
    for i=1:size(dbclus4,1)
        rowid = dbclus4(i);
        dbclus4(i,2)= Z1(rowid,1);
        dbclus4(i,3)= Z1(rowid,2);
    end

    dbclus5 = find(func_labels == 5);
    for i=1:size(dbclus5,1)
        rowid = dbclus5(i);
        dbclus5(i,2)= Z1(rowid,1);
        dbclus5(i,3)= Z1(rowid,2);
    end

    dbclus6 = find(func_labels == 6);
     for i=1:size(dbclus6,1)
        rowid = dbclus6(i);
        dbclus6(i,2)= Z1(rowid,1);
        dbclus6(i,3)= Z1(rowid,2);
     end
     dbclus1m = dbclus1(:,2:3);
     dbclus2m = dbclus2(:,2:3);
     dbclus3m = dbclus3(:,2:3);
     dbclus4m = dbclus4(:,2:3);
     dbclus5m = dbclus5(:,2:3);
     dbclus6m = dbclus6(:,2:3);
     dbclus1l = dbclus1(:,1);
     dbclus2l = dbclus2(:,1);
     dbclus3l = dbclus3(:,1);
     dbclus4l = dbclus4(:,1);
     dbclus5l = dbclus5(:,1);
     dbclus6l = dbclus6(:,1);
     dbcluscenter(1,:)= (mean(dbclus1m,1));
     dbcluscenter(2,:)= (mean(dbclus2m,1));
     dbcluscenter(3,:)= (mean(dbclus3m,1));
     dbcluscenter(4,:)= (mean(dbclus4m,1));
     dbcluscenter(5,:)= (mean(dbclus5m,1));
     dbcluscenter(6,:)= (mean(dbclus6m,1));
end

function [out] = maxclusout(cellip)
    [s,d] = cellfun(@size,cellip);
    out = max([s,d]);
end

function [weightmatrix] = weightcal(Bintruth,Bintest)
    for te = 1:6
        for tr = 1:6
            ids = ismember(Bintest{te,1},Bintruth{tr,2},'legacy');
            c = 1:size(Bintest{te,1},2);
            weightmatrix{te,tr}= sum(ids);
        end
    end
end



