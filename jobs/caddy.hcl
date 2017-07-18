job "caddy" {
  type = "service"
  
  datacenters = ["us-central1"]

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "caddy" {
    count = 2
    task "caddy" {
      driver = "docker"
      config {
        image = "ecr.io/badgerodon-173120/caddy:1.0"
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
