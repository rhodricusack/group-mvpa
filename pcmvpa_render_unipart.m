aap=aas_setcurrenttask(aap,4);
if ~(exist('l','var') && exist('u','var'))
    l=[];
    u=[];
    for subjind=1:50 %length(aap.acq_details.subjects)
        if (subjind~=47)
            fprintf('Subject %d\n',subjind);
            subjfn=aas_getsubjpath(aap,subjind);
            load(fullfile(subjfn,'searchlight_pca','stats.mat'))
            load(fullfile(subjfn,'searchlight_pca','backproj.mat'))
            for slind=1:5124
                l(subjind,slind)=sum(backproj{slind}(:,1))/(sqrt(sum(backproj{slind}(:,1).^2))*sqrt(size(backproj{slind},1)));
                u(subjind,slind)=stats(slind).unipart(1);
            end
        end;
    end;

end;

if ~exist('pcmvpa','var')
    load /home/rcusack/camcan/movieica/pcamvpa/aamod_searchlight_pca_mvpa_00001/searchlight_pca/pcmvpa.mat
end;

for slind=1:5124
    f(slind)=pcmvpa(slind).latent(1)/sum(pcmvpa(slind).latent);
end

l0=mean(l,1);
u0=mean(u,1);

figure(4)
clf
subplot 421
pcmvpa_render(l0);
title('Prop first latent that is univariate');

subplot 422
tl=mean(l,1)./(std(l,[],1)/sqrt(49));
pcmvpa_render(tl);
title('T stats for prop first latent that is univariate');


subplot 423
pcmvpa_render(u0);
title('Prop of top 20 latents that is univariate');

subplot 424
tu=mean(u,1)./(std(u,[],1)/sqrt(49));
pcmvpa_render(tu);
title('T stats for prop top 20 latents that is univariate');

subplot 425
pcmvpa_render(f);
title('First latent as proportion of others');

subplot 426
pcmvpa_render(1-l0);
title('Proportion of first latent that is not univariate');
