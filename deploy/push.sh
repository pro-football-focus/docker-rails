#!/bin/bash
cd ../
VERSION=$(cat version)
docker push profootballfocus/rails:$VERSION