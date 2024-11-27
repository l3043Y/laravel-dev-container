#!/bin/bash

sed -i '/listen \[::\]:8080 default_server;/s/^/# /' /etc/nginx/site-opts.d/http.conf
sed -i '/listen \[::\]:8443 ssl default_server;/s/^/# /' /etc/nginx/site-opts.d/https.conf
