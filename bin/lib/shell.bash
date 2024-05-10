#######################################
# Library of functions for working with Shells
#######################################

. bin/lib/out.bash

#######################################
# Receives an exitCode and throw error if it is greater than 0
#
# Arguments:
#   1 The exitCode to be validated
#   2 The error message to be printed when the error condition is true
#
#######################################
shell.exit.if.error() {
  local exitCode="$1"
  local message="$2"

  if [ $exitCode -gt 0 ]; then
    out.error.ln "$message"
    exit "$exitCode"
  fi
}

#######################################
# Validate the existence of a given command
#
# Arguments:
#   1 The command name to be checked
#
# Returns:
#   0 if the command is available
#   1 if the command is not available
#######################################
shell.command.exists() {
  local command="$1"

  out.info.ln "Determining if $command is available..."
  if [ -x "$(command -v "$command")" ]; then
    out.success.ln "$command is available."
    return 0
  else
    out.warn.ln "$command is not available. Please ensure project is configured properly. Check readme."
    return 1
  fi
}

#######################################
# Assert the existence of the command. Exit if the command is not available.
#
# Arguments:
#   1 The command name to be asserted
#######################################
shell.command.exists.assert() {
  local command="$1"

  shell.command.exists "$command" || exit 1;
}

shell.command.retry() {
  local max_attempts=10
  local attempt=0
  local delay=0 # Optional delay between attempts

  while [ $attempt -lt $max_attempts ]; do
    # Run the command passed as arguments to this function (The "${@}" allows passing all arguments, including spaces)
    # Then Check if the command succeeded
    if "${@}"; then
        out.success.ln "Command '$*' succeeded on attempt $((attempt + 1))."
        return 0
    fi

    # Increment attempt count
    attempt=$((attempt + 1))

    # Optionally wait a moment before retrying
    out.warn.ln "Command '$*' failed. Retrying in $delay second(s)..."
    sleep $delay
  done

  # If we exit the loop, it means all attempts failed
  out.error.ln "Command '$*' failed after $max_attempts attempts."
  return 1
}

#######################################
# Validate the existence of a env variable
#
# Arguments:
#   1 The name of the env variable to be checked
#
# Returns:
#   0 if the env variable is set
#   1 if the env variable is not set
#######################################
shell.env.exists() {
  local env="$1"

  out.info.ln "Determining if $env is set..."
  if [ -n "${!env-}" ]; then
    out.success.ln "$env is set."
    return 0
  else
    out.warn.ln "$env is not set. Please ensure project is configured properly. Check readme."
    return 1
  fi
}


#######################################
# Assert the existence of the env variable. Exit if the var is not set.
#
# Arguments:
#   1 The name of the env var to assert the existence of
#######################################
shell.env.exists.assert() {
  local env="$1"

  shell.env.exists "$env" || exit 1;
}

#######################################
# Sources a file if it exists.
#
# Arguments:
#   1 the full or relative path of the file to source
#######################################
shell.source.if.exists() {
  local file="$1"

  if [ -f "$file" ]; then
    source "$file"
  fi
}

#######################################
# Disables the input of the shell
#######################################
shell.input.disable() {
  if [[ -t 0 ]] ; then
    exec </dev/null
  fi
}
