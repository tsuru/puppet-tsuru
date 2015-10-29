#!/bin/bash

if [ -z $2 ]; then
    cat /etc/nginx/certs/nginx.$1
else
    echo $2
fi
exit 0
