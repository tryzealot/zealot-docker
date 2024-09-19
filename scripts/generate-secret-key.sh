echo "${_group}Generating secret key ..."

HAS_SECRET_TOKEN=$(grep -E 'SECRET_KEY_BASE|SECRET_TOKEN' $ENV_FILE | awk '{split($0,a,"="); print a[2]}')

if [ -z "$HAS_SECRET_TOKEN" ]; then
  token=$(export LC_ALL=C; head /dev/urandom | tr -dc "a-z0-9" | head -c 128 | sed -e 's/[\/&]/\\&/g')
  sed -i -e 's/^SECRET_TOKEN=.*$/SECRET_TOKEN='"'$token'"'/' $ENV_FILE
  sed -i -e 's/^SECRET_KEY_BASE=.*$/SECRET_KEY_BASE='"'$token'"'/' $ENV_FILE
  clean_sed_temp_file $ENV_FILE
  echo "Secret key written to .env: \`${token}\`"
else
  echo "Secret key had been write, skipped"
fi

echo "${_endgroup}"
