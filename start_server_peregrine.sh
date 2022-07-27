singularity run  --bind /data/p287578/singularity/rstudio-server/simulated_home:/home/p287578,\
/data/p287578/,\
/data/p287578/singularity/rstudio-server/rstudio-server-logging:/var/run/rstudio-server,\
/data/p287578/singularity/rstudio-server/lib:/var/lib/rstudio-server,\
/data/p287578/singularity/rstudio-server/etc:/etc/rstudio,\
/data/p287578/singularity/rstudio-server/tmp:/tmp \
/data/p287578/singularity/rstudio-server/singularity-rstudio.simg \
--server-user p287578 \
--server-data-dir ~/server-data/ \
--server-daemonize 0 \
--secure-cookie-key-file ~/server-data/rserver_cookie
