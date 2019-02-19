#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

rm -rf $BASEDIR/server/dist &&
cd $BASEDIR/app &&
cat $BASEDIR/app/src/env.js > /tmp/env.js &&
sed -i "s|__API_ORIGIN__|${API_ORIGIN}|" $BASEDIR/app/src/env.js &&
echo $FIREBASE_CONFIG | base64 --decode > $BASEDIR/app/src/firebase-config.js &&
trap "cat /tmp/env.js > $BASEDIR/app/src/env.js && rm /tmp/env.js" 0 1 2 3 15 &&
yarn install && yarn build &&
cp -r $BASEDIR/app/build $BASEDIR/server/dist
