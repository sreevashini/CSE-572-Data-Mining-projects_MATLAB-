function ypred = mypredict_kmeans(tbl)
%#function fitctree
load('kmeansmodel.mat');
load('kmeansfeat.mat');
ypred = trainedModel.predictFcn(tbl);
end