#!/bin/bash

if [ -f /etc/nginx/sites-enabled/consul/locations.conf ]; then
    cat /etc/nginx/sites-enabled/consul/locations.conf
fi

exit 0
