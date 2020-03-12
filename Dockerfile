ARG kernelver=4.19.99
FROM linuxkit/kernel:$kernelver AS ksrc

FROM linuxkit/alpine:3fdc49366257e53276c6f363956a4353f95d9a81 AS build
RUN apk add build-base elfutils-dev git curl

COPY --from=ksrc /kernel-dev.tar /
COPY vrouter_libs.tgz /
RUN tar xf kernel-dev.tar && \
#      curl -OL https://github.com/michaelhenkel/make_vrouter/raw/master/vrouter_libs.tgz && \
      mkdir /vrouter && \
      git clone https://github.com/Juniper/contrail-vrouter /vrouter/contrail-vrouter && \
      git clone https://github.com/Juniper/contrail-common /vrouter/src/contrail-common && \
      tar zxvf vrouter_libs.tgz
RUN cd /vrouter/contrail-vrouter && \
      gcc -o dp-core/vr_buildinfo.o -c -O0 -DDEBUG -g -D__VR_X86_64__ -D__VR_SSE__ -D__VR_SSE2__ -Iinclude -I ../vrouter_sandesh/sandesh/gen-c -I ../src/contrail-common dp-core/vr_buildinfo.c && \
      make -C /usr/src/linux-headers-${kernelver}-linuxkit M=/vrouter/contrail-vrouter SANDESH_HEADER_P
ATH=/vrouter/vrouter_sandesh SANDESH_SRC_ROOT=../kbuild_sandesh/ SANDESH_EXTRA_HEADER_PATH=/vrouter/src/contrail-common
FROM alpine:3.9
COPY --from=build /vrouter/contrail-vrouter/vrouter.ko /tmp
COPY init_kmod.sh /init_kmod.sh
COPY vif /usr/bin/vif
RUN chmod +x /usr/bin/vif
ENTRYPOINT ["/bin/sh", "/init_kmod.sh"]
