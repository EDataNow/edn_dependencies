# External tooling
export MAKE_FMWK=external/make-fmwk/make-fmwk.sh
export CURL_BUILD=external/curl-ios-build-scripts/build_curl

# Where to put things
export DOWNLOAD_DIR=downloads
export BUILD_DIR=build
export FRAMEWORKS_DIR=frameworks
export PLIST_DIR=plist_files

# Dev environment stuff
export SDK=8.1
export XCODE=/Applications/Xcode.app/Contents

export RUN_DIR=`pwd`
export LOGFILE=$RUN_DIR/build_output.log
export ERRFILE=$RUN_DIR/build_error.log


# Utility functions...

ensure_dir_exists() {
  DIR=$1
  if [ ! -d "$DIR" ]; then
    mkdir $DIR
  fi
}

clear_build_dir() {
  DIR=$1
  if [ -d "$BUILD_DIR/$DIR" ]; then
    rm -rf "$BUILD_DIR/$DIR"
  fi
}

clear_log_files() {
  if [ -e "$LOGFILE" ]; then
    rm -rf $LOGFILE
  fi
  if [ -e "$ERRFILE" ]; then
    rm -rf $ERRFILE
  fi
}

# Remove all download files from download dir
clear_downloads() {
  ensure_dir_exists $DOWNLOAD_DIR
  rm -f $DOWNLOAD_DIR/*
}

clear_all() {
  clear_downloads
  clear_log_files
  clear_build_dir
}

# download URL FILENAME
# ie. download "http://www.digip.org/jansson/releases/jansson-2.7.tar.gz" jansson-2.7.tar.gz
# ie. download "https://googlemock.googlecode.com/files/gmock-1.7.0.zip" gmock-1.7.0.zip
download()
{
    URL=$1
    FILENAME=$2

    ensure_dir_exists $DOWNLOAD_DIR

    cd $DOWNLOAD_DIR && curl -o $FILENAME "$1" >>$LOGFILE 2>>$ERRFILE
    cd $RUN_DIR
}

# ensure_downloaded URL FILENAME
ensure_downloaded()
{
  URL=$1
  FILENAME=$2

  ensure_dir_exists $DOWNLOAD_DIR

  if [ ! -e "$DOWNLOAD_DIR/$FILENAME" ]; then
    download $URL $FILENAME
  fi
}

# extract archive in downloads into appropriate build dir
# ie. extract_tgz jansson-2.7.tar.gz
extract_tgz()
{
    FILENAME=$1

    ensure_dir_exists $BUILD_DIR

    ARCHIVE="$RUN_DIR/$DOWNLOAD_DIR/$FILENAME"
    if [ -e "$ARCHIVE" ]; then
      cd $BUILD_DIR && tar -xzvf "$ARCHIVE" >>$LOGFILE 2>>$ERRFILE
      cd $RUN_DIR
    else
      echo "$ARCHIVE does not exist to extract."
    fi
}

# extract archive in downloads into appropriate build dir
# ie. extract_zip gmock-1.7.0.zip
extract_zip()
{
    FILENAME=$1

    ensure_dir_exists $BUILD_DIR

    ARCHIVE="$RUN_DIR/$DOWNLOAD_DIR/$FILENAME"
    if [ -e "$ARCHIVE" ]; then
      cd $BUILD_DIR && unzip -x "$ARCHIVE" >>$LOGFILE 2>>$ERRFILE
      cd $RUN_DIR
    else
      echo "$ARCHIVE does not exist to extract."
    fi
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
    shift
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

    echo "Using:"
    echo $CC
    echo $CXX
    echo $LD
    echo $AR
    echo $RANLIB

    echo "CFLAGS:"
    echo $CFLAGS

    run_configure $TARGET $CONFIG_OPTS

    make clean
    make
}
