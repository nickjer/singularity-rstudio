mkdir -p ${TMPDIR}/rstudio-server-logging
mkdir -p ${TMPDIR}/etc
mkdir -p ${TMPDIR}/tmp
mkdir -p ${TMPDIR}/server-data
echo "www-port=8765" > ${TMPDIR}/etc/rserver.conf
conda activate rstudio-server_env && \
singularity run  --bind /groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/simulated_home:/home/umcg-roelen,\
/groups/umcg-franke-scrna/tmp01/,\
/groups/umcg-wijmenga/tmp01/,\
/groups/umcg-bios/tmp01/,\
/groups/umcg-weersma/tmp01/,\
${TMPDIR},\
${TMPDIR}/rstudio-server-logging:/var/run/rstudio-server,\
${TMPDIR}/lib:/var/lib/rstudio-server,\
${TMPDIR}/etc:/etc/rstudio,\
${TMPDIR}/tmp:/tmp \
/groups/umcg-wijmenga/tmp01/users/umcg-roelen/singularity/rstudio-server/singularity-rstudio.simg \
--server-user umcg-roelen \
--server-data-dir ${TMPDIR}/server-data/ \
--server-daemonize 0 \
--secure-cookie-key-file ~/server-data/rserver_cookie
