# Sample env.sh. Rename to env.sh to use
# These setting bypass user input and hard set the values into .env upon running ./deploy

# Set SSL to "false", "letsencrypt", or "self-signed"
# export ZEALOT_FORCE_SSL=false

# Set the external port for zealot to run on if not using SSL
# export ZEALOT_NO_SSL_PORT=8008

# Set the location of the zealot data to either "docker" or "local"
# export ZEALOT_FORCE_VOLUME=docker