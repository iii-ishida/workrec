#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)
cd $BASEDIR/workrec && yarn test
