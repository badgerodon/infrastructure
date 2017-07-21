job "caddy" {
  type = "service"

  datacenters = ["dc1"]

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "caddy" {
    count = 2
    task "caddy" {
      driver = "docker"
      config {
        image = "gcr.io/badgerodon-prod/caddy:1.0"
        network_mode = "host"
        auth {
          server_address = "https://gcr.io"
        }
      }
      template {
        data = <<EOT
*.badgerodon.com:{{ env "NOMAD_PORT_http" }} {
    log stdout
    proxy / badgerodon-www.service.consul:9000
}

*.doxsey.net:{{ env "NOMAD_PORT_http" }} {
    proxy / doxsey-www.service.consul:9001
}
        EOT
        destination = "/etc/Caddyfile"
      }
      service {
        port = "http"
      }
      resources {
        network {
          port "http" {
            static = 80
          }
        }
      }
    }
  }
}
