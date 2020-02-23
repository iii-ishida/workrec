#! /bin/sh
ls -d ./**/*.swift | grep -v /apollogen/ | xargs swift-format -m lint
