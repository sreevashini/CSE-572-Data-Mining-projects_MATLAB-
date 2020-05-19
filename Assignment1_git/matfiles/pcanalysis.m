%Calucalted through function
[coeff,score,latent,~,variance]=pca(feat);
[U, Z]=pca(feat, 'NumComponents', 5);
%Calculated manually
covarianceMatrix = cov(feat);
[V,D] = eig(covarianceMatrix);
%Top 5 variance
variance = variance(1:5,:);
figure;
xlabel('PCA components');
ylabel('Variance of components');
yyaxis right;
bar(variance);
ylim([0 100]);
hold on;
ylim([0 100])
plot(cumsum(variance));
figure;
x = 1:150;
hold on
%Scatter Plot of PCAs
scatter(Z(:,1),Z(:,3),'filled');
scatter(Z(:,1),Z(:,4),'filled');
scatter(Z(:,1),Z(:,4),'filled');
scatter(Z(:,1),Z(:,5),'filled');
title('PCA components 2, 3, 4, 5 plotted against PCA component 1');
xlabel('PCA Component 1');
z_plot = Z(1:10,:);
spider(z_plot);
colormap(jet);
colorbar;