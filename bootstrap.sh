#!/bin/sh

readonly ASPHYXIA_DIR="/usr/local/share/asphyxia"
readonly CONFIG_FILE="${ASPHYXIA_DIR}/config.ini"
readonly DEFAULT_CONFIG_FILE="${ASPHYXIA_DIR}/config_default.ini"
readonly CUSTOM_DIR="/usr/local/share/custom"
readonly CUSTOM_CONFIG="${CUSTOM_DIR}/config.ini"
readonly CUSTOM_SAVE_DIR="${CUSTOM_DIR}/savedata"
readonly PLUGINS_DIR="${ASPHYXIA_DIR}/plugins"
readonly CUSTOM_PLUGINS_DIR="${CUSTOM_DIR}/plugins"
readonly DEFAULT_PLUGINS_DIR="${ASPHYXIA_DIR}/plugins_default"

log() {
    echo "LOG: $*" >&2
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

setup_config() {
  log "Setting up configuration..."

  if [[ ! -L "${CONFIG_FILE}" && -f "${CONFIG_FILE}" ]]; then
      log "Default config.ini found; moving to config_default.ini"
      mv "${CONFIG_FILE}" "${DEFAULT_CONFIG}" || die "Failed to move default config"
  fi

  if test -f "${CUSTOM_CONFIG}"; then
  	log "Custom config.ini FOUND; Using custom config.ini"
  	ln -sf "${CUSTOM_CONFIG}" "${CONFIG_FILE}" || die "Failed to symlink custom config.ini"
  else
  	log "Custom config.ini NOT FOUND; Using default config.ini"
  	ln -sf "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}" || die "Failed to symlink default config.ini"
  fi
}

setup_savedata() {
  log "Setting up savedata..."

  if [ -d "${CUSTOM_SAVE_DIR}" ]; then
      log "Custom savedata found"
      echo "-d ${CUSTOM_SAVE_DIR}"
  else
      log "Custom savedata not found; using default savedata"
      echo ""
  fi
}

setup_plugins() {
  log "Setting up plugins..."
  rm -rf "${PLUGINS_DIR}"/* || die "Failed to clean plugins directory"
  if [ -d "${CUSTOM_PLUGINS_DIR}" ]; then
      if [ -n "${ASPHYXIA_PLUGIN_REPLACE}" ]; then
          log "ASPHYXIA_PLUGIN_REPLACE defined, not copying default plugins"
      else
          log "Adding default plugins"
          cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/ || die "Failed to add default plugins"
      fi
  	log "Custom plugins FOUND; Adding custom plugins"
  	cp -r "${CUSTOM_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/ || die "Failed to add custom plugins"
  else
      log "Custom plugins NOT FOUND; Adding default plugins"
      cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/ || die "Failed to copy default plugins"
  fi
}

build_command_args() {
    local args=""

    # Add savedata argument if custom savedata exists
    local save_arg
    save_arg=$(setup_savedata)
    [ -n "$save_arg" ] && args="$args $save_arg"

    # Build optional arguments from environment variables
    [ -n "${ASPHYXIA_LISTENING_PORT:-}" ] && args="$args --port $ASPHYXIA_LISTENING_PORT"
    [ -n "${ASPHYXIA_BINDING_HOST:-}" ] && args="$args --bind $ASPHYXIA_BINDING_HOST"
    [ -n "${ASPHYXIA_MATCHING_PORT:-}" ] && args="$args --matching-port $ASPHYXIA_MATCHING_PORT"
    [ -n "${ASPHYXIA_DEV_MODE:-}" ] && args="$args --dev"
    [ -n "${ASPHYXIA_PING_IP:-}" ] && args="$args --ping-addr $ASPHYXIA_PING_IP"
    [ -n "${ASPHYXIA_SAVEDATA_DIR:-}" ] && args="$args --savedata-dir $ASPHYXIA_SAVEDATA_DIR"

    echo "$args"
}

main() {
  log "Starting Asphyxia bootstrap..."
  [ -d "${ASPHYXIA_DIR}" ] || die "Asphyxia directory not found: ${ASPHYXIA_DIR}"
  setup_config
  setup_plugins

  local cmd_args
  cmd_args=$(build_command_args)
  readonly ASPHYXIA_EXEC="${ASPHYXIA_DIR}/asphyxia-core"
  [ -x "${ASPHYXIA_EXEC}" ] || die "Asphyxia executable not found or not executable: ${ASPHYXIA_EXEC}"

  log "Running: ${ASPHYXIA_EXEC} ${cmd_args}"
  exec ${ASPHYXIA_EXEC} ${cmd_args}
}

main "$@"
