#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

rm -rf $BASEDIR/server/dist &&
cd $BASEDIR/app &&
echo $FIREBASE_CONFIG | base64 --decode > $BASEDIR/app/src/firebase-config.js &&
yarn install && REACT_APP_API_ORIGIN=${API_ORIGIN} yarn build &&
cp -r $BASEDIR/app/build $BASEDIR/server/dist
