#!/bin/bash -eu

export MSYS_NO_PATHCONV=1

usage() {
  cat <<_EOF_
encode and compress data

Usage:
  $0 [-i iter_count] [-h] {source dir} {destination dir}

Options:
  -i  iter count
  -h  help
_EOF_
  exit 1
}

# defaults
itr_cnt=20000

# options
while getopts i:h OPT; do
  case ${OPT} in
  i)
    itr_cnt=${OPTARG}
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
if [[ ! -d "${target}" ]]; then
  echo "Not Directory: $1" >&2
  exit 1
fi

if [[ ! -d "${dest}" ]]; then
  echo "Not Directory: $2" >&2
  exit 1
fi

# run docker
now=$(date --utc +"%Y%m%d_%H%M%S")

docker run --rm -it \
    -v "${target}:/src:ro" \
    -v "${dest}:/dest" \
    backup \
    enc -i "${itr_cnt}" -- /src "/dest/${now}.dat"
