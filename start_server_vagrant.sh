echo "www-port=8787" > /home/vagrant/etc/rserver.conf
echo "auth-minimum-user-id=100" > /home/vagrant/etc/rserver.conf
singularity run \
--bind /home/vagrant/rstudio-server-logging/:/var/run/rstudio-server/,\
/home/vagrant/lib/:/var/lib/rstudio-server/,\
/home/vagrant/etc/:/etc/rstudio/,/home/vagrant/tmp/:/tmp/ \
/vagrant/single-cell-container-server.simg --server-user vagrant
