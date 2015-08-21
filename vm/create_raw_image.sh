#!/bin/bash

IMGNAME="ubuntu.img"
IMGFMT="raw"
IMGSIZE="8G"
qemu-img create -f $IMGFMT $IMGNAME $IMGSIZE
