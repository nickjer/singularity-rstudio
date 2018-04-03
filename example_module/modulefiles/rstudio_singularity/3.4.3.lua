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
prepend_path("RSTUDIO_SINGULARITY_BINDPATH", library .. ":/library", ",")
setenv("RSTUDIO_SINGULARITY_IMAGE", img)
setenv("RSTUDIO_SINGULARITY_HOST_MNT", host_mnt)
setenv("RSTUDIO_SINGULARITY_CONTAIN", "1")
setenv("RSTUDIO_SINGULARITY_HOME", os.getenv("HOME") .. ":/home/" .. os.getenv("USER"))
setenv("R_LIBS_USER", pathJoin(host_mnt, user_library))

-- Note: Singularity on CentOS 6 fails to bind a directory to `/tmp` for some
-- reason. This is necessary for RStudio Server to work in a multi-user
-- environment. So to get around this we use a combination of:
--
--   - SINGULARITY_CONTAIN=1 (containerize /home, /tmp, and /var/tmp)
--   - SINGULARITY_HOME=$HOME (set back the home directory)
--   - SINGUARLITY_WORKDIR=$(mktemp -d) (bind a temp directory for /tmp and /var/tmp)
--
-- The last one is called from within the executable scripts found under `bin/`
-- as it makes the temp directory at runtime.
--
-- If your system does successfully bind a directory over `/tmp`, then you can
-- probably get away with just:
--
--   - SINGULARITY_BINDPATH=$(mktemp -d):/tmp,$SINGULARITY_BINDPATH
