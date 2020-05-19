%DWT wavelet only co.efficients are put in feature matrix
rows = size(y_cgm,1);
columns = size(y_cgm,2);
v = [];
for i = 1:rows
     %Dwt function called
    [a,b]= dwt(y_cgm{i,:},'sym4');
    v(i,:)=[a];
end
feat = horzcat(feat,v);