##################
# Main
##################
echo "${_group}Generating .env file ..."

if [ -f "$ENV_FILE" ]; then
  echo "File already exists, skipped."
else
  echo "Creating $ENV_FILE file"
  cp -n "${EXAMPLE_ENV_FILE}" "${ENV_FILE}"
fi

echo "${_endgroup}"
