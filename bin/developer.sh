#!/usr/bin/env bash
#
# developer.sh is loaded automatically by
#
# Copyright &copy; 2025 Market Acumen, Inc.
#
export DEVELOPER_TRACK=1

if source "${BASH_SOURCE[0]%/*}/tools.sh"; then

  __phpContainerContextInitialize() {
    developerAnnounce < <(__applicationToolsList)
  }

  __phpContainerContextInitialize

fi
