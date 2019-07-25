#!/usr/bin/env sh

if [ "$PHP_FPM_USER_ID" != "" ]; then
    (>&2 echo "Warning: PHP_FPM_USER_ID is deprecated. Please use WWW_DATA_USER_ID instead.")
    WWW_DATA_USER_ID=$PHP_FPM_USER_ID
fi

# Set the uid that www-data will run as if one was specified
if [ "$WWW_DATA_USER_ID" != "" ]; then
    usermod -u $WWW_DATA_USER_ID www-data
fi

replace_in_file() {
    PHP_FILE=${1}
    VAR_MATCH=${2}
    REPLACE_VARS=`printenv | awk -F'=' '{print $1}' | grep -E "^$2"`

    # If there are variables to be replace move forward
    if [ ! -z "$REPLACE_VARS" ]; then
      for VAR_NAME in $REPLACE_VARS; do
        # get the directive name by removing the prefixes e.g. PHP_CLI and making them lowercase.
        # if there are any double '_' replace with a dot.
        DIRECTIVE=`echo "$VAR_NAME" | cut -c9- | tr '[:upper:]' '[:lower:]' | sed 's/__/./g'`
        VALUE=`printenv "$VAR_NAME"`

        # Replace the variable only if it starts with the name of the directive and remove optional ';'
        sed -i "s!^\(;\)\{0,1\}$DIRECTIVE = [^\n]\+!$DIRECTIVE = $VALUE!g" "$PHP_FILE"
      done
    fi
}


# Set the php.ini file locations.
PHP_CLI_INI=/etc/php/$PHP_MAJOR_VERSION/cli/php.ini
PHP_FPM_INI=/etc/php/$PHP_MAJOR_VERSION/fpm/php.ini

# Replace all CLI variables ( prefixed by CLI )
replace_in_file $PHP_CLI_INI "PHP_CLI"

# Replace all FPM variables ( prefixed by FPM )
replace_in_file $PHP_FPM_INI "PHP_FPM"

# Replace variables on both files ( prefixed by ALL ).
replace_in_file $PHP_CLI_INI "PHP_ALL"
replace_in_file $PHP_FPM_INI "PHP_ALL"

/usr/local/bin/entrypoint.sh "$@"
