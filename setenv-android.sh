#!/bin/bash

# ====================================================================
# Sets the cross compile environment for Android
# Based upon OpenSSL's setenv-android.sh (by TH, JW, and SM).
#
# Crypto++ Library is copyrighted as a compilation and (as of version 5.6.2)
# licensed under the Boost Software License 1.0, while the individual files
# in the compilation are all public domain.
#
# See http://www.cryptopp.com/wiki/Android_(Command_Line) for more details
# ====================================================================

# Set ANDROID_NDK_ROOT to you NDK location. For example,
# /opt/android-ndk-r8e or /opt/android-ndk-r9. This can be done in a
# login script. If ANDROID_NDK_ROOT is not specified, the script will
# try to pick it up with the value of _ANDROID_NDK_ROOT below. If
# ANDROID_NDK_ROOT is set, then the value is ignored.
# _ANDROID_NDK="android-ndk-r8"
_ANDROID_NDK="android-ndk-r9"
# _ANDROID_NDK="android-ndk-r10"

# Set _ANDROID_EABI to the EABI you want to use. You can find the
# list in $ANDROID_NDK_ROOT/toolchains. This value is always used.
# _ANDROID_EABI="mipsel-linux-android-4.8"
# _ANDROID_EABI="x86-4.6"
# _ANDROID_EABI="arm-linux-androideabi-4.6"
_ANDROID_EABI="arm-linux-androideabi-4.8"

# Set _ANDROID_ARCH to the architecture you are building for.
# This value is always used.
# _ANDROID_ARCH=arch-mips
# _ANDROID_ARCH=arch-x86
_ANDROID_ARCH=arch-arm

# Set _ANDROID_API to the API you want to use. You should set it
# to one of: android-19, android-18, android-14, android-9, android-8,
# android-5, android-4, or android-3. You should set it to the minimum
# SDK you want to support, not the latest. This value is always used.
# _ANDROID_API="android-9"
_ANDROID_API="android-14"
# _ANDROID_API="android-18"
# _ANDROID_API="android-19"

# For Android 4.3 (released July 2013), the tuple is { android-ndk-r9,
# arm-linux-androideabi-4.8, arch-arm, android-18 }.

#####################################################################

# The Crypto++ makefile uses CXX and LD to determine the host capabilities.
# We need to set them early because IS_ANDROID is used after some
# capabilities are determined. We set the others (like AS and RANLIB)
# because this script is useful for other projects, including Autotools.

if [ "$_ANDROID_ARCH" == "arch-arm" ]; then
	export CPP="arm-linux-androideabi-cpp"
	export CC="arm-linux-androideabi-gcc"
	export CXX="arm-linux-androideabi-g++"
	export LD="arm-linux-androideabi-ld"
	export AS="arm-linux-androideabi-as"
	export AR="arm-linux-androideabi-ar"
	export RANLIB="arm-linux-androideabi-ranlib"
	export STRIP="arm-linux-androideabi-strip"
elif [ "$_ANDROID_ARCH" == "arch-x86" ]; then
	export CPP="i686-linux-android-cpp"
	export CC="i686-linux-android-gcc"
	export CXX="i686-linux-android-g++"
	export LD="i686-linux-android-ld"
	export AS="i686-linux-android-as"
	export AR="i686-linux-android-ar"
	export RANLIB="i686-linux-android-ranlib"
	export STRIP="i686-linux-android-strip"
elif [ "$_ANDROID_ARCH" == "arch-mips" ]; then
	export CPP="mipsel-linux-android-cpp"
	export CC="mipsel-linux-android-gcc"
	export CXX="mipsel-linux-android-g++"
	export LD="mipsel-linux-android-ld"
	export AS="mipsel-linux-android-as"
	export AR="mipsel-linux-android-ar"
	export RANLIB="mipsel-linux-android-ranlib"
	export STRIP="mipsel-linux-android-strip"
fi

#####################################################################

