@echo off
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
git config --global http.postBuffer 5242880000
git config --global https.postBuffer 5242880000