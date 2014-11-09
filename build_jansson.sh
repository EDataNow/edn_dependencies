#!/bin/bash

source build-util.sh

PRODUCT=jansson-2.7

build_jansson_static_archive() {
  OUTPUT=$1
  TARGET=$2
  PLATFORM=$3

  build_static_archive $OUTPUT $TARGET $PLATFORM src/.libs/*.o
}

assemble_jansson_static_framework() {
  ensure_dir_exists $FRAMEWORKS_DIR/jansson.framework/Headers
  cp $BUILD_DIR/$PRODUCT/src/jansson.h $FRAMEWORKS_DIR/jansson.framework/Headers/
  cp $BUILD_DIR/$PRODUCT/src/jansson_config.h $FRAMEWORKS_DIR/jansson.framework/Headers/

  cp $ARCHS_DIR/libjansson/libjansson.a $FRAMEWORKS_DIR/jansson.framework/jansson

  cp $PLIST_DIR/jansson-staticFramework-Info.plist $FRAMEWORKS_DIR/jansson.framework/
}

ensure_downloaded "http://www.digip.org/jansson/releases/$PRODUCT.tar.gz" $PRODUCT.tar.gz

clear_build_dir $PRODUCT
extract_tgz $PRODUCT.tar.gz

cd "$BUILD_DIR/$PRODUCT"

build_jansson_static_archive libjansson x86_64 iPhoneSimulator

make distclean
build_jansson_static_archive libjansson armv7 iPhoneOS

make distclean
build_jansson_static_archive libjansson armv7s iPhoneOS

make distclean
build_jansson_static_archive libjansson arm64 iPhoneOS

build_jansson_static_archive libjansson

cd $RUN_DIR

assemble_static_archives libjansson
assemble_jansson_static_framework
