export LDAP_URL="ldap://192.168.42.4:389"
export LDAP_USER_DN="cn=Users,dc=arenz,dc=cloud"
export LDAP_GROUP_DN="cn=Users,dc=arenz,dc=cloud"
export LDAP_BIND_DN="cn=vault-service,cn=Users,dc=arenz,dc=cloud"
export LDAP_BIND_PASSWORD="P@ssword1"


vault auth enable -path ad ldap

# The LDAP connection uses unecrypted LDAP, in production LDAPS should be used.
cat <<EOF > config-ldap.json
{
    "url": "${LDAP_URL}",
    "userattr":"sAMAccountName",
    "userdn":"${LDAP_USER_DN}",
    "groupdn":"${LDAP_GROUP_DN}",
    "groupfilter":"(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))",
    "binddn":"${LDAP_BIND_DN}",
    "bindpass":"${LDAP_BIND_PASSWORD}",
    "groupattr":"memberOf"
}
EOF

vault write auth/ad/config @config-ldap.json

vault secrets enable -path=secrets kv

vault write secrets/ad/data/drinks gin=tonic
vault write secrets/ad/users/drinks whisky=sour
vault write secrets/ad/owners/drinks white=russian
vault write secrets/non-ad/drinks pale=ale

cat <<EOF > policy-ad-all.hcl
# This policy allows all Active directory users to list everything. This isn't ideal and should not be considered in procution, however for demo purposes using the UI this is helpful.
path "secrets/*" {
  capabilities = ["list"]
}

# This grants every Active Directory user full access to its own area base on the accout name.
path "secrets/ad/users/{{identity.entity.aliases.$(vault auth list -format=json |jq -r '.["ad/"].accessor').name}}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Deny access to the non-ad area, only required to supress listing
path "secrets/non-ad" {
  capabilities = ["deny"]
}
EOF
vault policy write ad-all policy-ad-all.hcl

cat <<EOF > policy-ad-owner.hcl
# Grant full access to the data area.
path "secrets/ad/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Grant full access to the owner area.
path "secrets/ad/owners/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow owners to configure the LDAP config to add new groups, for example.
path "auth/ad/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

EOF
vault policy write ad-owner policy-ad-owner.hcl
vault write auth/ad/groups/vault-owner policies=ad-owner,ad-all

cat <<EOF > policy-ad-contributor.hcl
# Grant full access to the data area.
path "secrets/ad/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Deny access to the owner area, only required to supress listing.
path "secrets/ad/owners/*" {
  capabilities = ["deny"]
}

EOF
vault policy write ad-contributor policy-ad-contributor.hcl
vault write auth/ad/groups/vault-contributor policies=ad-contributor,ad-all

cat <<EOF > policy-ad-reader.hcl
# Only grant read access to the data area.
path "secrets/ad/data/*" {
  capabilities = ["read", "list"]
}

# Deny access to the owner area, only required to supress listing.
path "secrets/ad/owners/*" {
  capabilities = ["deny"]
}
EOF
vault policy write ad-reader policy-ad-reader.hcl
vault write auth/ad/groups/vault-reader policies=ad-reader,ad-all