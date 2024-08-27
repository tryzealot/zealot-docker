echo "${_group}Configuring cert file(s) ..."

CADDY_VOLUME_PATH="${CADDY_PATH}${CADDY_ROOTFS_PATH}"
CADDY_FILE="${CADDY_VOLUME_PATH}/${CADDYFILE_NAME}"
CERTS_PATH="${CADDY_VOLUME_PATH}/${CERTS_NAME}"
DOCKER_CADDY_FILE="${CADDY_ROOTFS_PATH}/${CADDYFILE_NAME}"
DOCKER_CERTS_PATH="${CADDY_ROOTFS_PATH}/${CERTS_NAME}"


##
## Check or generate Caddyfile
##
check_or_generate_caddyfile () {
  mkdir -p $CADDY_VOLUME_PATH
  mkdir -p $CERTS_PATH
  if [ -f "$CADDY_FILE" ]; then
    echo "${CADDY_FILE} file already exists, skipped."
  else
    echo "Creating $CADDY_FILE file"
    cp -n "$TEMPLATE_CADDY_FILE" "$CADDY_FILE"
  fi
}

##
## Check or configure Let's Encrypt SSL
##
check_or_configure_letsencrypt_ssl () {
  echo "${_group}Configuring Let's Encrypt SSL/TLS ..."
  echo "What is you email for let's encrypt?"
  printf "ZEALOT_CERT_EMAIL="
  read email

  if [ -z "$email" ]; then
    echo "Read ZEALOT_CERT_EMAIL failed, Quitting"
    exit
  else
    sed -i -e 's/^.*ZEALOT_CERT_EMAIL=.*$/ZEALOT_CERT_EMAIL='"$email"'/' $ENV_FILE
    clean_sed_temp_file $ENV_FILE
    echo "Let's Encrypt email written to .env"

    check_or_generate_caddyfile
  fi

  ZEALOT_USE_SSL="letsencrypt"
}

##
## Check or Generate self signed SSL
##
check_or_generate_selfsigned_ssl () {
  DOMAIN_NAME=$(grep 'ZEALOT_DOMAIN' $ENV_FILE | awk '{split($0,a,"="); print a[2]}')
  echo "${_group}Configuring self signed SSL/TLS cert ... ${DOMAIN_NAME}"

  CERT_NAME="${DOMAIN_NAME}.pem"
  KEY_NAME="${DOMAIN_NAME}-key.pem"
  CERT_FILE="${CERTS_PATH}/${CERT_NAME}"
  KEY_FILE="${CERTS_PATH}/${KEY_NAME}"

  docker run --rm --name zealot-mkcert \
    -v $(pwd)/$CERTS_PATH:/root/.local/share/mkcert \
    icyleafcn/mkcert \
    /bin/ash -c "mkcert -install && mkcert ${DOMAIN_NAME}" 1> /dev/null

  while true; do
    if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ];then
      sed -i -e 's/^.*ZEALOT_CERT=.*$/ZEALOT_CERT='"$CERT_NAME"'/' $ENV_FILE
      sed -i -e 's/^.*ZEALOT_CERT_KEY=.*$/ZEALOT_CERT_KEY='"$KEY_NAME"'/' $ENV_FILE
      clean_sed_temp_file $ENV_FILE
      echo "Generated cert and key to $CERTS_PATH"

      check_or_generate_caddyfile

      if [ grep 'tls {$ZEALOT_CERT_EMAIL}' $CADDY_FILE ]; then
        echo "CAN NOT read \$ZEALOT_CERT_EMAIL variable in $CADDY_FILE, abort"
        exit
      else
        local TEMP_PATH=$(echo $DOCKER_CERTS_PATH | sed 's/\//\\\//g')
        sed -i -e 's/{$ZEALOT_CERT_EMAIL}/'"$TEMP_PATH"'\/{$ZEALOT_CERT} '"$TEMP_PATH"'\/{$ZEALOT_CERT_KEY}/' $CADDY_FILE
        clean_sed_temp_file $CADDY_FILE
        echo "Self-signed cert and key written to $CADDY_FILE"
      fi

      break
    fi
    sleep 1
  done

  ZEALOT_USE_SSL="self-signed"
}

##
## Start deploy flow
##
choose_deploy () {
  set +u
  if [ -n $ZEALOT_FORCE_SSL ]; then
    case "$ZEALOT_FORCE_SSL" in
      "letsencrypt" )
        check_or_configure_letsencrypt_ssl;;
      "self-signed" )
        check_or_generate_selfsigned_ssl;;
      "false" )
        SSL_NAME=false
        ;;
      * )
        echo "ZEALOT_FORCE_SSL is not set, setup it."
        ;;
    esac
    echo "${_endgroup}"
  fi
  set -u

  printf "How do you deploy?\n\
  Use [L]et's Encryt SSL (default)\n\
  Use [S]elf-signed SSL\n\
  Do [n]ot use SSL? \n"
  read -n 1 action
  echo ""

  local SSL_NAME=letsencrypt
  case "$action" in
    L | l )
      check_or_configure_letsencrypt_ssl;;
    S | s )
      check_or_generate_selfsigned_ssl;;
    * )
      SSL_NAME=false
      ;;
  esac

  if [ -z "$action" ]; then
    check_or_configure_letsencrypt_ssl
  fi

  echo "${_endgroup}"
}

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
  if [ -n "cat $DOCKER_COMPOSE_FILE | grep '# USE SSL:'" ]; then
    HAS_DOCKERDOCKER_COMPOSE_FILE="true"
    echo "Cert already configured, skipped"
  else
    echo "Detected docker-compose file AND its not writon by zealot, at your own risk!!!"
  fi
fi

if [ "$HAS_DOCKERDOCKER_COMPOSE_FILE" == "false" ]; then
  choose_deploy
else
  echo "${_endgroup}"
fi
