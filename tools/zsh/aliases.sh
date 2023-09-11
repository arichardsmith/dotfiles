# Pretty print json (helpful for piping from curl)
pretty-json() {
	jq -M | bat -l json
}

# Alias to fuzzy find git branch
pick-branch() {
  git branch | fzf
}

# Use llama to cd into a directory
llam() {
  cd "$(llama "$@")"
}

# Search package.json scripts and run selected script
pks() {
  SCRIPT_NAME=$(cat package.json | jq -r '.scripts | keys | .[]' | fzf)
  if [ -n "${SCRIPT_NAME}" ]; then
    echo "Running '${SCRIPT_NAME}'"
    pnpm run ${SCRIPT_NAME}
  fi
}

# Pick a docker process and tail the logs
tail-docker() {
  CONTAINER_ID=$(docker ps --format '{{.Names}} => {{.ID}}' | fzf | awk -F ' => ' '{print $2}')
  if [ -n "${CONTAINER_ID}" ]; then
    docker logs --follow "${CONTAINER_ID}"
  fi
}

# Run clipboard content through the provided command
pbmap() {
  if [ $# -gt 0 ]; then
      pbpaste | "$@" | pbcopy
  else
      pbpaste | pbcopy
  fi
}
