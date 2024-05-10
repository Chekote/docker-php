#######################################
# Library of functions for working with Bash strings.
#######################################

#######################################
# Trims leading spaces from a provided string.
#######################################
string.ltrim() {
  sed -e 's/^[[:space:]]*//'
}

#######################################
# Trims trailing spaces from a provided string.
#######################################
string.rtrim() {
  sed -e 's/[[:space:]]*$//'
}

#######################################
# Trims spaces from both sides of a provided string.
#######################################
string.trim() {
  string.ltrim | string.rtrim
}

#######################################
# Escape special chars for grep regex pattern.
#######################################
string.grep.regex.escape() {
  sed -E 's/([@?$|^*(+{\[\\/])/\\\1/g'
}

#######################################
# Escape special chars for sed regex pattern.
#######################################
string.sed.regex.escape() {
  sed -E 's/([&|`?$#@^*\\)\\(+{\[/])/\\\1/g' | sed -E 's/\\{1,}(\$|\()/\\\1/g' | sed -E 's/\\{1,}`/`/g'
}

######################################
# Creates a hash based on the given string value
#
# Arguments:
#   1 the string value
#   2 length of the output hash [Optional] [Default=10, Min=1, Max=64]
#######################################
string.hash() {
  local value
  value=$(echo -n "$1" | sha256sum)
  local length=${2:-10}

  [[ $length -lt 1 ]] && length=1;
  [[ $length -gt 64 ]] && length=64;

  echo -n "${value:0:$length}"
}

######################################
# Simple string interpolation.
#
# If the string is a variable, then it will be replaced with the variables value.
#
# Note: This is intentionally simplistic. If we determine a need to support more complex string interpolation in the
# future, then we can expand this functions capability at that point.
#
# Arguments:
#   1 the string value to interpolate
#
# Output:
#   The interpolated string
#######################################
string.interpolate() {
    local string="$1"

    # If the string starts with a dollar sign
    if [[ "$string" == \$* ]]; then
      local variable_name

      # Strip the variable notation
      variable_name=${string/\$/}
      variable_name=${variable_name/\{/}
      variable_name=${variable_name/\}/}

      # Evaluate the variable name to get the value
      string="${!variable_name}"
    fi

    echo "$string"
}

#######################################
# Tests whether a given regex matches a specified string
#
# Arguments:
#   1 the regex to use for checking
#   2 the string to be searched
#
# Output:
#   0 if the string matches the regex, 1 otherwise
#######################################
string.regex.test() {
  local regex="$1"
  local input_string="$2"

  [[ "$input_string" =~ $regex ]]
}
