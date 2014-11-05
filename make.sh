#!/bin/sh 

export DOWNLOAD_DIR=downloads

export SDK=8.1
export XCODE=/Applications/Xcode.app/Contents

clear_downloads()
{
  rm -f $DOWNLOAD_DIR/*
}

download()
{
    URL=$1
    FILENAME=$2
    CWD=`pwd`
    cd $DOWNLOAD_DIR && curl -o $FILENAME "$1"
    cd $CWD
}

clear_downloads
download "http://www.digip.org/jansson/releases/jansson-2.7.tar.gz" jansson-2.7.tar.gz
download "https://googlemock.googlecode.com/files/gmock-1.7.0.zip" gmock-1.7.0.zip
exit 1

buildit()
{
    TARGET=$1
    PLATFORM=$2
    shift
    shift
    config_opts=$*

    XCRUN_SDK=$(echo ${PLATFORM} | tr '[:upper:]' '[:lower:]')

    export CC="$(xcrun -sdk ${XCRUN_SDK} -find gcc)"
    export CXX="$(xcrun -sdk ${XCRUN_SDK} -find g++)"
    export LD="$(xcrun -sdk ${XCRUN_SDK} -find ld)"
    export AR="$(xcrun -sdk ${XCRUN_SDK} -find ar)"
    export RANLIB="$(xcrun -sdk ${XCRUN_SDK} -find ranlib)"

    export CFLAGS="-arch ${TARGET} -isysroot ${XCODE}/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK}.sdk -miphoneos-version-min=8.0"

    if [ $TARGET == "arm64" ]; then
      export HOST_TARGET=aarch64
    else
      export HOST_TARGET=$TARGET
    fi

    ./configure ${config_opts} --host=${HOST_TARGET}-apple-darwin

    make clean
    make
}

build_gmock()
{
  # GMock

  PRODUCT=gmock-1.6.0
  copts=""

  rm -rf $PRODUCT
  unzip ${PRODUCT}.zip

  cd $PRODUCT

  buildit i386 iPhoneSimulator $copts

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
}

build_jansson()
{
  # BUILD JANSSON

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
}

build_jansson
