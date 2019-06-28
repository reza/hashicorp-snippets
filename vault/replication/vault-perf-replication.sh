export VAULT_ADDR_PRI=http://13.80.122.49:8200
export VAULT_TOKEN_PRI=s.4o2Pm5SbkStQun3GBtwxmrJc
export VAULT_CLUSTER_ADDR_PRI=http://13.80.122.49:8201
export VAULT_ADDR_SEC=http://165.22.92.155:8200
export VAULT_TOKEN_SEC=s.NsX7DXOWEJ1HOU01UQOsF0Qh
export VAULT_CLUSTER_ADDR_SEC=http://165.22.92.155:8201

export VAULT_ADDR=${VAULT_ADDR_PRI}
export VAULT_TOKEN=${VAULT_TOKEN_PRI}

vault auth enable userpass

cat <<EOF > policy-replication.hcl
path "secrets/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "/sys/replication/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
vault policy write replication policy-replication.hcl

vault write auth/userpass/users/replication-admin password="P@ssword1" policies="replication"

vault secrets enable -path=secrets kv
vault write secrets/drinks gin=tonic

vault write -f sys/replication/performance/primary/enable primary_cluster_addr="${VAULT_CLUSTER_ADDR_PRI}"
export SEC_TOKEN=$(vault write -format=json sys/replication/performance/primary/secondary-token id="perf-sec" |jq -r '.wrap_info.token')

read -n 1 -s -r -p "Press any key to continue"
echo ""

export VAULT_ADDR=${VAULT_ADDR_SEC}
export VAULT_TOKEN=${VAULT_TOKEN_SEC}

vault write sys/replication/performance/secondary/enable token=${SEC_TOKEN} primary_api_addr="${VAULT_ADDR_PRI}"