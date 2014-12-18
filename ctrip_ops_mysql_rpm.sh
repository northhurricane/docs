#!/bin/bash
#possible pre-request 
#sudo yum install rpm-build redhat-rpm-config gcc gcc-c++ cmake make zlib-devel openssl-devel gperf
cd ~
mkdir ctrip_ops_mysql
cd ctrip_ops_mysql
git clone http://git.dev.sh.ctripcorp.com/ops-mysql/mysql-5-6-21-ctrip.git mysql-5.6.21
#rpm directory
mkdir -p rpm/{BUILD,RPMS,SOURCES,SPECS,SRPMS} tmp
tar -zcvf mysql-5.6.21.tar.gz mysql-5.6.21
mkdir bld
cd bld
cmake ../mysql-5.6.21 -DBUILD_CONFIG=mysql_release
cd ..
cp bld/support-files/*.spec rpm/SPECS
cp mysql-5.6.21.tar.gz rpm/SOURCES
rpmbuild -v --define="_topdir $PWD/rpm" --define="_tmppath $PWD/tmp" -ba rpm/SPECS/mysql.5.6.21.spec
