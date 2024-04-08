echo "${_group}Fetching and updating Docker images ..."

if [ "$SKIP_UPDATE" == "false" ]; then
  $dc pull -q --ignore-pull-failures 2>&1 | grep -v -- -nightly || true
  echo "Docker images pulled"
else
  echo "Skipped"
fi

echo "${_endgroup}"
