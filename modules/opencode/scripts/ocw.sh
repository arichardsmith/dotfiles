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

runtime_dir() {
  # Keep the shared password file in a user-private runtime location so start
  # and attach can coordinate without relying on a platform-specific keychain.
  if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    printf '%s/opencode' "$XDG_RUNTIME_DIR"
  else
    printf '%s/ocw-%s/opencode' "${TMPDIR:-/tmp}" "${USER:-$(id -un)}"
  fi
}

password_file() {
  printf '%s/opencode-web-%s.password' "$(runtime_dir)" "$port"
}

ensure_runtime_dir() {
  local dir

  dir="$(runtime_dir)"
  mkdir -p "$dir"
  chmod 700 "$dir"
}

write_password() {
  local file="$1"
  local password="$2"

  printf '%s\n' "$password" >"$file"
  chmod 600 "$file"
}

read_password() {
  local file

  file="$(password_file)"
  if [[ ! -r "$file" ]]; then
    echo "ocw: no stored password found for port $port" >&2
    echo "ocw: run 'ocw start' first, or set OPENCODE_SERVER_PASSWORD manually" >&2
    exit 1
  fi

  cat "$file"
}

port="${OPENCODE_PORT:-4096}"

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

case "$1" in
  start)
    shift
    # The password is per-run, but we keep it in a private file so attach can
    # discover it later. This is intentionally local-only coordination, not a
    # long-term secret store.
    ensure_runtime_dir
    password_file_path="$(password_file)"
    if [[ -n "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
      password="$OPENCODE_SERVER_PASSWORD"
    else
      password="$(openssl rand -base64 32)"
      printf 'OpenCode server password: %s\n' "$password"
    fi
    write_password "$password_file_path" "$password"
    trap 'rm -f "$password_file_path"' EXIT
    export OPENCODE_SERVER_PASSWORD="$password"
    opencode web --hostname 127.0.0.1 --port "$port" "$@"
    ;;
  attach)
    shift
    password="${OPENCODE_SERVER_PASSWORD:-$(read_password)}"
    export OPENCODE_SERVER_PASSWORD="$password"
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
