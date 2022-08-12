#!/bin/bash -eu

export MSYS_NO_PATHCONV=1

usage() {
  cat <<_EOF_
decode and decompress data

Usage:
  $0 [-i iter_count] [-d] [-h] {source file} {destination dir}

Options:
  -i  iter count
  -d  decompress
  -h  help
_EOF_
  exit 1
}

# defaults
itr_cnt=20000
opt_decompress=0

# options
while getopts i:dh OPT; do
  case ${OPT} in
  i)
    itr_cnt=${OPTARG}
    ;;
  d)
    opt_decompress=1
    ;;
  h)
    usage
    ;;
  esac
done

shift $((OPTIND - 1))

# positional args
target="$(realpath "$1")"
dest="$(realpath "$2")"

# check args
if [[ ! -f "${target}" ]]; then
  echo "Not File: $1" >&2
  exit 1
fi

if [[ ! -d "${dest}" ]]; then
  echo "Not Directory: $2" >&2
  exit 1
fi

# run docker
target_dir="${target%/*}"
target_file="${target##*/}"
target_base="${target_file%.*}"

if [[ "${opt_decompress}" == "1" ]]; then

docker run --rm -it \
    -v "${target_dir}:/src:ro" \
    -v "${dest%/}/${target_base}:/dest" \
    backup \
        -i "${itr_cnt}" \
        -- dec "/src/${target_file}" /dest

else

docker run --rm -it \
    -v "${target_dir}:/src:ro" \
    -v "${dest}:/dest" \
    backup \
        -i "${itr_cnt}" \
        -- dec-tar "/src/${target_file}" "/dest/${target_base}.tar"

fi
