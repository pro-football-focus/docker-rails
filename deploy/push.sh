#!/bin/bash
cd ../

VERSION=$(cat version)
docker push profootballfocus/ruby_run:$VERSION