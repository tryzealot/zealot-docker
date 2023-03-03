echo "${_group}Configuring Docker volumes ..."

##
## Create docker volumes for zealot
##
create_docker_volumes () {
  # always remove zealot-app volume to make sure use old zealot data
  local HAS_APP_VOLUME=$(docker volume ls | grep -v DRIVER | grep zealot-app | wc -l 2> /dev/null)
  if [ -z "$HAS_APP_VOLUME" ]; then
    docker volume rm zealot-app
  fi

  echo "Created $(docker volume create --name=zealot-uploads)."
  echo "Created $(docker volume create --name=zealot-backup)."
  echo "Created $(docker volume create --name=zealot-postgres)."
  echo "Created $(docker volume create --name=zealot-redis)."

  cat $TEMPLATE_DOCKER_COMPOSE_PATH/external-volumes.yml >> $DOCKER_COMPOSE_FILE
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
    mkdir -p "$stored/zealot/uploads"
    mkdir -p "$stored/zealot/backup"
    mkdir -p "$stored/redis"
    mkdir -p "$stored/postgres"

    sed -i -e 's|zealot-uploads|'"$stored"'/uploads|g' $DOCKER_COMPOSE_FILE
    sed -i -e 's|zealot-backup|'"$stored"'/backup|g' $DOCKER_COMPOSE_FILE
    sed -i -e 's|zealot-redis|'"$stored"'/redis|g' $DOCKER_COMPOSE_FILE
    sed -i -e 's|zealot-postgres|'"$stored"'/postgres|g' $DOCKER_COMPOSE_FILE
    clean_sed_temp_file $DOCKER_COMPOSE_FILE

    echo "Local volumes '$stored' write to file: $DOCKER_COMPOSE_FILE"
  fi
}

choose_volumes () {
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


VOLUMES_EXISTS=$(grep -cE "^(\s+)zealot\-(\w+):" $DOCKER_COMPOSE_FILE || echo 0)
if [ "$VOLUMES_EXISTS" -eq 4 ]; then
  echo "Volumes already exists, skipped"
else
  choose_volumes
fi

echo "${_endgroup}"
