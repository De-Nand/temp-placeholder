#!/usr/bin/env bash

BUILD_FLAGS="-Wall -Wextra -std=c11"

if [ "$1" = "mac" ]
then
    echo "mac build"
    echo ""
    gcc main.c $BUILD_FLAGS -I../sdls/macos/include/ -L../sdls/macos/lib -lSDL3 -o main 
elif [ "$1" = "sim" ]
then
    echo "simulator build"
    echo ""
    SDL_HEADERS="-I../sdls/macos/include/"
    SDL_LIBRARY="-L../sdls/ios-sim -lSDL3"
    IOS_SDK_LIBRARY="-isysroot/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator18.2.sdk"
    IOS_SDK_LIBRARY_W="-isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -mios-simulator-version-min=18.0"
    
    # First build the object file
    clang -arch arm64 $BUILD_FLAGS $SDL_HEADERS $SDL_LIBRARY $IOS_SDK_LIBRARY_W main.c -o main.o 
    # Then create a static library from the object file
    ar rcs main.a main.o
else
    echo "default - windows"
    echo ""
    gcc main.c $BUILD_FLAGS -I../sdls/windows/include/ -L../sdls/windows/lib -lSDL3 -o main.exe 
fi
