#!/bin/bash -eu
set -o pipefail

cmd="$1"
src="$2"
dest="$3"
itr_cnt="${4:-20000}"

# input pass
read -s -p "Enter password: " pass
echo "${pass}" > /tmp/pass
echo ""

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

else

  echo "Usaage: docker run --rm -v {source-mount} -v {destination-mount} backup {enc|dec} {source} {destination}" 1>&2

fi

# remove pass
rm -f /tmp/pass
