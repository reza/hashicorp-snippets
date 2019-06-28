tee /etc/consul.d/client.hcl <<EOF
services {
  name = "client"
  port = 8080
  connect {
    sidecar_service {
      proxy {
        upstreams {
          destination_name = "web"
          local_bind_port  = 8181
        }
      }
    }
  }
}
EOF

docker run --rm -d --network host --name client-proxy timarenz/consul-envoy:1.9.1 -sidecar-for client -- -l debug
#consul connect proxy -sidecar-for client -log-level debug