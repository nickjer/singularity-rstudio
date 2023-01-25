# Singularity RStudio Server

Singularity image for [RStudio Server]. It was built based on the work of nickjer at nickjer/singularity-rstudio. Most important differences are updates to make it work on more recent software, and the removal of the dependency on the base r singularity image.
Additionally, libraries and dependencies were added for the use of work with single-cell RNA-seq data.

This is still a work in progress.

## Build

You can build a local Singularity image named `singularity-rstudio.simg` with:

```sh
sudo singularity build singularity-rstudio.simg Singularity
```

The best way to do this, is to set up a Vagrant box that contains Singularity, this is also the most clear-cut option for Mac OSX users. 
https://docs.sylabs.io/guides/3.2/user-guide/installation.html#setup

## Deploy

Work is being done on supplying automated builds of the image, but for now it can be found on Google Drive
https://drive.google.com/file/d/1fXIQncg7S3kp_MByydyqkQsssX0XgJ8_/view?usp=sharing

## Run

### RStudio Server

#### Vagrant box

From the vagrant box, the singularity image can be started with:

```sh
mkdir -p /home/vagrant/rstudio-server-logging/
mkdir -p /home/vagrant/lib/
mkdir -p /home/vagrant/etc/
mkdir -p /home/vagrant/tmp/
echo "www-port=8787" > /home/vagrant/etc/rserver.conf
echo "auth-minimum-user-id=100" >> /home/vagrant/etc/rserver.conf
singularity run \
--bind /home/vagrant/rstudio-server-logging/:/var/run/rstudio-server/,\
/home/vagrant/lib/:/var/lib/rstudio-server/,\
/home/vagrant/etc/:/etc/rstudio/,/home/vagrant/tmp/:/tmp/ \
/vagrant/single-cell-container-server.simg --server-user vagrant
```

This will start on the 8787 port. You can modify your vagrant settings to map 8787 from the Vagrant box to 8787 on your local machine. This way you can reach the server running on the Vagrant box at localhost:8787


#### Gearshift cluster

To use the singularity image on the UMCG HPC gearshift cluster, a bit of setup is required. This is described in step 1. After setting up, only step 2 and 3 need to be repeated for using the image.

STEP 1

