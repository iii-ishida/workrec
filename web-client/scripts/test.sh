#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)
cd $BASEDIR && yarn lint && yarn test
