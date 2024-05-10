#######################################
# Library of functions for working with directories.
#######################################

#######################################
# Ensures that the specified directory exists
#
# Arguments:
#   1 The path for the directory
# Returns:
#   0 if the directory already exists, or if it is created successfully
#   1 if the path exists, but it is not a directory
#######################################
dir.ensure.exists() {
  local dir="$1"

  if [[ ! -e "$dir" ]]; then
    echo "$dir doesn't exist, creating the directory..." 1>&2
    mkdir -p "$dir"
    return 0
  elif [[ ! -d "$dir" ]]; then
    echo "$dir already exists but is not a directory" 1>&2
    return 1
  fi
}
