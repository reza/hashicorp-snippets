docker run -d -p 80:80 --name httpbin kennethreitz/httpbin

tee /etc/consul.d/web-service.json <<EOF
{
  "service": {
    "name": "web",
    "tags": [
      "httpbin"
    ],
    "port": 80,
    "check": {
      "args": [
        "curl",
        "localhost"
      ],
      "interval": "10s"
    },
    "connect": {
      "sidecar_service": {}
    }
  }
}
EOF

docker run --rm -d --network host --name web-proxy timarenz/consul-envoy:1.9.1 -sidecar-for web -- -l debug
#consul connect proxy -sidecar-for web -log-level debug