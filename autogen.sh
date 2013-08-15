#!/bin/bash

# create structure
aclocal
autoconf
automake --add-missing

# rename files
mv cgi/index.cgi cgi/index.cgi.in
mv etc/monitoring-ui.yml etc/monitoring-ui.yml.in
mv sample-config/httpd.conf sample-config/httpd.conf.in

exit 0
