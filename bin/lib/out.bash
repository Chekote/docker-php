#######################################
# Library of functions for outputting content.
#######################################

. bin/lib/colors.bash

#######################################
# Outputs a single line of text without a line break at the end, and resets the color to "No Color".
#
# Environment Variables:
#   NC the terminal sequence to set no color.
#
# Arguments:
#   1 the text to output
#######################################
out.print() {
  echo -ne "$1$COLOR_NONE"
}

#######################################
# Outputs a single line of informational text with a line break at the end, and resets the color to "No Color".
#
# Arguments:
#   1 [optional] the text to output. Defaults to an empty string (followed by a line break)
#######################################
out.print.ln() {
  out.print "${1:-}\n"
}

#######################################
# Outputs a single line of informational text without a line break at the end, and resets the color to "No Color".
#
# Arguments:
#   1 the text to output
#######################################
out.info() {
  out.print "$1"
}

#######################################
# Outputs a single line of informational text with a line break at the end, and resets the color to "No Color".
#
# Arguments:
#   1 the text to output
#######################################
out.info.ln() {
  out.info "$1\n"
}

######################################
# Outputs a single line of informational text denoting the start of a section of text.
#
# The text will be preceded with a blank line, and a line break at the end, and resets the color to "No Color".
#
# Arguments:
#   1 the text to output
#######################################
out.info.section.start() {
  out.info.ln "\n$1"
}

#######################################
# Outputs a single line of warning text with a line break at the end, and resets the color to "No Color".
#
# Environment Variables:
#   YELLOW the terminal sequence to set no color.
#
# Arguments:
#   1 the text to output
#######################################
out.warn() {
  out.print "$COLOR_FG_YELLOW$1"
}

#######################################
# Outputs a single line of warning text with a line break at the end, and resets the color to "No Color".
#
# Arguments:
#   1 the text to output
#######################################
out.warn.ln() {
  out.warn "$1\n"
}

#######################################
# Outputs a single line of success text with a line break at the end, and resets the color to "No Color".
#
# Environment Variables:
#   GREEN the terminal sequence to set no color.
#
# Arguments:
#   1 the text to output
#######################################
out.success() {
  out.print "$COLOR_FG_GREEN$1"
}

#######################################
# Outputs a single line of success text with a line break at the end, and resets the color to "No Color".
#
# Arguments:
#   1 the text to output
#######################################
out.success.ln() {
  out.success "$1\n"
}

#######################################
# Outputs a single line of error text with a line break at the end, and resets the color to "No Color".
#
# Environment Variables:
#   RED the terminal sequence to set no color.
#
# Arguments:
#   1 the text to output
#######################################
out.error() {
  >&2 out.print "$COLOR_FG_RED$1"
}

#######################################
# Outputs a single line of error text with a line break at the end, and resets the color to "No Color".
#
# Arguments:
#   1 the text to output
#######################################
out.error.ln() {
  out.error "$1\n"
}
