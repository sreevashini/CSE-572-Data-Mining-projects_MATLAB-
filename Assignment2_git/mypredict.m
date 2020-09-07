function ypred = mypredict(tbl)
%#function fitrtree
load('mymodel.mat');
load('featue.mat')
ypred = trainedModel.predictFcn(tbl);
end