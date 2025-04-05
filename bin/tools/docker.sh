#!/usr/bin/env bash
#
# Docker-related
#
# Copyright &copy; 2025 Market Acumen, Inc.
#

# compose wrapper for php Docker containers
phpContainerCompose() {
  local usage="_${FUNCNAME[0]}"

  local deployment="STAGING" aa=() buildFlag=false deleteVolumes=false keepVolumes="" keepVolumesDefault=false databaseVolume=""

  # _IDENTICAL_ argument-case-header 5
  local __saved=("$@") __count=$#
  while [ $# -gt 0 ]; do
    local argument="$1" __index=$((__count - $# + 1))
    [ -n "$argument" ] || __throwArgument "$usage" "blank #$__index/$__count ($(decorate each quote "${__saved[@]}"))" || return $?
    case "$argument" in
      # _IDENTICAL_ --help 4
      --help)
        "$usage" 0
        return $?
        ;;
      --production)
        deployment=PRODUCTION
        ;;
      --staging)
        deployment=STAGING
        ;;
      --clean)
        deleteVolumes=true
        ;;
      --volume)
        shift
        databaseVolume=$(usageArgumentString "$usage" "$argument" "${1-}") || return $?
        ;;
      --keep)
        deleteVolumes=false
        keepVolumes=true
        ;;
      --build)
        buildFlag=true
        ;;
      db)
        aa+=("$argument")
        keepVolumesDefault=false
        ;;
      web)
        keepVolumesDefault=true
        aa+=("$argument")
        ;;
      *)
        # _IDENTICAL_ argumentUnknown 1
        __throwArgument "$usage" "unknown #$__index/$__count \"$argument\" ($(decorate each code "${__saved[@]}"))" || return $?
        ;;
    esac
    # _IDENTICAL_ argument-esac-shift 1
    shift
  done

  local start

  start=$(timingStart)

  [ -n "$keepVolumes" ] || keepVolumes=$keepVolumesDefault

  if [ -z "$databaseVolume" ]; then
    local home dockerName

    home=$(__catchEnvironment "$usage" buildHome) || return $?
    dockerName=$(basename "$home")

    databaseVolume="${dockerName}_database_data"
  fi

  __deploymentEnvironmentSetup "$usage" "$deployment" || return $?

  if $buildFlag; then
    aa=("build" "${aa[@]+"${aa[@]}"}")
    if $deleteVolumes; then
      if __phpContainerVolumeExists "$databaseVolume"; then
        __phpContainerDeleteVolume "$usage" "$databaseVolume" || return $?
      else
        decorate info "Volume $(decorate code "$databaseVolume") does not exist"
      fi
    elif $keepVolumes; then
      if __phpContainerVolumeExists "$databaseVolume"; then
        decorate info "Keeping volume $(decorate code "$databaseVolume")"
      fi
    else
      __phpContainerDeleteVolumeInteractive "$usage" "$databaseVolume" || return $?
    fi
  fi

  __phpContainerCompose "${aa[@]+"${aa[@]}"}"

  local name
  name="$(decorate value "$(buildEnvironmentGet APPLICATION_NAME)")"
  statusMessage --last timingReport "$start" "Built $name in"
}
_phpContainerCompose() {
  # _IDENTICAL_ usageDocument 1
  usageDocument "${BASH_SOURCE[0]}" "${FUNCNAME[0]#_}" "$@"
}

__phpContainerCompose() {
  local home
  home=$(__catchEnvironment "$usage" buildHome) || return $?
  COMPOSE_BAKE=true docker compose -f "$home/docker-compose.yml" "$@"
}


__dockerComposeIsRunning() {
  ! __phpContainerCompose ps --format json | outputTrigger >/dev/null 2>&1
}

__phpContainerVolumeExists() {
  docker volume ls --format json | jq .Name | grep -q "$1"
}
__phpContainerDeleteVolumeInteractive() {
  local usage="$1" databaseVolume="$2" && shift 2

  local running=false suffix=""

  if __dockerComposeIsRunning; then
    running=true
    suffix=" (container will also be shut down)"
  fi

  if __phpContainerVolumeExists "$databaseVolume"; then
    if confirmYesNo --no --timeout 60 --info "Delete database volume $(decorate code "$databaseVolume")$suffix?"; then
      if $running; then
        statusMessage decorate info "Bringing down container ..."
        __catchEnvironment "$usage" docker compose down --remove-orphans || return $?
      fi
      __phpContainerDeleteVolume "$usage" "$databaseVolume" || return $?
    fi
  fi
}

__phpContainerDeleteVolume() {
  local usage="$1" databaseVolume="$2" && shift 2

  __catchEnvironment "$usage" docker volume rm "$databaseVolume" || return $?
  statusMessage decorate warning "Deleted volume $(decorate code "${databaseVolume}") - will be created with new environment variables"
}
