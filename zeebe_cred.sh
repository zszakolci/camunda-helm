#!/bin/bash
export ZEEBE_ADDRESS='zeebe-gateway.local.distro.ultrawombat.com:443'
export ZEEBE_CLIENT_ID='zeebe'
export ZEEBE_CLIENT_SECRET='4h2ODXfaEN'
export ZEEBE_AUTHORIZATION_SERVER_URL='https://keycloak.local.distro.ultrawombat.com/auth/realms/camunda-platform/protocol/openid-connect/token'
zbctl status
