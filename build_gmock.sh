#!/bin/sh 

source build-util.sh

PRODUCT=gmock-1.7.0
copts=""

rm -rf $PRODUCT
unzip ${PRODUCT}.zip

cd $PRODUCT

buildit x86_64 iPhoneSimulator $copts

cd ..

mkdir -p gmock.framework/Headers/gmock/internal
cp $PRODUCT/include/gmock/gmock.h gmock.framework/Headers/gmock.h
cp $PRODUCT/include/gmock/*.h gmock.framework/Headers/gmock/
cp $PRODUCT/include/gmock/*.pump gmock.framework/Headers/gmock/
cp $PRODUCT/include/gmock/internal/*.h gmock.framework/Headers/gmock/internal/
cp $PRODUCT/include/gmock/internal/*.pump gmock.framework/Headers/gmock/internal/
cp $PRODUCT/lib/.libs/libgmock.a gmock.framework/libgmock.a
cp $PRODUCT/lib/.libs/libgmock_main.a gmock.framework/libgmock_main.a
cp gmock-staticFramework-Info.plist gmock.framework/
