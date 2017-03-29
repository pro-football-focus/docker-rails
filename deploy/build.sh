#!/bin/bash
cd ../
VERSION=$(cat version)
docker build -t profootballfocus/ruby_run:$VERSION .
