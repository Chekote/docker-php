#!/usr/bin/env bash

########################################
# Writes the args to stdout in the default color
########################################
out.info() {
  echo "$@"
}

########################################
# Writes the args to stdout in green
########################################
out.success() {
  printf "${COLOR_GREEN}$@${COLOR_RESET}\n"
}

########################################
# Writes the args to stdout in yellow
########################################
out.warn() {
  printf "${COLOR_YELLOW}$@${COLOR_RESET}\n"
}

########################################
# Writes the args to stderr in red
########################################
out.error() {
  (>&2 printf "${COLOR_RED}$@${COLOR_RESET}\n")
}
