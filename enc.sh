#!/bin/bash -eux

export MSYS_NO_PATHCONV=1

target="$(realpath "$1")"

now=$(date --utc +"%Y%m%d_%H%M%S")
docker run --rm -it -v "${target}:/src:ro" -v "$(pwd)/dest:/dest" backup enc /src "/dest/${now}.dat"
