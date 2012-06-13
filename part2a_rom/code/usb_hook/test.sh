#!/bin/sh

TARGET="$1" LD_PRELOAD="./usb-hook.so" ./ssticrypt -d fd4185ff66a94afda1a2a3a4a5a6a7a8 secret
