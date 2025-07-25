#!/usr/bin/env sh

replace_var_in_files() {
    local PHP_CONFIG_FILES="$1"
    local VAR_NAME="$2"

    # get the directive name by removing the prefixes e.g. PHP_CLI and making them lowercase.
    # if there are any double '_' replace with a dot.
    DIRECTIVE=$(echo "$VAR_NAME" | cut -c9- | tr '[:upper:]' '[:lower:]' | sed 's!__!.!g')
    VALUE=$(printenv "$VAR_NAME")

    # Replace the variable only if it starts with the name of the directive and remove optional ';'
    # Some directives will not have spaces after the directive name. i.e opcache
    find $PHP_CONFIG_FILES -follow -type f -exec sed -i "s!^;\?$DIRECTIVE \?=[^\n]*!$DIRECTIVE=$VALUE!g" {} \;
}

replace_in_files() {
    PHP_CONFIG_FILES="$1"
    VAR_MATCH="$2"
    REPLACE_VARS=$(printenv | awk -F'=' '{print $1}' | grep -E "^$VAR_MATCH")

    # If there are variables to be replace move forward
    if [ -n "$REPLACE_VARS" ]; then
      for VAR_NAME in $REPLACE_VARS; do
        replace_var_in_files "$PHP_CONFIG_FILES" "$VAR_NAME"
      done
    fi
}

get_config_files() {
  local TYPE="$1"

  distro="$(get_distro_name)"

  case "$distro" in
      alpine)
          if [ "$TYPE" = "fpm" ]; then
              echo "/etc/php$PHP_VERSION/php-fpm.*"
          else
              echo "/etc/php$PHP_VERSION/conf.d /etc/php$PHP_VERSION/php.ini"
          fi
          ;;
      ubuntu)
          echo "/etc/php/$PHP_VERSION/$TYPE"
          ;;
      *)
          echo "Unknown distro: $distro" >&2
          return 1
          ;;
  esac
}

get_distro_name() {
  if [ -f /etc/os-release ]; then
    sed -n 's/^ID=//p' /etc/os-release | tr -d '"'
  else
    echo "unknown"
    return 1
  fi
}

# Set php.ini options
for TYPE in cli fpm; do
    PHP_CONFIG_FILES="$(get_config_files $TYPE)"
    VAR_TYPE="$(echo "PHP_$TYPE" | tr '[:lower:]' '[:upper:]')"

    # Replace all variables ( prefixed by PHP_TYPE ) on the proper PHP type file
    replace_in_files "$PHP_CONFIG_FILES" "$VAR_TYPE"

    # Replace all variables ( prefixed by PHP_ALL )
    replace_in_files "$PHP_CONFIG_FILES" "PHP_ALL"
done

/usr/local/bin/entrypoint.sh "$@"
