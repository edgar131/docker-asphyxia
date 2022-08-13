#!/bin/sh
# Setting up config.ini
if [ ! -L "/usr/local/share/asphyxia/config.ini" ] && [ -f "/usr/local/share/asphyxia/config.ini" ]; then
	echo "LOG: Default config.ini FOUND; Moving default config.ini"
	mv /usr/local/share/asphyxia/config.ini /usr/local/share/asphyxia/config_default.ini
fi
if test -f "/usr/local/share/custom/config.ini"; then
	echo "LOG: Custom config.ini FOUND; Setting up symbolic link to custom config.ini"
	ln -sf /usr/local/share/custom/config.ini /usr/local/share/asphyxia/config.ini
else
	echo "LOG: custom config.ini NOT FOUND; Setting up symbolic link to default config.ini"
	ln -sf /usr/local/share/asphyxia/config_default.ini /usr/local/share/asphyxia/config.ini 
fi

# Setting up savedata
SAVE_DIR=""
if [ -d "/usr/local/share/custom/savedata" ]; then
	echo "LOG: Custom savedata FOUND"
	SAVE_DIR="-d /usr/local/share/custom/savedata"
else
	echo "LOG: Custom savedata NOT FOUND; Using default savedata"
fi

# Setting up plugins
rm -rf /usr/local/share/asphyxia/plugins/*
cp -r /usr/local/share/asphyxia/plugins_default/* /usr/local/share/asphyxia/plugins/
if [ -d "/usr/local/share/custom/plugins" ]; then
	echo "LOG: Custom plugins FOUND; Setting up symbol link to custom plugins"
	cp -r /usr/local/share/custom/plugins/* /usr/local/share/asphyxia/plugins/
fi

[ ! -z "${ASPHYXIA_LISTENING_PORT}" ] && LISTENING_PORT="--port ${ASPHYXIA_LISTENING_PORT}" || LISTENING_PORT=""
[ ! -z "${ASPHYXIA_BINDING_HOST}" ] && BINDING_PORT="--bind ${ASPHYXIA_BINDING_HOST}" || BINDING_PORT=""
[ ! -z "${ASPHYXIA_MATCHING_PORT}" ] && MATCHING_PORT="--matching-port ${ASPHYXIA_MATCHING_PORT}" || MATCHING_PORT=""
[ ! -z "${ASPHYXIA_DEV_MODE}" ] && DEV_MODE="--dev" || DEV_MODE=""
[ ! -z "${ASPHYXIA_PING_IP}" ] && PING_IP="--ping-addr ${ASPHYXIA_PING_IP}" || PING_IP=""
[ ! -z "${ASPHYXIA_SAVEDATA_DIR}" ] && SAVEDATA_DIR="--savedata-dir ${ASPHYXIA_SAVEDATA_DIR}" || SAVEDATA_DIR=""


echo "RUNNING: /usr/local/share/asphyxia/asphyxia-core ${SAVE_DIR} ${LISTENING_PORT} ${BINDING_PORT} ${MATCHING_PORT} ${DEV_MODE} ${PING_IP} ${SAVEDATA_DIR}"
/usr/local/share/asphyxia/asphyxia-core ${SAVE_DIR} ${LISTENING_PORT} ${BINDING_PORT} ${MATCHING_PORT} ${DEV_MODE} ${PING_IP} ${SAVEDATA_DIR}