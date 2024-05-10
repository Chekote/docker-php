#######################################
# Library of functions for the diff tool
#
# https://www.man7.org/linux/man-pages/man1/diff.1.html
#######################################

##
# Wrapper for diff that causes the exit code to behave how you would expect
#
# As the time of writing, diff uses three exit codes:
#   0 no difference
#   1 a difference
#   2 error
#
# This causes a problem because diff is using 1 to communicate something other
# than an error, but the shell considers any exit code other than zero to be
# an error. As a result, when set -e is active, any scripts that call diff
# and find a difference will exit as if an error had occurred.
#
# To fix this, this method captures the exit code and only returns it if it is
# higher than 1.
#
# Arguments:
#   1 The first file to pass to diff
#   2 The second file to pass to diff
#
# Output:
#   The diff (if there is a difference)
##
diff.diff () {
  local file_one="$1"
  local file_two="$2"
  local diff
  local exitCode

  # Temporarily suppress -e because diff returns exit code 1 if the files don't match
  set +e
  diff="$(diff "$file_one" "$file_two")"
  exitCode=$?
  set -e

  if [ $exitCode -gt 1 ]; then
    # Exit code 1 just means there was a difference, not an error. So only return an error if the exit code is > 1
    return $exitCode
  elif [ -n "$diff" ]; then
    # Otherwise output the diff (if we have one)
    echo "$diff"
  fi
}
