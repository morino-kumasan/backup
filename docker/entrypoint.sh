#!/bin/bash -eu
set -o pipefail

usage() {
  cat <<_EOF_
encode/decode data

Usage:
  $0 [-i iter_count] [-h] {command} {source} {destination}

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
cmd="$1"
src="$2"
dest="$3"

# input pass
read -s -p "Enter password: " pass
echo "${pass}" > /tmp/pass
echo ""

# remove pass
trap "rm -f /tmp/pass" exit

if [[ "${cmd}" == "enc" ]]; then

  # verify pass
  read -s -p "Verify password: " pass
  echo ""

  if [[ "${pass}" != "$(cat /tmp/pass)" ]]; then
    echo "Error: password not match" 1>&2
    exit 1
  fi

  # encrypt and tar
  cd "${src}"

  tar cf - . | \
    pv -s "$(du -sb . | awk '{print $1}')" | \
    openssl enc -e -aes-256-cbc -iter "${itr_cnt}" -pbkdf2 -pass "file:/tmp/pass" -out "${dest}"

elif [[ "${cmd}" == "dec" ]]; then

  # decrypt and tar
  openssl enc -d -aes-256-cbc -iter "${itr_cnt}" -pbkdf2 -pass "file:/tmp/pass" -in "${src}" | \
    pv -s "$(stat --print="%s" "${src}")" | \
    tar xf - -C "${dest}"

elif [[ "${cmd}" == "dec-tar" ]]; then

  # decrypt
  openssl enc -d -aes-256-cbc -iter "${itr_cnt}" -pbkdf2 -pass "file:/tmp/pass" -in "${src}" | \
    pv -s "$(stat --print="%s" "${src}")" > ${dest}

else

  usage

fi
