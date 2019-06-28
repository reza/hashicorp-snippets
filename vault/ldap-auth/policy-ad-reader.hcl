# Only grant read access to the data area.
path "secrets/ad/data/*" {
  capabilities = ["read", "list"]
}

# Deny access to the owner area, only required to supress listing.
path "secrets/ad/owners/*" {
  capabilities = ["deny"]
}
