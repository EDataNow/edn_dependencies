#!/bin/bash

source build-util.sh

assemble_curl_static_framework() {
  ensure_dir_exists $FRAMEWORKS_DIR/curl.framework/Headers

  cp $ARCHS_DIR/curl/ios-appstore/lib/libcurl.a $FRAMEWORKS_DIR/curl.framework/libcurl
  cp $ARCHS_DIR/curl/ios-appstore/include/* $FRAMEWORKS_DIR/curl.framework/Headers

  cp $PLIST_DIR/curl-staticFramework-Info.plist $FRAMEWORKS_DIR/curl.framework/
}

# Bug in current curl-ios-build-scripts
# ensure_dir_exists $ARCHS_DIR/curl
ensure_dir_exists $ARCHS_DIR

$RUN_DIR/external/curl-ios-build-scripts/build_curl --archs armv7,armv7s,arm64,x86_64 --no-cleanup --work-dir $BUILD_DIR/curl --result-dir $ARCHS_DIR/curl

# Bug in current curl-ios-build-scripts, ignores --work-dir and --result-dir directives
mv $RUN_DIR/curl $ARCHS_DIR

assemble_curl_static_framework


