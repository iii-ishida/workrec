#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

cd $BASEDIR && go mod verify && go vet ./... && golint -set_exit_status ./... && go test ./...