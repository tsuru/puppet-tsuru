#!/bin/bash

if [ -z "$2" ]; then
    cat /etc/nginx/certs/nginx.$1
else
    header_key_cert=""
    footer_key_cert=""
    for line in $2; do
        if [[ $line =~ ^-----BEGIN$ ]]; then
            header_key_cert=true
            cert_line=$line
            continue
        fi
        if [[ $line =~ ^-----END$ ]]; then
            footer_key_cert=true
            cert_line=$line
            continue
        fi
        if [[ $line =~ -----$ ]]; then
            header_key_cert=""
            footer_key_cert=""
            cert_line="${cert_line} ${line}"
            echo $cert_line
            cert_line=""
            continue
        fi
        if [ "$header_key_cert" -o "$footer_key_cert" ]; then
            cert_line="${cert_line} ${line}"
            continue
        fi
        echo $line
    done
fi
exit 0
