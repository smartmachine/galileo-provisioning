#!/bin/bash
## WARNING, only tested on MAC
rm -f preseed/preseed.txt
rm -f TFTP/Ubuntu12.04/boot-screens/preseed.cfg
rm -f templates/post_provision.sh
rm -rf ~/.vagrant.d
rm -rf ~/Sites/*
rm -rf dist
