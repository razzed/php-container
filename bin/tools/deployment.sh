#!/usr/bin/env bash
#
# Deployment-related
#
# Copyright &copy; 2025 Market Acumen, Inc.
#

phpContainerCompose() {
  dockerCompose --env CONTAINER_PORT_DATABASE=3307 --env CONTAINER_PORT_WEB=8000 --env XDEBUG_IDE_KEY=phpContainer --env XDEBUG_CLIENT_HOST=host.docker.internal "$@"
}
