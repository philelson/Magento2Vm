#!/bin/bash
#
# Currently the service for this isn't working
#
chcon -R -t httpd_sys_rw_content_t /var/www/pegasus
setsebool httpd_can_network_connect=1