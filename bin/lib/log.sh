#!/usr/bin/env bash

########################################
# Writes the args to a log file for the image currently being built
#
# Globals:
#   IMAGE the name of the image currently being build
########################################
log.log() {
  echo "$@" >> "logs/$IMAGE.log"
}

########################################
# Writes the args prefixed with [INFO] to the log file
########################################
log.info() {
  log.log "[INFO] $@"
}

########################################
# Writes the args prefixed with [SUCCESS] to the log file
########################################
log.success() {
  log.log "[SUCCESS] $@"
}

########################################
# Writes the args prefixed with [WARN] to the log file
########################################
log.warn() {
  log.log "[WARN] $@"
}

########################################
# Writes the args prefixed with [ERROR] to the log file
########################################
log.error() {
  log.log "[ERROR] $@"
}
