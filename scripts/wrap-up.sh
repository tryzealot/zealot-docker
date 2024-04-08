if [[ "$MINIMIZE_DOWNTIME" ]]; then
  echo "${_group}Waiting for Zealot to start ..."

  # Start the whole setup, except proxy(caddy) service.
  $dc up -d --remove-orphans $($dc config --services | grep -v -E '^(web)$')
  $dc exec -T web caddy reload --config /etc/caddy/Caddyfile

  # Make sure everything is up. This should only touch relay and nginx
  $dc up -d

  echo "${_endgroup}"
else
  echo ""
  echo "-----------------------------------------------------------------"
  echo ""
  echo "You're all done! Run the following command to get Zealot running:"
  echo ""
  echo "  [sudo] docker compose up -d"
  echo ""
  echo "-----------------------------------------------------------------"
  echo ""
fi
