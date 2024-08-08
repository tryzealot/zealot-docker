echo "${_group}Generating docker-compose.file ..."

ZEALOT_NO_SSL_PORT=${ZEALOT_NO_SSL_PORT:-"80"}

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
  echo "File already exists, skipped"
else
  echo "# Generated on $(date)" > $DOCKER_COMPOSE_FILE
  echo "# USE SSL: ${ZEALOT_USE_SSL}" >> $DOCKER_COMPOSE_FILE

  if [ "${REDIS_ENABLED_LEGACY:-0}" == 1 ]; then
    cat $TEMPLATE_DOCKER_COMPOSE_PATH/base-with-redis.yml >> $DOCKER_COMPOSE_FILE
  else
    cat $TEMPLATE_DOCKER_COMPOSE_PATH/base.yml >> $DOCKER_COMPOSE_FILE
  fi

  if [ "$ZEALOT_USE_SSL" == "false" ]; then
    echo "    ports:"  >> $DOCKER_COMPOSE_FILE
    echo '      - "'"${ZEALOT_NO_SSL_PORT}"':80"' >> $DOCKER_COMPOSE_FILE
  else
    cat $TEMPLATE_DOCKER_COMPOSE_PATH/cert.yml >> $DOCKER_COMPOSE_FILE
  fi

  echo "Generated docker-compose.yml"
fi

echo "${_endgroup}"
