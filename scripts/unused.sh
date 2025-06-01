#!/bin/sh

set -e

DIR=`dirname $0`

flutter pub run daunused:daunused.dart ${DIR}/../example example/src/main.dart main,toJson