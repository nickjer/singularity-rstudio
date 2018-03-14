#!/usr/bin/env bash

export SINGULARITY_IMAGE="${SINGULARITY_IMAGE:-singularity-rstudio.simg}"
echo "Using Singularity image: ${SINGULARITY_IMAGE}"

check_password () {
  echo "${2}" | \
    singularity exec rstudio_auth "${1}"
}

set -e
set -x

# Verify RStudio Server installation
singularity exec rserver --verify-installation=1 --www-address=0.0.0.0 --www-port=9898

# Verify default PAM auth helper script
export RSTUDIO_PASSWORD="password"
if ! check_password "${USER}" "${RSTUDIO_PASSWORD}"; then
  exit 1
fi
if check_password "bad_user" "${RSTUDIO_PASSWORD}"; then
  exit 1
fi
if check_password "${USER}" "bad_password"; then
  exit 1
fi

{ set +x; } 2>/dev/null
echo "All tests passed!"
