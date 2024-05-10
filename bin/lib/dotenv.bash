#######################################
# Library of functions for working with .env files
#
# See https://www.dotenv.org/
# See https://www.npmjs.com/package/dotenv
# See https://github.com/vlucas/phpdotenv
#######################################

. bin/lib/diff.bash
. bin/lib/out.bash

#######################################
# Creates or checks a .env file from a .env.example file
#######################################
dotenv.init() {
  # Create the .env file if it does not exist
  if [ ! -e .env ]; then
    out.success.ln "No .env file found in $(pwd). Creating from .env.example..."
    dotenv.create
    return;
  fi

  # The dotenv file exists. If it matches the example, we're done
  if dotenv.check; then
    return;
  fi

  # It doesn't match the example. Ask the user how they want to proceed (if we're not in CI)
  if [ "${CI:-}" != true ] ; then
    dotenv.init.prompt
  fi
}

#######################################
# Prompts the user to confirm whether or not they want to revert changes to .env so that it matches .env.example
#######################################
dotenv.init.prompt() {
  while true; do
    read -r -p 'Would you like to revert changes to .env so it matches .env.example? ' response
    case "$response" in
      [Yy]* ) dotenv.create; break;;
      [Nn]* ) break;;
      * ) echo "Please answer yes or no (y/n).";;
    esac
  done
}

#######################################
# Creates a .env file from a .env.example file
#######################################
dotenv.create() {
  cp .env.example .env
}

#######################################
# Updates a .env file with a .env.example file
#######################################
dotenv.check() {
  diff="$(diff.diff .env .env.example)"

  if [ -z "$diff" ]; then
    out.info.ln ".env file exists in $(pwd), and matches example."
    return 0;
  fi

  out.warn.ln ".env file exists in $(pwd), but does NOT match example."
  out.warn.ln "NOTE: Please note the following differences, and update your .env if necessary:"
  out.print.ln
  out.warn.ln "$diff"
  out.print.ln

  return 1;
}
