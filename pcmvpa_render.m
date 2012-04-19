function pcmvpa_render(torender)
cortsurf=gifti('/home/rcusack/software/spm_cbu_svn/releases/spm8_fil_r4290/canonical/cortex_5124.surf.gii');
cortsurf2=cortsurf;
%cortsurf2=spm_mesh_inflate(cortsurf);
IAX=spm_mesh_render(cortsurf2,'parent',gca);
spm_mesh_render('Overlay',IAX,torender)
spm_mesh_render('ColourMap',IAX,colormap('hot'));
spm_mesh_render('ColorBar',IAX,'on');
lighting none