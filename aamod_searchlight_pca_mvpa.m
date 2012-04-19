% AA module - VOI pca mvpa
%

function [aap,resp]=aamod_searchlight_pca_mvpa(aap,task)

resp='';

switch task
    case 'report'
        
    case 'doit'
        
        % Use surface from MEG
        cortsurf=gifti('/home/rcusack/software/spm_cbu_svn/releases/spm8_fil_r4290/canonical/cortex_5124.surf.gii');
        vertices=cortsurf.vertices;

        
        if (length(aap.acq_details.sessions)~=1)
            aas_log(aap,true,'At present, aamod_pvmvpa_searchlight only handle a single session');
        else
            sessind=1;
        end;

        studypth=aas_getstudypath(aap);
        outdir=fullfile(studypth,'searchlight_pca');
        aas_makedir(aap,outdir);
        nslind=size(vertices,1); % 10; 
        numOfIC=8;

        outfn=cell(nslind);
        
       % backproj=cell(nslind,1);
        
        parfor slind=1:nslind
            aas_log(aap,false,sprintf('Searchlight %d/%d',slind,nslind));
           
            for subjind=1:length(aap.acq_details.subjects)
                    sesspth=aas_getsesspath(aap,subjind,1);
                    loadsl=load(fullfile(sesspth,'searchlight_pca',sprintf('sl%d.mat',slind)));
                    if (subjind==1)
                        sl=loadsl.sl;
                    else
                        sl(subjind)=loadsl.sl;
                    end;
                    if (subjind==1)
                        % dims are (subjects, timepoints, components)
                        data=zeros(length(aap.acq_details.subjects),size(sl(subjind).score,1),size(sl(subjind).score,2));
                    end;
                    data(subjind,:,:)=sl(subjind).score(:,:);
            end;
            ncompfirstlevel=size(data,3);
            data=reshape(permute(data,[2 3 1]),[size(data,2) size(data,1)*size(data,3)]);
                
            % SECOND LEVEL SUMMARIZE
            % now the 1000 dimension has major PCs towards the left
            switch(aap.tasklist.currenttask.settings.method)
                case 'pca'
                    figure(20);
                    [coeff score latent]=princomp(data,'econ');
                    pcmvpa(slind).coeff=coeff;
                    pcmvpa(slind).score=score;
                    pcmvpa(slind).latent=latent;
                case 'ica'
                    figure(21);
                    % ICA
                    [icasig A W] = FASTICA(data','numOfIC',numOfIC,'only','pca');
                    pcmvpa(slind).W=icasig;
                    pcmvpa(slind).A=A;
                    pcmvpa(slind).W=W;
            end;

           
            % now, lets project back PCA onto individual subjects
            %   dimensions are (components, subjects, voxels)
            
%             backproj{slind}=zeros(numOfIC,length(aap.acq_details.subjects),size(sl(1).coeff,1));
%             for compind=1:numOfIC
%                 for subj=1:length(aap.acq_details.subjects)
%                     indweight=coeff((subj-1)*ncompfirstlevel+[1:ncompfirstlevel],compind);
%                     backproj{slind}(compind,subj,:)=sl(subj).coeff(:,1:ncompfirstlevel)*indweight;
%                 end;
%             end;
        end;
        
        
        % Write outputs
        outfn=fullfile(outdir,'pcmvpa.mat');
        save(outfn,'pcmvpa','-v7.3');
        aap=aas_desc_outputs(aap,'pcmvpa_groupspace',outfn);

%         outfn=fullfile(outdir,'backproj.mat');
%         save(outfn,'backproj','-v7.3');
%         aap=aas_desc_outputs(aap,'pcmvpa_backproj',outfn);
end
