#!/bin/bash

if [[ "$@" == *"devices"* ]]; then
    /Users/nightmare/Library/Android/sdk/platform-tools/adb $@
    exit 0
fi

echo "please input verify password"
read password
# if $@ containes "devices" then do not verify password

if [ "$password" == "adb369875" ]; then
    /Users/nightmare/Library/Android/sdk/platform-tools/adb $@
else
    echo "verify failed!"
fi
