#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

rm -rf $BASEDIR/server/dist &&
cd $BASEDIR/workrec &&
yarn install && yarn build &&
cp -r $BASEDIR/workrec/build $BASEDIR/server/dist
