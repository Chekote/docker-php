# Docker image for PHP

A [Docker](https://www.docker.com) image for the [PHP](https://secure.php.net/) Command Line scripting language.

To use the container with a project, do the following:

  * Copy the bin directory into your project.

  * Ensure that your profile PATH includes `./bin` and that it takes priority over any other directory that may include a php executable:

        PATH=./bin:$PATH

Now whenever you are in your project's directory, you can simply execute `php` as you would with a typical composer installation, and the command will execute in the container instead:

    php -r 'phpinfo();'

# User ID control

It is possible to control what UID the initial process (usually PHP) and/or PHP-FPM processes run as. The `bin/php` file already does this for the initial process.

This is important if you are mounting a volumes into the container, as the the UID of the initial process or PHP-FPM will likely need to match the volume to be able to read and/or write to it.

Note: You should _NOT_ try to set the UID using Dockers -u or --user option, as this does not ensure that the user actually exists (entry in `/etc/passwd` home directory etc).

## Initial process UID

To set the UID for the initial process, you should set a `LOCAL_USER_ID` environmental variable on the container. e.g:

    docker run -e LOCAL_USER_ID=1000 chekote/php:5.6.30-a php -v

## PHP-FPM user

To set the user that the PHP-FPM process runs as, you can set the php.ini directives "user" and "listen.owner" using the "php.ini directives" feature outlined in the section below. e.g:

    docker run -e PHP_FPM_USER=1000 -e PHP_FPM_LISTEN__OWNER=1000 chekote/php:5.6.30-a php-fpm5.6

# php.ini directives

You can modify any php.ini directives by setting environmental variables within the container. This can be accomplished by prefixing the variable with the particular environment to be affected (FPM, CLI or ALL for both).

Note: If you want to set a directive that has a period in the name, you should substitude the period for a double underscore in your environmental variable name. e.g. to set the PHP FPM listen.owner directive, you would use an environmental variable named PHP_FPM_LISTEN__OWNER.

A few examples:

| environmental variable         | php.ini directives                                                                                        | php.ini config file |
|--------------------------------|-----------------------------------------------------------------------------------------------------------|---------------------|
| `PHP_FPM_POST_MAX_SIZE`        | [`post_max_size`](http://php.net/manual/en/ini.core.php#ini.post-max-size)                                | fpm                 |
| `PHP_ALL_UPLOAD_MAX_FILESIZE`  | [`upload_max_filesize`](http://php.net/manual/en/ini.core.php#ini.upload-max-filesize)                    | fpm, cli            |
| `PHP_CLI_MAX_FILE_UPLOADS`     | [`max_file_uploads`](https://php.net/manual/en/ini.core.php#ini.max-file-uploads)                         | cli                 |
| `PHP_FPM_PM__MAX_CHILDREN`     | [`pm.max_children`](https://www.php.net/manual/en/install.fpm.configuration.php#pm.max-children)          | fpm                 |
| `PHP_ALL_SESSION__SAVE_PATH`   | [`session.save_path`](https://www.php.net/manual/en/session.configuration.php#ini.session.save-path)      | fpm, cli            |
| `PHP_ALL_SESSION__SAVE_HANDLER`| [`session.save_handler`](https://www.php.net/manual/en/session.configuration.php#ini.session.save-handler)| fpm, cli            |

e.g. the following will start a PHP container with the `post_max_size` to 30 Megabytes for both CLI and FPM:

`docker run -e PHP_ALL_UPLOAD_MAX_FILESIZE=30M chekote/php:7`

and the following will start a PHP container with the `pm.max_children` setting to 50 for FPM processes:

`docker run -e PHP_FPM_PM__MAX_CHILDREN=50 chekote/php:7`

and the following will start a PHP container with the `session.save_handler` on both FPM and CLI using redis:

`docker run -e PHP_ALL_SESSION__SAVE_HANDLER=redis chekote/php:7`

# Distribution

Docker Hub : https://hub.docker.com/r/chekote/php/
