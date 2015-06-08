#!/bin/bash
DSTAMP=$(date --iso-8601)
wget --no-check-certificate -o download-${DSTAMP}.log -O ubuntu.img https://craft.homeip.net:5001/fbsharing/6YU0ac3D


