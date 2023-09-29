#!/bin/bash
export ZEEBE_ADDRESS='zeebe-gateway.local.distro.ultrawombat.com:443'
export ZEEBE_CLIENT_ID='zeebe'
export ZEEBE_CLIENT_SECRET='FHlkLoPGuq'
export ZEEBE_AUTHORIZATION_SERVER_URL='https://keycloak.local.distro.ultrawombat.com/auth/realms/camunda-platform/protocol/openid-connect/token'
zbctl status
zbctl  set variables 2251799813877256 --variables '{"aVariable": "1234-1234-4567-7890"}' --local -o json
