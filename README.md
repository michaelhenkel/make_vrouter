# Get IT
```
git clone https://github.com/michaelhenkel/make_vrouter
```

# Building
## Default build (kernel 4.19.99)
```
cd make_vrouter
docker build -t vrouter .
```

## Build against different kernel
*check available Kernel versions here: https://hub.docker.com/r/linuxkit/kernel/tags
```
cd make_vrouter
docker build -t vrouter:4.19.104 --build-arg KERNELVER=4.19.104 .
```

## Build against different kernel and specific vrouter branch
```
cd make_vrouter
docker build -t vrouter:5.4.19_R2003 --build-arg CONTRAILVER=R2003 --build-arg KERNELVER=5.4.19
```

## Build against different kernel and specific vrouter branch and a patchset
```
cd make_vrouter
docker build -t vrouter:5.4.19_R2003 --build-arg CONTRAILVER=R2003 --build-arg KERNELVER=5.4.19 --build-arg CHERRYPICKREF=refs/changes/06/57506/1 .
```

# Getting the kmod
```
docker create -ti --name vrouter vrouter:5.4.19_R2003 sh
docker cp vrouter:/tmp/vrouter.ko /tmp
docker rm -f vrouter
```

