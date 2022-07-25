#!/usr/bin/env bash

replace_in_files() {
    PHP_CONFIG_FILES="$1"
    VAR_MATCH="$2"
    REPLACE_VARS=$(printenv | awk -F'=' '{print $1}' | grep -E "^$VAR_MATCH")

    # If there are variables to be replace move forward
    if [ -n "$REPLACE_VARS" ]; then
      for VAR_NAME in $REPLACE_VARS; do
        # get the directive name by removing the prefixes e.g. PHP_CLI and making them lowercase.
        # if there are any double '_' replace with a dot.
        DIRECTIVE=$(echo "$VAR_NAME" | cut -c9- | tr '[:upper:]' '[:lower:]' | sed 's!__!.!g')
        VALUE=$(printenv "$VAR_NAME")

        # Replace the variable only if it starts with the name of the directive and remove optional ';'
        # Some directives will not have spaces after the directive name. i.e opcache
        find "$PHP_CONFIG_FILES" -follow -type f -exec \
            sed -i "s!^;\?$DIRECTIVE \?=[^\n]*!$DIRECTIVE=$VALUE!g" {} \;
      done
    fi
}

# Set php.ini options
for TYPE in cli fpm; do
    PHP_CONFIG_FILES="/etc/php/$PHP_VERSION/$TYPE/"
    VAR_TYPE="$(echo "PHP_$TYPE" | tr '[:lower:]' '[:upper:]')"

    # Replace all variables ( prefixed by PHP_TYPE ) on the proper PHP type file
    replace_in_files "$PHP_CONFIG_FILES" "$VAR_TYPE"

    # Replace all variables ( prefixed by PHP_ALL )
    replace_in_files "$PHP_CONFIG_FILES" "PHP_ALL"
done

/usr/local/bin/entrypoint.sh "$@"
