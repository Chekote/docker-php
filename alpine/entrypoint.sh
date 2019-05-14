#!/usr/bin/env sh

if [ "$PHP_FPM_USER_ID" != "" ]; then
    usermod -u $PHP_FPM_USER_ID nobody
fi

# Set php.ini options
PHP_INI=/etc/php$PHP_MAJOR_VERSION/php.ini

# Update the PHP upload_max_filesize setting if one was specified
if [ "$PHP_UPLOAD_MAX_FILESIZE" != "" ]; then
    sed -i "s!upload_max_filesize = 2M!upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE!g" "$PHP_INI"
fi

# Update the post_max_size setting if one was specified
if [ "$PHP_POST_MAX_SIZE" != "" ]; then
    sed -i "s!post_max_size = 8M!post_max_size = $PHP_POST_MAX_SIZE!g" "$PHP_INI"
fi

/usr/local/bin/entrypoint.sh "$@"
