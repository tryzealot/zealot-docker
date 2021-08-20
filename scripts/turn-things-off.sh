echo "${_group}Turning things off ..."

if [[ -n "$MINIMIZE_DOWNTIME" ]]; then
  # Stop everything but proxy service
  $dc rm -fsv $($dc config --services | grep -v -E '^(web)$')
else
  $dc down -t $STOP_TIMEOUT --rmi local --remove-orphans
fi

echo "${_endgroup}"