# If the user did not specify the NDK location, try and pick it up.
# We expect something like ANDROID_NDK_ROOT=/opt/android-ndk-r8e
# or ANDROID_NDK_ROOT=/usr/local/android-ndk-r8e.

if [ -z "$ANDROID_NDK_ROOT" ]; then

  _ANDROID_NDK_ROOT=""
  if [ -z "$_ANDROID_NDK_ROOT" ] && [ -d "/usr/local/$_ANDROID_NDK" ]; then
    _ANDROID_NDK_ROOT="/usr/local/$_ANDROID_NDK"
  fi

  if [ -z "$_ANDROID_NDK_ROOT" ] && [ -d "/opt/$_ANDROID_NDK" ]; then
    _ANDROID_NDK_ROOT="/opt/$_ANDROID_NDK"
  fi

  if [ -z "$_ANDROID_NDK_ROOT" ] && [ -d "$HOME/$_ANDROID_NDK" ]; then
    _ANDROID_NDK_ROOT="$HOME/$_ANDROID_NDK"
  fi

  if [ -z "$_ANDROID_NDK_ROOT" ] && [ -d "$PWD/$_ANDROID_NDK" ]; then
    _ANDROID_NDK_ROOT="$PWD/$_ANDROID_NDK"
  fi

  # If a path was set, then export it
  if [ ! -z "$_ANDROID_NDK_ROOT" ] && [ -d "$_ANDROID_NDK_ROOT" ]; then
    export ANDROID_NDK_ROOT="$_ANDROID_NDK_ROOT"
  fi
fi

# Error checking
# ANDROID_NDK_ROOT should always be set by the user (even when not running this script)
# http://groups.google.com/group/android-ndk/browse_thread/thread/a998e139aca71d77
if [ -z "$ANDROID_NDK_ROOT" ] || [ ! -d "$ANDROID_NDK_ROOT" ]; then
  echo "Error: ANDROID_NDK_ROOT is not a valid path. Please edit this script."
  # exit 1
fi

# Error checking
if [ ! -d "$ANDROID_NDK_ROOT/toolchains" ]; then
  echo "Error: ANDROID_NDK_ROOT/toolchains is not a valid path. Please edit this script."
  # exit 1
fi

# Error checking
if [ ! -d "$ANDROID_NDK_ROOT/toolchains/$_ANDROID_EABI" ]; then
  echo "Error: ANDROID_EABI is not a valid path. Please edit this script."
  # exit 1
fi

#####################################################################

# Based on ANDROID_NDK_ROOT, try and pick up the required toolchain. We expect something like:
# /opt/android-ndk-r83/toolchains/arm-linux-androideabi-4.7/prebuilt/linux-x86_64/bin
# Once we locate the toolchain, we add it to the PATH. Note: this is the 'hard way' of
# doing things according to the NDK documentation for Ice Cream Sandwich.
# https://android.googlesource.com/platform/ndk/+/ics-mr0/docs/STANDALONE-TOOLCHAIN.html

ANDROID_TOOLCHAIN=""
for host in "linux-x86_64" "linux-x86" "darwin-x86_64" "darwin-x86"
do
  if [ -d "$ANDROID_NDK_ROOT/toolchains/$_ANDROID_EABI/prebuilt/$host/bin" ]; then
    ANDROID_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/$_ANDROID_EABI/prebuilt/$host/bin"
    break
  fi
done

# Error checking
if [ -z "$ANDROID_TOOLCHAIN" ] || [ ! -d "$ANDROID_TOOLCHAIN" ]; then
  echo "Error: ANDROID_TOOLCHAIN is not valid. Please edit this script."
  # exit 1
fi

# Error checking
if [ ! -e "$ANDROID_TOOLCHAIN/$CPP" ]; then
  echo "Error: Failed to find Android cpp. Please edit this script."
  # exit 1
fi

# Error checking
if [ ! -e "$ANDROID_TOOLCHAIN/$CC" ]; then
  echo "Error: Failed to find Android gcc. Please edit this script."
  # exit 1
