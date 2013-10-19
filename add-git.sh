#!/bin/bash
EMAIL=$1
mkdir ~/.ssh
cd ~/.ssh
ssh-keygen -t rsa -C  "$EMAIL"
ssh-add id_rsa

xclip -sel clip < ~/.ssh/id_rsa.pub
x-www-browser https://github.com/settings/ssh
