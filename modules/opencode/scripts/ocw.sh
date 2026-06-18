show_help() {
  cat << EOF
Usage: ocw <command> [options...]

Commands:
  start     Start the opencode web server
  attach    Attach to a running opencode web server

Options:
  --help    Show this help message

The OPENCODE_PORT environment variable can be set to customise the port
(default: 4096).
EOF
}

port="${OPENCODE_PORT:-4096}"

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

case "$1" in
  start)
    shift
    opencode web --hostname 127.0.0.1 --port "$port" "$@"
    ;;
  attach)
    shift
    exec opencode attach "http://localhost:$port" "$@"
    ;;
  --help)
    show_help
    exit 0
    ;;
  *)
    echo "Unknown command: $1" >&2
    show_help
    exit 1
    ;;
esac