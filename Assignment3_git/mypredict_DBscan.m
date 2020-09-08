function ypred = mypredict_DBscan(tbl)
%#function fitctree
load('dbscanmodel.mat');
load('dbscanfeat.mat');
ypred = dbscanModel.predictFcn(tbl);
end