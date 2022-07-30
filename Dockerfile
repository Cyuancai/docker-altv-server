
FROM ubuntu:focal-20210723

ARG BRANCH=release
ARG LIBNODE_VERSION=102

COPY ./.docker/scripts/entrypoint.sh /root/

RUN apt-get update && \
    apt-get install -y wget jq gnupg libatomic1 libc-bin apt-transport-https dotnet-runtime-6.0 && \
    mkdir -p /opt/altv/modules && \
    mkdir -p /opt/altv/resources && \
    mkdir -p /opt/altv/data && \
    wget --no-cache -q -O /opt/altv/altv-server https://cdn.altv.mp/server/${BRANCH}/x64_linux/altv-server && \
    wget --no-cache -q -O /opt/altv/data/vehmodels.bin https://cdn.altv.mp/data/${BRANCH}/data/vehmodels.bin && \
    wget --no-cache -q -O /opt/altv/data/vehmods.bin https://cdn.altv.mp/data/${BRANCH}/data/vehmods.bin && \
    wget --no-cache -q -O /opt/altv/data/clothes.bin https://cdn.altv.mp/data/${BRANCH}/data/clothes.bin && \
    chmod +x /opt/altv/altv-server /root/entrypoint.sh && \
    \
    ######
    # Install JS Module
    ######
    mkdir -p /opt/altv/modules/js-module/ && \
    wget --no-cache -q -O /opt/altv/modules/js-module/libnode.so.${LIBNODE_VERSION} https://cdn.altv.mp/js-module/${BRANCH}/x64_linux/modules/js-module/libnode.so.${LIBNODE_VERSION} && \
    wget --no-cache -q -O /opt/altv/modules/js-module/libjs-module.so https://cdn.altv.mp/js-module/${BRANCH}/x64_linux/modules/js-module/libjs-module.so && \
    wget --no-cache -q -O /opt/altv/modules/js-module/libjs-bytecode-module.so https://cdn.altv.mp/js-bytecode-module/${BRANCH}/x64_linux/modules/libjs-bytecode-module.so && \
    \
    ######
    # Install .NET 6 Module
    ######
    # install dotnet runtime(s)
    wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm -f packages-microsoft-prod.deb && \
    # install altV module
    wget --no-cache -q -O /opt/altv/modules/libcsharp-module.so https://cdn.altv.mp/coreclr-module/${BRANCH}/x64_linux/modules/libcsharp-module.so && \
    mkdir -p /usr/share/dotnet/host/fxr/ && \
    wget --no-cache -q -O /opt/altv/AltV.Net.Host.dll https://cdn.altv.mp/coreclr-module/${BRANCH}/x64_linux/AltV.Net.Host.dll && \
    # remove unused tools
    apt-get purge -y wget jq gnupg && \
    apt autoremove -y && \
    apt-get clean

WORKDIR /opt/altv/

# Meant are the default values provided by the entrypoint script.
# Of course you can change the port as you like by using the
# environment variable "ALTV_SERVER_PORT".
EXPOSE 7788/udp
EXPOSE 7788/tcp

ENTRYPOINT [ "/root/entrypoint.sh" ]
