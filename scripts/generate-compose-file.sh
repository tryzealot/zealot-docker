echo "${_group}Generating docker-compose.file ..."

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
  echo "File already exists, skipped"
else
  echo "# Generated on $(date)" > $DOCKER_COMPOSE_FILE
  echo "# USE SSL: ${ZEALOT_USE_SSL}" >> $DOCKER_COMPOSE_FILE
  cat $TEMPLATE_DOCKER_COMPOSE_PATH/base.yml >> $DOCKER_COMPOSE_FILE

  if [ "$ZEALOT_USE_SSL" == "false" ]; then
    echo "    ports:"  >> $DOCKER_COMPOSE_FILE
    echo '      - "80:80"' >> $DOCKER_COMPOSE_FILE
  else
    cat $TEMPLATE_DOCKER_COMPOSE_PATH/cert.yml >> $DOCKER_COMPOSE_FILE
  fi

  echo "Generated docker-compose.yml"
fi

echo "${_endgroup}"
