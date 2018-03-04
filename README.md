# Singularity RStudio Server

[![Singularity Hub](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/463)
[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Singularity image for [RStudio Server]. It was built on top of the base
Singularity image [nickjer/singularity-r].

This is still a work in progress.

## Build

You can build a local Singularity image named `singularity-rstudio.simg` with:

```sh
sudo singularity build singularity-rstudio.simg Singularity
```

## Deploy

Instead of building it yourself you can download the pre-built image from
[Singularity Hub](https://www.singularity-hub.org) with:

```sh
singularity pull --name singularity-rstudio.simg shub://nickjer/singularity-rstudio
```

## Run

### RStudio Server

The `rserver` command is launched using the default run command:

```sh
singularity run singularity-rstudio.simg
```

or as an explicit app:

```sh
singularity run --app rserver singularity-rstudio.simg
```

Example:

```console
$ singularity run --app rserver singularity-rstudio.simg --help
command-line options:

verify:
  --verify-installation arg (=0)        verify the current installation

server:
  --server-working-dir arg (=/)         program working directory
  --server-user arg (=rstudio-server)   program user
  --server-daemonize arg (=0)           run program as daemon
  --server-app-armor-enabled arg (=1)   is app armor enabled for this session
  --server-set-umask arg (=1)           set the umask to 022 on startup

...
```

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

If your institution provides access to an LDAP (or Active Directory)
server, you may use it to authenticate users to RStudio. You must
first determine the following:

1. The name of the LDAP host
2. The base DN for users in the domain. A placeholder in the form '%s'
   will be replaced by the username provided to RStudio at the time of
   authentication.
3. A public TLS certificate used for encryption of the LDAP session

For example:

```sh
export LDAP_HOST=your.ldap.server.org
export LDAP_USER_DN='CN=%s,CN=Users,DC=MyDomain,DC=com'
singularity run \
  --bind thawte_Primary_Root_CA.pem:/etc/ldap-cert.pem \
  singularity-rstudio.simg \
  --auth-none 0 \
  --auth-pam-helper-path ldap_auth
```

Here the certificate file `thawte_Primary_Root_CA.pem` (used here only
as an example) is bound to the default path for the certificate in the
image.

### R and Rscript

See [nickjer/singularity-r] for more information on how to run `R` and
`Rscript` from within this Singularity image.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/nickjer/singularity-rstudio.

## License

The code is available as open source under the terms of the [MIT License].


[RStudio Server]: https://www.rstudio.com/products/rstudio/
[nickjer/singularity-r]: https://github.com/nickjer/singularity-r
[MIT License]: http://opensource.org/licenses/MIT
