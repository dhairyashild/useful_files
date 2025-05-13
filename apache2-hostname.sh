#!/bin/bash

sudo apt-get update -y

sudo apt-get install apache2 -y

sudo systemctl enable apache2

sudo echo "this is my hostname = $(hostname)"





