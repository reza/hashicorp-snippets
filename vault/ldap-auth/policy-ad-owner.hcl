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

