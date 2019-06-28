export VAULT_ADDR=http://localhost:8200

vault operator init -format=json -key-shares=1 -key-threshold=1

vault operator unseal