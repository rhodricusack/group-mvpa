% Make up some data
%  rows are reps
%  cols are features
m=120;
n=30;
x=rand(m,n);

% Zero columns, important to make SVD=princomp
x=x-repmat(mean(x,1),[size(x,1) 1]);

% SVD
[u s v]=svd(x);

% GET PCA
coeff_s=v;
score_s=u*s;
latent_s=diag(s).^2/(m-1);

% CHECK IT AGAINST MATLAB STATS TOOLBOX
[coeff score latent]=princomp(x);

coeff_r=coeff./coeff_s;
score_r=score./score_s;
latent_r=latent./latent_s;

% TRY RECONSTRUCTING THE ORIGINAL DATA
fit=u*s*v';
fit2=score_s*coeff_s';

% CHECK DIFFS
diff=fit-x;
diff2=fit2-x;
max(diff(:))
max(diff2(:))

% LIMITED NUMBER OF DIMS
ncomps=3;
fit_l=score_s(:,1:ncomps)*coeff_s(:,1:ncomps)';
diff_l=x-fit_l;

fprintf('Prop of var explained: %f\n',mean(var(x,[],1)-var(diff_l,[],1))/mean(var(x,[],1)));
fprintf('Latent say: %f',sum(latent_s(1:ncomps))/sum(latent_s));

