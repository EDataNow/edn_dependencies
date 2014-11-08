#!/bin/bash

source build-util.sh

PRODUCT=gmock-1.7.0

build_gmock_static_archive() {
  OUTPUT=$1
  TARGET=$2
  PLATFORM=$3

  build_binary $TARGET $PLATFORM
  ensure_dir_exists "$ARCHS_DIR/$OUTPUT"

  cp lib/.libs/libgmock.a ${ARCHS_DIR}/${OUTPUT}/${OUTPUT}.a
  cp lib/.libs/libgmock_main.a ${ARCHS_DIR}/${OUTPUT}/${OUTPUT}_main.a
}

assemble_gmock_static_framework() {
  ensure_dir_exists gmock.framework/Headers/gmock/internal
  cp $BUILD_DIR/$PRODUCT/include/gmock/gmock.h $FRAMEWORKS_DIR/gmock.framework/Headers/gmock.h
  cp $BUILD_DIR/$PRODUCT/include/gmock/*.h $FRAMEWORKS_DIR/gmock.framework/Headers/gmock/
  cp $BUILD_DIR/$PRODUCT/include/gmock/*.pump $FRAMEWORKS_DIR/gmock.framework/Headers/gmock/
  cp $BUILD_DIR/$PRODUCT/include/gmock/internal/*.h $FRAMEWORKS_DIR/gmock.framework/Headers/gmock/internal/
  cp $BUILD_DIR/$PRODUCT/include/gmock/internal/*.pump $FRAMEWORKS_DIR/gmock.framework/Headers/gmock/internal/

  cp ${ARCHS_DIR}/${OUTPUT}/libgmock.a gmock.framework/libgmock

  cp $PLIST_DIR/gmock-staticFramework-Info.plist gmock.framework/
}

ensure_downloaded "https://googlemock.googlecode.com/files/${PRODUCT}.zip" $PRODUCT.zip

clear_build_dir $PRODUCT
extract_zip $PRODUCT.zip

cd "$BUILD_DIR/$PRODUCT"

build_gmock_static_archive libgmock x86_64 iPhoneSimulator

cd $RUN_DIR

assemble_gmock_static_framework
