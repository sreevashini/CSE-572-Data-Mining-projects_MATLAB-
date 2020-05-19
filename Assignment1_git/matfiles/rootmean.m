%RMS average glucose for one person's one meal is calculated
rows = size(y_cgm,1);
columns = size(y_cgm,2);
v = [];
for i = 1:rows
    y_cgm{i,:}= y_cgm{i,:}.^2;
    temp = sum(y_cgm{i,:});
    v(i,:) = sqrt(temp/columns);
end 
feat = horzcat(feat,v);
