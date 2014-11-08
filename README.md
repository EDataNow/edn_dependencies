EDN Build System
================

You will find current builds of frameworks in the frameworks/ dir. Talk
to your peers to determine when they were built and to ensure they're
always kept up to date.

Building frameworks is touchy work, so when you sit down to do this
expect problems. The team should be able to continue using the pre-built
frameworks until you work those problems out.

For the convenience of the framework builder, you can source the
build-util package into your bash shell, and use lower-level commands
directly to discover where problems lie. This ensures that your
environment is correctly set up to trigger the correct command-line
toolchain etc.

ONLY SOURCE THE build-util.sh FILE FROM THE ROOT OF THIS PROJECT. If you
source it from somewhere else on your hard drive, things WILL fail.

Quick Ref
---------

./build_jansson.sh
./build_gmock.sh

Directory Structure
-------------------

downloads/

Downloaded archives are placed in downloads/ - this dir is ignored by
git. Each package should know how to get its archive off the Internet.

build/
      (product)

Individual packages are unpacked and built here.

build/
      archs

Various architectures for each product are assembled here.

external/

External build tooling is referenced here. There is also right now a
copy of the Jansson repository in the EDN github account. One day, when
we're cool, it might be nice to use this for Jansson builds instead of
raw source downloads from their site. It will give us more control, if
we desire that one day, when we're cool enough to handle it.

Beware of Wizards
-----------------

For you are crunchy and go well with ketchup. If you don't get this,
find yourself an old neckbeard and ask about it. If you don't know what
that means, kindly move along, you may be soggy and hard to light.

OK, now that we're alone let's get to it. Calling the functions in
build-utils.sh can be tricky.

. build-utils.sh

Step 1, get the functions into your current bash session.

setup_commands arm64 iPhoneOS

Currently we don't use the target architecture argument, but we might
one day. This will set up your CC, CXX, LD, AR and RANLIB environment
variables so that ./configure can find them correctly.

setup_cflags arm64 iPhoneOS

Similarly, this will set up CFLAGS for you.

run_configure arm64

This will run configure for that architecture. There is logic here to
handle --host correctly (ie. arm64 is aarch64).

Lower level
- setup_commands, setup_cflags, run_configure, etc

Higher level
- build_binary, build_static_archive

You will tend to find specialist functions for build_static_archive in
each product's own build script, they should/will tend to delegate to
the central function.

As you can see, we're trying to focus responsibility around different
stages of the tooling. You should find most logic localized that way.

Many of the rest of the functions are in flux, but you will find many
handy things if you look through the utils script.

Other Handy functions:
- clear_build_dir
- clear_all
- ensure_dir_exists
- download {URL} {archive name}
- ensure_downloaded {URL} {archive name}

TODO:
-----

- set up build script for gtest framework
- set up a way to build a project (ie. jansson) from a submodule
