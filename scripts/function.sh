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
HAS_DOCKERDOCKER_COMPOSE_FILE="false"

TEMPLATE_PATH="templates"
TEMPLATE_DOCKER_COMPOSE_PATH="${TEMPLATE_PATH}/docker-compose"
TEMPLATE_CADDY_FILE="${TEMPLATE_PATH}/Caddyfile"

CADDY_PATH="caddy"
CADDY_ROOTFS_PATH="/etc/caddy"
CADDYFILE_NAME="Caddyfile"
CERTS_NAME="certs"


if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  _group="::group::"
  _endgroup="::endgroup::"
else
  _group="▶ "
  _endgroup=""
fi

dc="docker-compose --ansi never"
dcr="$dc run --rm"

##
## Current OS name
##
current_os() {
  echo `uname -s`
}

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
