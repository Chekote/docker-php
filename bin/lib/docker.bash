#######################################
# Library of functions for working with Docker.
#
# https://www.docker.com/
#######################################

. bin/lib/dir.bash
. bin/lib/dotenv.bash
. bin/lib/file.bash
. bin/lib/out.bash
. bin/lib/shell.bash
. bin/lib/string.bash

#######################################
# Ensures that all images referenced in a Docker Compose file are available locally.
#
# @see docker.image.ensure.is.pulled
#
# Arguments:
#   1 the Docker Compose file referencing the desired.
#######################################
docker.compose.images.ensure.pulled() {
  # Export the function so it is available to the Bash subshell that we'll use via xargs below
  export -f docker.image.ensure.is.pulled

  # Temporarily disable pipefail, because we don't want grep not finding any matches to be considered an error
  set +o pipefail

  # Grab the images (if any) and call docker.image.ensure.is.pulled for each.
  for image in $(grep 'image:' "$1" | sed 's/image: //'); do
    docker.image.ensure.is.pulled "$(string.interpolate "$image")"
  done

  # Re-enable pipefail
  set -o pipefail
}

#######################################
# Initializes the .env environment within the docker directory.
#######################################
docker.env.init() {
  (cd docker && dotenv.init)
}

#######################################
# Determines the UID of the user running the Docker containers.
#
# Output
#   The UID of the user running the Docker containers.
#######################################
docker.host.user.id() {
  if [ "$(uname)" == 'Linux' ]; then
    # We're on Linux. There's no virtualization, so we use our own UID.
    id -u
  else
    # We're not on Linux. The User ID doesn't really matter on non-linux hosts as modern Docker allows any user within
    # the container to have full read/write access to mounted volumes. But to make it easier for users of this script
    # to work with the env var, we'll set this to something innocuous so it can still be passed to commands and used in
    # docker compose config files.
    echo 1000
  fi
}

#######################################
# This function populates a global associative array, SERVICE_IMAGES,
# with service names as keys and their corresponding image names as values.
# The data is parsed from the Docker Compose files passed as arguments.
#
# Arguments:
#   One or more Docker Compose files to parse.
#######################################
docker.yaml.images.parse() {
  local yaml_file serviceName image

  # declare global associative array
  declare -Ag SERVICE_IMAGES

  # Iterate over each yaml file
  for yaml_file in "$@"; do
    # Skip file if there is no services key
    if ! yq e -e ".services" "$yaml_file" > /dev/null; then
      continue
    fi

    # Use yq to extract all service names and images, then iterate over them
    while IFS='=' read -r serviceName image; do
      sanitized_image=$(printf '%s' "$image" | sed 's/[^[:print:]]//g')
      if [ "$sanitized_image" != "null" ]; then
        # this is a global associative array, so we don't need to export it
        # shellcheck disable=SC2034
        SERVICE_IMAGES["$serviceName"]="$sanitized_image"
      fi
    done < <(yq e '.services | to_entries | .[] | .key + "=" + (.value.image // "null")' "$yaml_file")
  done
}

#######################################
# Ensures that a Docker image is available locally.
#
# Will first check if the tag is already present locally, and if not, will delegate to docker.image.resilient.pull.
#
# Arguments:
#   1 the image to ensure is available locally.
#######################################
docker.image.ensure.is.pulled() {
  local image="$1";

  # If the image already exists, then exit
  if [ "$(docker image ls -q "$image")" != '' ]; then
    return;
  fi

  docker.image.resilient.pull "$image"

  return $?
}

#######################################
# Attempts to pull a Docker image up to 10 times.
#
# Arguments:
#   1 the image to pull.
#######################################
docker.image.resilient.pull() {
  local image="$1";

  shell.command.retry docker image pull "$image"

  return $?
}

#######################################
# Attempts to login to a Docker registry multiple times to overcome transient network issues.
#
# Arguments:
#   1 the docker username
#   2 the docker password
#   3 [optional] the docker registry
#######################################
docker.login.ensure() {
  local username="$1";
  local password="$2";
  local registry="${3:-}"

  # The try var is just for iteration, but the value is not needed. So suppress the shellcheck warning
  # shellcheck disable=SC2034
  for try in {1..10}; do
    echo "$password" | docker login -u "$username" --password-stdin "$registry" && return;
  done;

  out.error.ln "Failed to log in to Docker after 10 attempts."
  return 1;
}

#######################################
# Ensures that the docker network exists, and returns the name
#
# Arguments:
#   1 The name of the network. Defaults to 'global'
#
# Output
#   The name of the network.
#######################################
docker.network.init() {
  local docker_network="${1:-global}"

  if [[ "$(docker network ls | grep -c "$docker_network" | awk '{ print $1 }')" = 0 ]]; then
    docker network create "$docker_network" > /dev/null
  fi

  echo "$docker_network"
}

#######################################
# Generates a string of standard options that should be used for all "docker run" commands.
#
# Output
#   The options string
#######################################
docker.run.options() {
  local options='';

  if [ -f docker/.env ]; then
    options='--env-file docker/.env'
  fi

  echo "$options"
}

#######################################
# Determines if the current shell supports TTY, and if so, outputs the -t option.
#
# Output
#   The -t option if the current shell supports TTY
#######################################
docker.tty() {
  if [[ -t 0 ]] ; then
    echo "-t";
  fi
}

#######################################
# Creates a Docker volume
#
# Arguments:
#   1 the volume name
#   2 the volume path
#   3 the volume type
#   4 the volume opts
#######################################
docker.volume.create() {
  local volume_name="$1"
  local volume_path="$2"
  local volume_type="$3"
  local volume_opts="$4"

  echo "Creating Docker Volume $volume_name for path $volume_path"

  if [ "${VOLUME_TYPES[$volume_name]}" = "$DIRECTORY" ]; then
    dir.ensure.exists "$volume_path"
  else
    file.ensure.exists "$volume_path"
  fi

  if [[ $volume_type = 'nfs' ]]; then
    volume_path=":$volume_path"
  fi

  docker volume create \
    --driver local \
    --opt type="$volume_type" \
    --opt o="$volume_opts" \
    --opt device="$volume_path" \
    "$volume_name" > /dev/null
}

#######################################
# Recreate a Docker volume if the existing volume is mounted from incorrect location.
#
# Arguments:
#   1 the volume name
#   2 the volume path
#   3 the volume type
#   4 the volume opts
#######################################
docker.volume.ensure.has.path() {
  local volume_name="$1"
  local volume_path="$2"
  local volume_type="$3"
  local volume_opts="$4"

  if [[ $(docker volume inspect --format '{{.Options.device}}' "$volume_name" | sed 's/^://') != "$volume_path" ]]; then
    docker volume rm "$volume_name"
    docker.volume.create "$volume_name" "$volume_path" "$volume_type" "$volume_opts"
  fi
}

