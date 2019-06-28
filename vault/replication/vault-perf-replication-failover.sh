export VAULT_ADDR_PRI=http://13.80.122.49:8200
export VAULT_TOKEN_PRI=s.4o2Pm5SbkStQun3GBtwxmrJc
export VAULT_CLUSTER_ADDR_PRI=http://13.80.122.49:8201
export VAULT_ADDR_SEC=http://157.230.115.242:8200
export VAULT_TOKEN_SEC=s.28AViPC8NVwYoNFM7S2qk9XO
export VAULT_CLUSTER_ADDR_SEC=http://157.230.115.242:8201

export VAULT_ADDR=${VAULT_ADDR_PRI}
vault login -method="userpass" username="replication-admin" password="P@ssword1"

vault write -f sys/replication/performance/primary/demote

read -n 1 -s -r -p "Press any key to continue"
echo ""

export VAULT_ADDR=${VAULT_ADDR_SEC}
vault login -method="userpass" username="replication-admin" password="P@ssword1"
vault write sys/replication/performance/secondary/promote primary_cluster_addr="${VAULT_CLUSTER_ADDR_SEC}"