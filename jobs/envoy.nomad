job "envoy" {
  type = "system"

  datacenters = ["us-central1"]

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "envoy" {
    count = 2
    task "envoy" {
      driver = "docker"
      config {
        image = "lyft/envoy-alpine:latest"
        network_mode = "host"
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
