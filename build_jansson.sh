#!/bin/bash

source build-util.sh

PRODUCT=jansson-2.7

ensure_downloaded "http://www.digip.org/jansson/releases/$PRODUCT.tar.gz" $PRODUCT.tar.gz

clean_build_dir $PRODUCT
extract_tgz $PRODUCT.tar.gz

cd "$BUILD_DIR/$PRODUCT"

build_binary x86_64 iPhoneSimulator
$AR rv libjansson.x86_64.a src/.libs/*.o

make distclean
build_binary armv7 iPhoneOS
$AR rv libjansson.armv7.a src/.libs/*.o

make distclean
build_binary armv7s iPhoneOS
$AR rv libjansson.armv7s.a src/.libs/*.o

make distclean
build_binary arm64 iPhoneOS
$AR rv libjansson.arm64.a src/.libs/*.o

lipo -create libjansson.arm64.a libjansson.armv7s.a libjansson.armv7.a libjansson.x86_64.a -output libjansson.a

cd $RUN_DIR

# BUILD jansson.framework

mkdir -p $FRAMEWORKS_DIR/jansson.framework/Headers
cp $BUILD_DIR/$PRODUCT/src/jansson.h $FRAMEWORKS_DIR/jansson.framework/Headers/
cp $BUILD_DIR/$PRODUCT/src/jansson_config.h $FRAMEWORKS_DIR/jansson.framework/Headers/
cp $BUILD_DIR/$PRODUCT/libjansson.a $FRAMEWORKS_DIR/jansson.framework/jansson
cp $PLIST_DIR/jansson-staticFramework-Info.plist $FRAMEWORKS_DIR/jansson.framework/

rm -rf $PRODUCT
