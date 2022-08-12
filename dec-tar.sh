#!/bin/bash -eu

export MSYS_NO_PATHCONV=1

target="$(realpath "$1")"
dest="$(realpath "$2")"
itr_cnt="${3:-20000}"

target_dir="${target%/*}"
target_file="${target##*/}"
target_base="${target_file%.*}"

docker run --rm -it -v "${target_dir}:/src:ro" -v "${dest}:/dest" backup dec-tar "/src/${target_file}" "/dest/${target_base}.tar" "${itr_cnt}"
