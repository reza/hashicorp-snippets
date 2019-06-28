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
