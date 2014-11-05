#!/bin/sh 

source util.sh


clear_downloads
download "https://googlemock.googlecode.com/files/gmock-1.7.0.zip" gmock-1.7.0.zip
extract_zip gmock-1.7.0.zip

download "http://www.digip.org/jansson/releases/jansson-2.7.tar.gz" jansson-2.7.tar.gz
extract_tgz jansson-2.7.tar.gz

exit 1

PRODUCT=jansson-2.7
copts=""

rm -rf $PRODUCT
tar -xzf ${PRODUCT}.tar.gz

cd $PRODUCT

buildit arm64 iPhoneOS $copts
$AR rv libjansson.arm64.a src/.libs/*.o

buildit armv7s iPhoneOS $copts
$AR rv libjansson.armv7s.a src/.libs/*.o

buildit armv7 iPhoneOS $copts
$AR rv libjansson.armv7.a src/.libs/*.o

buildit i386 iPhoneSimulator $copts
$AR rv libjansson.i386.a src/.libs/*.o

lipo -create libjansson.arm64.a libjansson.armv7s.a libjansson.armv7.a libjansson.i386.a -output libjansson.a

cd ..

# BUILD jansson.framework

mkdir -p jansson.framework/Headers
cp $PRODUCT/src/jansson.h jansson.framework/Headers/
cp $PRODUCT/src/jansson_config.h jansson.framework/Headers/
cp $PRODUCT/libjansson.a jansson.framework/jansson
cp jansson-staticFramework-Info.plist jansson.framework/

rm -rf $PRODUCT
