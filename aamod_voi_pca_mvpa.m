% AA module - VOI pca mvpa
%

function [aap,resp]=aamod_voi_pca_mvpa(aap,task)

resp='';

switch task
    case 'report'
        
    case 'doit'
        
        fn = aas_getfiles_bystream(aap,'groupvoi');
        vois=load(fn);
        % Components at first level
        
        % One session and voi at a time
        for sess=1:size(vois,1)
            for voiind=1:size(vois,2)
                data=vois.all_subj_pca_score{sess,voiind};
                data=reshape(permute(data,[2 3 1]),[size(data,2) size(data,1)*size(data,3)]);
                ncompfirstlevel=size(data,2)/length(aap.acq_details.subjects);
                
                % USE PCA
                % now the 1000 dimension has major PCs towards the left
                numOfIC=8;
                switch(aap.tasklist.currenttask.settings.method)
                    case 'pca'
                        figure(20);
                        [coeff score latent]=princomp(data);
                    case 'ica'
                        figure(21);
                        % ICA
                        [E D] = FASTICA(data','numOfIC',numOfIC,'only','pca');
                        coeff=E;
                end;
                figind=1;
                % now, lets project back PCA onto individual subjects
                for compind=1:numOfIC
                    for subj=1:length(aap.acq_details.subjects)
                        subplot(numOfIC,length(aap.acq_details.subjects),figind);
                        indvoi=load(aas_getfiles_bystream(aap,subj,aap.acq_details.selected_sessions(sess),'voi'));
                        % First, project from group space to individual's 20
                        % comps
                        indweight=coeff((subj-1)*ncompfirstlevel+[1:ncompfirstlevel],compind);
                        indproj=indvoi.vois(voiind).pca.coeff(:,1:ncompfirstlevel)*indweight;
                        scatter3(indvoi.vois(voiind).xyz(:,1),indvoi.vois(voiind).xyz(:,2),indvoi.vois(voiind).xyz(:,3),[],indproj)
                        axis off;
                        view(0,90);
                        figind=figind+1;
                    end;
                end;
            end;
        end;
end;
