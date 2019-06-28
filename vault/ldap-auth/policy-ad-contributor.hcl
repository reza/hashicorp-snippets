# Grant full access to the data area.
path "secrets/ad/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Deny access to the owner area, only required to supress listing.
path "secrets/ad/owners/*" {
  capabilities = ["deny"]
}

