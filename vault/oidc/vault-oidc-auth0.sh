#! /bin/bash

export AUTH0_DOMAIN=arenz.eu.auth0.com
export AUTH0_CLIENT_ID=4THz4WkSu0WCVCN4LmjLIQFcIkeJ2R9Q
export AUTH0_CLIENT_SECRET=3VlcebWxz2KzOOpSsNcz3CJnZRFQt4Au7pj0FaQ8O4E5W60OQzoXs1W_Foy5rLVw

export AUTH_PATH=auth0

vault auth enable -path=${AUTH_PATH} oidc

export AUTH_REDIRECT_URL1=http://localhost:8200/ui/vault/auth/${AUTH_PATH}/oidc/callback
export AUTH_REDIRECT_URL2=http://localhost:8250/${AUTH_PATH}/callback
export AUTH_REDIRECT_URL3=http://127.0.0.1:8200/ui/vault/auth/${AUTH_PATH}/oidc/callback
export AUTH_REDIRECT_URL4=http://127.0.0.1:8250/${AUTH_PATH}/callback

echo "Use the following URL as allowed callback URLs in Auth0"
echo "${AUTH_REDIRECT_URL1},"
echo "${AUTH_REDIRECT_URL2},"
echo "${AUTH_REDIRECT_URL3},"
echo "${AUTH_REDIRECT_URL4}"

vault write auth/${AUTH_PATH}/config \
        oidc_discovery_url="https://$AUTH0_DOMAIN/" \
        oidc_client_id="$AUTH0_CLIENT_ID" \
        oidc_client_secret="$AUTH0_CLIENT_SECRET" \
        default_role="reader"

vault write auth/${AUTH_PATH}/role/reader \
        bound_audiences="$AUTH0_CLIENT_ID" \
        allowed_redirect_uris="${AUTH_REDIRECT_URL1}" \
        allowed_redirect_uris="${AUTH_REDIRECT_URL2}" \
        allowed_redirect_uris="${AUTH_REDIRECT_URL3}" \
        allowed_redirect_uris="${AUTH_REDIRECT_URL4}" \
        user_claim="sub" \
        policies="${AUTH_PATH}-reader"

vault secrets enable -path=${AUTH_PATH}-secrets -version=1 kv
vault write ${AUTH_PATH}-secrets/drinks pims=cup

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