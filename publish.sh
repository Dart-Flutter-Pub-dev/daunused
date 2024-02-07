#!/bin/sh

set -e

dart format lib
flutter packages pub publish