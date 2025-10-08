#!/bin/bash

sudo apt-get update -y
sudo apt-get install docker.io -y
sudo usermod -aG docker ${USER}
newgrp docker
docker --version

git clone https://github.com/dhairyashild/java-source-code.git
cd java-source-code
docker build -t web .
docker run -d -p 80:8080 web 
