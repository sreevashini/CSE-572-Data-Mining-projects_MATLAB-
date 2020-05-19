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
for i=1:size(v,1)
    j=1;
    while j <= 19
          feat(i,j+6) = (v(i,j)+v(i,j+1)+v(i,j+2)+v(i,j+3)+v(i,j+4)+v(i,j+5))/6;
          j = j+6;
    end
end
feat = feat(:,any(feat));
for i=1:size(v,1)
    subplot(10,20,i);
    x = double.empty(length(v(i,:)),0);
    for m = 1:length(v(i,:))
        x(m) = 5*m - 5;
    end
    plot(x, v(i,:));
    hold on;
end