Choose a location to put all of your files. The home folder on the Gearshift cluster is too small, so preferably set up a directory in one of the group folders you are a member of. For example if you are a member of the 'weersma' group, you can set up a directory in */groups/umcg-weersma/tmp01/user/${USER}/*

if there are already singularity folders in your home folder, we need to move them. check if there are the *.singularity* and *singularity* folders in your home directory by using:
```sh
ls -lah ~
```

for each of these two folders, if they exist they need to be moved:
```sh
mv ~/.singularity /groups/umcg-weersma/tmp01/user/${USER}/
mv ~/singularity /groups/umcg-weersma/tmp01/user/${USER}/
```

if they don’t exist they need to made in the new location:
```sh
mkdir -p /groups/umcg-weersma/tmp01/user/${USER}/.singularity/
mkdir -p /groups/umcg-weersma/tmp01/user/${USER}/singularity/
```

next we need to link these back to your home folder
```sh
ln -s /groups/umcg-weersma/tmp01/user/${USER}/.singularity ~/
ln -s /groups/umcg-weersma/tmp01/user/${USER}/singularity ~/
```
now to make a folder to house the singularity container:
```sh
mkdir -p /groups/umcg-weersma/tmp01/user/${USER}/singularity/rstudio-server/
```

and a simulated home directory, so that when you install new R libraries, they don’t conflict with the cluster versions
```sh
mkdir -p /groups/umcg-weersma/tmp01/user/${USER}/singularity/rstudio-server/simulated_home/
```

to use the singularity image, it needs to be downloaded from the Google Drive to the cluster, or uploaded to the cluster from your own machine, using rsync. If for example you had the image downloaded in your downloads folder on your mac, you could do (remember to change the username/group/downloadname):
```sh
rsync ~/Downloads/name_you_saved_image_under.simg airlock+gearshift:/groups/umcg-weersma/tmp01/user/umcg-whatever_your_username_is/singularity/rstudio-server/singularity-rstudio.simg
```

finally, we want to make it easy to start the server, so we'll create a startup script with the following contents. You can use nano to create a file and copy in the contents. The CTRL+O to save, and CTRL+X to exit. I will be naming the file *start_server_computenode.sh*, and saving it in my actual home directory *~/*
```sh
#!/bin/bash
mkdir -p ${TMPDIR}/rstudio-server-logging
mkdir -p ${TMPDIR}/etc
mkdir -p ${TMPDIR}/tmp
mkdir -p ${TMPDIR}/server-data
mkdir -p ${TMPDIR}/lib
echo "www-port=8777" > ${TMPDIR}/etc/rserver.conf
singularity run  --bind /groups/umcg-weersma/tmp01/users/${USER}/singularity/rstudio-server/simulated_home:/home/${USER},\
/groups/umcg-weersma/tmp01/,\
${TMPDIR},\
${TMPDIR}/rstudio-server-logging:/var/run/rstudio-server,\
${TMPDIR}/lib:/var/lib/rstudio-server,\
${TMPDIR}/etc:/etc/rstudio,\
${TMPDIR}/tmp:/tmp \
/groups/umcg-weersma/tmp01/users/${USER}/singularity/rstudio-server/singularity-rstudio.simg \
--server-user ${USER} \
--server-data-dir ${TMPDIR}/server-data/ \
--server-daemonize 0 \
--secure-cookie-key-file ~/server-data/rserver_cookie
```

if you are using an other group than weersma, be sure to change that in the file. Of course you can add to the binds, more paths, if you have access to more groups. For example if you have access to biogen and umcg-franke-scrna, and your user folder is in umcg-biogen, your file could instead look like this:

```sh
#!/bin/bash
mkdir -p ${TMPDIR}/rstudio-server-logging
mkdir -p ${TMPDIR}/etc
mkdir -p ${TMPDIR}/tmp
mkdir -p ${TMPDIR}/server-data
mkdir -p ${TMPDIR}/lib
echo "www-port=8777" > ${TMPDIR}/etc/rserver.conf
singularity run  --bind /groups/umcg-biogen/tmp01/users/${USER}/singularity/rstudio-server/simulated_home:/home/${USER},\
/groups/umcg-biogen/tmp01/,\
/groups/umcg-franke-scrna/tmp01/,\
${TMPDIR},\
${TMPDIR}/rstudio-server-logging:/var/run/rstudio-server,\
${TMPDIR}/lib:/var/lib/rstudio-server,\
${TMPDIR}/etc:/etc/rstudio,\
${TMPDIR}/tmp:/tmp \
/groups/umcg-biogen/tmp01/users/${USER}/singularity/rstudio-server/singularity-rstudio.simg \
--server-user ${USER} \
--server-data-dir ${TMPDIR}/server-data/ \
--server-daemonize 0 \
--secure-cookie-key-file ~/server-data/rserver_cookie
```

Okay, that was the setup, now to use the container


STEP 2

If you are using Windows, I am assuming you can use ssh via the (git bash) command line, otherwise you will run into issues when forwarding the ports. If you need help setting up ssh via the command line in Windows, you can use this tutorial: https://ssh-and-rsync-for-windows.readthedocs.io/en/latest/
Mac OSX and Linux users do not have to worry about this

open a screen session on the cluster


```sh
screen -S rserver
```

request the amount of resources you think you need, and be sure to ask for temporary storage
```sh
srun --cpus-per-task=8 --mem=64gb --nodes=1 --qos=priority --time=23:59:59 --job-name=rstudio_server --tmp=10GB --pty bash -i
```

once you get your session, check if the port in your *start_server_computenode.sh* file is available
```sh
lsof -i:8777
```

if you get output, it means the port is in use. Use nano to change the port to one that is not already taken

when you have found a port, you can start the server simply by using
```sh
~/start_server_computenode.sh
```

if you don't get any errors, the server has started. Take note of the computenode you are running at, you can see this in the prompt (in the example below, it is gs-vcompute09). Once you have that written down, you can keep the server running in the background and leave the screen session with CTRL+A,D
```sh
umcg-username@gs-vcompute09:~$
```


Now on your local machine, we are going to use one of your local ports, to connect to a port on the cluster
We need the username (*umcg-username* in this example), the port on the cluster (*8777* in this example), the compute node (*gs-vcompute09* in this example), and a local port you would like to use (*8787* in this example). To do this, we execute this command:

```sh
ssh -N -f -L localhost:8787:localhost:8777 umcg-username@airlock+gs-vcompute09
```

now you should be able to go to localhost:8787 (or an other port if you chose a different local port, and be connect to rstudio on the cluster)

If you lose your internet connection (due to your laptop going into sleep mode for example), you can re-execute the previous command again to get back the forwarding of your local port to the port on the cluster. You might have to reload the webpage as well.

When you want to stop the server (due to a hangup or because you need the interactive session for something else), you can reconnect on the cluster to the screen session (by the name you gave it, or the ID it has, see *screen -ls* for example), and killing it with CTRL+C.

Using the settings supplied in the examples here, you will have a home directory for the image, that is separate from your regular home directory. This will allow you to install additional R libraries to use with the container, without it interfering with locaal R installations. (The simulated home directory for the example would be */groups/umcg-weersma/tmp01/users/${USER}/singularity/rstudio-server/simulated_home/*)


STEP 3

Of course when you are running sbatch jobs, you would prefer to use the same R version that you are using for your interactive sessions. This is easily achieved by creating a shell script that calls the Singularity container. For example this script *start_Rscript.sh* in the home directory:

```sh
#!/bin/bash
singularity exec --bind /groups/umcg-weersma/tmp01/users/${USER}/singularity/rstudio-server/simulated_home:/home/${USER},\
/groups/umcg-weersma/tmp01/ \
/groups/umcg-weersma/tmp01/users/${USER}/singularity/rstudio-server/singularity-rstudio.simg \
Rscript $@
```

You can then use *~/start_Rscript.sh* instead of the usual *Rscript* command to use the container.

#### Peregrine cluster

TODO


#### Simple Password Authentication

To secure the RStudio Server you will need to:

1. Launch the container with the environment variable `RSTUDIO_PASSWORD` set to
   a password of your choosing.
2. Launch the `rserver` command with the PAM helper script `rstudio_auth`.

An example is given as:

```sh
RSTUDIO_PASSWORD="password" singularity run singularity-rstudio.simg \
  --auth-none 0 \
  --auth-pam-helper rstudio_auth
```

Now when you attempt to access the RStudio Server you will be presented with a
log in form. You can log in with your current user name and password you set in
`RSTUDIO_PASSWORD`.

#### LDAP Authentication

Another option is using an LDAP (or Active Directory) server for
authentication. Configuration of the LDAP authentication script `ldap_auth` is
handled through the following environment variables:

- `LDAP_HOST` - the host name of the LDAP server
- `LDAP_USER_DN` - the formatted string (where `%s` is replaced with the
  username supplied during log in) of the bind DN used for LDAP authentication
- `LDAP_CERT_FILE` - the file containing the CA certificates used by
  the LDAP server (default: use system CA certificates)

An example for an LDAP server with signed SSL certificate from a trusted CA:

```sh
export LDAP_HOST=ldap.example.com
export LDAP_USER_DN='cn=%s,dc=example,dc=com'
singularity run singularity-rstudio.simg \
  --auth-none 0 \
  --auth-pam-helper-path ldap_auth
```

An example for an LDAP server with a self-signed SSL certificate:

```sh
export LDAP_HOST=ldap.example.com
export LDAP_USER_DN='cn=%s,dc=example,dc=com'
export LDAP_CERT_FILE=/ca-certs.pem
singularity run \
  --bind /path/to/ca-certs.pem:/ca-certs.pem \
  singularity-rstudio.simg \
    --auth-none 0 \
    --auth-pam-helper-path ldap_auth
```

Note that we had to bind mount the CA certificates file from the host machine
into the container and specify the container's path in `LDAP_CERT_FILE` (not
the host's path).

[MIT License]: http://opensource.org/licenses/MIT
