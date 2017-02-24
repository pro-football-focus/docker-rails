#!/bin/bash
cd ../
VERSION=$(cat version)
docker build -t profootballfocus/rails:$VERSION .