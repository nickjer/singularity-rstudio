help([[
This module loads the RStudio Server environment which utilizes a Singularity
image for portability.
]])

whatis([[Description: RStudio Server environment using Singularity]])

local root = "/path/to/this/example_module"
local bin = pathJoin(root, "/bin")
local img = pathJoin(root, "/3.4.3/singularity-rstudio.simg")
local library = pathJoin(root, "/library-3.4")
local host_mnt = "/mnt"

local user_library = os.getenv("HOME") .. "/R/library-3.4"

prereq("singularity")
prepend_path("PATH", bin)
prepend_path("RSTUDIO_SINGULARITY_BINDPATH", "/:" .. host_mnt, ",")
prepend_path("RSTUDIO_SINGULARITY_BINDPATH", library .. ":/usr/local/lib/R/site-library", ",")
setenv("RSTUDIO_SINGULARITY_IMAGE", img)
setenv("RSTUDIO_SINGULARITY_HOST_MNT", host_mnt)
setenv("RSTUDIO_SINGULARITY_CONTAIN", "1")
setenv("RSTUDIO_SINGULARITY_HOME", os.getenv("HOME"))
setenv("R_LIBS_USER", pathJoin(host_mnt, user_library))
