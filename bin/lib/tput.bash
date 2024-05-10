#######################################
# Library of functions for the tput command.
#
# https://en.wikipedia.org/wiki/Tput
#######################################

#######################################
# Executes a tput command, passing all of the provided arguments to it
#
# Will use tput.options to ensure a -T option is passed to tput if the
# current session does not have a TERM env var
#
# Arguments:
#   * The args to pass to tput
#######################################
tput.exec() {
  # Need word splitting for the -T option to work
  # shellcheck disable=SC2046
  if ! tput $(tput.options) "$@"; then
    return $?
  fi

  return 0
}

#######################################
# Returns a list of options for tput
#
# Provides a -T option of "xterm" if the current session does not have a TERM env var.
#######################################
tput.options() {
  # Pass xterm if TERM is not set. This env var is needed by tput to generate the correct escape sequences
  if [ -z "$TERM" ]; then
     echo -T xterm
  fi
}

#######################################
# Uses tput to output the escape sequence to set the terminal background to the specified color.
#
# Arguments:
#   1 The id number of the color to use.
#######################################
tput.setab() {
  local color="$1"

  tput.suppress.error setab "$color"
}

#######################################
# Uses tput to output the escape sequence to set the terminal foreground to the specified color.
#
# Arguments:
#   1 The id number of the color to use.
#######################################
tput.setaf() {
  local color="$1"

  tput.suppress.error setaf "$color"
}

#######################################
# Executes tput.exec while suppressing a non-zero exit code
#
# This allows the command to be run in a session where the errexit option is enabled,
# but you don't want tput to cause the script to exit. This is useful when tput might
# execute in an environment where the TERM env var is set, but it is not something
# that tput understands. When this happens, you typically want the output of tput to
# simply be an empty string rather than an error.
#######################################
tput.suppress.error() {
  # Use || true to suppress the error code (if any)
  tput.exec "$@" 2> /dev/null || :
}
