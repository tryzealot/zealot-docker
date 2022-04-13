# Compare dot-separated strings - function below is inspired by https://stackoverflow.com/a/37939589/808368
ver () { echo "$@" | awk -F. '{ printf("%d%03d%03d", $1,$2,$3); }'; }

detect_minium_version () {
  local name=$1
  local version=$2
  local min_version=$3

  if [[ "$(ver $version)" -lt "$(ver $min_version)" ]]; then
    echo "FAIL: Expected minimum $name version to be $min_version but found $version"
    exit 1
  fi

  echo "Using Container CLI tool: $CURRENT_OS_VERSION $name ($d) version $version"
}

##################
# Main
##################
echo "${_group}Checking requirements ..."

if [ "$d" == "docker" ]; then
  MIN_DOCKER_VERSION='20.10.0'
  MIN_COMPOSE_VERSION='1.28.0'

  DOCKER_VERSION=$($d version --format '{{.Server.Version}}')
  COMPOSE_VERSION=$($dc_bse version | head -n1 | sed -E 's/^.* version:? v?([0-9.]+),?.*$/\1/')

  detect_minium_version "Docker" "$DOCKER_VERSION" "$MIN_DOCKER_VERSION"
  detect_minium_version "Docker Compose" "$COMPOSE_VERSION" "$MIN_COMPOSE_VERSION"
elif ! [ -z "$d" ]; then
  MIN_NERDCTL_VERSION='1.5.0'
  NERDCTL_VERSION=$($d version --format '{{(index .Server.Components 0).Version}}' | head -n1 | sed -E 's/^v?([0-9.]+),?.*$/\1/')

  detect_minium_version "Nerdctl" "$NERDCTL_VERSION" "$MIN_NERDCTL_VERSION"
else
  echo "FAIL: No found any docker bin in your system, install docker & docker-compose or nerdctl first!"
  exit 1
fi

echo "${_endgroup}"
