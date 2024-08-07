echo "${_group}Generating domain ..."

DOMAIN_FROM_USER=0
DOMAIN=$(grep 'ZEALOT_DOMAIN' $ENV_FILE | awk '{split($0,a,"="); print a[2]}')
if [ -z "$DOMAIN" ]; then
  DOMAIN_FROM_USER=1
  echo "Input zealot domain, without http(s):// (eg, zealot.test)."
  printf "ZEALOT_DOMAIN="
  read DOMAIN
else
  echo "Read zealot domain: ${DOMAIN}, skipped"
fi

if [ -z "$DOMAIN" ]; then
  echo "Read ZEALOT_DOMAIN failed, skipped"
else
  if [ "$DOMAIN_FROM_USER" == "1" ]; then
    sed -i -e 's/^.*ZEALOT_DOMAIN=.*$/ZEALOT_DOMAIN='"$DOMAIN"'/' $ENV_FILE
    clean_sed_temp_file $ENV_FILE
    echo "Domain written to .env"
  fi
fi

echo "${_endgroup}"
