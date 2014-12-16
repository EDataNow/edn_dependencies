#!/bin/bash

source build-util.sh

assemble_curl_static_framework() {
  ensure_dir_exists $FRAMEWORKS_DIR/curl.framework/Headers

  lipo -create $ARCHS_DIR/curl/ios-dev/lib/libcurl.a $ARCHS_DIR/curl/osx/lib/libcurl.a -output $FRAMEWORKS_DIR/curl.framework/curl
  cp $ARCHS_DIR/curl/ios-dev/include/* $FRAMEWORKS_DIR/curl.framework/Headers

  cp $PLIST_DIR/curl-staticFramework-Info.plist $FRAMEWORKS_DIR/curl.framework/
}

# Bug in current curl-ios-build-scripts
ensure_dir_exists $ARCHS_DIR/curl
#ensure_dir_exists $ARCHS_DIR

$RUN_DIR/external/curl-ios-build-scripts/build_curl --archs i386,armv7,armv7s,arm64,x86_64 --no-cleanup --work-dir $BUILD_DIR/curl --result-dir $ARCHS_DIR/curl

# Bug in current curl-ios-build-scripts, ignores --work-dir and --result-dir directives
rm -rf $ARCHS_DIR/curl
mv $RUN_DIR/curl $ARCHS_DIR

assemble_curl_static_framework


