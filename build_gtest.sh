#!/bin/bash

source build-util.sh

PRODUCT=gtest-1.7.0

build_gtest_static_archive() {
  OUTPUT=$1
  TARGET=$2
  PLATFORM=$3

  build_binary $TARGET $PLATFORM
  ensure_dir_exists "$ARCHS_DIR/$OUTPUT"

  cp lib/.libs/libgtest.a ${ARCHS_DIR}/${OUTPUT}/${OUTPUT}.a
  cp lib/.libs/libgtest_main.a ${ARCHS_DIR}/${OUTPUT}/${OUTPUT}_main.a
}

assemble_gtest_static_framework() {
  ensure_dir_exists $FRAMEWORKS_DIR/gtest.framework/Headers/internal
  cp $BUILD_DIR/$PRODUCT/include/gtest/*.h $FRAMEWORKS_DIR/gtest.framework/Headers/
  cp $BUILD_DIR/$PRODUCT/include/gtest/*.pump $FRAMEWORKS_DIR/gtest.framework/Headers/
  cp $BUILD_DIR/$PRODUCT/include/gtest/internal/*.h $FRAMEWORKS_DIR/gtest.framework/Headers/internal/
  cp $BUILD_DIR/$PRODUCT/include/gtest/internal/*.pump $FRAMEWORKS_DIR/gtest.framework/Headers/internal/

  cp ${ARCHS_DIR}/${OUTPUT}/libgtest.a $FRAMEWORKS_DIR/gtest.framework/gtest

  cp $PLIST_DIR/gtest-staticFramework-Info.plist $FRAMEWORKS_DIR/gtest.framework/
}

ensure_downloaded "https://googletest.googlecode.com/files/${PRODUCT}.zip" $PRODUCT.zip

clear_build_dir $PRODUCT
extract_zip $PRODUCT.zip

cd "$BUILD_DIR/$PRODUCT"

build_gtest_static_archive libgtest x86_64 iPhoneSimulator

cd $RUN_DIR

assemble_gtest_static_framework
