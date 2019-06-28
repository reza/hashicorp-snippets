#!/bin/sh

export AUTH_PATH=aad
export AUTH_SP_NAME=ChangeMe-vault-oidc
export AUTH_CLIENT_SECRET=MyVaultTestPasswordChangeMe
export AUTH_TENANT=$(az account show |jq -r '.tenantId')

export AUTH_REDIRECT_URL1=http://localhost:8200/ui/vault/auth/${AUTH_PATH}/oidc/callback
export AUTH_REDIRECT_URL2=http://localhost:8250/${AUTH_PATH}/callback

az ad app create --display-name ${AUTH_SP_NAME} --password ${AUTH_CLIENT_SECRET} --reply-urls ${AUTH_REDIRECT_URL1} ${AUTH_REDIRECT_URL2} --output none
export AUTH_CLIENT_ID=$(az ad app list --display-name ${AUTH_SP_NAME} |jq -r '.[0].appId')

vault auth enable -path=${AUTH_PATH} oidc

vault write auth/${AUTH_PATH}/config \
        oidc_discovery_url="https://login.microsoftonline.com/${AUTH_TENANT}/v2.0" \
        oidc_client_id="$AUTH_CLIENT_ID" \
        oidc_client_secret="$AUTH_CLIENT_SECRET" \
        default_role="reader"

vault write auth/${AUTH_PATH}/role/reader \
        bound_audiences="$AUTH_CLIENT_ID" \
        allowed_redirect_uris="${AUTH_REDIRECT_URL1}" \
        allowed_redirect_uris="${AUTH_REDIRECT_URL2}" \
        user_claim="sub" \
        policies="${AUTH_PATH}-reader"

vault secrets enable -path=${AUTH_PATH}-secrets -version=1 kv
vault write ${AUTH_PATH}-secrets/drinks pina=colada

vault policy write ${AUTH_PATH}-contributor -<<EOF
path "/${AUTH_PATH}-secrets/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

vault policy write ${AUTH_PATH}-reader -<<EOF
path "/${AUTH_PATH}-secrets/*" {
    capabilities = ["read", "list"]
}
EOF