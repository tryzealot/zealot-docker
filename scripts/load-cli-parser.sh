echo "${_group}Parsing command line ..."

MINIMIZE_DOWNTIME="${MINIMIZE_DOWNTIME:-}"
SKIP_UPDATE="${SKIP_UPDATE:-"false"}"
SKIP_COMMIT_CHECK="${SKIP_COMMIT_CHECK:-0}"
REDIS_ENABLED_LEGACY="${REDIS_ENABLED_LEGACY:-"false"}"

##
## Banner
##
print_banner () {
  echo '  ______          _       _
 |___  /         | |     | |
    / / ___  __ _| | ___ | |_
   / / / _ \/ _` | |/ _ \| __|
  / /_|  __/ (_| | | (_) | |_
 /_____\___|\__,_|_|\___/ \__|'
}

show_help() {
  cat <<EOF
Usage: $0 [options]
Install Zealot with docker-compose.
Options:
 -h, --help             Show this message and exit.
 --skip-update          Skip docker-compose pull the images (default value: ${SKIP_UPDATE}).
 --redis-enabled-legacy LEGACY MODE: enable legacy Redis support (default value: ${REDIS_ENABLED_LEGACY}).
 --minimize-downtime    EXPERIMENTAL: try to keep accepting events for as long as possible while upgrading.
                        This will disable cleanup on error, and might leave your installation in partially upgraded state.
                        This option might not reload all configuration, and is only meant for in-place upgrades.
 --skip-commit-check    Skip the check for the latest commit when on the main branch of a \`self-hosted\` Git working copy.
EOF
}

while (( $# )); do
  case "$1" in
    -h | --help) show_help; exit;;
    --skip-update) SKIP_UPDATE=1;;
    --use-nightly) ZEALOT_TAG=nightly;;
    --minimize-downtime) MINIMIZE_DOWNTIME=1;;
    --skip-commit-check) SKIP_COMMIT_CHECK=1;;
    --redis-enabled-legacy) REDIS_ENABLED_LEGACY=1;;
    --) ;;
    *) echo "Unexpected argument: $1. Use --help for usage information."; exit 1;;
  esac
  shift
done

print_banner

echo "${_endgroup}"
