echo "${_group}Configuring Zealot version ..."

CURRENT_TAG=$(grep -E "tryzealot/zealot:(.+)$" $DOCKER_COMPOSE_FILE | awk -F ':' '{print $3}')
if [ "$CURRENT_TAG" != "$ZEALOT_TAG" ]; then
  echo "Detected Zealot current version is \`$CURRENT_TAG\` != \`$ZEALOT_TAG\`, updating ..."
  sed -i -e "s|tryzealot/zealot:${CURRENT_TAG}|tryzealot/zealot:${ZEALOT_TAG}|g" $DOCKER_COMPOSE_FILE
  clean_sed_temp_file $DOCKER_COMPOSE_FILE
else
  echo "Detected Zealot current version is \`$CURRENT_TAG\`"
fi

echo "${_endgroup}"
