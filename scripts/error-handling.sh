echo "${_group}Setting up error handling ..."

# Courtesy of https://stackoverflow.com/a/2183063/90297
trap_with_arg() {
  func="$1" ; shift
  for sig ; do
    trap "$func $sig "'$LINENO' "$sig"
  done
}

ZEALOT_CLEAN_UP="${ZEALOT_CLEAN_UP:-"false"}"
cleanup () {
  if [ "$ZEALOT_CLEAN_UP" == "false" ]; then
    return 0;
  fi
  ZEALOT_CLEAN_UP=true

  if [[ "$1" != "EXIT" ]]; then
    echo ""
    echo "An error occurred, caught SIG$1 on line $2";

    if [[ -n "$MINIMIZE_DOWNTIME" ]]; then
      echo "*NOT* cleaning up, to clean your environment run \"docker-compose stop\"."
    else
      echo "Cleaning up..."
    fi
  fi

  if [[ -z "$MINIMIZE_DOWNTIME" ]]; then
    $dc stop -t $STOP_TIMEOUT &> /dev/null
  fi
}
trap_with_arg cleanup ERR INT TERM EXIT

echo "ZEALOT_CLEAN_UP=${ZEALOT_CLEAN_UP}"

echo "${_endgroup}"