fi

if [ ! -e "$ANDROID_TOOLCHAIN/$CXX" ]; then
  echo "Error: Failed to find Android g++. Please edit this script."
  # exit 1
fi

# Error checking
if [ ! -e "$ANDROID_TOOLCHAIN/$RANLIB" ]; then
  echo "Error: Failed to find Android ranlib. Please edit this script."
  # exit 1
fi

# Error checking
if [ ! -e "$ANDROID_TOOLCHAIN/$AR" ]; then
  echo "Error: Failed to find Android ar. Please edit this script."
# exit 1
fi

# Error checking
if [ ! -e "$ANDROID_TOOLCHAIN/$AS" ]; then
  echo "Error: Failed to find Android as. Please edit this script."
# exit 1
fi

# Error checking
if [ ! -e "$ANDROID_TOOLCHAIN/$LD" ]; then
  echo "Error: Failed to find Android ld. Please edit this script."
  # exit 1
fi

# Only modify/export PATH if ANDROID_TOOLCHAIN good
if [ ! -z "$ANDROID_TOOLCHAIN" ]; then

  # And only modify PATH if ANDROID_TOOLCHAIN is not present
  LEN=${#ANDROID_TOOLCHAIN}
  SUBSTR=${PATH:0:$LEN}
  if [ "$SUBSTR" != "$ANDROID_TOOLCHAIN" ]; then
    export PATH="$ANDROID_TOOLCHAIN":"$PATH"
  fi
fi

#####################################################################

# For the Android SYSROOT. Can be used on the command line with --sysroot
# https://android.googlesource.com/platform/ndk/+/ics-mr0/docs/STANDALONE-TOOLCHAIN.html
ANDROID_API="$_ANDROID_API"
export ANDROID_SYSROOT="$ANDROID_NDK_ROOT/platforms/$ANDROID_API/$_ANDROID_ARCH"

# Error checking
if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; then
  echo "Error: ANDROID_SYSROOT is not valid. Does the NDK support the API? Please edit this script."
  # exit 1
fi

#####################################################################

# For the Android STL.

# Error checking
if [ ! -d "$ANDROID_NDK_ROOT/sources/cxx-stl/stlport/stlport/" ]; then
  echo "Error: STLport headers is not valid. Please edit this script."
  # exit 1
fi

# If more than one library is using STLport, then all libraries in the
# APK ***must*** use the shared version.
# STLPORT_LIB=libstlport_static.a
STLPORT_LIB=libstlport_shared.so

# Error checking
if [ ! -e "$ANDROID_NDK_ROOT/sources/cxx-stl/stlport/libs/armeabi/$STLPORT_LIB" ]; then
  echo "Error: STLport library is not valid. Please edit this script."
  # exit 1
fi

export ANDROID_STL_INC="$ANDROID_NDK_ROOT/sources/cxx-stl/stlport/stlport/"
export ANDROID_STL_LIB="$ANDROID_NDK_ROOT/sources/cxx-stl/stlport/libs/armeabi/$STLPORT_LIB"

#####################################################################

# The Crypto++ Makefile uses these. Once the makefile encounters them,
# it knows to unset some host variables (such as IS_LINUX and IS_DARWIN)
export IS_ANDROID=1
export IS_CROSS_COMPILE=1

VERBOSE=1
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" != "0" ]; then
  echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT"
  echo "ANDROID_EABI: $_ANDROID_EABI"
  echo "ANDROID_ARCH: $_ANDROID_ARCH"
  echo "ANDROID_API: $_ANDROID_API"
  echo "ANDROID_SYSROOT: $ANDROID_SYSROOT"
  echo "ANDROID_TOOLCHAIN: $ANDROID_TOOLCHAIN"
  echo "ANDROID_STL_INC: $ANDROID_STL_INC"
  echo "ANDROID_STL_LIB: $ANDROID_STL_LIB"
fi
