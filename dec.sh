#!/bin/bash -eux

export MSYS_NO_PATHCONV=1

target="$(realpath "$1")"
dest="$(realpath "$2")"

target_dir="${target%/*}"
target_file="${target##*/}"
target_base="${target_file%.*}"

docker run --rm -it -v "${target_dir}:/src:ro" -v "${dest%/}/${target_base}:/dest" backup dec "/src/${target_file}" /dest
