#!/bin/bash
#This assumes we're cd'd into the server_build dir of
#the source code

if [ -z "${BUILD_LABEL}" ]; then
    export BUILD_LABEL="$(date +%Y%m%d-%H%M)_build"
fi
export SROOT=$(realpath `pwd`/..)
export BROOT=${SROOT}
export DEPS_HOME=/deps
export USE_REAL_TRANSLATIONS=true
export SLESNORPMS=yes
export IMASERVER_BASE_DIR=$BROOT/rpmtree

if [ -z "${JAVA_HOME}" ]; then
    if [ -d "/etc/alternatives/java_sdk_11" ]; then
        export JAVA_HOME=/etc/alternatives/java_sdk_11
    elif [ -d "/etc/alternatives/java_sdk_1.8.0" ]; then
        export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0
    elif [ -d "/etc/alternatives/java_sdk" ]; then
        export JAVA_HOME=/etc/alternatives/java_sdk
    else
        echo "build.sh: Can't guess java sdk location, please set JAVA_HOME"
        exit 10
    fi
fi
echo "JAVA_HOME is set to ${JAVA_HOME}"
export PATH=$JAVA_HOME/bin:$PATH

#Set up a home directory we can write to (for rpmbuild)
if [ "${HOME}" == "/" ]; then 
    unset HOME
fi
    
if [ -z "${HOME}" ]; then
    export HOME=$BROOT/home
    mkdir $HOME
fi

#Unitest tests require some diskspace and we have to be careful where that is...
export STOREROOT=$BROOT/unitteststore
mkdir $STOREROOT

echo "HOME is $HOME"
echo "free mem:"
free -g
echo "Num processors according to nproc:"
nproc

#We're getting out of mem errors in Eclipse infrastructure
export AMLEN_MAX_BUILD_JOBS=3

#Get the git commit that we are building with embedded in the build
export IMA_SOURCELEVEL_INFO=${GIT_COMMIT}
echo "Git commit info is ${IMA_SOURCELEVEL_INFO}"

ant -f $SROOT/server_build/build.xml ${BUILD_TYPE}  2>&1 | tee $BROOT/ant.log
