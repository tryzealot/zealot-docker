echo "${_group}Configuring Docker volumes ..."

detect_volumes_exists () {
  local HAS_APP_VOLUME=$(docker volume ls | grep -v DRIVER | grep zealot- | wc -l 2> /dev/null)

  # if gt 0, means zealot volumes exists, return 0
  if [ $HAS_APP_VOLUME -gt 0 ]; then
    echo "Zealot volumes already exists, skipped"
    return 0
  fi
}

##
## Create docker volumes for zealot
##
create_docker_volumes () {
  # always remove zealot-app volume to make sure use old zealot data
  local HAS_APP_VOLUME=$(docker volume ls | grep -v DRIVER | grep zealot-app | wc -l 2> /dev/null)
  if [ -z "$HAS_APP_VOLUME" ]; then
    docker volume rm zealot-app
  fi

  # check if detect_volumes_exists, if not use below code flow
  detect_volumes_exists && return 0

  echo "Created $(docker volume create --name=zealot-uploads)."
  echo "Created $(docker volume create --name=zealot-backup)."
  echo "Created $(docker volume create --name=zealot-postgres)."

  if [ "${REDIS_ENABLED_LEGACY:-0}" == 1 ]; then
    echo "Created $(docker volume create --name=zealot-redis)."
    cat $TEMPLATE_DOCKER_COMPOSE_PATH/external-volumes-redis.yml >> $DOCKER_COMPOSE_FILE
  else
    cat $TEMPLATE_DOCKER_COMPOSE_PATH/external-volumes.yml >> $DOCKER_COMPOSE_FILE
  fi

  echo "Exteral volumes write to file: $DOCKER_COMPOSE_FILE"
}

configure_local_docker_volumes() {
  echo "Which path do you want to storage?"
  printf "ZEALOT_STORED_PATH="
  read stored

  if [ -z "$stored" ]; then
    echo "Read ZEALOT_STORED_PATH failed, Quitting"
    exit
  else
    if [ "${REDIS_ENABLED_LEGACY:-0}" == 1 ]; then
      cat $TEMPLATE_DOCKER_COMPOSE_PATH/local-volumes-redis.yml >> $DOCKER_COMPOSE_FILE
      mkdir -p "$stored/redis"
    else
      cat $TEMPLATE_DOCKER_COMPOSE_PATH/local-volumes.yml >> $DOCKER_COMPOSE_FILE
    fi

    mkdir -p "$stored/zealot/uploads"
    mkdir -p "$stored/zealot/backup"
    mkdir -p "$stored/postgres"

    sed -i -e 's|/tmp|'"$stored"'|g' $DOCKER_COMPOSE_FILE
    clean_sed_temp_file $DOCKER_COMPOSE_FILE

    echo "Local volumes '$stored' write to file: $DOCKER_COMPOSE_FILE"
  fi
}

choose_volumes () {
  set +u
  echo "ZEALOT_FORCE_VOLUME=${ZEALOT_FORCE_VOLUME}"

  if [ -n "$ZEALOT_FORCE_VOLUME" ]; then
    case "$ZEALOT_FORCE_VOLUME" in
      "docker" )
        create_docker_volumes;;
      "local" )
        configure_local_docker_volumes;;
      * )
        echo "Invalid ZEALOT_FORCE_VOLUME value, Quitting"
        exit
        ;;
    esac
    set -u
    return
  fi
  set -u

  printf "Which way do you choose to storage zealot data?\n\
  Use Docker [V]olumes (default)\n\
  Use [L]ocal file system\n"
  read -n 1 action
  echo ""

  local STORAGE=volumes
  case "$action" in
    V | v )
      create_docker_volumes;;
    L | l )
      configure_local_docker_volumes;;
    * )
      ;;
  esac

  if [ -z "$action" ]; then
    create_docker_volumes
  fi
}

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
  VOLUMES_EXISTS=$(grep -cE "^(\s+)zealot\-(\w+):" $DOCKER_COMPOSE_FILE || true)
else
  VOLUMES_EXISTS=0
fi
echo "VOLUMES_EXISTS=$VOLUMES_EXISTS"
if [[ "$VOLUMES_EXISTS" -gt 3 ]]; then
  echo "Volumes already exists, skipped"
else
  choose_volumes
fi

echo "${_endgroup}"
