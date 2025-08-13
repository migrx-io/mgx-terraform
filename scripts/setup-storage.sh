#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

MGX_VAR_DIR=/var/lib/migrx

# 1. install mgx-core and etc
sh ./mgx-bootstrap-deb.sh

# 2. Generate mgx-id and mgx-hosts
# if [ ! -f ${MGX_VAR_DIR}/mgx-id ]; then                                         
#     uuidgen > ${MGX_VAR_DIR}/mgx-id                                             
# fi                                                                              
# set all hosts for pool
# echo "" >> ${MGX_VAR_DIR}/mgx-hosts


# 1. Copy and modify env files

echo "Storage OK!"
