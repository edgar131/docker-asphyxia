FROM alpine:latest
LABEL maintainer=Edgar131
ENV ASPHYXIA_VERSION=1.60a
ENV ASPHYXIA_GIT_PATH=heads
ENV ASPHYXIA_PLUGIN_VERSION=stable
WORKDIR /usr/local/share
COPY bootstrap.sh .
RUN apk add gcompat libgcc libstdc++ &&\
    wget https://github.com/asphyxia-core/core/releases/download/v${ASPHYXIA_VERSION}/asphyxia-core-linux-x64.zip &&\
    wget https://github.com/asphyxia-core/plugins/archive/${ASPHYXIA_GIT_PATH}/${ASPHYXIA_PLUGIN_VERSION}.zip &&\
    mkdir -p ./asphyxia &&\
    unzip asphyxia-core-linux-x64.zip -d ./asphyxia &&\
    unzip ${ASPHYXIA_PLUGIN_VERSION}.zip -d ./ &&\
    ls -alt &&\
    cp -r plugins-${ASPHYXIA_GIT_PATH}-${ASPHYXIA_PLUGIN_VERSION}/* ./asphyxia/plugins &&\
    mv ./asphyxia/plugins ./asphyxia/plugins_default &&\
    mkdir -p ./asphyxia/plugins &&\
    rm *.zip &&\
    rm -rf plugins-${ASPHYXIA_PLUGIN_VERSION} &&\
    chmod -R 774 ./asphyxia
CMD /usr/local/share/bootstrap.sh