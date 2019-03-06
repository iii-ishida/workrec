#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

echo $FIREBASE_SERVICE_ACCOUNT_KEY | base64 --decode > $BASEDIR/web/serviceAccountKey.json
