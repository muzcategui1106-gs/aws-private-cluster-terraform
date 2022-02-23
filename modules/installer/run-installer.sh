#!/bin/bash

# cd to installation directory
cd $1

./opeshift-install create manifests --dir <installation_directory>
