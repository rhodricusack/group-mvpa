% AA module - VOI pca mvpa
%

function [aap,resp]=aamod_searchlight_pca_backproject(aap,task,subjind)

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
        
        studypth=aas_getsubjpath(aap,subjind);
        outdir=fullfile(studypth,'searchlight_pca');
        pcmvpa=struct([]);
        fn=aas_getfiles_bystream(aap,'pcmvpa_groupspace');
        load(fn);
        
        aas_makedir(aap,outdir);
        nslind=size(vertices,1); % 10;
        numOfIC=8;
        
        stats=struct([]);
        
        backproj=cell(nslind,1);
        parfor slind=1:nslind
            aas_log(aap,false,sprintf('Searchlight %d/%d',slind,nslind));
            sesspth=aas_getsesspath(aap,subjind,1);
            loadsl=load(fullfile(sesspth,'searchlight_pca',sprintf('sl%d.mat',slind)));
            sl=loadsl.sl;
            
            % now, lets project back PCA onto individual subjects
            %   dimensions are (components, subjects, voxels)
            
            backproj{slind}=zeros(size(sl.coeff,1),numOfIC);
            
            
            
            unipart=0;
            ncompfirstlevel=size(sl.coeff,2);
            for compind=1:numOfIC
                indweight=pcmvpa(slind).coeff((subjind-1)*ncompfirstlevel+[1:ncompfirstlevel],compind);
                backproj{slind}(:,compind)=sl.coeff(:,1:ncompfirstlevel)*indweight;
                unipart=unipart+pcmvpa(slind).latent(compind)*sum(backproj{slind}(:,compind))/(sqrt(sum(backproj{slind}(:,compind).^2))*sqrt(size(backproj{slind},1)));
            end;
            
            sumoflatent=sum(pcmvpa(slind).latent);
            stats(slind).firstlatent_unipart=sum(backproj{slind}(:,1))/(sqrt(sum(backproj{slind}(:,1).^2))*sqrt(size(backproj{slind},1)));
            stats(slind).firstlatent=pcmvpa(slind).latent(1)/sumoflatent;
            stats(slind).unipart=unipart/sumoflatent;
            
        end;
        
        
        % Write outputs
        outfn=fullfile(outdir,'backproj.mat');
        save(outfn,'backproj','-v7.3');
        aap=aas_desc_outputs(aap,subjind,'pcmvpa_backproj',outfn);

        outfn=fullfile(outdir,'stats.mat');
        save(outfn,'stats','-v7.3');
        aap=aas_desc_outputs(aap,subjind,'pcmvpa_stats',outfn);

        %         outfn=fullfile(outdir,'backproj.mat');
        %         save(outfn,'backproj','-v7.3');
        %         aap=aas_desc_outputs(aap,'pcmvpa_backproj',outfn);
end
