#!/bin/sh

set -e

flutter format ./lib
flutter packages pub publish