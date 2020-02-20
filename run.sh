#!/bin/bash
yum install kernel-devel
mkdir /vrouter
cd /vrouter
git clone https://github.com/Juniper/contrail-vrouter
curl -OL https://github.com/michaelhenkel/make_vrouter/raw/master/vrouter_libs.tgz
tar zxvf vrouter_libs.tgz
cat << EOF > contrail-vrouter/include/vr_buildinfo.h

/*
 * Autogenerated file. Do not edit
*/
#ifndef __VR_BUILDINFO_H__
#define __VR_BUILDINFO_H__

#define VROUTER_VERSIONID "2003"

#endif /* __VR_BUILDINFO_H__ */
EOF

cat << EOF > contrail-vrouter/dp-core/vr_buildinfo.c

/*
* Autogenerated file. DO NOT EDIT.
*/

const char *ContrailBuildInfo = "{\"build-info\": [{\"build-time\": \"2020-02-20 00:35:47.073918\", \"build-hostname\": \"d3b07bc07165\", \"build-user\": \"root\", \"build-version\": \"2003\"}]}";
EOF
cd contrail-vrouter
gcc -o dp-core/vr_buildinfo.o -c -O0 -DDEBUG -g -D__VR_X86_64__ -D__VR_SSE__ -D__VR_SSE2__ -Iinclude -I ../build/debug/vrouter/sandesh/gen-c -I ../src/contrail-common dp-core/vr_buildinfo.c
make -C /usr/src/kernels/3.10.0-1062.12.1.el7.x86_64 M=/vrouter/contrail-vrouter SANDESH_HEADER_PATH=/vrouter/build/debug/vrouter SANDESH_SRC_ROOT=../build/kbuild/ SANDESH_EXTRA_HEADER_PATH=/vrouter/src/contrail-common
