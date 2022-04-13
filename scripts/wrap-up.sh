if [[ "$MINIMIZE_DOWNTIME" ]]; then
  echo "${_group}Waiting for Zealot to start ..."

  # Start the whole setup, except proxy(caddy) service.
  $dc up -d --remove-orphans $($dc config --services | grep -v -E '^(web)$')
  $dc exec -T web caddy reload --config /etc/caddy/Caddyfile

  docker run --rm --network="${COMPOSE_PROJECT_NAME}_default" redis:5-alpine ash \
    -c 'while [[ "$(wget -T 1 -q -O- http://web:3000/_health/)" != "ok" ]]; do sleep 0.5; done'

  # Make sure everything is up. This should only touch relay and nginx
  $dc up -d

  echo "${_endgroup}"
else
  echo ""
  echo "-----------------------------------------------------------------"
  echo ""
  echo "You're all done! Run the following command to get Zealot running:"
  echo ""
  echo "  [sudo] $dc up -d"
  echo ""
  echo "-----------------------------------------------------------------"
  echo ""
fi
