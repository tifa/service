#!/bin/sh

apk add --no-cache inotify-tools jq

BASE_DIR=${1}
CERT_RESOLVER=${2}
FILE=${BASE_DIR}/acme.json

update()
{
    local date=$(date);

    jq -c ".${CERT_RESOLVER}.Certificates[] | {domain: .domain.main, certificate: .certificate, key: .key}" ${FILE} | while read -r cert; do
        local domain=$(echo ${cert} | jq -r .domain)
        mkdir -p ${BASE_DIR}/${domain}

        local certificate=$(echo ${cert} | jq -r .certificate)
        echo ${certificate} | base64 -d > ${BASE_DIR}/${domain}/fullchain.pem
        if [ $? -ne 0 ]; then
            echo "${date}: Error decoding and writing certificate for ${domain}"
        else
            echo "${date}: Certificate for ${domain} updated: ${BASE_DIR}/${domain}/fullchain.pem"
        fi

        key=$(echo $cert | jq -r .key)
        echo ${key} | base64 -d > ${BASE_DIR}/${domain}/privkey.pem
        if [ $? -ne 0 ]; then
            echo "${date}: Error decoding and writing key for ${domain}"
        else
            echo "${date}: Key for ${domain} updated: ${BASE_DIR}/${domain}/privkey.pem"
        fi
    done
}

update
while inotifywait -e modify ${FILE}; do
    update
done
