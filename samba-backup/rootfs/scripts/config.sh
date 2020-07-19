#!/usr/bin/env bashio

# user input variables
declare TARGET_DIR
declare KEEP_LOCAL
declare KEEP_REMOTE
declare TRIGGER_TIME
declare TRIGGER_DAYS
declare EXCLUDE_ADDONS
declare EXCLUDE_FOLDERS
declare BACKUP_NAME
declare BACKUP_PWD
declare MQTT_HOST
declare MQTT_USERNAME
declare MQTT_PASSWORD
declare MQTT_PORT
declare MQTT_TOPIC

# smbclient command string
declare SMB


# ------------------------------------------------------------------------------
# Read and print config.
# ------------------------------------------------------------------------------
function get-config {
    local host
    local share
    local username
    local password

    host=$(bashio::config 'host' | escape-input)
    share=$(bashio::config 'share' | escape-input)
    username=$(bashio::config 'username' | escape-input)
    password=$(bashio::config 'password' | escape-input)

    TARGET_DIR=$(bashio::config 'target_dir')
    KEEP_LOCAL=$(bashio::config 'keep_local')
    KEEP_REMOTE=$(bashio::config 'keep_remote')
    TRIGGER_TIME=$(bashio::config 'trigger_time')
    TRIGGER_DAYS=$(bashio::config 'trigger_days')
    EXCLUDE_ADDONS=$(bashio::config 'exclude_addons')
    EXCLUDE_FOLDERS=$(bashio::config 'exclude_folders')

    bashio::config.exists 'backup_name' && BACKUP_NAME=$(bashio::config 'backup_name') || BACKUP_NAME=""
    bashio::config.exists 'backup_password' && BACKUP_PWD=$(bashio::config 'backup_password') || BACKUP_PWD=""
    bashio::config.exists 'mqtt_host' && MQTT_HOST=$(bashio::config 'mqtt_host') || MQTT_HOST=""
    bashio::config.exists 'mqtt_username' && MQTT_USERNAME=$(bashio::config 'mqtt_username') || MQTT_USERNAME=""
    bashio::config.exists 'mqtt_password' && MQTT_PASSWORD=$(bashio::config 'mqtt_password') || MQTT_PASSWORD=""
    bashio::config.exists 'mqtt_port' && MQTT_PORT=$(bashio::config 'mqtt_port') || MQTT_PORT=""
    bashio::config.exists 'mqtt_topic' && MQTT_TOPIC=$(bashio::config 'mqtt_topic') || MQTT_TOPIC="samba_backup"

    if [[ -n "$username" && -n "$password" ]]; then
        SMB="smbclient -U \"${username}\"%\"${password}\" \"//${host}/${share}\" 2>&1"
    else
        SMB="smbclient -N \"//${host}/${share}\" 2>&1"
    fi


    # setup logging
    bashio::config.exists 'log_level' && bashio::log.level $(bashio::config 'log_level')

    bashio::log.info "Host: ${host}"
    bashio::log.info "Share: ${share}"
    bashio::log.info "Target Dir: ${TARGET_DIR}"
    bashio::log.info "Keep local: ${KEEP_LOCAL}"
    bashio::log.info "Keep remote: ${KEEP_REMOTE}"
    bashio::log.info "Trigger time: ${TRIGGER_TIME}"
    [[ "$TRIGGER_TIME" != "manual" ]] && bashio::log.info "Trigger days: $(echo "$TRIGGER_DAYS" | xargs)"

    return 0
}


# ------------------------------------------------------------------------------
# Escape input given by the user.
#
# Returns the escaped string on stdout
# ------------------------------------------------------------------------------
function escape-input {
    local input
    read -r input

    # escape the evil dollar sign
    input=${input//$/\\$}

    echo "$input"
}
