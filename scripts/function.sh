set -euo pipefail
test "${DEBUG:-}" && set -x

log_file="zealot_install_log-`date +'%Y-%m-%d_%H-%M-%S'`.txt"
exec &> >(tee -a "$log_file")

MINIMIZE_DOWNTIME="${MINIMIZE_DOWNTIME:-}"

ZEALOT_TAG=nightly
ZEALOT_USE_SSL=false

ZEALOT_ROOT=$(dirname $0)
EXAMPLE_ENV_FILE="config.env"
ENV_FILE=".env"
DOCKER_COMPOSE_FILE="docker-compose.yml"
HAS_DOCKER_COMPOSE_FILE="false"

TEMPLATE_PATH="templates"
TEMPLATE_DOCKER_COMPOSE_PATH="${TEMPLATE_PATH}/docker-compose"
TEMPLATE_CADDY_FILE="${TEMPLATE_PATH}/Caddyfile"

CADDY_PATH="caddy"
CADDY_ROOTFS_PATH="/etc/caddy"
CADDYFILE_NAME="Caddyfile"
CERTS_NAME="certs"

CURRENT_OS=$(uname -s)
CURRENT_OS_VERSION=$(uname -sm)
if ! [ -z "$(which lsb_release || echo "" 2> /dev/null)" ]; then
  CURRENT_OS_VERSION=$(lsb_release -ds)
fi

d="docker"
dc_base="$($d compose version &> /dev/null && echo 'docker compose' || echo 'docker-compose')"
dc="$dc_base --ansi never --env-file ${ENV_FILE}"
dcr="$dc run --rm"

if ! [ -z "$(which lima 2> /dev/null)"  ]; then
  d="lima nerdctl"
  dc_base="$d compose"
  dc="$dc_base --env-file ${ENV_FILE}"
  dcr="$dc run --rm"
elif ! [ -z "$(which nerdctl 2> /dev/null)"  ]; then
  d="nerdctl"
  dc_base="$d compose"
  dc="$dc_base --env-file ${ENV_FILE}"
  dcr="$dc run --rm"
fi

# Printing of group
if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  _group="::group::"
  _endgroup="::endgroup::"
else
  _group="▶ "
  _endgroup=""
fi

##
## Clean sed temp file (always -e as suffix) if exists
##
clean_sed_temp_file () {
  local FILENAME=$1
  if [ -f "${FILENAME}-e" ]; then
    rm ${FILENAME}-e
  fi
}

# Increase the default 10 second SIGTERM timeout
# to ensure celery queues are properly drained
# between upgrades as task signatures may change across
# versions
STOP_TIMEOUT=60 # seconds
