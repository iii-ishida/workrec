#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

cd $BASEDIR &&
echo $FIREBASE_CONFIG | base64 --decode > $BASEDIR/src/firebase-config.ts &&
yarn install && REACT_APP_API_ORIGIN=${API_ORIGIN} yarn build
