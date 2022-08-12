conda activate rstudio-server_env && \
singularity run  --bind /groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/simulated_home:/home/umcg-roelen,\
/groups/umcg-franke-scrna/tmp01/,\
/groups/umcg-wijmenga/tmp01/,\
/groups/umcg-bios/tmp01/projects/1M_cells_scRNAseq/ongoing/,\
/groups/umcg-weersma/tmp01/,\
/groups/umcg-lifelines/tmp01/releases/,\
/groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/rstudio-server-logging:/var/run/rstudio-server,\
/groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/lib:/var/lib/rstudio-server,\
/groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/etc:/etc/rstudio,\
/groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/tmp:/tmp \
/groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/singularity-rstudio.simg \
--server-user umcg-roelen \
--server-data-dir ~/server-data/ \
--server-daemonize 0 \
--secure-cookie-key-file ~/server-data/rserver_cookie
