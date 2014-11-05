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

echo "It isn't appropriate to run this script. Use a build script for the framework you want to build."
