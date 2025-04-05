#!/usr/bin/env bash
#
# Deployment-related
#
# Copyright &copy; 2025 Market Acumen, Inc.
#

#
# Set up the deployment
#
__deploymentEnvironmentSetup() {
  local usage="$1" deployment="$2"

  local home deploymentEnv envFile
  home=$(__catchEnvironment "$usage" buildHome) || return $?

  deploymentEnv=".$deployment.env"
  [ -f "$home/$deploymentEnv" ] || __throwEnvironment "$usage" "Missing $deploymentEnv" || return $?

  envFile="$home/.env"
  if [ -f "$envFile" ]; then
    local checkEnv
    while read -r checkEnv; do
      if muzzle diff -q "$envFile" "$checkEnv"; then
        __catchEnvironment "$usage" rm -rf "$envFile" || return $?
        break
      fi
    done < <(find "$home" -maxdepth 1 -name ".*.env")
  fi
  if [ -f "$envFile" ]; then
    statusMessage decorate warning "Backing up $(decorate file "$envFile") ..."
    __catchEnvironment "$usage" cp "$envFile" "$home/.$(date '+%F_%T').env" || return $?
  fi
  __catchEnvironment "$usage" cp "$deploymentEnv" "$envFile" || return $?
}
