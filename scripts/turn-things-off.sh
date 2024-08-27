echo "${_group}Turning things off ..."

if [[ -f "$DOCKER_COMPOSE_FILE" ]]; then
  if [[ -n "$MINIMIZE_DOWNTIME" ]]; then
    # Stop everything but proxy service
    $dc rm -fsv $($dc config --services | grep -v -E '^(web)$')
  else
    $dc down -t $STOP_TIMEOUT --rmi local --remove-orphans
  fi
fi

echo "${_endgroup}"
