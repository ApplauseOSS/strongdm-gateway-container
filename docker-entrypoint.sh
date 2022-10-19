#!/bin/bash

__sdm=sdm

if [[ -z ${SDM_ADMIN_TOKEN} ]]; then
  echo "Missing SDM_ADMIN_TOKEN! Aborting!"
  exit 1
fi

# supress stdout
unset SDM_DOCKERIZED

# Setup our gateway
__addr=${SDM_RELAY_ADDR:-$(hostname -s)}
__port=${SDM_RELAY_PORT:-5000}
__name=${SDM_RELAY_NAME:-$(hostname -s)}

function __token() {
  # We create a gateway, not a relay... our token should match
  ${__sdm} relay create-gateway --name ${__name} ${__addr}:${__port} 0.0.0.0:${__port}
}

# See if we have a token file configured, and if so, try to load it
if [[ -n ${SDM_RELAY_TOKEN_FILE} ]]; then
  # We're configured, do we exist? If not, generate a token
  if [[ -r ${SDM_RELAY_TOKEN_FILE} && -s ${SDM_RELAY_TOKEN_FILE} ]]; then
    SDM_RELAY_TOKEN=$(<${SDM_RELAY_TOKEN_FILE})
  else
    SDM_RELAY_TOKEN=$(__token)
    # We have a populated SDM_RELAY_TOKEN and we're ready to write it back
    echo ${SDM_RELAY_TOKEN} > ${SDM_RELAY_TOKEN_FILE} || echo "$(date -u) WARN Unable to write token file..."
  fi
else
  # If we're here, we need to generate a token and use it... we shouldn't do this, as it's not self-recoverable
  SDM_RELAY_TOKEN=$(__token)
fi

export SDM_RELAY_TOKEN

# Clean up temporary auth state
unset SDM_ADMIN_TOKEN

# --daemon arg automatically respawns child relay process during
# version upgrades or abnormal termination
export SDM_DOCKERIZED=true # reinstate stdout logging
${__sdm} relay --daemon
