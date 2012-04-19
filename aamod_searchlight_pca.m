% AA module -
% function [aap,resp]=aamod_searchlight_pca(aap,task,subjind)
% Rhodri Cusack 2006-2012

function [aap,resp]=aamod_searchlight_pca(aap,task,subjind)

resp='';

switch task
    case 'doit'
        
        % Searchlight size
        slrad=12; % mm radius searchlight
        slrad2=slrad.^2;
        
        % Use surface from MEG
        cortsurf=gifti('/home/rcusack/software/spm_cbu_svn/releases/spm8_fil_r4290/canonical/cortex_5124.surf.gii');
        vertices=cortsurf.vertices;
        
        if (length(aap.acq_details.sessions)~=1)
            aas_log(aap,true,'At present, aamod_pcmvpa_searchlight only handle a single session');
        else
            sessind=1;
        end;
        
        % Load first volume and get ready for data
        XYZ=[];
        fns=aas_getfiles_bystream(aap,subjind,sessind,'epi');
        nvols=length(fns);
        V=spm_vol(fns(1,:));
        Y=zeros(nvols,V.dim(1),V.dim(2),V.dim(3));
        [junk XYZ]=spm_read_vols(V);
        
        % Load up data
        aas_log(aap,false,'Loading data');
        parfor scanind=1:nvols
            V=spm_vol(fns(scanind,:));
            Y(scanind,:,:,:)=spm_read_vols(V);
        end;
        
        Y=reshape(Y,[size(Y,1) size(Y,2)*size(Y,3)*size(Y,4)]);
        % ***Flip data if incorrectly loaded from SPM 99
        %    Y=flipdim(Y,3);
        
        ncomps=aap.tasklist.currenttask.settings.numberofcomponents;
        
        % Searchlight loop
        nsl=size(vertices,1);
        coeff=cell(nsl,1);
        score=cell(nsl,1);
        latent=cell(nsl,1);
        parfor slind=1:nsl
            fprintf('Subject %d searchlight %d of %d\n',subjind,slind,size(vertices,1));
            sl=vertices(slind,:);
            slmask=(XYZ(1,:)>=(sl(1)-slrad)) & (XYZ(1,:)<=(sl(1)+slrad));
            slmask(slmask)= (XYZ(2,slmask)>=(sl(2)-slrad)) & (XYZ(2,slmask)<=(sl(2)+slrad));
            slmask(slmask)= (XYZ(3,slmask)>=(sl(3)-slrad)) & (XYZ(3,slmask)<=(sl(3)+slrad));
            slmask(slmask)=((XYZ(1,slmask)-sl(1)).^2+(XYZ(2,slmask)-sl(2)).^2+(XYZ(3,slmask)-sl(3)).^2)<slrad2;
            data=Y(:,slmask);
            [coeff0 score0 latent0]=princomp(data,'econ');
            coeff{slind}=coeff0(:,1:ncomps);
            score{slind}=score0(:,1:ncomps);
            latent{slind}=latent0;
         end;
        
        % Write outputs into lots of separate files, so a later stage can
        % rotate them into a more convenient matrix
        outdir=fullfile(aas_getsesspath(aap,subjind,sessind),'searchlight_pca');
        aas_makedir(aap,outdir);

        aas_log(aap,false,'Saving outputs');
        outpth=cell(size(vertices,1),1);
        for slind=1:size(vertices,1)
            outpth{slind}=fullfile(outdir,sprintf('sl%d.mat',slind));
            sl=struct([]);
            sl(1).coeff=coeff{slind};
            sl(1).score=score{slind};
            sl(1).latent=latent{slind};
            save(outpth{slind},'sl');
        end;
        
        aap=aas_desc_outputs(aap,subjind,sessind,'searchlightpca',outpth);
end;


end
