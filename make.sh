#!/bin/sh 

# External tooling
export MAKE_FMWK=external/make-fmwk/make-fmwk.sh
export CURL_BUILD=external/curl-ios-build-scripts/build_curl

# Where to put things
export DOWNLOAD_DIR=downloads

# Dev environment stuff
export SDK=8.1
export XCODE=/Applications/Xcode.app/Contents

# Utility functions...

# Remove all download files from download dir
clear_downloads()
{
  rm -f $DOWNLOAD_DIR/*
}

# download URL FILENAME
# ie. download "http://www.digip.org/jansson/releases/jansson-2.7.tar.gz" jansson-2.7.tar.gz
# ie. download "https://googlemock.googlecode.com/files/gmock-1.7.0.zip" gmock-1.7.0.zip
download()
{
    URL=$1
    FILENAME=$2
    CWD=`pwd`
    cd $DOWNLOAD_DIR && curl -o $FILENAME "$1"
    cd $CWD
}

# Set up build tooling for specified target & platform
# setup_commands {armv7|armv7s|arm64|i386|x86_64} {iPhoneOS|iPhoneSimulator}
# ie. setup_commands arm64 iPhoneOS
# ie. setup_commands x86_64 iPhoneSimulator
setup_commands()
{
    TARGET=$1
    PLATFORM=$2

    XCRUN_SDK=$(echo ${PLATFORM} | tr '[:upper:]' '[:lower:]')

    export CC="$(xcrun -sdk ${XCRUN_SDK} -find gcc)"
    export CXX="$(xcrun -sdk ${XCRUN_SDK} -find g++)"
    export LD="$(xcrun -sdk ${XCRUN_SDK} -find ld)"
    export AR="$(xcrun -sdk ${XCRUN_SDK} -find ar)"
    export RANLIB="$(xcrun -sdk ${XCRUN_SDK} -find ranlib)"
}

# Set up CFLAGS for build tooling
# setup_cflags {armv7|armv7s|arm64|i386|x86_64} {iPhoneOS|iPhoneSimulator}
setup_cflags()
{
    TARGET=$1
    PLATFORM=$2

    export CFLAGS="-arch ${TARGET} -isysroot ${XCODE}/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK}.sdk -miphoneos-version-min=8.0"
}

# Run the ./configure script in the current source
# run_configure {armv7|armv7s|arm64|i386|x86_64} {any configure options required}
run_configure()
{
    TARGET=$1
    CONFIG_OPTS=$*

    if [ $TARGET == "arm64" ]; then
      export HOST_TARGET=aarch64
    else
      export HOST_TARGET=$TARGET
    fi

    ./configure ${CONFIG_OPTS} --host=${HOST_TARGET}-apple-darwin
}

# Build the binary for the current directory
# build_binary {armv7|armv7s|arm64|i386|x86_64} {iPhoneOS|iPhoneSimulator} {any configure options required}
build_binary()
{
    TARGET=$1
    PLATFORM=$2
    shift
    shift
    CONFIG_OPTS=$*

    setup_commands $TARGET $PLATFORM
    setup_cflags $TARGET $PLATFORM

    run_configure $TARGET $CONFIG_OPTS

    make clean
    make
}

# Specifics for building out gmock
build_gmock()
{
  # GMock

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
}

# Specifics for building out jansson
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
