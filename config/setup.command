#!/bin/bash
cd `dirname $0`

if [ ! -f "config.yml" ]
then
    cp config.yml.example config.yml
fi
ruby setup.rb
kill -9 $PPID
exit 0
