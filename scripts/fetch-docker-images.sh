echo "${_group}Fetching Docker images ..."

if [ "$SKIP_UPDATE" == "false" ]; then
  $dc pull
  echo "Docker images pulled"
else
  echo "Skipped"
fi

echo "${_endgroup}"
