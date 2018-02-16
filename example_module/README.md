# RStudio Server + Singularity Module

This is an example module that sets up the environment necessary to launch
RStudio Server.

## Setup

1. Modify the `modulefiles/x.y.z.lua` to your specification.
2. Download the corresponding Singularity image under
   `x.y.z/singularity-rstudio.simg`:

   ```console
   $ mkdir x.y.z
   $ cd x.y.z
   $ singularity pull --name singularity-rstudio.simg shub://nickjer/singularity-rstudio:x.y.z
   $ cd ..
   ```

The downloaded Singularity image [nickjer/singularity-rstudio] is entirely
optional. You are welcome to create and maintain your own images using the
above image as an example.

[nickjer/singularity-rstudio]: https://www.singularity-hub.org/collections/463

## Install Libraries

Users may request that you install R packages. I am not entirely sure if
installed packages work across major (`x`) or minor (`x.y`) version numbers. So
to err on the side of caution I treat packages separate within minor versions
of R.

1. Create a library for the corresponding R minor version if one doesn't
   already exist:

   ```console
   $ mkdir library-x.y
   ```
2. Confirm you have permissions to write to this directory.
3. Confirm the corresponding module files `modulesfiles/x.y.z.lua` point to
   this library.
4. Load any one of the corresponding module files and launch R:

   ```console
   $ module load rstudio_singularity/x.y.z
   $ R
   ```
5. Install requested packages:

   ```R
   install.packages("my_package", lib="/usr/local/lib/R/site-library")
   ```

   and be sure it is writing to the path `/usr/local/lib/R/site-library`.

### Locally Install Libraries

Although it should be noted that users can install their own R packages under
the `R_LIBS_USER` directory specified in the module file.

1. Load any one of the corresponding module files and launch R:

   ```console
   $ module load rstudio_singularity/x.y.z
   $ R
   ```
2. Install requested packages:

   ```R
   install.packages("my_package")
   ```
