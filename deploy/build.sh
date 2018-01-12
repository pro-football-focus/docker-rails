#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

VERSION=$(cat version)

docker build -t profootballfocus/ruby_run:$VERSION .
