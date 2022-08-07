#!/bin/bash -eu
set -o pipefail

cmd=$1
src=$2
dest=$3

read -s -p "Enter password: " pass
echo "${pass}" > /tmp/pass
echo ""
read -s -p "Verify password: " pass
echo ""

if [[ "${pass}" != "$(cat /tmp/pass)" ]]; then
  echo "Error: password not match" 1>&2
  exit 1
fi

if [[ "${cmd}" == "enc" ]]; then

  cd "${src}"

  tar cf - . | \
    pv -s "$(du -sb . | awk '{print $1}')" | \
    openssl enc -e -aes-256-cbc -iter 20000 -pbkdf2 -pass "file:/tmp/pass" -out "${dest}"

elif [[ "${cmd}" == "dec" ]]; then

  openssl enc -d -aes-256-cbc -iter 20000 -pbkdf2 -pass "file:/tmp/pass" -in "${src}" | \
    pv -s "$(stat --print="%s" "${src}")" | \
    tar xf - -C "${dest}"

else

  echo "Usaage: docker run --rm -v {source-mount} -v {destination-mount} backup {enc|dec} {source} {destination}" 1>&2

fi

rm -f /tmp/pass
