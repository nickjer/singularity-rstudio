# Singularity RStudio Server

Singularity image for [RStudio Server]. It was built based on the work of nickjer at nickjer/singularity-rstudio. Most important differences are updates to make it work on more recent software, and the removal of the dependency on the base r singularity image

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
echo "www-port=8787" > /home/vagrant/etc/rserver.conf
echo "auth-minimum-user-id=100" > /home/vagrant/etc/rserver.conf
singularity run \
--bind /home/vagrant/rstudio-server-logging/:/var/run/rstudio-server/,\
/home/vagrant/lib/:/var/lib/rstudio-server/,\
/home/vagrant/etc/:/etc/rstudio/,/home/vagrant/tmp/:/tmp/ \
/vagrant/single-cell-container-server.simg --server-user vagrant
```

This will start on the 8787 port. You can modify your vagrant settings to map 8787 from the Vagrant box to 8787 on your local machine. This way you can reach the server running on the Vagrant box at localhost:8787


#### Gearshift cluster

TODO


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
