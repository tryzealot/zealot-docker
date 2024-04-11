echo "${_group}Generating .env file ..."

if [ -f "$ENV_FILE" ]; then
  echo "File already exists, skipped."
else
  echo "Creating $ENV_FILE file"
  cp -n "${EXAMPLE_ENV_FILE}" "${ENV_FILE}"
fi

if [ "${REDIS_ENABLED_LEGACY:-0}" == 1 ] && ! grep -q "REDIS_URL" $ENV_FILE; then
  echo "" >> $ENV_FILE
  echo "# The full Redis URL for the Redis cache." >> $ENV_FILE
  echo "REDIS_URL=redis://redis:6379/0" >> $ENV_FILE
fi

echo "${_endgroup}"
