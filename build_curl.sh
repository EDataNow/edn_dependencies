#!/bin/bash

source build-util.sh

$RUN_DIR/external/curl-ios-build-scripts/build_curl --archs armv7,armv7s,arm64,x86_64 --result-dir $ARCH_DIR/curl
