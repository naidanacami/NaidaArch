#!/bin/bash
name=( $(whoami) )
hostname=( $(cat /etc/hostname) )
echo "$name@$hostname"
