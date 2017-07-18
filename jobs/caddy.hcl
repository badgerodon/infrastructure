job "caddy" {
  type = "service"

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
    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "frontend" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "hashicorp/web-frontend"
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
