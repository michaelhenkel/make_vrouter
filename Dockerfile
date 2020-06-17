ARG KERNELVER=4.19.99
FROM linuxkit/kernel:${KERNELVER} AS ksrc
FROM linuxkit/alpine:3fdc49366257e53276c6f363956a4353f95d9a81 AS build
ARG CONTRAILVER=master
ARG KERNELVER=4.19.99
ARG CONTRAILREPO=https://github.com/Juniper/contrail-vrouter
ARG CHERRYPICKREF=""
RUN apk add build-base elfutils-dev git curl

COPY --from=ksrc /kernel-dev.tar /
COPY vrouter_libs.tgz /
RUN tar xf kernel-dev.tar && \
      mkdir /vrouter && \
      git clone ${CONTRAILREPO} /vrouter/contrail-vrouter -b ${CONTRAILVER} && \
      if [[ ! -z ${CHERRYPICKREF} ]]; then (cd /vrouter/contrail-vrouter && git config --global user.email "you@example.com" && git config --global user.name "Your Name" && git fetch "https://review.opencontrail.org/Juniper/contrail-vrouter" ${CHERRYPICKREF} && git cherry-pick FETCH_HEAD); fi && \
      git clone https://github.com/tungstenfabric/tf-common /vrouter/src/contrail-common -b ${CONTRAILVER} && \
      tar zxvf vrouter_libs.tgz
RUN cd /vrouter/contrail-vrouter && \
      gcc -o dp-core/vr_buildinfo.o -c -O0 -DDEBUG -g -D__VR_X86_64__ -D__VR_SSE__ -D__VR_SSE2__ -Iinclude -I ../vrouter_sandesh/sandesh/gen-c -I ../src/contrail-common dp-core/vr_buildinfo.c && \
      make -C /usr/src/linux-headers-${KERNELVER}-linuxkit M=/vrouter/contrail-vrouter SANDESH_HEADER_PATH=/vrouter/vrouter_sandesh SANDESH_SRC_ROOT=../kbuild_sandesh/ SANDESH_EXTRA_HEADER_PATH=/vrouter/src/contrail-common
FROM alpine:3.9
COPY --from=build /vrouter/contrail-vrouter/vrouter.ko /tmp
COPY --from=build /vrouter/init_kmod.sh /init_kmod.sh
COPY --from=build /vrouter/vif /usr/bin/vif
ENTRYPOINT ["/bin/sh", "/init_kmod.sh"]
