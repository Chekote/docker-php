#######################################
# Library of functions for working with files.
#######################################

#######################################
# Ensures that the specified file exists
#
# Arguments:
#   1 The path for the file
# Returns:
#   0 if the file already exists, or if it is created successfully
#   1 if the path exists, but it is not a file
#######################################
file.ensure.exists() {
  local file="$1"

  if [[ ! -e "$file" ]]; then
    echo "$file doesn't exist, creating the file..." 1>&2
    touch "$file"
    return 0
  elif [[ ! -f "$file" ]]; then
    echo "$file already exists but is not a file" 1>&2
    return 1
  fi
}

#######################################
# Checks if a file contains a specific line
#
# Arguments:
#   1 the line to check for
#   2 the path of the file to check
#######################################
file.has.line() {
  local line="$1"
  local file="$2"

  grep -qF -- "$line" "$file"

  return $?
}

#######################################
# Ensure a file contains a specific line via sudo
#
# Arguments:
#   1 message to output
#   2 the line to write
#   3 the file path
#######################################
file.sudo.ensure.has.line() {
  local message="$1"
  local line="$2"
  local file="$3"

  if file.has.line "$line" "$file"; then
    echo " - $message already exists on $file, skipping..."
  else
    echo " - $message"
    file.sudo.write.line "$line" "$file"
  fi
}

#######################################
# Writes the specified data to a file at the provided
# file path, overwriting the file if it already exists
#
# Arguments:
#   1 the data to be written to the file
#   2 the file path where the data will be written
#######################################
file.create.or.replace() {
  local data="$1"
  local file="$2"

  echo "$data" > "$file"
}

#######################################
# Writes a line to a file using sudo
#
# Arguments:
#   1 the line to write
#   2 the path of the file to write to
#######################################
file.sudo.write.line() {
  local line="$1"
  local file="$2"

  echo "$line" | sudo tee -a "$file" > /dev/null
}

#######################################
# Checks if a file exists and exits
# if it does not.
#
# Arguments:
#   1 the line number within the scenario
#######################################
exit_if_file_does_not_exist() {
  local file="$1"

  if [ ! -f "$file" ]; then
      echo "$file does not exist."
      exit 1;
  fi
}

#######################################
# Retrieves the line count of a file
# exiting if that file doesn't exist
#
# Arguments:
#   1 the file to determine the line count of
#######################################
get_file_line_count() {
  local file="$1"

  exit_if_file_does_not_exist "$file"

  wc -l "$file"  | awk '{ print $1 }'
}

#######################################
# Determine if a string is a proper scenario
#
# Arguments:
#   1 the string to compare
#######################################
is_string_a_scenario_title() {
  local line_contents="$1"
  if [[ "$line_contents" == "  Scenario: "* || "$line_contents" == "  Scenario Outline: "* ]]; then
    echo "true"
  else
    echo "false"
  fi
}

#######################################
# Retrieves the scenario based on a given line number
# or returns the file if the background was updated
#
# Arguments:
#   1 the line number within the scenario
#   2 the file to search within
#######################################
get_scenario_by_line_number_of_feature_file() {
  local line_number="$1"
  local file="$2"

  # We're just using this as a label for the infinite loop. So the constant is intentional.
  # shellcheck disable=SC2078
  while [[ 'A Scenario or the Background has not been found' ]]; do
    if [[ "$line_number" == '0' ]]; then
      break
    fi

    line_contents="$(sed "${line_number}q;d" "$file")"

    if [[ "$line_contents" == "  Scenario: "* || "$line_contents" == "  Scenario Outline: "* ]]; then
      echo "${line_contents/*: /}"
      break
    fi

    if [[ "$line_contents" == "  Background:"* ]]; then
      echo "$file"
      break
    fi

    line_number="$((line_number-1))"
  done
}

#######################################
# Retrieves the scenarios in a given feature file
# exiting if that file doesn't exist
# Arguments:
#   1 the file to retrieve scenarios from
#######################################
get_scenarios_from_file() {
  local file="$1"

  exit_if_file_does_not_exist "$file"

  current_line=$(get_file_line_count "$file")

  while [[ current_line -gt 0 ]]; do
    line_contents=$(sed "${current_line}q;d" "$file")

    if [[ $(is_string_a_scenario_title "$line_contents") == "true" ]]; then
      echo "${line_contents/*: /}"
    fi

    if [[ "$line_contents" == "  Background:"* ]]; then
      break
    fi

    current_line="$((current_line-1))"
  done
}

########################################################
# Filters a list of files based on a grep pattern
#
# Arguments:
#   1 The pattern to filter file names by
#   * A list of paths to one or more files
########################################################
file.list.filter () {
  local pattern="$1"
  local files=( "${@:2}" )
  local filtered_files=""

  for file in "${files[@]}"; do
    if echo "$file" | grep -q $pattern; then
      filtered_files="$filtered_files $file"
    fi
  done

  echo "$filtered_files"
}
