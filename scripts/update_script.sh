#!/bin/bash

sudo apt-get update && sudo apt-get upgrade >> /var/log/update_script.log
sudo echo --------------------"$(date) $line"--- >> /var/log/update_script.log
