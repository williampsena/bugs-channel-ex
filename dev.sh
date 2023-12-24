#!/bin/bash

function run_compose() {
  local compose_file="$1"
  docker compose -f $1 up -d
}

run_compose "dev-docker-compose.yml"

echo "Do you want to run and integrate the ELK stack in your development environment? (y/n)"
read up_elk_stack

[[ "$up_elk_stack" == "y" ]] && run_compose "elk-docker-compose.yml"
