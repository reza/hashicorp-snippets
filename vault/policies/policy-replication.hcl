path "secrets/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "/sys/replication/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
