#!/bin/sh
echo "Starting Nextcloud AI Worker $1"
cd /var/www/nextcloud
sudo -u www-data php occ background-job:worker -t 30 'OC\TaskProcessing\SynchronousBackgroundJob'
