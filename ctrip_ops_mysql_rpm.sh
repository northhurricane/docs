#!/bin/bash
#possible pre-request 
#sudo yum install rpm-build redhat-rpm-config gcc gcc-c++ cmake make zlib-devel openssl-devel gperf ncurses-devel bison git libaio-devel

#variables of version / branch.

#default version is 5.6.21. relative variables' default value list below
MYSQL_VERSION_DEFAULT="5.6.21"
#REPOSITORY_DEFAULT="http://git.dev.sh.ctripcorp.com/ops-mysql/mysql-5-6-21-ctrip.git"
REPOSITORY_DEFAULT="git@git.dev.sh.ctripcorp.com:ops-mysql/mysql-5-6-21-ctrip.git"
SOURCE_DIR_DEFAULT="mysql-5.6.21"
#BRANCH_DEFAULT="master"
BRANCH_DEFAULT="feature_audit_dev_jiangyx"
SOURCE_TAR_DEFAULT="mysql-5.6.21.tar.gz"
SPEC_DEFAULT="mysql.5.6.21.spec"
RPM_BASE_DIR_DEFAULT="~"

MYSQL_VERSION=$MYSQL_VERSION_DEFAULT

while getopts "v:b:d:" arg #选项后面的冒号表示该选项需要参数
do
  case $arg in
  v)
#    echo "v's arg:$OPTARG" #参数存在$OPTARG中
    MYSQL_VERSION="$OPTARG"
    ;;
  b)
#    echo "b"
    BRANCH="$OPTARG"
echo "$BRANCH"
    ;;
  d)
    RPM_BASE_DIR="$OPTARG"
    ;;
  ?)  #当有不认识的选项的时候arg为?
    echo "unkonw argument"
    exit 1
    ;;
  esac
done


#variables required by execution
RPM_DIR="ctrip_ops_mysql"
REPOSITORY=""
SOURCE_DIR=""
SOURCE_TAR=""
#BRANCH=""

#get execution infomation
#version related variables
case "$MYSQL_VERSION" in
5[.-]6[.-]12)
MYSQL_VERSION="5.6.12"
REPOSITORY="http://git.dev.sh.ctripcorp.com/ops-mysql/mysql-5-6-12-ctrip.git"
SOURCE_DIR="mysql-5.6.12"
SOURCE_TAR="mysql-5.6.12.tar.gz"
SPEC="mysql.5.6.12.spec"
;;
5[.-]6[.-]21)
MYSQL_VERSION=$MYSQL_VERSION_DEFAULT
REPOSITORY=$REPOSITORY_DEFAULT
SOURCE_DIR=$SOURCE_DIR_DEFAULT
SOURCE_TAR=$SOURCE_TAR_DEFAULT
SPEC=$SPEC_DEFAULT
;;
*)
echo "unsupported version"
exit 1
;;
esac

#get branch
if [ -z "$BRANCH" ]
then
BRANCH=$BRANCH_DEFAULT
#echo "BRANCH -z"
fi
#echo "$BRANCH"

#debug for show current infomation 
#read

#get rpm build base dir
if [ -z "$RPM_BASE_DIR" ]
then
RPM_BASE_DIR=$RPM_BASE_DIR_DEFAULT
#echo "RPM_BASE_DIR -z"
fi
#echo "RPM_BASE_DIR is $RPM_BASE_DIR"

echo "Building Mysql rpm at version "$MYSQL_VERSION
echo "Code repository is "$REPOSITORY
echo "Features are from branch "$BRANCH
echo "Code directory is "$SOURCE_DIR
echo "rpm building directory is "$RPM_BASE_DIR

cd "$RPM_BASE_DIR"

#exit

if [ -d "$RPM_DIR" ];
then
echo "directory "$RPM_DIR" exist.Now remove it!!!!!"
rm -rf "$RPM_DIR"
fi
mkdir $RPM_DIR

#get source code
cd $RPM_DIR
git clone $REPOSITORY $SOURCE_DIR
if (( $? )); then 
exit 1 ; 
fi
#switch to branch if specified
cd $SOURCE_DIR
if [ "$BRANCH" != "master" ]; then
git checkout -b $BRANCH origin/$BRANCH
fi
if (( $? )); then 
exit 1 ; 
fi
cd ..

#rpm building
mkdir -p rpm/{BUILD,RPMS,SOURCES,SPECS,SRPMS} tmp
tar -zcvf $SOURCE_TAR $SOURCE_DIR
mkdir bld
cd bld
cmake ../$SOURCE_DIR -DBUILD_CONFIG=mysql_release
cd ..
cp bld/support-files/*.spec rpm/SPECS
cp $SOURCE_TAR rpm/SOURCES
rpmbuild -v --define="_topdir $PWD/rpm" --define="distro_specific 1" --define="_tmppath $PWD/tmp" -ba rpm/SPECS/$SPEC
