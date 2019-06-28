# This policy allows all Active directory users to list everything. This isn't ideal and should not be considered in procution, however for demo purposes using the UI this is helpful.
path "secrets/*" {
  capabilities = ["list"]
}

# This grants every Active Directory user full access to its own area base on the accout name.
path "secrets/ad/users/{{identity.entity.aliases.auth_ldap_81ed8ca7.name}}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Deny access to the non-ad area, only required to supress listing
path "secrets/non-ad" {
  capabilities = ["deny"]
}
