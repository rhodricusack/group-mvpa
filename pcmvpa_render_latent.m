figure(3);
l0=[] 
for i=1:5124
    l0(i)=pcmvpa(i).latent(1);
end
pcmvpa_render(l0);