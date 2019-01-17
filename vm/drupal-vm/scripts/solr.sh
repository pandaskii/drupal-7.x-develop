#!/usr/bin/env bash

SOLR_CORE_NAME="govcms"
SOLR_SETUP_COMPLETE_FILE="/etc/drupal_vm_solr_config_complete_$SOLR_CORE_NAME"

# Search API Solr module.
SOLR_DOWNLOAD="https://ftp.drupal.org/files/projects/search_api_solr-7.x-1.14.tar.gz"
SOLR_DOWNLOAD_DIR="/tmp"
SOLR_MODULE_NAME="search_api_solr"
SOLR_VERSION="6.x"
SOLR_CORE_PATH="/var/solr/data/collection1"

# Check to see if we've already performed this setup.
if [ ! -e "$SOLR_SETUP_COMPLETE_FILE" ]; then
  # Download and expand the Solr module.
  wget -qO- $SOLR_DOWNLOAD | tar xvz -C $SOLR_DOWNLOAD_DIR

  # Copy new Solr collection core with the Solr configuration provided by module.
  sudo cp -a $SOLR_DOWNLOAD_DIR/$SOLR_MODULE_NAME/solr-conf/$SOLR_VERSION/. $SOLR_CORE_PATH/conf/

  # Adjust the autoCommit time so index changes are committed in 1s.
  sudo sed -i 's/\(<maxTime>\)\([^<]*\)\(<[^>]*\)/\11000\3/g' $SOLR_CORE_PATH/conf/solrconfig.xml

  # Fix file permissions.
  sudo chown -R solr:solr $SOLR_CORE_PATH/conf

  # Fix service for old Solr.
  sudo rm /etc/systemd/system/solr.service

  # Reload the system daemon.
  sudo systemctl daemon-reload

  # Restart Apache Solr.
  sudo service solr restart

  # Create a file to indicate this script has already run.
  sudo touch $SOLR_SETUP_COMPLETE_FILE
else
  exit 0
fi
