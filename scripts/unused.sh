#!/bin/sh

set -e

DIR=`dirname $0`

flutter pub pub run daunused:daunused.dart ${DIR}/../example example/src/main2.dart