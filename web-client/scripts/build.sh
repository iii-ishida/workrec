#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

rm -rf $BASEDIR/server/dist &&
cd $BASEDIR/workrec &&
cat $BASEDIR/workrec/src/env.js > /tmp/env.js &&
sed -i "s|__API_ORIGIN__|${API_ORIGIN}|" $BASEDIR/workrec/src/env.js &&
trap "cat /tmp/env.js > $BASEDIR/workrec/src/env.js && rm /tmp/env.js" 0 1 2 3 15 &&
yarn install && yarn build &&
cp -r $BASEDIR/workrec/build $BASEDIR/server/dist
